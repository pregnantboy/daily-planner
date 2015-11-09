//
//  EventManagerFactory.h
//  DailyPlanner
//
//  Created by Ian Chen on 9/11/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventManager.h"

typedef NS_ENUM(NSUInteger, CalType) {
    CalGoogle,
    CalExchange
};

@interface EventManagerFactory : NSObject

@end
