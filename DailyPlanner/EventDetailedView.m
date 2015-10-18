//
//  EventDetailedView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 17/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventDetailedView.h"

@implementation EventDetailedView

- (IBAction)clickSuggestLocation:(id)sender {
}

- (id) init{
    self = [super init];
//    [[NSBundle mainBundle] loadNibNamed:@"EventDetailedView" owner:self options:nil];
//    [self addSubview:self.view];
    return self;
}

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [[NSBundle mainBundle] loadNibNamed:@"EventDetailedView" owner:self options:nil];
    [self addSubview:self.view];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EventDetailedView" owner:self options:nil];
        [self addSubview:self.view];
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
