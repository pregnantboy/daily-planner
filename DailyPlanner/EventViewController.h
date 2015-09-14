//
//  EventViewController.h
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

@import UIKit;
#import "EventTableViewCell.h"
#import "EventManager.h"
#import "WeatherManager.h"

@interface EventViewController : UIViewController

// main clock
@property (strong, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampmLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


// settings button
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) UIAlertController *popupSettings;

// Events table view
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;

@end