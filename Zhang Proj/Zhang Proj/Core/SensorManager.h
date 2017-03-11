//
//  SensorManager.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "DBManager.h"
#import "Sensor.h"

//Sensors to be used

#import "Locations.h"
#import "Camera.h"
#import "Screen.h"
#import "Calls.h"
#import "IOSActivityRecognition.h"
#import "AmbientLight.h"
#import "AmbientNoise.h"
#import "Wifi.h"
#import "Pedometer.h"
#import "Battery.h"

/*
 Activity
 Locations
 Screen
 Calls
 AmbientNoise
 AmbientLight
 Wifi
 Battery
 
 */

#ifndef SensorManager_h
#define SensorManager_h

@interface SensorManager : NSObject 

@property DBManager* dbManager;
@property int batteryTestIndex;
@property double testRate;
@property NSDate* startDate;
@property NSArray* sensorsArray;
@property NSTimer* dataCollectionTimer;
@property NSTimer* dailyUpdateTimer;
@property (strong, nonatomic) CLLocationManager *sharedLocationManager; //for background hack

-(instancetype) initSensorManagerWithDBManager:(DBManager*)dbManager;

-(void) acceptDataFromSensors;
-(void) acceptDataFromSensor :(Sensor*)sensor;
-(void) uploadSensorData;
-(void) uploadAllSensorData;

- (NSDate *) getTargetNSDate:(NSDate *) nsDate
                        hour:(int) hour
                      minute:(int) minute
                      second:(int) second
                     nextDay:(BOOL)nextDay;
-(NSArray*) createDataSetForSensor:(NSString*) sensorName fromStartDate:(NSDate *)startDate toEndDate:(NSDate*)endDate;
-(BOOL) startPeriodicCollectionWithInterval:(float)interval;
-(BOOL) stopPeriodicCollection;
-(BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName;
-(BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName;


@end

@interface SensorManager() <CLLocationManagerDelegate>;
@end


#endif /* SensorManager_h */
