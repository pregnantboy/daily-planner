//
//  EventObject.h
//  DailyPlanner
//
//  Created by Ian Chen on 22/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLCalendar.h"

@interface EventObject : NSObject <NSCoding>

- (id)initWithTitle:(NSString *)title
      startTime:(NSDate *)startTime
        endTime:(NSDate *)endTime
       location:(NSString *)location
        details:(NSString *)details
reminderMinutes:(NSInteger)minutes;
- (id)initWithNotLoggedIn;
- (id)initWithLoading;
- (id)initWithNoUpcomingEvents;
- (id)initWithEvent: (EventObject *)event;

- (NSString *)title;
- (NSString *)startString;
- (NSString *)endString;
- (NSDate *)startTime;
- (NSDate *) endTime;
- (NSString *) location;
- (void) setLocation:(NSString *)location;
- (NSString *)details;
- (NSString *)reminderString;
- (NSInteger)minutes;
- (NSString *)minutesString;
- (BOOL)isEvent;
- (NSString *)startStringWithDate;
- (NSString *)endStringWithDate;
- (void)setStartTime:(NSDate *)date;
- (void)setEndTime:(NSDate *)date;
- (void)setTitle:(NSString *)title;
- (void)setMinutes:(NSInteger)minutes;
- (void)setDetails:(NSString *)details;

@end
