//
//  EventManagerFactory.m
//  DailyPlanner
//
//  Created by Ian Chen on 9/11/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "EventManagerFactory.h"

@implementation EventManagerFactory

+ (id)createEventManager:(CalType)calendarType withViewController:(UIViewController *)vc {
    switch(calendarType) {
        case CalGoogle:
            return [[GoogleEventManager alloc] initWithViewController:vc];
        case CalExchange:
            NSLog(@"Exchange calendar not added yet");
            return nil;
        default:
            NSLog(@"New calendars to be added");
            return nil;
    }
}

@end
