//
//  GoogleEventObject.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 21/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//
// Sample code: https://github.com/google/google-api-objectivec-client/blob/master/Examples/CalendarSample/CalendarSampleWindowController.m
//

#import "GoogleEventObject.h"

@interface GoogleEventObject() {
    GTLCalendarEvent *_gEvent;
}
@end

@implementation GoogleEventObject

- (id)initWithGoogleEvent:(GTLCalendarEvent *)gEvent{
    self = [super init];
    if (self) {
        int minutesReminder;
        if (gEvent.reminders.useDefault.intValue == 1) {
            minutesReminder = -1;
        } else if (gEvent.reminders.useDefault.intValue== 0) {
            if ([gEvent.reminders.overrides count] > 0) {
                minutesReminder = [[[gEvent.reminders.overrides objectAtIndex:0] valueForKey:@"minutes"] intValue];
            }
        }
        self = [super initWithTitle:gEvent.summary
                          startTime:[gEvent.start.dateTime date]
                            endTime:[gEvent.end.dateTime date]
                           location:gEvent.location
                            details:gEvent.descriptionProperty
                    reminderMinutes:minutesReminder];
        _gEvent = gEvent;
    }
    return self;
}

- (id)initWithEvent:(GoogleEventObject *)event {
    self = [super initWithEvent:event];
    if (self) {
        _gEvent = [event gEvent];
    }
    return self;
}

- (id) initWithNewEvent {
    self = [super init];
    if (self) {
        _gEvent = [GTLCalendarEvent object];
        self = [super initWithTitle:@""
                          startTime:[GoogleEventObject dateWithZeroSeconds:[NSDate date]]
                            endTime:[GoogleEventObject dateWithZeroSeconds:[NSDate dateWithTimeIntervalSinceNow:60*60]]
                           location:@""
                            details:nil
                    reminderMinutes:-1];
    }
    return self;
}

+ (NSDate *)dateWithZeroSeconds:(NSDate *)date {
    NSTimeInterval time = floor([date timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return  [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}

- (void)updateGoogleCalendarEvent {
    _gEvent.summary = self.title;
    _gEvent.descriptionProperty = self.details;
    _gEvent.start = [GTLCalendarEventDateTime object];
    _gEvent.end = [GTLCalendarEventDateTime object];
    _gEvent.start.dateTime = [GTLDateTime dateTimeWithDate:self.startTime timeZone:[NSTimeZone systemTimeZone]];
    _gEvent.end.dateTime = [GTLDateTime dateTimeWithDate:self.endTime timeZone:[NSTimeZone systemTimeZone]];
    if (self.minutes >= 0) {
        GTLCalendarEventReminder *reminder = [GTLCalendarEventReminder object];
        reminder.minutes = [NSNumber numberWithInteger:self.minutes];
        reminder.method = @"email"; // can be email or popup
        _gEvent.reminders = [GTLCalendarEventReminders object];
        _gEvent.reminders.overrides = [NSArray arrayWithObject:reminder];
        _gEvent.reminders.useDefault = [NSNumber numberWithBool:NO];
    }
    _gEvent.location = self.location;
}

- (GTLCalendarEvent *) gEvent {
    [self updateGoogleCalendarEvent];
    return _gEvent;
}

#pragma mark - NSCoding Protocol
- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_gEvent forKey:@"gEvent"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        _gEvent = [decoder decodeObjectForKey:@"gEvent"];
    }
    return self;
}

@end
