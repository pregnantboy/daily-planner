//
//  WeatherIcon.m
//  DailyPlanner
//
//  Created by Ian Chen on 9/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "WeatherObject.h"

@interface WeatherObject() {
    WeatherType _weatherType;
    UIImage *_imageIcon;
}

@end

@implementation WeatherObject

- (id)initWithWeatherType:(WeatherType)weatherType {
    self = [super init];
    if (self) {
        _weatherType = weatherType;
        NSString *filename;
        switch(weatherType) {
            case WTSunny:
                filename = @"sunny.png";
                break;
            case WTPartlyCloudy:
                filename = @"partlyCloudy.png";
                break;
            case WTCloudy:
                filename = @"cloudy.png";
                break;
            case WTRainy:
                filename = @"rainy.png";
                break;
            case WTThunderstorm:
                filename = @"thunderstorm.png";
                break;
            default:
                filename = @"cloudy.png";
                break;
        }
        _imageIcon = [UIImage imageNamed:filename];
    }
    return self;
}

- (UIImage *)imageIcon {
    return _imageIcon;
}

@end
