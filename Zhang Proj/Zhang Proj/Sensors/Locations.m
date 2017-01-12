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


- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Locations";
        //self.dataTable = [[NSMutableDictionary alloc] init];
        defaultInterval = 10; // seconds
        //defaultInterval = -1; // only on updates to location
        defaultAccuracy = 1; // meters
        self.dataTable = [[NSMutableDictionary alloc] init];
        if (locationManager == nil){
            locationManager = [[CLLocationManager alloc] init];
            locationManager.delegate = self;
            locationManager.pausesLocationUpdatesAutomatically = NO;
            
            CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (currentVersion >= 9.0)
            {
                locationManager.allowsBackgroundLocationUpdates = YES;
            }
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [locationManager requestAlwaysAuthorization];
            }
            //[self saveAuthorizationStatus:[CLLocationManager authorizationStatus]];
        }
    }
    return self;
}

-(BOOL)startCollecting
{
    [super startCollecting];
    [self startSensorWithInterval:defaultInterval accuracy:defaultAccuracy];
    return YES;
    
}


- (BOOL)stopCollecting
{
    [super stopCollecting];
    // Stop a sensing timer
    [locationTimer invalidate];
    locationTimer = nil;
    
    // Stop location sensors
    [locationManager stopUpdatingHeading];
    [locationManager stopUpdatingLocation];
    //locationManager = nil;
    
    return YES;
}

-(BOOL) setAccuracy:(double)accuracyMeter
{
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
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = accuracyMeter; // meter
    return YES;
}

- (BOOL)startSensorWithInterval:(double)interval accuracy:(double)accuracyMeter
{
    // Set and start a location sensor with the senseing frequency and min GPS accuracy
    if(locationManager)
    {
        [self setAccuracy:accuracyMeter];
        [locationManager startMonitoringSignificantLocationChanges];
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



///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////


- (void) getGpsData: (NSTimer *) theTimer
{
    CLLocation* location = [locationManager location];
    if(location != nil)
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

    NSString * latitude = [NSString stringWithFormat:@"%.02f", location.coordinate.latitude];
    NSString * longitude = [NSString stringWithFormat:@"%.02f", location.coordinate.longitude];
    //NSString * longitude = [[NSNumber numberWithDouble:location.coordinate.longitude] stringValue];
    double acc = ((location.verticalAccuracy + location.horizontalAccuracy) / 2);
    NSString * accuracy = [[NSNumber numberWithDouble:acc] stringValue];
    NSString *locationStr = [@[latitude, longitude, accuracy] componentsJoinedByString:@","];
    [self saveData:locationStr];
}

@end
