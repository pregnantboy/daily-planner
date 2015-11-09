//
//  WeatherManager.m
//  DailyPlanner
//
//  Created by Ian Chen on 10/9/15.
//  Copyright (c) 2015 Ian Chen. All rights reserved.
//

#import "WeatherManager.h"

@interface WeatherManager() <NSXMLParserDelegate> {
    NSString *_forecastPath;
    NSString *_hiLoTempPath;
    NSString *_nowcastPath;
    NSDictionary *_rawNowcast;
    NSDictionary *_rawForecast;
    NSMutableArray *_prettyForecast;
    NSMutableDictionary *_prettyNowcast;
    NSDictionary *_hiLoTemp;
    NSDate *_forecastLastUpdated;
    NSDate *_nowcastLastUpdated;
    NSXMLParser *_neaForecastParser;
    NSUserDefaults *_defaults;
}

@end

static WeatherManager *_sharedManager;
// high/low forecast
static NSString *neaForecastUrl = @"http://www.nea.gov.sg/api/WebAPI/?dataset=12hrs_forecast&keyref=781CF461BB6606AD19AA45F38E88F174F0E3E9D8D4FF2BF7";
// current temp and condition
static NSString *nowcastUrl = @"http://api.wunderground.com/api/04955c68ad1e9d80/conditions/q/SG/Singapore.json";
// hourly temp and condition
static NSString *forecastUrl = @"http://api.wunderground.com/api/04955c68ad1e9d80/hourly/q/SG/Singapore.json";
static NSString *const ForecastLastUpdatedUserDefault = @"ForecastLastUpdatedUserDefault";
static NSString *const NowcastLastUpdatedUserDefault = @"NowcastLastUpdatedUserDefault";
NSString *const weatherReceivedNotification = @"WeatherReceivedNotification";

@implementation WeatherManager

- (id)init {
    self = [super init];
    if (self) {
        // Set save paths for all data
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0) {
            _forecastPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"forecast.out"];
            _hiLoTempPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"hilo.out"];
            _nowcastPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"nowcast.out"];
        } else {
            NSLog(@"application document path not found");
        }
        _neaForecastParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:neaForecastUrl]];
        [_neaForecastParser setDelegate:self];
        
        _defaults = [NSUserDefaults standardUserDefaults];
        if ([_defaults objectForKey:ForecastLastUpdatedUserDefault]) {
            _forecastLastUpdated = [_defaults objectForKey:ForecastLastUpdatedUserDefault];
        }
        if ([_defaults objectForKey:NowcastLastUpdatedUserDefault]) {
            _nowcastLastUpdated = [_defaults objectForKey:NowcastLastUpdatedUserDefault];
        }
        
        [self tryUpdate];
    }
    return self;
}

#pragma mark - SharedManager
+ (id)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[WeatherManager alloc] init];
        [_sharedManager tryUpdate];
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
        [_defaults setObject:_forecastLastUpdated forKey:ForecastLastUpdatedUserDefault];
        [self parseForecast];
    }
}

