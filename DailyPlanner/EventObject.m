//
//  EventObject.m
//  DailyPlanner
//
//  Created by Ian Chen on 22/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventObject.h"

@interface EventObject() {
    NSString *_title;
    NSDate *_startTime;
    NSDate *_endTime;
    NSString *_location;
    NSString *_details;
    NSInteger _minutes;
    GTLCalendarEvent * _gEvent;
    BOOL _isEvent;
}
@end

@implementation EventObject

- initWithTitle:(NSString *)title
      startTime:(NSDate *)startTime
        endTime:(NSDate *)endTime
       location:(NSString *)location
        details:(NSString *)details
reminderMinutes:(NSInteger)minutes{
    self = [super init];
    if (self) {
        _title = title;
        _startTime = startTime;
        _endTime = endTime;
        _location = location;
        _details = details;
        _minutes = minutes;
        _isEvent = YES;
    }
    return self;
}

- initWithNotLoggedIn {
    self = [super init];
    if (self) {
        _title = @"Not Logged In";
        _isEvent = NO;
    }
    return self;
}

- initWithLoading {
    self = [super init];
    if (self) {
        _title = @"Loading...";
        _isEvent = NO;
    }
    return self;
}

- (NSString *)title {
    return _title;
}

- (NSString *)startString {
    return [NSDateFormatter localizedStringFromDate:_startTime
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)endString {
    return [NSDateFormatter localizedStringFromDate:_endTime
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:NSDateFormatterShortStyle];
}


- (NSDate *)startTime{
    return _startTime;
}
- (NSDate *)endTime{
    return _endTime;
}

- (NSString *)location {
    if (_location) {
        return _location;
    } else {
        return @"Not Specified";
    }
}

- (void) setLocation:(NSString *)newLocation {
    _location = newLocation;
}

- (NSString *)details {
    if (_details) {
        return _details;
    } else {
        return @"";
    }
}

- (NSString *)reminderString {
    if (_minutes > 0) {
        return [NSString stringWithFormat:@"%ld minutes before", _minutes];
    } else {
        return @"Not set";
    }
}

- (NSInteger)minutes {
    return _minutes;
}

- (GTLCalendarEvent *)gEvent {
    return _gEvent;
}

- (BOOL)isEvent {
    return _isEvent;
}

# pragma mark - Setters
- (void)setlocation:(NSString *)location {
    _location = location;
}

@end
