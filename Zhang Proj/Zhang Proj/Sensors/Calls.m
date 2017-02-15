//
//  Calls.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Calls.h"
#import "AppDelegate.h"


@implementation Calls {
    NSDate * start;
}

-(instancetype) initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Calls";
        _callCenter = [[CTCallCenter alloc] init];
        self.dataTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    
    // Set and start a call sensor
    
    _callCenter.callEventHandler = ^(CTCall* call){
        NSString * callId = call.callID;
        if (callId == nil) callId = @"";
        NSNumber * callType = @0;
        NSString * callTypeStr = @"Unknown";
        int duration = 0;
        if (start == nil) start = [NSDate new];
        
        // one of the Android’s call types (1 – incoming, 2 – outgoing, 3 – missed)
        if (call.callState == CTCallStateIncoming) {
            // start
            callType = @1;
            //start = [NSDate new];
            callTypeStr = @"Incoming";
        } else if (call.callState == CTCallStateConnected){
            callType = @2;
            //duration = [[NSDate new] timeIntervalSinceDate:start];
            //start = [NSDate new];
            callTypeStr = @"Connected";
        } else if (call.callState == CTCallStateDialing){
            // start
            callType = @3;
            //start = [NSDate new];
            callTypeStr = @"Dialing";
        } else if (call.callState == CTCallStateDisconnected){
            // fin
            callType = @4;
            callTypeStr = @"Disconnected";
            //duration = [[NSDate new] timeIntervalSinceDate:start];
            //start = [NSDate new];
        }
        
        NSLog(@"Call Duration is %d seconds @ [%@]", duration, callTypeStr);
       
        [self saveData:callTypeStr];
        
    };
    return YES;
}

-(BOOL) changeCollectionInterval:(double)interval
{
    [super changeCollectionInterval:interval];
    return YES;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    _callCenter.callEventHandler = nil;
    return YES;
}


-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        //"containsString" only supported after iOS7
        
        int callVal ;
        if([[obj valueForKey:@"stateVal"] isEqualToString:@"Incoming"])
            callVal = 1;
        else if([[obj valueForKey:@"stateVal"] isEqualToString:@"Connected"])
            callVal = 3;
        else if([[obj valueForKey:@"stateVal"] isEqualToString:@"Dialing"])
            callVal = 2;
        else if([[obj valueForKey:@"stateVal"] isEqualToString:@"Disconnected"])
            callVal = 0;
        else continue;
        
        NSNumber* callNum =  [[NSNumber alloc ] initWithInt:callVal];
        NSDictionary *datum = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [obj valueForKey:@"time"],@"x",
                               callNum,@"y",
                               nil
                               ];
        [ret addObject:datum ];
    }
    return ret;
}


@end
