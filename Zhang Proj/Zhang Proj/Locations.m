//
//  Locations.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

/**
 * Check an authorization of location sensor
 * https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/c/tdef/CLAuthorizationStatus
 */

#import "Locations.h"
#import "AppDelegate.h"


@implementation Locations{
    NSTimer *locationTimer;
    IBOutlet CLLocationManager *locationManager;
    double defaultInterval;
    double defaultAccuracy;
}


- (instancetype)init
{
    if (self) {
        //defaultInterval = 180; // seconds
        defaultInterval = -1; // only on updates to location
        defaultAccuracy = 50; // meters
    }
    return self;
}

-(BOOL)startCollecting
{
    [self startSensorWithInterval:defaultInterval accuracy:defaultAccuracy];
    return YES;
    
}

- (BOOL)startSensorWithInterval:(double)interval accuracy:(double)accuracyMeter
{
    // Set and start a location sensor with the senseing frequency and min GPS accuracy
    if (locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        
        if (accuracyMeter == 0) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        } else if (accuracyMeter <= 5){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        } else if (accuracyMeter <= 25 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        } else if (accuracyMeter <= 100 ){
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        } else if (accuracyMeter <= 1000){
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        }
        locationManager.pausesLocationUpdatesAutomatically = NO;
        
        CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (currentVersion >= 9.0) {
            locationManager.allowsBackgroundLocationUpdates = YES;
        }
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = accuracyMeter; // meter
        
        [locationManager startMonitoringSignificantLocationChanges];
        //[self saveAuthorizationStatus:[CLLocationManager authorizationStatus]];
        
        [self getGpsData:nil];
        
        //sampled vs on update
        if(interval > 0){
            locationTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(getGpsData:) userInfo:nil repeats:YES];
            [self getGpsData:nil];
        }
        else
        {
            [locationManager startUpdatingLocation];
        }
    }
    return YES;
}


- (BOOL)stopCollecting
{
    // Stop a sensing timer
    [locationTimer invalidate];
    locationTimer = nil;
    
    // Stop location sensors
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////


- (void) getGpsData: (NSTimer *) theTimer
{
    CLLocation* location = [locationManager location];
    [self saveLocation:location];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    for (CLLocation* location in locations)
    {
        [self saveLocation:location];
    }
}

- (void) saveLocation:(CLLocation *)location
{

    NSString * latitude = [[NSNumber numberWithDouble:location.coordinate.latitude] stringValue];
    NSString * longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    double acc = ((location.verticalAccuracy + location.horizontalAccuracy) / 2);
    NSString * accuracy = [[NSNumber numberWithDouble:acc] stringValue];
    NSString *locationStr = [@[latitude, longitude, accuracy] componentsJoinedByString:@","];
    [_dataTable setObject:locationStr forKey:[NSDate new]];
}

/*
- (void) saveLocation:(CLLocation *)location{

    double accuracy = (location.verticalAccuracy + location.horizontalAccuracy) / 2;
    
    //NSNumber * unixtime = [AWAREUtils getUnixTimestamp:[NSDate new]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //[dict setObject:unixtime forKey:@"timestamp"];
    //[dict setObject:[self getDeviceId] forKey:@"device_id"];
    [dict setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"double_latitude"];
    [dict setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"double_longitude"];
    [dict setObject:[NSNumber numberWithDouble:location.course] forKey:@"double_bearing"];
    [dict setObject:[NSNumber numberWithDouble:location.speed] forKey:@"double_speed"];
    [dict setObject:[NSNumber numberWithDouble:location.altitude] forKey:@"double_altitude"];
    [dict setObject:@"gps" forKey:@"provider"];
    [dict setObject:@(accuracy) forKey:@"accuracy"];
    [dict setObject:@"" forKey:@"label"];
    //[self setLatestValue:[NSString stringWithFormat:@"%f, %f, %f", location.coordinate.latitude, location.coordinate.longitude, location.speed]];
    //[self setLatestData:dict];
    
    
}


- (void)insertNewEntit25yWithData:(NSDictionary *)data
           managedObjectContext:(NSManagedObjectContext *)childContext
                     entityName:(NSString *)entity{
    
    EntityLocation* entityLocation = (EntityLocation *)[NSEntityDescription
                                              insertNewObjectForEntityForName:entity
                                              inManagedObjectContext:childContext];
    
    entityLocation.device_id = [data objectForKey:@"device_id"];
    entityLocation.timestamp = [data objectForKey:@"timestamp"];
    entityLocation.double_latitude = [data objectForKey:@"double_latitude"];
    entityLocation.double_longitude = [data objectForKey:@"double_longitude"];
    entityLocation.double_bearing = [data objectForKey:@"double_bearing"];
    entityLocation.double_speed = [data objectForKey:@"double_speed"];
    entityLocation.double_altitude = [data objectForKey:@"double_altitude"];
    entityLocation.provider = [data objectForKey:@"provider"];
    entityLocation.accuracy = [data objectForKey:@"accuracy"];
    entityLocation.label = [data objectForKey:@"label"];
    
}


- (void)saveDummyData{
    [self getGpsData:nil];
}


//- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    if (newHeading.headingAccuracy < 0)
//        return;
////    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
////                                       newHeading.trueHeading : newHeading.magneticHeading);
////    [sdManager addSensorDataMagx:newHeading.x magy:newHeading.y magz:newHeading.z];
////    [sdManager addHeading: theHeading];
//}


*/


@end
