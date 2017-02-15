//
//  AmbientLight.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Battery.h"

@implementation Battery


- (instancetype) initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Battery";
        self.dataTable = [[NSMutableDictionary alloc] init];
        self.samplingInterval = 10.0f;
    }
    return self;
}

-(BOOL) startCollecting
{
    return [self startCollectingAtInterval:self.samplingInterval];
    return YES;
}

-(BOOL) startCollectingAtInterval:(double)interval
{
    [super startCollecting];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(getBatteryState) userInfo:nil repeats:YES];
    return YES;
}

-(BOOL) changeCollectionInterval:(double)interval
{
    [super changeCollectionInterval:interval];
    if([self isCollecting])
    {
        [self stopCollecting];
        [self startCollectingAtInterval:interval];
    }
    return YES;
}


-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    return YES;
}



-(void) getBatteryState
{
    NSString* batteryString = [NSString stringWithFormat:@"%f",[self measureBattery]];
    [self saveData:batteryString];
}



- (double) measureBattery
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    double batLeft = (double)[myDevice batteryLevel];
    return batLeft;
}


-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        NSDictionary *datum = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [obj valueForKey:@"time"],@"x",
                               [[NSNumber alloc ] initWithDouble:[[obj valueForKey:@"stateVal"] doubleValue]],@"y",
                               nil
                               ];
        [ret addObject:datum];
    }
    return ret;
}


@end





