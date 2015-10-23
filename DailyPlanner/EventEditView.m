//
//  EventEditView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 18/10/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventEditView.h"
#import "EventViewController.h"
@interface EventEditView () {
    EventViewController *_vc;
    EventObject *_event;
}
@end

@implementation EventEditView

int _datePickerForWhich;

- (id) initWithEventObject:(EventObject *)event withViewController:(UIViewController *)vc{
    _event = event;
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil] objectAtIndex:0];
    if ([vc isKindOfClass:[EventViewController class]]) {
        _vc = (EventViewController *)vc;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self addGestureRecognizer:tap];
    [self.title addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.location addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [self.minutes addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
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

- (void)textFieldDidChange:(UITextField *) textField {
    if (textField == self.title) {
        [_event setTitle:textField.text];
        NSLog(@"%@",textField.text);
    }
    if (textField == self.location) {
        [_event setLocation:textField.text];
    }
    if (textField == self.minutes) {
        [_event setMinutes:textField.text.integerValue];
    }
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
        self.datePicker.minimumDate = [NSDate date];
        if ([_event startTime]){
            [self.datePicker setDate:[_event startTime] animated:NO];
        } else {
            [self.datePicker setDate:[NSDate date] animated:NO];        }
        
        [self showDatePickerView];
        return NO;
    }
    if (textField == self.endTime) {
        _datePickerForWhich = 2;
        if ([_event startTime]){
            self.datePicker.minimumDate = [_event startTime];
        }
        if ([_event endTime]){
            [self.datePicker setDate:[_event endTime] animated:NO];
        } else {
            [self.datePicker setDate:[[NSDate date] dateByAddingTimeInterval:3600] animated:NO];
        }
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
    if (_datePickerForWhich == 1) {
        [_event setStartTime:self.datePicker.date];
    } else if (_datePickerForWhich == 2) {
        [_event setEndTime:self.datePicker.date];
    }
    _datePickerForWhich = 0;
    [self updateView];
    [self hideDatePickerView];
}

- (IBAction)deleteButton:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message: @"Confirm deletion?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [_vc deleteEventforSelectedEvent];
    }];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [_vc presentViewController:alert animated:YES completion:nil];
}

- (EventObject *)eventObject {
    return _event;
}

@end