- (void)updateNowcast {
    NSLog(@"updating nowcast");
    [_neaForecastParser parse];
    NSData *nowcastData = [NSData dataWithContentsOfURL:[NSURL URLWithString:nowcastUrl]];
    NSError *errorJson =  nil;
    _rawNowcast = [NSJSONSerialization JSONObjectWithData:nowcastData options:kNilOptions error:&errorJson];
    if (errorJson) {
        NSLog(@"hourly forecast error %@", errorJson);
    } else {
        [_rawNowcast writeToFile:_nowcastPath atomically:YES];
        _nowcastLastUpdated = [NSDate date];
        [_defaults setObject:_nowcastLastUpdated forKey:NowcastLastUpdatedUserDefault];
        [self parseNowcast];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (parser == _neaForecastParser) {
        if ([elementName isEqualToString:@"temperature"]) {
            _hiLoTemp = attributeDict;
            [_hiLoTemp writeToFile:_hiLoTempPath atomically:YES];
        }
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

- (void)tryUpdateNowcast {
    BOOL hiLoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:_hiLoTempPath];
    BOOL nowcastFileExists = [[NSFileManager defaultManager] fileExistsAtPath:_nowcastPath];
    if (nowcastFileExists && hiLoFileExists && ![self isOutdated:_nowcastLastUpdated]) {
        NSLog(@"Nowcast file exists!");
        _rawNowcast = [NSDictionary dictionaryWithContentsOfFile:_nowcastPath];
        _hiLoTemp = [NSDictionary dictionaryWithContentsOfFile:_hiLoTempPath];
    } else {
        [self updateNowcast];
    }
    [self parseNowcast];
}

- (void)tryUpdateForecast {
    BOOL forecastFileExists = [[NSFileManager defaultManager] fileExistsAtPath:_forecastPath];
    if (forecastFileExists && ![self isOutdated:_forecastLastUpdated]) {
        _rawForecast = [NSDictionary dictionaryWithContentsOfFile:_forecastPath];
        NSLog(@"Forecast file exists!");

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

        [hourDict setObject:[self weatherObjectForDict:hourDict] forKey:@"weather"];
        int tempHour = [[hourDict objectForKey:@"hour" ]intValue] % 12;
        if (tempHour == 0) {
            tempHour = 12;
        }
        [hourDict setObject:[NSNumber numberWithInt:tempHour] forKey:@"hour"];
        
        [_prettyForecast addObject:hourDict];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:weatherReceivedNotification object:nil];
}

- (void)parseNowcast {
    _prettyNowcast = [[NSMutableDictionary alloc] init];
    NSDictionary* conditions = [_rawNowcast objectForKey:@"current_observation"];
    [_prettyNowcast setObject:[conditions objectForKey:@"temp_c"] forKey:@"temp"];
    WeatherObject *weatherObj = [self weatherObjectForString:[conditions objectForKey:@"icon"]];
    [_prettyNowcast setObject:weatherObj forKey:@"weather"];
    [[NSNotificationCenter defaultCenter] postNotificationName:weatherReceivedNotification object:nil];
}

#pragma mark - Public API

- (NSMutableArray *)prettyForecast {
    return _prettyForecast;
}

- (NSDictionary *)prettyNowcast {
    return _prettyNowcast;
}

- (NSDictionary *)hiLoTemp {
    return _hiLoTemp;
}

- (NSDate *)lastUpdated {
    return _forecastLastUpdated;
}

- (void)tryUpdate {
    [self tryUpdateForecast];
    [self tryUpdateNowcast];
}

- (void)forceUpdate {
    [self updateForecast];
    [self updateNowcast];
}

#pragma mark - Private helpers

- (BOOL)isNightWithHour:(int)hour {
    if (hour < 7 || hour >= 19) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isNightNow {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSInteger hour = [cal component:NSCalendarUnitHour fromDate:now];
    if (hour < 7 || hour >= 19) {
        return YES;
    } else {
        return NO;
    }
}

- (WeatherObject *)weatherObjectForDict:(NSDictionary *)hourDict {
    int fctcode = [[hourDict objectForKey:@"code"] intValue];
    int hour = [[hourDict objectForKey:@"hour"] intValue];
    BOOL isNight = [self isNightWithHour:hour]
    ;
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

- (WeatherObject *)weatherObjectForString:(NSString *)iconName {
    BOOL isNight = [self isNightNow];
    WeatherType weatherType;
    if ([iconName isEqualToString:@"clear"] || [iconName isEqualToString:@"sunny"]) {
        if (!isNight) {
            weatherType = WTSunny;
        } else {
            weatherType = WTClearNight;
        }
    } else if ([iconName isEqualToString:@"partlycloudy"] || [iconName isEqualToString:@"partlysunny"]) {
        if (!isNight) {
            weatherType = WTPartlyCloudy;
        } else {
            weatherType = WTPartlyCloudyNight;
        }
    } else if ([iconName isEqualToString:@"mostlycloudy"] || [iconName isEqualToString:@"cloudy"]) {
        weatherType = WTCloudy;
    } else if ([iconName isEqualToString:@"fog"] || [iconName isEqualToString:@"hazy"]) {
        weatherType = WTHazy;
    } else if ([iconName isEqualToString:@"chancerain"] || [iconName isEqualToString:@"rain"]) {
        weatherType = WTRainy;
    } else if ([iconName isEqualToString:@"tstorms"] || [iconName isEqualToString:@"chancetstorms"]) {
        weatherType = WTThunderstorm;
    } else {
        weatherType = WTCloudy;
    }
    return [[WeatherObject alloc] initWithWeatherType:weatherType];
    
}

@end
