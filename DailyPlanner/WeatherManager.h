//
//  WeatherManager.h
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

@import Foundation;
@import CoreData;

#import "WeatherObject.h"

extern NSString *const weatherReceivedNotification;

@interface WeatherManager : NSObject

+ (id)sharedManager;

- (NSMutableArray *)prettyForecast;
- (NSDictionary *)hiLoTemp;
- (NSDictionary *)prettyNowcast;
- (NSDate *)lastUpdated;
- (void)tryUpdate;
- (void)forceUpdate;
@end
