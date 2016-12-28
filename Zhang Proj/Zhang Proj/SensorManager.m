//
//  SensorManager.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorManager.h"



@implementation SensorManager


- (NSURL*)storeURL
{
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"NestedTodoList" withExtension:@"momd"];
}

-(instancetype) initSensorManager
{
    self = [super init];
    if(self)
    {
        _databaseMgr = [[DBManager alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];
        _sensorsArray = [NSArray arrayWithObjects:  [[IOSActivityRecognition alloc] initSensor], //movement
                                                    [[Calls alloc] initSensor],                  //social
                                                    [[Locations alloc] initSensor],              //activity
                                                    [[Screen alloc] initSensor],                 //phone use
                                                    [[Camera alloc] initSensor], nil];           //face scan
        
    }
    return self;
}

-(BOOL) startPeriodicCollectionWithInterval:(float) interval
{
    //Make all sensors begin collecting data. On specified interval, flush the data of each sensor into the database
    
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(acceptDataFromSensors) userInfo:nil repeats:YES];
    for (id sensor in _sensorsArray) {
        [sensor startCollecting];
    }
    return YES;
}

-(BOOL) stopPeriodicCollection
{
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    for (id sensor in _sensorsArray)
    {
        [sensor stopCollecting];
    }
    
    return YES;
}

-(void) acceptDataFromSensors
{
    for (id sensor in _sensorsArray) {
        if([sensor isCollecting])
            [self acceptDataFromSensor:sensor];
    }
}
-(void) acceptDataFromSensor:(Sensor *)sensor
{
    [_databaseMgr saveData:[sensor flushData]];
    
}


@end
