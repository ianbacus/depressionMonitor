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
@synthesize isCollecting = _isCollecting;

-(instancetype) initSensor
{
    self = [super init];
    if(self)
    {
        //publicCounter = 5;
        //_protectedCounter = 5;
        //_dataTable = [[NSMutableDictionary alloc] init];
        //assert(_dataTable);
    }
    return self;
}

-(NSDictionary *) flushData
{
    NSDictionary * retDict = [[NSDictionary alloc] initWithDictionary:_dataTable copyItems:YES];
    [_dataTable removeAllObjects];
    return retDict;
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
    _isCollecting = YES;
    return YES;
}

-(BOOL) stopCollecting
{
    _isCollecting = NO;
    return YES;
}


@end
