//
//  LocationObject.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 25/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface LocationObject : NSObject

- (id) initWithTitle:(NSString *) title position:(CLLocationCoordinate2D) position;
@property NSString * title;
@property CLLocationCoordinate2D position;

@end
