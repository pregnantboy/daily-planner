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
    NSDate *_lastUpdated;
    NSString *_eventsPath;
    NSUserDefaults *_defaults;
}
@end

static NSString *const kKeychainItemName = @"Google Calendar API";
static NSString *const kClientID = @"216231891570-usfj63n5edd0r30iv9hbjcnbq3ututo5.apps.googleusercontent.com";
static NSString *const kClientSecret = @"fbfkhRPW-5ZAPlRRRMdPaHi3";
static NSString *const EventsLastUpdatedUserDefaults = @"eventsLastUpdatedUserDefaults";

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
        _defaults = [NSUserDefaults standardUserDefaults];
        if ([_defaults objectForKey:EventsLastUpdatedUserDefaults]) {
            _lastUpdated = [_defaults objectForKey:EventsLastUpdatedUserDefaults];
        }
        
        // initialize google calendar api service
        self.service = [[GTLServiceCalendar alloc] init];
        self.service.authorizer =
        [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:kClientID
                                                          clientSecret:kClientSecret];
        
        // Instantiate Events Path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            _eventsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"events.out"];
            NSLog(@"%@", _eventsPath);
        }
    }
    return self;
}

#pragma mark - Google Calendar API

// Construct a query and get a list of upcoming events from the user calendar.
- (void)fetchEvents {
    
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
        // TODO: ADD SPINNER TO STOP HERE
        _events = [[NSMutableArray alloc] init];
        if (events.items.count > 0) {
            for (GTLCalendarEvent *event in events) {
                GoogleEventObject *aEvent = [[GoogleEventObject alloc] initWithGoogleEvent:event];
                [_events addObject:aEvent];
            }
        } else {
            NSLog(@"No upcoming events found.");
            [_events addObject:[[EventObject alloc] initWithNoUpcomingEvents]];
        }
        _lastUpdated = [NSDate date];
        [_defaults setObject:_lastUpdated forKey:EventsLastUpdatedUserDefaults];
        
        // write to file
        BOOL success = [NSKeyedArchiver archiveRootObject:_events toFile:_eventsPath];
        NSLog(@"events archive success: %d", success);
        
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
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeCalendar, nil];
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
    if (![self isLoggedIn] && !loginPageDismissed && shouldShowLoginPageOnLoad) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self postLoggedOutNotification];
        [self loginGoogle];
    } else {
        if (loginPageDismissed) {
            [self postLoggedOutNotification];
        } else {
            if ([self loadOldData]) {
                if ([self isOutdated]) {
                    [self fetchEvents];
                }
            } else {
                [self fetchEvents];
            }
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
    self.service.authorizer= NULL;
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    
    [[NSFileManager defaultManager] removeItemAtPath:_eventsPath error:NULL];
    
    [self postLoggedOutNotification];
}

- (BOOL)isLoggedIn {
    return self.service.authorizer.canAuthorize;
}

- (void)refreshEvents {
    [self fetchEvents];
}

- (NSArray *)events {
    return _events;
}

- (NSDate *)lastUpdated {
    return _lastUpdated;
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
    EventObject *notLoggedInEvent = [[EventObject alloc ] initWithNotLoggedIn];
    _events = [[NSMutableArray alloc] initWithObjects:notLoggedInEvent, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];

}

- (BOOL)loadOldData {
    NSLog(@"loadOldData called");
    BOOL eventsExists = [[NSFileManager defaultManager] fileExistsAtPath:_eventsPath];
    NSLog(@"%d ee", eventsExists);
    if (eventsExists) {
        NSLog(@"Events file exists!");
        _events = [[NSKeyedUnarchiver unarchiveObjectWithFile:_eventsPath] mutableCopy];
    } else {
        EventObject *loadingEvents = [[EventObject alloc ] initWithLoading];
        _events = [[NSMutableArray alloc] initWithObjects:loadingEvents, nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:eventsReceivedNotification object:nil];
    return eventsExists;
}

- (BOOL)isOutdated {
    NSDate *now = [NSDate date];
    if (_lastUpdated) {
        if ([now timeIntervalSinceDate:_lastUpdated] > (60 * 60)) {
            NSLog(@"outdated");
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}
# pragma mark - CRUD operations


- (void)addEventWithObject:(EventObject *)event {
    if (!event.title || [event.title isEqualToString:@""]) {
        [self showAlert:@"Ooops!" message:@"Event title cannot be null."];
        return;
    }
    if ([event isKindOfClass:[GoogleEventObject class]]) {
        GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsInsertWithObject:[(GoogleEventObject *)event gEvent] calendarId:@"primary"];
        [self.service executeQuery:query
                          delegate:self
                 didFinishSelector:@selector(addEventWithTicket:finishedWithEvent:error:)];
    } else {
        [self showAlert:@"Not a Google Calendar event." message:nil];
    }
}

- (void)addEventWithTicket:(GTLServiceTicket *)ticket finishedWithEvent:(GTLCalendarEvent *)event error:(NSError *) error {
    if (error) {
        [self showAlert:@"Add Event Error" message:error.localizedDescription];
    } else {
        [self showAlert:[NSString stringWithFormat:@"%@ successfully added.",event.summary] message:nil];
        [self refreshEvents];
    }
}

- (void)updateEventWithEvent:(EventObject *)event{
    if (!event.title || [event.title isEqualToString:@""]) {
        [self showAlert:@"Ooops!" message:@"Event title cannot be null."];
        return;
    }
    if ([event isKindOfClass:[GoogleEventObject class]]) {
        GTLCalendarEvent *gEvent = [(GoogleEventObject *)event gEvent];
        GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsUpdateWithObject:gEvent calendarId:@"primary" eventId:gEvent.identifier];
        [self.service executeQuery:query
                          delegate:self
                 didFinishSelector:@selector(updateEventWithTicket:finishedWithEvent:error:)];
    } else {
        [self showAlert:@"Not a Google Calendar event." message:nil];
    }
}

- (void)updateEventWithTicket:(GTLServiceTicket *)ticket finishedWithEvent:(GTLCalendarEvent *)event error:(NSError *) error {
    if (error) {
        [self showAlert:@"Update Event Error" message:error.localizedDescription];
    } else {
        [self showAlert:[NSString stringWithFormat:@"%@ successfully updated.",event.summary] message:nil];
        [self refreshEvents];
    }
}

- (void)deleteEvent:(GTLCalendarEvent *)event{
    if ([event isKindOfClass:[GoogleEventObject class]]){
        GTLCalendarEvent *gEvent = [(GoogleEventObject *)event gEvent];
         GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsDeleteWithCalendarId:@"primary" eventId:[gEvent identifier]];
        [self.service executeQuery:query
                          delegate:self
                 didFinishSelector:@selector(deleteEventWithTicket:finishedWithEvent:error:)];
    }
}

- (void)deleteEventWithTicket:(GTLServiceTicket *)ticket finishedWithEvent:(id)nilObject error:(NSError *) error {
    if (error) {
        [self showAlert:@"Delete Event Error" message:error.localizedDescription];
    } else {
        [self showAlert:[NSString stringWithFormat:@"Event successfully deleted."] message:nil];
        [self refreshEvents];
    }
}

@end
