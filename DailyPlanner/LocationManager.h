//
//  LocationManager.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 25/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationObject.h"
#import <TBXML.h>

/*
 *  Parses XML file and stores objects in memory
 *
 */

@import CoreLocation;

@interface LocationManager : NSObject

@property NSArray * locations;
typedef enum {
    FOOD,
    SPORTS
} Category;

@property Category category;
@property NSURLConnection * currentConnection;
@property NSMutableArray * foodLocations;
@property NSMutableArray * sportsLocations;

- (NSMutableArray *) getLocations;
- (NSString *) getLocationIcon;
- (NSMutableArray *) parseKMLLocationsFile:(NSString *)fileName;
- (LocationObject *) parseLocationElement:(TBXMLElement *) elem;

@property (strong) LocationObject * chosenLocation;
- (void) deselectLocation;
@property (nonatomic) BOOL choseALocation;

- (void) chooseLocation:(NSString *)place position:(CLLocationCoordinate2D) position;
- (void) cancelChosenLocation;
@end
