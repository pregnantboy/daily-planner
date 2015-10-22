//
//  EventEditView.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 18/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EventObject.h"

@interface EventEditView : UIView
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UITextView *details;
@property (weak, nonatomic) IBOutlet UIDatePicker *startTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTime;
@property (strong, nonatomic) IBOutlet UILabel *reminder;

- (id) initWithEventObject:(EventObject *)event;
- (IBAction)changedReminderValue:(UISlider *)sender;

@end
