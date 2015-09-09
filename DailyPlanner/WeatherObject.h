//
//  WeatherIcon.h
//  DailyPlanner
//
//  Created by Ian Chen on 9/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherObject : NSObject

typedef NS_ENUM(NSUInteger, WeatherType) {
    WTSunny,
    WTPartlyCloudy,
    WTCloudy,
    WTRainy,
    WTThunderstorm,
    WTHazy
};

- (id)initWithWeatherType:(WeatherType)weatherType;
- (UIImage *)imageIcon;

@end
