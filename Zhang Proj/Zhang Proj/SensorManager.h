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


#ifndef SensorManager_h
#define SensorManager_h

@interface SensorManager : NSObject 

@property DBManager* dbManager;
@property NSArray* sensorsArray;


-(instancetype) initSensorManagerWithDBManager:(DBManager*)dbManager;

//Dynamically enable or disable sensors from viewcontroller

-(void) acceptDataFromSensors;
-(void) acceptDataFromSensor :(Sensor*)sensor;

-(BOOL) startPeriodicCollectionWithInterval:(float)interval;
-(BOOL) stopPeriodicCollection;
-(BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName;
-(BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName;


@property NSTimer* dataCollectionTimer;
//@property DBManager* databaseMgr;

@end

#endif /* SensorManager_h */
