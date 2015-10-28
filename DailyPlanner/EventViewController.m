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
#import "EventDetailedView.h"
#import "EventEditView.h"
#import "MapViewController.h"

@interface EventViewController() {
    NSArray *_events;
    EventManager *_eventManager;
    UIView *_closePopUpButton;
    NSInteger _selectedRowIndex;
    EventEditView *_currentEventEditView;
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
    
    // Close pop up button
    _closePopUpButton = [[UIView alloc] initWithFrame:self.view.frame];
    _closePopUpButton.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.2];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector (closePopUpViews)];
    [_closePopUpButton addGestureRecognizer:singleTap];
    [self.view insertSubview:_closePopUpButton belowSubview:self.popupView];
    [_closePopUpButton addSubview:self.saveButton];
    
    // Close all pop ups on load
    [self forceClosePopUpViews];
}

- (void)viewDidAppear:(BOOL)animated {
    [_eventManager viewDidAppear];
    [WeatherManager sharedManager];
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
    cell.eventTitle.text = event.title;
    
    if ([event isEvent]) {
        // Set event location
        cell.location.text = [event location];
        
        // Set event start time and end time
        cell.startEndTime.text = [NSString stringWithFormat:@"%@ - %@", [event startString], [event endString]];
        
        // Set weather icon (TODO or not to do)
        [cell.weatherIcon setImage:NULL];
//        WeatherObject *weather = [[WeatherObject alloc] initWithWeatherType:rand()%8];
//        [cell.weatherIcon setImage:[weather imageIcon]];
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
    if (indexPath.row < [_events count]) {
        EventObject *event = (EventObject *)[_events objectAtIndex:indexPath.row];
        if ([event isEvent]){
            [self createDetailedEventView:event];
            _selectedRowIndex = indexPath.row;
        }
    }
}

# pragma mark - PopupView
- (void) showPopupWithView:(UIView *)view {
    _currentEventEditView = NULL;
    [self resetPopup];
    _closePopUpButton.hidden = NO;
    self.popupView.hidden = NO;
    if ([view isKindOfClass:[EventEditView class]]) {
        self.saveButton.hidden = NO;
        _currentEventEditView = (EventEditView *)view;
    } else if ([view isKindOfClass:[EventDetailedView class]] ) {
        [self.addNewButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    }
    [self.popupView addSubview:view];
     view.frame = self.popupView.bounds;
    [UIView animateWithDuration:0.5 animations:^{
        self.popupView.alpha = 0.95;
        _closePopUpButton.alpha = 1.0;
    }];
}

- (void)printConstraints:(CGRect) rect {
    NSLog(@"%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void) resetPopup {
    for(UIView *subview in [self.popupView subviews]) {
        [subview removeFromSuperview];
    }
}


- (void) createDetailedEventView:(EventObject *)event {
    EventDetailedView *view = [[EventDetailedView alloc] initWithEventObject:event andViewController:self];
    [self showPopupWithView:view];
}
- (void) createEditEventView:(EventObject *)event{
    EventEditView *view = [[EventEditView alloc] initWithEventObject:event withViewController:self];
    [self showPopupWithView:view];
}
- (void) createAddEventView{
    // For now, only create google event object
    GoogleEventObject *newEvent = [[GoogleEventObject alloc] initWithNewEvent];
    [self createEditEventView:newEvent];
    
}

#pragma mark - Add new event button

- (IBAction)clickAddEventButton:(id)sender {
    [self createAddEventView];
}

#pragma  mark - Private helpers


- (void)closePopUpViews {
    [self.view endEditing:YES];
    if (_currentEventEditView != NULL) {
        if ([_currentEventEditView hasChanged]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message: @"Discard all changes?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                [self forceClosePopUpViews];
            }];
            UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            [self presentViewController:alert animated:YES completion:nil];

        } else {
            [self forceClosePopUpViews];
        }
    } else {
        [self forceClosePopUpViews];
    }
}

- (void)forceClosePopUpViews {
    [self.view endEditing:YES];
    _selectedRowIndex = -1;
    [self.addNewButton setImage:[UIImage imageNamed:@"add-icon.png"] forState:UIControlStateNormal];
    self.popupView.hidden = YES;
    self.popupView.alpha = 0.0;
    _saveButton.hidden = YES;
    _closePopUpButton.hidden = YES;
    _closePopUpButton.alpha = 0.0;
    _currentEventEditView = NULL;
}

# pragma mark - edit/add event
- (IBAction)clickAddEvent:(id)sender {
    [self createAddEventView];
}

- (IBAction)saveEvent:(id)sender {
    // do something im giving up on you
    EventObject *currEvent = [_currentEventEditView eventObject];
    // VERY weak check but meh~
    if (_selectedRowIndex <0) {
        [_eventManager addEventWithObject:currEvent];
    } else if (_selectedRowIndex < [_events count]){
        [_eventManager updateEventWithEvent:currEvent];
    } 
    [self forceClosePopUpViews];
}

#pragma mark - public API
- (void)createEditEventViewForSelectedEvent {
    [self createEditEventView:[_events objectAtIndex:_selectedRowIndex]];
}

- (void)deleteEventforSelectedEvent {
    // VERY weak check but meh~
    if (_selectedRowIndex >=0 && _selectedRowIndex < [_events count] ) {
        [_eventManager deleteEvent:[_events objectAtIndex:_selectedRowIndex]];
    }
    [self forceClosePopUpViews];
}

- (void)updateEventWithEvent:(EventObject *)event {
    if (_selectedRowIndex < [_events count] && _selectedRowIndex >= 0){
        [_eventManager updateEventWithEvent:event];
    }
}

@end
