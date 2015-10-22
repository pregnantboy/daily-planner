//
//  GoogleEventObject.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 21/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "GoogleEventObject.h"

@interface GoogleEventObject() {
    GTLCalendarEvent *_gEvent;
}
@end

@implementation GoogleEventObject

- initWithGoogleEvent:(GTLCalendarEvent *)gEvent{
    int minutesReminder;
    if (gEvent.reminders.useDefault.intValue == 1) {
        minutesReminder = 30;
    } else if (gEvent.reminders.useDefault.intValue== 0) {
        NSLog(@"%@", gEvent.reminders.overrides);
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
    return self;
}

- (GTLCalendarEvent *) gEvent {
    return _gEvent;
}

@end
