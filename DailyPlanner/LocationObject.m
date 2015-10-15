//
//  LocationObject.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 25/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "LocationObject.h"

@implementation LocationObject

- (id) initWithTitle:(NSString *) title position:(CLLocationCoordinate2D) position {
    self = [super init];
    self.title = title;
    self.position = position;
    return self;
}

@end
