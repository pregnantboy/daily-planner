//
//  WeatherViewController.h
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "WeatherTableViewCell.h"
#include "WeatherManager.h"

@interface WeatherViewController : UIViewController

// main clock
@property (strong, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampmLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdated;

// current weather objects
@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UILabel *hiTemp;
@property (weak, nonatomic) IBOutlet UILabel *loTemp;
@property (weak, nonatomic) IBOutlet UIImageView *currWeatherIcon;

// weather forecast
@property (weak, nonatomic) IBOutlet UITableView *weatherTable;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;

@end
