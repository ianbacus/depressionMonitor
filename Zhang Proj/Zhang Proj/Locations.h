//
//  Locations.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#ifndef Locations_h
#define Locations_h

#import <CoreLocation/CoreLocation.h>
#import "Sensor.h"

@interface Locations : Sensor

//- (BOOL) startSensorWithInterval:(double)interval;
//- (BOOL) startSensorWithAccuracy:(double)accuracyMeter;

- (BOOL) startSensorWithInterval:(double)interval accuracy:(double)accuracyMeter;
- (void) saveLocation:(CLLocation *)location;

//- (void) saveAuthorizationStatus:(CLAuthorizationStatus)status;




@end


@interface Locations() <CLLocationManagerDelegate>;
@end


#endif
