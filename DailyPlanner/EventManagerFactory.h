//
//  EventManagerFactory.h
//  DailyPlanner
//
//  Created by Ian Chen on 9/11/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleEventManager.h"

typedef NS_ENUM(NSUInteger, CalType) {
    CalGoogle,
    CalExchange
};

@interface EventManagerFactory : NSObject

+ (id)createEventManager:(CalType)calendarType withViewController:(UIViewController *)vc;

@end
