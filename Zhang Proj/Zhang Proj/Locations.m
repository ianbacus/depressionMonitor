//
//  Locations.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Locations.h"
#import "AppDelegate.h"

NSString * const AWARE_PREFERENCES_STATUS_LOCATION_GPS = @"status_location_gps";
NSString * const AWARE_PREFERENCES_FREQUENCY_GPS = @"frequency_gps";
NSString * const AWARE_PREFERENCES_MIN_GPS_ACCURACY = @"min_gps_accuracy";



@implementation Locations{
    NSTimer *locationTimer;
    IBOutlet CLLocationManager *locationManager;
    double defaultInterval;
    double defaultAccuracy;
}


- (instancetype)init
{
    if (self) {
        defaultInterval = 180; // 180sec(=3min)
        defaultAccuracy = 250; // 250m
    }
    return self;
}

-(BOOL)startCollecting
{
    
    // Get a sensing frequency from settings
    double interval = defaultInterval;
    double frequency = 1;//[self getSensorSetting:settings withKey:@"frequency_gps"];
    if(frequency != -1){
        NSLog(@"Sensing requency is %f ", frequency);
        interval = frequency;
    }
    
    // Get a min gps accuracy from settings
    double minAccuracy = 1;//[self getSensorSetting:settings withKey:@"min_gps_accuracy"];
    if ( minAccuracy > 0 ) {
        NSLog(@"Mini GSP accuracy is %f", minAccuracy);
    } else {
        minAccuracy = defaultAccuracy;
    }
    [self startSensorWithInterval:0 accuracy:minAccuracy];
    
    return YES;
    
}

- (BOOL)startSensorWithInterval:(double)interval accuracy:(double)accuracyMeter
{
    // Set and start a location sensor with the senseing frequency and min GPS accuracy
    //NSLog(@"[%@] Start Location Sensor!", [self getSensorName]);
    
    if (nil == locationManager){
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
        } else if (accuracyMeter <= 3000){
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        }

        
        locationManager.pausesLocationUpdatesAutomatically = NO;
        
        CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        NSLog(@"OS:%f", currentVersion);
        if (currentVersion >= 9.0) {
            //This variable is an important method for background sensing after iOS9
            locationManager.allowsBackgroundLocationUpdates = YES;
        }
        
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        
        /**
         * Check an authorization of location sensor
         * https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/#//apple_ref/c/tdef/CLAuthorizationStatus
         */
        
        //[self saveAuthorizationStatus:[CLLocationManager authorizationStatus]];
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = accuracyMeter; // meter
        // locationManager.activityType = CLActivityTypeFitness;
        
        // Start Monitoring
        [locationManager startMonitoringSignificantLocationChanges];
        // [locationManager startUpdatingLocation];
        // [locationManager startUpdatingHeading];
        // [_locationManager startMonitoringVisits];
        
        [self getGpsData:nil];
        
        if(interval > 0){
            locationTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                             target:self
                                                           selector:@selector(getGpsData:)
                                                           userInfo:nil
                                                            repeats:YES];
            [self getGpsData:nil];
        }else{
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


- (void) getGpsData: (NSTimer *) theTimer {
    //[sdManager addLocation:[_locationManager location]];
    CLLocation* location = [locationManager location];
    [self saveLocation:location];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    for (CLLocation* location in locations) {
        [self saveLocation:location];
    }
}

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

/*
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

*/
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





@end
