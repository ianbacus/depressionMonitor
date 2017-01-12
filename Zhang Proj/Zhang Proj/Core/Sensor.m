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
    NSLog(@"%@: Started collecting",self._name);
    _isCollecting = YES;
    return YES;
}

-(BOOL) stopCollecting
{
    NSLog(@"%@: Stopped collecting",self._name);
    _isCollecting = NO;
    return YES;
}

-(void) saveData:(NSString *)dataStr
{
    NSLog(@"%@: %@",self._name, dataStr);
    [self.dataTable setObject:dataStr forKey:[[NSDate alloc] init]];
}


@end
