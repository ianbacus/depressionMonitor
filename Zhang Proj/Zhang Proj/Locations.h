//
//  Locations.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#ifndef Locations_h
#define Locations_h

//#import "AWARESensor.h"
#import <CoreLocation/CoreLocation.h>
#import "Sensor.h"

extern NSString * const AWARE_PREFERENCES_STATUS_LOCATION_GPS;
extern NSString * const AWARE_PREFERENCES_FREQUENCY_GPS;
extern NSString * const AWARE_PREFERENCES_MIN_GPS_ACCURACY;

@interface Locations : Sensor


- (BOOL) startSensor;
- (BOOL) startSensorWithInterval:(double)interval;
- (BOOL) startSensorWithAccuracy:(double)accuracyMeter;
- (BOOL) startSensorWithInterval:(double)interval accuracy:(double)accuracyMeter;

- (void) saveLocation:(CLLocation *)location;

- (void) saveAuthorizationStatus:(CLAuthorizationStatus)status;

@end


#endif
