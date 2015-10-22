//
//  EventDetailedView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 17/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventDetailedView.h"

@implementation EventDetailedView

- (IBAction)editButton:(id)sender {
    NSLog(@"edit");
}

- (IBAction)clickSuggestLocation:(id)sender {
}

- (id) initWithEventObject:(EventObject *)event{
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventDetailedView" owner:self options:nil] objectAtIndex:0];
    if (event) {
        [self updateViewWithEventObject:event];
    }
    return self;
}

- (void) updateViewWithEventObject:(EventObject *)event{
    self.title.text = event.title;
    self.locationText.text = event.location;
    self.time.text = [NSString stringWithFormat:@"%@ to %@", [event startString], [event endString]];
    self.reminder.text = event.reminderString;
    self.notes.text = event.details;
}
@end
