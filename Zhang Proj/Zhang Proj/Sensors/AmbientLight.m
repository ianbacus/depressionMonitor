//
//  AmbientLight.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "AmbientLight.h"

@implementation AmbientLight

- (instancetype) initSensor
{
    self = [super init];
    if (self) {
        self._name = @"AmbientLight";
        self.dataTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    [self startCollectingAtInterval:self.samplingInterval];
    return YES;
}

-(BOOL) startCollectingAtInterval:(double)interval
{
    [super startCollecting];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(getScreenBrightness) userInfo:nil repeats:YES];
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


/*
 *  Screen brightness is a floating point value from 0 to 1. 1 Is the max brightness, 0 is the minimum. Value is saved in sensor's local storage
 */
-(void) getScreenBrightness
{
    NSString* brightnessStr = [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] brightness]];
    [self saveData:brightnessStr];
}

/*
 *  Return a data series of [time,brightness] pairs
 */
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



