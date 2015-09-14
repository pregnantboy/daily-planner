//
//  EventManager.m
//  DailyPlanner
//
//  Created by Ian Chen on 12/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventManager.h"

@interface EventManager() {
    UIViewController *_viewController;
    NSMutableArray *_events;
}
@end

static NSString *const kKeychainItemName = @"Google Calendar API";
static NSString *const kClientID = @"216231891570-usfj63n5edd0r30iv9hbjcnbq3ututo5.apps.googleusercontent.com";
static NSString *const kClientSecret = @"fbfkhRPW-5ZAPlRRRMdPaHi3";

// Public constant
NSString *const eventsReceivedNotification = @"eventsReceivedNotification";
 

BOOL loginPageDismissed;
#if DEBUG
static BOOL shouldShowLoginPageOnLoad = YES;
#else 
static BOOL shouldShowLoginPageOnLoad = NO;
#endif


@implementation EventManager

#pragma mark - Object Lifecycle
- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
        loginPageDismissed = NO;
        
        // initialize google calendar api service
        self.service = [[GTLServiceCalendar alloc] init];
        self.service.authorizer =
        [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:kClientID
                                                          clientSecret:kClientSecret];
    }
    return self;
}

#pragma mark - Google Calendar API

// Construct a query and get a list of upcoming events from the user calendar.
- (void)fetchEvents {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];

    
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"primary"];
    query.maxResults = 10;
    
    // For debugging purposes, set timeMin to 00:00 of today
    // For release build, the timeMin should be current time
    NSDate *now = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *startTime = [cal dateBySettingHour:0 minute:0 second:0 ofDate:now options:0];
    NSDate *endTime = [startTime dateByAddingTimeInterval:24*60*60];
    query.timeMin = [GTLDateTime dateTimeWithDate:startTime
                                         timeZone:[NSTimeZone localTimeZone]];
    query.timeMax = [GTLDateTime dateTimeWithDate:endTime
                                         timeZone:[NSTimeZone localTimeZone]];
    
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Display query results
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLCalendarEvents *)events
                          error:(NSError *)error {
    if (error == nil) {
        // ADD SPINNER TO STOP HERE
        _events = [[NSMutableArray alloc] init];
        NSMutableString *eventString = [[NSMutableString alloc] init];
        if (events.items.count > 0) {
            [eventString appendString:@"Upcoming 10 events:\n"];
            for (GTLCalendarEvent *event in events) {
                GTLDateTime *start = event.start.dateTime;
                GTLDateTime *end = event.end.dateTime;
                NSString *startString =
                [NSDateFormatter localizedStringFromDate:[start date]
                                               dateStyle:NSDateFormatterNoStyle
                                               timeStyle:NSDateFormatterShortStyle];
                NSString *endString =
                [NSDateFormatter localizedStringFromDate:[end date]
                                               dateStyle:NSDateFormatterNoStyle
                                               timeStyle:NSDateFormatterShortStyle];
                
                [eventString appendFormat:@"%@ - %@: %@\n", startString, endString, event.summary];
                NSString *location = @"Not Specified";
                if (event.location) {
                    location = event.location;
                }
                NSDictionary *aEvent = @{
                                         @"start":startString,
                                         @"end":endString,
                                         @"title":event.summary,
                                         @"location":location
                                         };
                [_events addObject:aEvent];
            }
        } else {
            [eventString appendString:@"No upcoming events found."];
            [_events addObject:@{@"start":@"",
                                     @"end":@"",
                                     @"title":@"No upcoming events for today.",
                                     @"location":@""
                                     }];
        }
        NSLog(@"%@", eventString);
        [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];
    } else if (!loginPageDismissed && shouldShowLoginPageOnLoad) {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}


# pragma mark - Google Auth

// Creates the auth controller for authorizing access to Google Calendar API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    
    // Instantiate AuthController
    GTMOAuth2ViewControllerTouch *authController;
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeCalendarReadonly, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:kClientSecret
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    // Back button to cancel sign in
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton addTarget:self
                   action:@selector(dismissLoginPage)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@" Back" forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"backButton.png"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 25, 60, 20);
    [authController.view addSubview:backButton];
    
    return authController;
}

// Handle completion of the authorization process, and update the Google Calendar API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (loginPageDismissed) {
        self.service.authorizer = nil;
    }
    else if (error) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [_viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

// Public methods

- (void)viewDidAppear {
    if (!self.service.authorizer.canAuthorize && !loginPageDismissed && shouldShowLoginPageOnLoad) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self postLoggedOutNotification];
        [self loginGoogle];
    } else {
        if (loginPageDismissed) {
            [self postLoggedOutNotification];
        } else {
            [self postLoadingNotification];
            [self fetchEvents];
        }
    }
}

- (void)dismissLoginPage {
    [_viewController dismissViewControllerAnimated:YES completion:nil];
    loginPageDismissed = YES;
}

- (void)loginGoogle {
    loginPageDismissed = NO;
    [_viewController presentViewController:[self createAuthController] animated:YES completion:nil];
}

- (void)logoutGoogle {
    NSLog(@"logging out");
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    [self postLoggedOutNotification];
}

- (BOOL)isLoggedIn {
    return self.service.authorizer.canAuthorize;
}

- (NSArray *)events {
    return _events;
}

// Private helper methods
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}

- (void)postLoggedOutNotification {
    _events = [[NSMutableArray alloc] initWithObjects:@{@"start":@"",
                                                        @"end":@"",
                                                        @"title":@"Not Logged In.",
                                                        @"location":@""
                                                        }, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];

}

- (void)postLoadingNotification {
    _events = [[NSMutableArray alloc] initWithObjects:@{@"start":@"",
                                                        @"end":@"",
                                                        @"title":@"Loading.",
                                                        @"location":@""
                                                        }, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];
}

@end
