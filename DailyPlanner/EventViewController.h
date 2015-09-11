//
//  EventViewController.h
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"
#import "WeatherObject.h"
#import "EventTableViewCell.h"

@interface EventViewController : UIViewController

// main clock
@property (strong, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampmLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

// google calendar api
@property (nonatomic, strong) GTLServiceCalendar *service;

// settings button
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) UIAlertController *popupSettings;

// Events table view
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;


@end
