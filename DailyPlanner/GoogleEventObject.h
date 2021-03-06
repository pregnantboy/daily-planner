//
//  GoogleEventObject.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 21/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventObject.h"

@interface GoogleEventObject : EventObject <NSCoding>

- (id) initWithGoogleEvent:(GTLCalendarEvent *)gEvent;
- (id)initWithEvent:(GoogleEventObject *)event;
- (void)updateGoogleCalendarEvent;
- (id) initWithNewEvent;
- (GTLCalendarEvent *) gEvent;
@end
