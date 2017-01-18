//
//  Pedometer.m
//  Zhang Proj
//
//  Created by Ian Bacus on 1/3/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pedometer.h"

@implementation Pedometer
{
    CMPedometer* _pedoMeter;
}


-(instancetype) initSensor
{
    self = [super init];
    if(self)
    {
        self._name = @"Pedometer";
        if (!_pedoMeter) {
            _pedoMeter = [[CMPedometer alloc]init];
        }
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    // start live tracking
    [_pedoMeter startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error)
    {
        NSString* stepsStr = [self formatPedometerData:pedometerData];
        [self saveData:stepsStr];
    }];
    return YES;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_pedoMeter stopPedometerUpdates];
    return YES;
}

-(NSString* ) formatPedometerData:(CMPedometerData * _Nullable) pedometerData
{
    NSString* stepsStr = [[NSString alloc] init];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.maximumFractionDigits = 2;
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Steps walked: %@", [formatter stringFromNumber:pedometerData.numberOfSteps]]];
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Distance travelled: \n%@ meters", [formatter stringFromNumber:pedometerData.distance]] ];
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Current Pace: \n%@ seconds per meter", [formatter stringFromNumber:pedometerData.currentPace]] ];
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Cadence: \n%@ steps per second", [formatter stringFromNumber: pedometerData.currentCadence]] ];
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Floors ascended: %@", pedometerData.floorsAscended] ];
    stepsStr = [stepsStr stringByAppendingString:
                [NSString stringWithFormat:@"Floors descended: %@", pedometerData.floorsDescended] ];
    return stepsStr;
}

-(BOOL) queryPedometerFromDate:(NSDate*)startDate toDate:(NSDate*)endDate
{
    // retrieve data between dates
    [_pedoMeter queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        
        // historic pedometer data is provided here
        [self formatPedometerData:pedometerData];
        
    }];
    return YES;
}



    
    
@end
