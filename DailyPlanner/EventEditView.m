//
//  EventEditView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 18/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventEditView.h"

@implementation EventEditView

int _datePickerForWhich;
EventObject *_event;

- (id) initWithEventObject:(EventObject *)event {
    _event = event;
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil] objectAtIndex:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self addGestureRecognizer:tap];
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_event) {
        [self updateView];
    }
    [self hideDatePickerView];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.details) {
        [_event setDetails:textView.text];
    }
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField == self.title) {
        [_event setTitle:self.title.text];
    }
    if (textField == self.location) {
        [_event setLocation:self.location.text];
    }
    if (textField == self.minutes) {
        [_event setMinutes:self.minutes.text.integerValue];
        NSLog(@"textField %f,", textField.frame.origin.y);
    }
    return YES;
}

- (void)dismissKeyboard {
    [self endEditing:YES];
}

- (void) updateView{
    NSLog(@"in update view %@", [_event title]);
    self.title.text = [_event title];
    self.location.text = [_event location];
    self.startTime.text = [_event startStringWithDate];
    self.endTime.text = [_event endStringWithDate];
    self.minutes.text =  [_event minutesString];
    self.details.text = [_event details];
}

// Need to move scroll view up when keyboard whos but no need if demoing on simulator
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.startTime) {
        _datePickerForWhich = 1;
        [self showDatePickerView];
        return NO;
    }
    if (textField == self.endTime) {
        _datePickerForWhich = 2;
        [self showDatePickerView];
        return NO;
    }
    return YES;
}
- (void)showDatePickerView {
    self.datePickerView.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.datePickerView.alpha = 1.0;
    }];
}

- (void)hideDatePickerView {
    self.datePickerView.alpha = 0.0;
    self.datePickerView.hidden = YES;
}

// Need to do startdate before enddate checking somewhere but im too lazy
- (IBAction)dateSetButton:(id)sender {
    if (_datePickerForWhich ==1) {
        [_event setStartTime:self.datePicker.date];
    } else if (_datePickerForWhich == 2) {
        [_event setEndDate:self.datePicker.date];
    }
    _datePickerForWhich = 0;
    [self updateView];
    [self hideDatePickerView];
}

- (EventObject *)eventObject {
    return _event;
}

@end
