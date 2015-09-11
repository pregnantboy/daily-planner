//
//  WeatherViewController.m
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "WeatherViewController.h"

@interface WeatherViewController () {
    WeatherManager *_weatherManager;
    NSArray *_weatherForecast;
}

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up clock label
    [self updateClock];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    
    
    // Instantiate Weather Manager
    _weatherManager = [WeatherManager sharedManager];

}

- (void)viewDidAppear:(BOOL)animated {
    _weatherForecast = [_weatherManager prettyForecast];
    [self.weatherTable reloadData];
}

#pragma mark - Main Clock

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

#pragma mark - UITableView delegates

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeatherCell";
    
    WeatherTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
       cell = [[WeatherTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *hourlyWeatherData = [_weatherForecast objectAtIndex:indexPath.row];
    
    // Set hourly time
//    NSDate *timeToSet = [NSDate date];
//    NSTimeInterval secondsToAdd = (indexPath.row + 1) * 60 * 60;
//    timeToSet = [timeToSet dateByAddingTimeInterval:secondsToAdd];
//    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
//    [hourFormatter setDateFormat:@"h a"];
//    cell.hourLabel.text = [[hourFormatter stringFromDate:timeToSet] lowercaseString];
   
    cell.hourLabel.text = [NSString stringWithFormat:@"%d %@", [[hourlyWeatherData objectForKey:@"hour"] intValue], [[hourlyWeatherData objectForKey:@"ampm"] lowercaseString]];
    
    // Set weather icon
    WeatherObject *weather = (WeatherObject *)[hourlyWeatherData objectForKey:@"weather"];
    [cell.weatherIcon setImage:[weather imageIcon]];
    
    // Set temperature
    cell.tempLabel.text = [NSString stringWithFormat:@"%@%@", [hourlyWeatherData objectForKey:@"temp"] , @"\u00B0"];
    
    return cell;
}


@end
