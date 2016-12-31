//
//  IOSActivityRecognition.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 9/19/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
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
            activityStr = [NSMutableString stringWithString:@"Could be "];
            break;
        case CMMotionActivityConfidenceHigh:
            activityStr =  [NSMutableString stringWithString:@"Definitely "];
            break;
        case CMMotionActivityConfidenceMedium:
            activityStr = [NSMutableString stringWithString:@"Probably "];
            break;
    }
    
    if (motionActivity.unknown)
        [activityStr appendString:@"Unknown"];
    if (motionActivity.stationary)
        [activityStr appendString:@"Stationary"];
    if (motionActivity.running)
        [activityStr appendString:@"Running"];
    if (motionActivity.walking)
        [activityStr appendString:@"Walking"];
    if (motionActivity.automotive)
        [activityStr appendString:@"Driving"];
    if (motionActivity.cycling)
        [activityStr appendString:@"Cycling"];
    
    if(activityStr != nil)
    {
        [self.dataTable setObject:activityStr forKey:[NSDate date]];
        NSLog(@"%@", activityStr);
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

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [motionActivityManager stopActivityUpdates];
    motionActivityManager = nil;
    return YES;
}


@end
