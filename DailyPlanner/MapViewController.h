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

@class MapViewController;
@protocol MapViewControllerDelegate <NSObject>
- (void)returnFromMapViewController:(MapViewController *)mvc withLocation:(NSString *)locationString;
@end

@interface MapViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *searchResultsView;
@property (weak, nonatomic) IBOutlet GMSMapView *map;
@property (strong) NSMutableArray* searchAutocompleteResults;
@property (strong) LocationManager* locationManager;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;

@end
