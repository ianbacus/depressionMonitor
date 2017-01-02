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

-(instancetype) initSensorManagerWithDBManager:(DBManager *)dbManager
{
    self = [super init];
    if(self)
    {
        //_databaseMgr = [[DBManager alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];
        _dbManager = dbManager;
        _sensorsArray = [NSArray arrayWithObjects:  [[IOSActivityRecognition alloc] initSensor], //movement
                                                    [[Calls alloc] initSensor],                  //social
                                                    [[Locations alloc] initSensor],              //activity
                                                    [[Screen alloc] initSensor],                 //phone use
                                                    [[AmbientLight alloc] initSensor],           //screen brightness
                                                    [[AmbientNoise alloc] initSensor],           //ambient noise
                                                    //[[Camera alloc] initSensor],               //face scan
                                                    nil];
        
    }
    return self;
}

- (BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName
{
    for(Sensor* sensor in _sensorsArray)
    {
        if([sensor _name] == sensorName){
            [sensor startCollecting];
        }
    }
    return YES;
}

- (BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName
{
    for(Sensor* sensor in _sensorsArray)
    {
        if([sensor _name] == sensorName){
           [sensor stopCollecting];
        }
    }
    return YES;
}

-(BOOL) startPeriodicCollectionWithInterval:(float) interval
{
    //Make all sensors begin collecting data. On specified interval, flush the data of each sensor into the database
    
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(acceptDataFromSensors) userInfo:nil repeats:YES];
    for (id sensor in _sensorsArray) { [sensor startCollecting]; }
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
    for (Sensor* sensor in _sensorsArray) {
        if([sensor isCollecting])
            [self acceptDataFromSensor:sensor];
    }
}

-(void) uploadSensorData:(NSURL*)dbServer
{
    for (Sensor* sensor in _sensorsArray) {
        NSArray* data = [_dbManager getDataForSensor:sensor];
        
    }
}
-(void)postData:(NSArray*)data toURL:(NSURL*)dbServer
{
    //Delete SQLite contents for the day, convert them to a single piece of data
    NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"username",@"password"];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:dbServer];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    
}


-(void) acceptDataFromSensor:(Sensor *)sensor
{
    [_dbManager saveData:[sensor flushData]
                  forSensor:[sensor _name]];
    
}


@end
