//
//  LocationManager.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 25/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "LocationManager.h"

//static NSString * locationsAPIUrl = @"https://api.yelp.com/v2/search";
//static NSString * searchUrl = @"/v2/search";
//NSString * oauth_consumer_key = @"6C2_O5ulk-M27Vo_7kfF0Q";
//NSString * oauth_token = @"1RWnrX4fSLKxB9SZ1gj_p4U2uwZFJjS-";
//NSString * oauth_consumer_secret = @"isSMGBZ3iuvVrDQGtz5hc_tx8PE";
//NSString * oath_token_secret = @"lJM17R-ZERdYJHV-_n7l2IIo2jk";


@implementation LocationManager

- (id) init {
    self = [super init];
    self.foodLocations = [self parseKMLLocationsFile:@"HawkerCenter.kml"];
    self.sportsLocations = [self parseKMLLocationsFile:@"SSC_Sports_Facilities.kml"];
    return self;
}

- (NSMutableArray *) parseKMLLocationsFile:(NSString *)fileName {
    NSMutableArray * locations = nil;
    NSLog(@"parsing file %@", fileName);
    NSError * err = nil;
    TBXML *sourceXML = [[TBXML alloc] initWithXMLFile:fileName error:&err];
    TBXMLElement *rootElem = sourceXML.rootXMLElement;
    TBXMLElement * document = [TBXML childElementNamed:@"Document" parentElement:rootElem];
    TBXMLElement * elem = document->firstChild;
    do {
        if (!locations){
            LocationObject * obj = [self parseLocationElement:elem];
            locations = [NSMutableArray arrayWithObject:obj];
        } else {
            [locations addObject:[self parseLocationElement:elem]];
        }
        
    } while((elem = elem->nextSibling));
    return locations;
}

- (LocationObject *) parseLocationElement:(TBXMLElement *) elem {
    TBXMLElement * nameElement = [TBXML childElementNamed:@"name" parentElement:elem];
    NSString * name = [TBXML textForElement:nameElement];
    TBXMLElement * positionElement = [TBXML childElementNamed:@"coordinates" parentElement:[TBXML childElementNamed:@"Point" parentElement:elem]];
    NSString * pos_str = [TBXML textForElement:positionElement];
    NSArray * posArray = [pos_str componentsSeparatedByString:@","];
    float lon = [posArray[0] floatValue];
    float lat = [posArray[1] floatValue];
    CLLocationCoordinate2D pos = CLLocationCoordinate2DMake(lat, lon);
    return [[LocationObject alloc] initWithTitle:name position:pos];
}

- (NSMutableArray *) getLocations {
    switch(self.category){
        case FOOD:
            return self.foodLocations;
        case SPORTS:
            return self.sportsLocations;
    }
    return nil;
}

- (NSString *) getLocationIcon {
    switch(self.category){
        case FOOD:
            return @"foodicon.png";
        case SPORTS:
            return nil;
    }
    return nil;
}

- (void) setCategory:(Category)cat {
    self.category = cat;
}

@end
