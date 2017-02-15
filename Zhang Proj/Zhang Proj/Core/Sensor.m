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

@synthesize _name = __name;
@synthesize isCollecting = _isCollecting;

-(instancetype) initSensor
{
    self = [super init];
    return self;
}

/*
 *  Empty the temporary, local storage for this sensor
 */
-(NSDictionary *) flushData
{
    NSDictionary * retDict = [[NSDictionary alloc] initWithDictionary:_dataTable copyItems:YES];
    [_dataTable removeAllObjects];
    return retDict;
}

/*
 *  Store data to local, temporary storage
 */
-(void) saveData:(NSString *)dataStr
{
    
    [self.dataTable setObject:dataStr forKey:[[NSDate alloc] init]];
}

/*
 *  Determine if local data store has any entries
 */
-(BOOL) hasData
{
    if([self.dataTable count] > 0)
        return YES;
    else
        return NO;
}

/*
 *  Change sampling frequency. Not called in child classes that do not allow sample interval configuration
 */
-(BOOL) changeCollectionInterval:(double)interval
{
    _samplingInterval = interval;
    return YES;
    
}

/*
 *  Set sampling frequency, set flag indicating sensor is collecting
 */
-(BOOL) startCollectingAtInterval:(double)interval
{
    _samplingInterval = interval;
    _isCollecting = YES;
    return YES;
}

/*
 *  Set flag indicating sensor is collecting
 */
-(BOOL) startCollecting
{
    NSLog(@"%@: Started collecting",self._name);
    _isCollecting = YES;
    return YES;
}

/*
 *  Clear flag indicating sensor is collecting
 */
-(BOOL) stopCollecting
{
    NSLog(@"%@: Stopped collecting",self._name);
    _isCollecting = NO;
    return YES;
}



@end
