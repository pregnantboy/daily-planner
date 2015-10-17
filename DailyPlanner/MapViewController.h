//
//  MapViewController.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 19/9/15.
//  Copyright © 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
@import GoogleMaps;

@interface MapViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsView;
@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (strong) NSMutableArray* searchAutocompleteResults;
@property (strong) LocationManager* locationManager;


- (IBAction)selectCategory:(UISegmentedControl *)sender;
- (void) goToPosition:(CLLocationCoordinate2D)coord;
- (IBAction)categorySelector:(UISegmentedControl *)sender;
- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position title:(NSString *)title;
- (IBAction)clickCancel:(id)sender;
- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position title:(NSString *)title icon:(UIImage *)icon;
@end
