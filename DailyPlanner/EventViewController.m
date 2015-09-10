//
//  EventViewController.m
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventViewController.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateClock];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
}

- (void)updateClock {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *ampmFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    [ampmFormatter setDateFormat:@"a"];
    [dateFormatter setDateFormat: @"d MMM YY | EEEE"];
    NSDate *currentDate = [NSDate date];
    self.clockLabel.text =[formatter stringFromDate:currentDate];
    self.ampmLabel.text = [ampmFormatter stringFromDate:currentDate];
    self.dateLabel.text = [dateFormatter stringFromDate:currentDate];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
