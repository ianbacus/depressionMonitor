//
//  Accelerometer.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#ifndef Accelerometer_h
#define Accelerometer_h

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Sensor.h"

extern NSString* const AWARE_PREFERENCES_STATUS_ACCELEROMETER;
extern NSString* const AWARE_PREFERENCES_FREQUENCY_ACCELEROMETER;
extern NSString* const AWARE_PREFERENCES_FREQUENCY_HZ_ACCELEROMETER;

@interface Accelerometer : Sensor
/*
- (BOOL) startSensor;
- (BOOL) startSensorWithInterval:(double)interval;
- (BOOL) startSensorWithInterval:(double)interval bufferSize:(int)buffer;
- (BOOL) startSensorWithInterval:(double)interval bufferSize:(int)buffer fetchLimit:(int)fetchLimit;
*/

@end


#endif
