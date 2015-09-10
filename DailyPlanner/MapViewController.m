//
//  WeatherViewController.m
//  DailyPlanner
//
//  Created by Ian Chen on 8/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end
@implementation MapViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    [self.locationSearch setTranslucent:YES];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.map.camera = camera;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)onCategoryChange:(UISegmentedControl *)categorySelector {
    NSInteger cat = categorySelector.selectedSegmentIndex;
    switch (cat) {
        case 0:  // Food
            NSLog(@"Chose food category");
            break;
        case 1:  // Sports
            // make API call here
            NSLog(@"Chose sports category");
            break;
        default:
            break;
    }
    
}
@end
