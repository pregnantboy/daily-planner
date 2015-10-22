//
//  EventManager.h
//  DailyPlanner
//
//  Created by Ian Chen on 12/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//
@import UIKit;
@import Foundation;
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"
#import "EventObject.h"
#import "GoogleEventObject.h"

extern NSString *const eventsReceivedNotification;

@interface EventManager : NSObject
// google calendar api
@property (nonatomic, strong) GTLServiceCalendar *service;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)viewDidAppear;
- (void)dismissLoginPage;
- (void)loginGoogle;
- (void)logoutGoogle;
- (BOOL)isLoggedIn;
- (NSDate *)lastUpdated;
- (NSArray *)events;
- (void)refreshEvents;

# pragma mark - CRUD operations

- (void) createEvent:(EventObject *)event;
- (void) updateEventWithObject:(EventObject *)newEvent index:(NSInteger) idx;
- (void) deleteEvent:(NSInteger) idx;
@end
