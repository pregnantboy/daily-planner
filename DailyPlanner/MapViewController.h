//
//  MapViewController.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 19/9/15.
//  Copyright © 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface MapViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsView;
@property (strong, nonatomic) IBOutlet GMSMapView *map;
@property (strong) NSMutableArray* searchAutocompleteResults;
- (void) goToPosition:(CLLocationCoordinate2D)coord;
- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position;
@end
