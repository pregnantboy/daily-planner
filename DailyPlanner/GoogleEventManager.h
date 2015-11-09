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
#import "GoogleEventObject.h"
#import "EventManagerInterface.h"

extern NSString *const eventsReceivedNotification;

@interface GoogleEventManager : EventManagerInterface
// google calendar api
@property (nonatomic, strong) GTLServiceCalendar *service;

- (id)initWithViewController:(UIViewController *)viewController;
- (void)viewDidAppear;
- (void)dismissLoginPage;
- (void)loginCalendar;
- (void)logoutCalendar;
- (BOOL)isLoggedIn;
- (NSDate *)lastUpdated;
- (NSArray *)events;
- (void)refreshEvents;

# pragma mark - CRUD operations

- (void)addEventWithObject:(EventObject *)event;
- (void)updateEventWithEvent:(EventObject *)event;
- (void)deleteEvent:(EventObject *)event;

@end
