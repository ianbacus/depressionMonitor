//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import "IOSActivityRecognition.h"

@implementation IOSActivityRecognition {
    CMMotionActivityManager *motionActivityManager;
    CMMotionActivityConfidence confidenceFilter;
}

-(instancetype) initSensor
{
    self = [super init];
    if(self)
    {
        _lastUpdate = nil;
        self.dataTable = [[NSMutableDictionary alloc] init];
        self._name = @"Activity";
        if([CMMotionActivityManager isActivityAvailable])
            motionActivityManager = [[CMMotionActivityManager alloc] init];
        
        
        confidenceFilter = CMMotionActivityConfidenceLow;
    }
    return self;
}

- (BOOL) performConfidenceFiltering :(CMMotionActivity *) motionActivity
{
    //Set minimum allowable accuracy
    switch (confidenceFilter) {
        case CMMotionActivityConfidenceHigh:
            if(motionActivity.confidence == CMMotionActivityConfidenceMedium ||
               motionActivity.confidence == CMMotionActivityConfidenceLow){
                return NO;
            }
            break;
        case CMMotionActivityConfidenceMedium:
            if(motionActivity.confidence == CMMotionActivityConfidenceLow){
                return NO;
            }
            break;
        case CMMotionActivityConfidenceLow:
            break;
        default:
            break;
    }
    return YES;
}

- (void) addMotionActivity: (CMMotionActivity *) motionActivity{
    
    if(![self performConfidenceFiltering:motionActivity]) return;
    //0: low confidence, 2: high confidence
    NSMutableString* activityStr = nil;
    switch(motionActivity.confidence)
    {
        case CMMotionActivityConfidenceLow:
            activityStr = [NSMutableString stringWithString:@"0"]; //9
            break;
        case CMMotionActivityConfidenceHigh:
            activityStr =  [NSMutableString stringWithString:@"1"]; //11
            break;
        case CMMotionActivityConfidenceMedium:
            activityStr = [NSMutableString stringWithString:@"2"]; //8
            break;
    }
    if (motionActivity.unknown)
        [activityStr appendString:@"Unknown"];
    else if (motionActivity.stationary)
        [activityStr appendString:@"Stationary"];
    else if (motionActivity.running)
        [activityStr appendString:@"Running"];
    else if (motionActivity.walking)
        [activityStr appendString:@"Walking"];
    else if (motionActivity.automotive)
        [activityStr appendString:@"Driving"];
    else if (motionActivity.cycling)
        [activityStr appendString:@"Cycling"];
    else
        activityStr = nil;
    
    if(activityStr != nil && activityStr != _lastUpdate)
    {
        _lastUpdate = activityStr;
        [self saveData:activityStr];
    }
    
}


-(BOOL) startCollecting
{
    [super startCollecting];
    /*
    //motionActivityManager = [CMMotionActivityManager new];
    [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue new]
       withHandler:^(CMMotionActivity *activity) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [self addMotionActivity:activity];
           });
       }];*/
    
    //
    CMMotionActivityHandler motionActivityHandler = ^(CMMotionActivity *activity)
    {
         [self addMotionActivity:activity];
    };
    
    if (motionActivityManager) {
        [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:motionActivityHandler];
    }
    
    
    return YES;
}

-(BOOL) changeCollectionInterval:(double)interval
{
    [super changeCollectionInterval:interval];
    return NO;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [motionActivityManager stopActivityUpdates];
    //motionActivityManager = nil;
    return YES;
}


/*
 *  Enumerate activity states, store [time,enum] pairs
 */
-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        //"containsString" only supported after iOS7
        
        int activityVal = 0;
        if([[obj valueForKey:@"stateVal"] containsString:@"Stationary"])
            activityVal = 0;
        else if([[obj valueForKey:@"stateVal"] containsString:@"Walking"])
            activityVal = 1;
        else if([[obj valueForKey:@"stateVal"] containsString:@"Running"])
            activityVal = 2;
        else if([[obj valueForKey:@"stateVal"] containsString:@"Cycling"])
            activityVal = 3;
        else if([[obj valueForKey:@"stateVal"] containsString:@"Driving"])
            activityVal = 4;
        else continue;
        
        NSNumber* activtyNum =  [[NSNumber alloc ] initWithInt:activityVal];
        NSDictionary *datum = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [obj valueForKey:@"time"],@"x",
                               activtyNum,@"y",
                               nil
                               ];
        [ret addObject:datum ];
    }
    return ret;
}

@end
