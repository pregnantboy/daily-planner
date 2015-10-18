//
//  EventEditView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 18/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventEditView.h"

@implementation EventEditView
- (id) init{
    self = [super init];
    [[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil];
    [self addSubview:self.view];
    return self;
}

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil];
    [self addSubview:self.view];
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void) updateViewWithEventObject:(EventObject *)event {
    self.location.text = [event location];
    self.startTime.date = [event startTime];
    self.endTime.date = [event endTime];
    self.details.text = [event details];
}
@end
