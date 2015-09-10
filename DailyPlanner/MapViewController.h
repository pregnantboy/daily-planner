//
//  WeatherViewController.h
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface MapViewController : UIViewController


@property (strong, nonatomic) IBOutlet GMSMapView *map;
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearch;
- (IBAction) onCategoryChange:(UISegmentedControl *)categorySelector;

@end
