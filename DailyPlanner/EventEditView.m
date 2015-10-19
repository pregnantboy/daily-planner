//
//  EventEditView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 18/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventEditView.h"

@implementation EventEditView
- (id) initWithEventObject:(EventObject *)event {
    if (event) {
        [self updateViewWithEventObject:event];
    }
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil] objectAtIndex:0];
    return self;
}

- (void) updateViewWithEventObject:(EventObject *)event {
    self.location.text = [event location];
    self.startTime.date = [event startTime];
    self.endTime.date = [event endTime];
    self.details.text = [event details];
}
@end
