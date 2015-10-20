//
//  EventObject.h
//  DailyPlanner
//
//  Created by Ian Chen on 22/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLCalendar.h"

@interface EventObject : NSObject

- initWithTitle:(NSString *)title
      startTime:(NSDate *)startTime
        endTime:(NSDate *)endTime
       location:(NSString *)location
        details:(NSString *)details
reminderMinutes:(NSInteger)minutes;
- initWithNotLoggedIn;
- initWithLoading;

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
- (GTLCalendarEvent *) gEvent;
- (BOOL)isEvent;

@end
