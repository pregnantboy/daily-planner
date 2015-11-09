//
//  EventManagerInterface.h
//  DailyPlanner
//
//  Created by Ian Chen on 9/11/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>
#import "EventObject.h"

@interface EventManagerInterface : NSObject

- (id)initWithViewController:(UIViewController *)viewController;
- (BOOL)isLoggedIn;
- (void)refreshEvents;
- (NSDate *)lastUpdated;
- (void)viewDidAppear;
- (void)dismissLoginPage;
- (NSArray *)events;
- (void)loginCalendar;
- (void)logoutCalendar;
- (void)addEventWithObject:(EventObject *)event;
- (void)updateEventWithEvent:(EventObject *)event;
- (void)deleteEvent:(EventObject *)event;

@end
