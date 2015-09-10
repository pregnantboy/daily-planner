//
//  APICalls.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APICalls.h"

NSString *const DJANGO_SERVER_URL = @"http://127.0.0.1:8000";

// events stuff
void getCalendarEvents(){
    
}
void updateCalendarEvent(){
    
}
void createCalendarEvent(){
    
}


// API stuff
void getWeatherData(){
    
}

void getMapData(GMSCameraPosition * camPos, int cat){
    switch(cat){
        case MAP_CATEGORY_FOOD:
            break;
        case MAP_CATEGORY_SPORTS:
            break;
        default:
            break;
    }
}

NSDictionary* makeRequest(NSString *requestUrl){
    NSURL * baseUrl = [NSURL URLWithString:DJANGO_SERVER_URL];
    NSURL * url = [NSURL URLWithString:requestUrl relativeToURL:baseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSError *requestError = nil;
    NSURLResponse *urlResponse = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse error:&requestError];
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:&localError];
    return parsedObject;
}
