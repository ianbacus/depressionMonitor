//
//  Accelerometer.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Sensor.h"
#import "Accelerometer.h"

NSString * const AWARE_PREFERENCES_STATUS_ACCELEROMETER    = @"status_accelerometer";
NSString * const AWARE_PREFERENCES_FREQUENCY_ACCELEROMETER = @"frequency_accelerometer";
NSString * const AWARE_PREFERENCES_FREQUENCY_HZ_ACCELEROMETER = @"frequency_hz_accelerometer";

@implementation Accelerometer{
    CMMotionManager *manager;
    double sensingInterval;
    int dbWriteInterval; //second
    int currentBufferSize;
    NSMutableArray * bufferArray;
    NSDictionary * defaultSettings;
}


/*
 
 -(instancetype) initSensor;
 -(int) setupTable;
 -(int) startCollecting;
 -(int) stopCollecting;
 -(int) getStatus;

 */

- (instancetype)initSensor {
    if (self) {
        manager = [[CMMotionManager alloc] init];
        sensingInterval = 0.1f;
        bufferArray = [[NSMutableArray alloc] init];
        currentBufferSize = 0;
    }
    
    return self;
}

-(void) enableSensor :(NSString *)sensorName
{
    
}

-(void) disableSensor :(NSString *)sensorName
{
    
}

-(void) acceptDataFromSensor :(Sensor*)sensor :(NSData *)sensorData
{
    
}

/**
 * Start sensor with interval and buffer, fetchLimit
 */
- (BOOL) startSensorWithInterval:(double)interval
{

    //NSLog(@"[%@] Start Sensor!", [self getSensorName]);
    
    manager.accelerometerUpdateInterval = interval;
    
    // Set and start a motion sensor
    [manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
      withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
          if( error ) {
              NSLog(@"%@:%ld", [error domain], (long)[error code] );
          } else {
              
              // SQLite
              NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
              //[dict setObject:[AWAREUtils getUnixTimestamp:[NSDate new]] forKey:@"timestamp"];
              //[dict setObject:[self getDeviceId] forKey:@"device_id"];
              [dict setObject:@(accelerometerData.acceleration.x) forKey:@"double_values_0"];
              [dict setObject:@(accelerometerData.acceleration.y) forKey:@"double_values_1"];
              [dict setObject:@(accelerometerData.acceleration.z) forKey:@"double_values_2"];
          }
      }];

    return YES;
}

-(BOOL) stopSensor {
    //[super stopSensor];
    [manager stopAccelerometerUpdates];
    return YES;
}


- (BOOL) setInterval:(double)interval{
    // [self setDefaultSettingWithNumber:@(interval) key:AWARE_PREFERENCES_FREQUENCY_ACCELEROMETER];
    sensingInterval = interval;
    return YES;
}

- (double) getInterval{
    // NSDictionary * settings = [self getDefaultSettings];
    // return [[settings objectForKey:AWARE_PREFERENCES_FREQUENCY_ACCELEROMETER] doubleValue];
    return sensingInterval;
}

@end
