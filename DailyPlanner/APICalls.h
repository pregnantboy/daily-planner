//
//  APICalls.h
//  DailyPlanner
//
//  Created by Soham Ghosh on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#ifndef DailyPlanner_APICalls_h
#define DailyPlanner_APICalls_h

@import GoogleMaps;


extern NSString *const DJANGO_SERVER_URL;

int const MAP_CATEGORY_FOOD = 1;
int const MAP_CATEGORY_SPORTS = 2;

// events stuff
void getCalendarEvents();
void updateCalendarEvent();
void createCalendarEvent();


// API stuff
void getWeatherData();
void getMapData(GMSCameraPosition *, int);


NSDictionary* makeRequest(NSString *);
#endif
