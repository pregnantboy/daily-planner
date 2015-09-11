//
//  WeatherManager.m
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "WeatherManager.h"

@interface WeatherManager() {
    NSString *_forecastPath;
    NSDictionary *_nowcast;
    NSDictionary *_rawForecast;
    NSMutableArray *_prettyForecast;
    NSDate *_forecastLastUpdated;
}

@end

static WeatherManager *_sharedManager;
static NSString *forecastUrl = @"http://api.wunderground.com/api/04955c68ad1e9d80/hourly/q/SG/Singapore.json";

@implementation WeatherManager

- (id)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            _forecastPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"forecast.out"];
            NSLog(@"%@", _forecastPath);
        } else {
            NSLog(@"application document path not found");
        }
        [self tryUpdateForecast];
    }
    return self;
}

#pragma mark - SharedManager
+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[WeatherManager alloc] init];
    });
    return _sharedManager;
}

- (void)updateForecast {
    NSLog(@"updating forecast");
    NSData *forecastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:forecastUrl]];
    NSError *errorJson =  nil;
    _rawForecast = [NSJSONSerialization JSONObjectWithData:forecastData options:kNilOptions error:&errorJson];
    if (errorJson) {
        NSLog(@"hourly forecast error %@", errorJson);
    } else {
        [_rawForecast writeToFile:_forecastPath atomically:YES];
        _forecastLastUpdated = [NSDate date];
    }
}

- (BOOL)isOutdated:(NSDate *)lastUpdated {
    NSCalendar *cal = [NSCalendar currentCalendar];
    if (lastUpdated) {
        NSDate *now = [NSDate date];
        if ([cal component:NSCalendarUnitYear fromDate:now] > [cal component:NSCalendarUnitYear fromDate:lastUpdated]) {
            if ([cal component:NSCalendarUnitMonth fromDate:now] > [cal component:NSCalendarUnitMonth fromDate:lastUpdated]) {
                if ([cal component:NSCalendarUnitDay fromDate:now] > [cal component:NSCalendarUnitDay fromDate:lastUpdated]) {
                    if ([cal component:NSCalendarUnitHour fromDate:now] > [cal component:NSCalendarUnitHour fromDate:lastUpdated]) {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)tryUpdateForecast {
    BOOL forecastFileExists = [[NSFileManager defaultManager] fileExistsAtPath:_forecastPath];
    if (forecastFileExists && [self isOutdated:_forecastLastUpdated]) {
        _rawForecast = [NSDictionary dictionaryWithContentsOfFile:_forecastPath];
    } else {
        [self updateForecast];
    }
    [self parseForecast];
}


- (void)parseForecast {
    _prettyForecast = [[NSMutableArray alloc] init];
    NSArray *hourlyForecast = [_rawForecast objectForKey:@"hourly_forecast"];
    NSUInteger count = [hourlyForecast count];
    for (int i = 0 ; i < count; i++) {
        NSDictionary *objectForHour = [hourlyForecast objectAtIndex:i];
        NSMutableDictionary *hourDict = [[NSMutableDictionary alloc] initWithCapacity:5];
        [hourDict setObject:[[objectForHour objectForKey:@"FCTTIME"] objectForKey:@"hour"] forKey:@"hour"];
        [hourDict setObject:[[objectForHour objectForKey:@"FCTTIME"] objectForKey:@"ampm"] forKey:@"ampm"];
        [hourDict setObject:[[objectForHour objectForKey:@"temp"] objectForKey:@"metric"] forKey:@"temp"];
        [hourDict setObject:[objectForHour objectForKey:@"fctcode"] forKey:@"code"];

        [hourDict setObject:[self weatherTypeForDict:hourDict] forKey:@"weather"];
        int tempHour = [[hourDict objectForKey:@"hour" ]intValue] % 12;
        if (tempHour == 0) {
            tempHour = 12;
        }
        [hourDict setObject:[NSNumber numberWithInt:tempHour] forKey:@"hour"];
        
        [_prettyForecast addObject:hourDict];
    }
}

- (NSMutableArray *)prettyForecast {
    return _prettyForecast;
}

- (BOOL)isNightWithHour:(int)hour andAmPm:(NSString *)ampm {
    if ([ampm caseInsensitiveCompare:@"AM"] == NSOrderedSame) {
        if (hour < 7) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (hour < 7) {
            return NO;
        } else {
            return YES;
        }
    }
}

- (WeatherObject *)weatherTypeForDict:(NSDictionary *)hourDict {
    int fctcode = [[hourDict objectForKey:@"code"] intValue];
    int hour = [[hourDict objectForKey:@"hour"] intValue];
    NSString *ampm = [hourDict objectForKey:@"ampm"];
    BOOL isNight = [self isNightWithHour:hour andAmPm:ampm];
    WeatherType weatherType;
    switch(fctcode) {
        case 1:
            if (!isNight) {
                weatherType = WTSunny;
            } else {
                weatherType = WTClearNight;
            }
            break;
        case 2:
        case 7:
        case 8:
            if (!isNight) {
                weatherType = WTPartlyCloudy;
            } else {
                weatherType = WTPartlyCloudyNight;
            }
            break;
        case 3:
        case 4:
            weatherType = WTCloudy;
            break;
        case 5:
        case 6:
            weatherType = WTHazy;
            break;
        case 10:
        case 11:
        case 12:
        case 13:
            weatherType = WTRainy;
            break;
        case 14:
        case 15:
            weatherType = WTThunderstorm;
            break;
        default:
            weatherType = WTCloudy;
            break;
    }
    return [[WeatherObject alloc] initWithWeatherType:weatherType];
}

@end
