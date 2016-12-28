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

-(instancetype) initSensorManager
{
    self = [super init];
    if(self)
    {
        
    }
    _sensorsArray = [NSArray arrayWithObjects: [Accelerometer alloc], [Locations alloc], [Screen alloc], [Calls alloc], [IOSActivityRecognition alloc], nil];
    
    
    return self;
}

-(void) enableSensor:(Sensor *)sensor
{
    
}

-(void) disableSensor:(Sensor *)sensor
{
    
}

-(void)acceptDataFromSensor:(Sensor *)sensor :(NSData *)sensorData
{
    
}

@end
