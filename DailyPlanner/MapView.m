//
//  MapView.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "MapView.h"

@implementation MapView {
    GMSMapView *mapView_;
}

- (void)baseInit {
}


- (id)init
{
    mapView_ = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    mapView_.myLocationEnabled = YES;
}
@end
