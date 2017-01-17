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
        NSString *dataStr = [obj valueForKey:@"stateVal"];
        
        [ret insertObject:dataStr atIndex:dataIndex];
    }
    return ret;
}


@end
