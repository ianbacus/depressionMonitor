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
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(getScreenBrightness) userInfo:nil repeats:YES];
    //[_dataCollectionTimer fire];
    return YES;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    return YES;
}

-(void) getScreenBrightness
{
    NSString* brightnessStr = [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] brightness]];
    [self saveData:brightnessStr];
}

-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        NSString *dataStr = [obj valueForKey:@"stateVal"];
        
        [ret insertObject:dataStr atIndex:dataIndex];
    }
    return ret;
}


@end



