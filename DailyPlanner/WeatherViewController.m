//
//  WeatherViewController.m
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "WeatherViewController.h"

@interface WeatherViewController ()

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up clock label
    [self updateClock];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
}

- (void)updateClock {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *ampmFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm"];
    [ampmFormatter setDateFormat:@"a"];
    [dateFormatter setDateFormat: @"d MMM YY EEEE"];
    NSDate *currentDate = [NSDate date];
    self.clockLabel.text =[formatter stringFromDate:currentDate];
    self.ampmLabel.text = [ampmFormatter stringFromDate:currentDate];
    self.dateLabel.text = [dateFormatter stringFromDate:currentDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
