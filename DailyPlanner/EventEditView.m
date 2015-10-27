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
    BOOL _hasChanged;
}
@end

@implementation EventEditView

int _datePickerForWhich;

- (id) initWithEventObject:(EventObject *)event withViewController:(UIViewController *)vc{
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventEditView" owner:self options:nil] objectAtIndex:0];
    if (self) {
        if ([vc isKindOfClass:[EventViewController class]]) {
            _vc = (EventViewController *)vc;
        }
        _event = [[GoogleEventObject alloc] initWithEvent:(GoogleEventObject *)event];
        
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
        _hasChanged = NO;
    }
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
    _hasChanged = YES;

    if (textView == self.details) {
        [_event setDetails:textView.text];
    }
}

- (void)textFieldDidChange:(UITextField *) textField {
    _hasChanged = YES;
    if (textField == self.title) {
        [_event setTitle:textField.text];
        NSLog(@"%@",textField.text);
    }
    if (textField == self.location) {
        [_event setLocation:textField.text];
    }
    if (textField == self.minutes) {
        if (![self isNumeric:textField.text]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Input!" message: @"Input is not an integer." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                self.minutes.text = @"";
            }];
            [alert addAction: okButton];
            [_vc presentViewController:alert animated:YES completion:nil];
        }
        [_event setMinutes:textField.text.integerValue];
    }
}

// Checks if String is Numeric
- (BOOL)isNumeric:(NSString *)input {
    for (int i = 0; i < [input length]; i++) {
        char c = [input characterAtIndex:i];
        if (!(c >= '0' && c <= '9')) {
            return NO;
        }
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
    self.startTime.text = [_event startString];
    self.endTime.text = [_event endString];
    self.minutes.text =  [_event minutesString];
    self.details.text = [_event details];
}

// Need to move scroll view up when keyboard whos but no need if demoing on simulator
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.startTime) {
        _hasChanged = YES;
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
        _hasChanged = YES;
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

- (BOOL)hasChanged {
    return _hasChanged;
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
        self.location.text = locationString;
        [_event setLocation:locationString];
    }
}

@end
