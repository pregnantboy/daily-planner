//
//  EventDetailedView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 17/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventDetailedView.h"
#import "EventViewController.h"

@interface EventDetailedView () {
    EventViewController *_vc;
    EventObject *_event;
}
@end

@implementation EventDetailedView

- (id) initWithEventObject:(EventObject *)event andViewController:(UIViewController *) vc{
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventDetailedView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        if ([vc isKindOfClass:[EventViewController class]]) {
            _vc = (EventViewController *)vc;
        }
        if (event) {
            [self updateViewWithEventObject:event];
            _event = event;
        }
    }
    return self;
}

- (IBAction)editButton:(id)sender {
    [_vc createEditEventViewForSelectedEvent];
}

- (void) updateViewWithEventObject:(EventObject *)event{
    self.title.text = event.title;
    self.locationText.text = event.location;
    self.time.text = [NSString stringWithFormat:@"%@ to %@", [event startString], [event endString]];
    self.reminder.text = event.reminderString;
    self.notes.text = event.details;
}

#pragma mark - MapViewControllerDelegate

- (IBAction)suggestLocationButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *mvc = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [_vc presentViewController:mvc animated:YES completion:^void {
        mvc.delegate = self;
    }];
}

- (void)returnFromMapViewController:(MapViewController *)mvc withLocation:(NSString *)locationString {
    if (locationString) {
        [_event setLocation:locationString];
        [self updateViewWithEventObject:_event];
        [_vc updateEventWithEvent:_event];
    }
}

@end
