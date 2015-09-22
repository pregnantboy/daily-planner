//
//  EventViewController.m
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

/* 
  Google Calendar Account to use
  Username: dailyplannerproject@gmail.com
  Password: dailyplan
*/


#import "EventViewController.h"

@interface EventViewController() {
    NSArray *_events;
    EventManager *_eventManager;
    WeatherManager *_weatherManager;
}

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateClock];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateClock) userInfo:nil repeats:YES];
    
    // Instantiate managers
    _eventManager = [[EventManager alloc] initWithViewController:self];
    
    
    // Notification Center Observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newEventsData) name:eventsReceivedNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [_eventManager viewDidAppear];
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

#pragma mark - Refresh button
- (IBAction)refreshButton:(id)sender {
    [_eventManager refreshEvents];
}

#pragma mark - NSNotification handler
- (void)newEventsData {
    NSDateFormatter *lastUpdatedFormatter = [[NSDateFormatter alloc] init];
    [lastUpdatedFormatter setDateFormat:@"d MMM, hh:mm a"];
    NSString *dateString = [lastUpdatedFormatter stringFromDate:[_eventManager lastUpdated]];
    if (dateString) {
        self.lastUpdated.text = [@"Last updated: " stringByAppendingString:dateString];
    }
    _events = [_eventManager events];
    [self.eventsTableView reloadData];
}

#pragma mark - UITableView delegates

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (_events) {
        return [_events count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[EventTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    EventObject *event = (EventObject *)[_events objectAtIndex:indexPath.row];
    
    // Set event title
    cell.eventTitle.text = [event title];
    
    if ([event isEvent]) {
        // Set event location
        cell.location.text = [event location];
        
        // Set event start time and end time
        cell.startEndTime.text = [NSString stringWithFormat:@"%@ - %@", [event startString], [event endString]];
        
        // Set weather icon
        WeatherObject *weather = [[WeatherObject alloc] initWithWeatherType:rand()%8];
        [cell.weatherIcon setImage:[weather imageIcon]];
    } else {
        cell.location.text = @"";
        cell.startEndTime.text = @"";
        [cell.weatherIcon setImage:nil];
    }
    
    return cell;
}

# pragma mark - Settings

- (IBAction)settingsButton:(id)sender {
    self.popupSettings = [UIAlertController alertControllerWithTitle:@"Google Account Settings" message: nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    UIAlertAction *logoutButton = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [_eventManager logoutGoogle];
    }];
    UIAlertAction *loginButton = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [_eventManager loginGoogle];
    }];
    UIAlertAction *switchAccountButton = [UIAlertAction actionWithTitle:@"Switch Account" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    if ([_eventManager isLoggedIn]) {
        [self.popupSettings addAction:switchAccountButton];
        [self.popupSettings addAction:logoutButton];
    } else {
        [self.popupSettings addAction:loginButton];
    }
    [self.popupSettings addAction:defaultButton];
    
    [self presentViewController:self.popupSettings animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
