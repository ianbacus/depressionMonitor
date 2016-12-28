//
//  Sensor.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sensor.h"


@implementation Sensor

@synthesize name = _name;

-(instancetype) initSensor// :(NSString*)sensorName
{
    self = [super init];
    //_name = sensorName;
    return self;
}

-(BOOL) initTable
{
 
    return YES;
}

-(BOOL) getStatus
{
    return YES;
}

-(BOOL) startCollecting
{
    return YES;
}

-(BOOL) stopCollecting
{
    return YES;
}


@end
