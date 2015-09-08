//
//  WeatherViewController.h
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampmLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UILabel *hiTemp;
@property (weak, nonatomic) IBOutlet UILabel *loTemp;

@end
