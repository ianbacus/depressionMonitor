//
//  Screen.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Screen.h"
#import "notify.h"

@implementation Screen {
    int _notifyTokenForDidChangeLockStatus;
    int _notifyTokenForDidChangeDisplayStatus;
}

- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Screen";
        self.dataTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    [self registerAppforDetectLockState];
    [self registerAppforDetectDisplayStatus];
    return YES;
}
-(BOOL) stopCollecting
{
    [super stopCollecting];
    uint32_t result = notify_cancel(_notifyTokenForDidChangeLockStatus);
    
    if (result == NOTIFY_STATUS_OK) {
        NSLog(@"[screen] OK --> %d", result);
    } else {
        NSLog(@"[screen] NO --> %d", result);
    }

    result = notify_cancel(_notifyTokenForDidChangeDisplayStatus);
    if (result == NOTIFY_STATUS_OK) {
        NSLog(@"[screen] OK ==> %d", result);
    } else {
        NSLog(@"[screen] NO ==> %d", result);
    }
    return YES;
}


/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l),
//dispatch_get_main_queue()
-(void)registerAppforDetectLockState {
    notify_register_dispatch("com.apple.springboard.lockcomplete", &_notifyTokenForDidChangeLockStatus,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l), ^(int token) {
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        NSString* screenStr = nil;
        
        if(state == 0)
        {
            screenStr = @"Unlocked";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZP_SCREEN_UNLOCKED" object:nil userInfo:nil];
        }
        else {
            screenStr = @"Locked";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZP_SCREEN_UNLOCKED" object:nil userInfo:nil];
        }
        
        [self saveData:screenStr];

    });
}

- (void) registerAppforDetectDisplayStatus {
    notify_register_dispatch("com.apple.iokit.hid.displayStatus", &_notifyTokenForDidChangeDisplayStatus,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0l), ^(int token) {
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        NSString* screenStr = nil;
        
        if(state == 0)
        {
            screenStr = @"Off";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZP_AWARE_SCREEN_OFF" object:nil userInfo:nil];
        }
        else
        {
            screenStr = @"On";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZP_AWARE_SCREEN_ON" object:nil userInfo:nil];
        }
        
        [self saveData:screenStr];
        
    });
}

-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        int screenVal = 0;
        if([[obj valueForKey:@"stateVal"] isEqualToString:@"Off"])
            screenVal = 0;
        else if([[obj valueForKey:@"stateVal"] isEqualToString:@"On"])
            screenVal = 1;
        else continue;
        
        NSNumber* screenState =  [[NSNumber alloc ] initWithInt:screenVal];
        NSDictionary *datum = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [obj valueForKey:@"time"],@"x",
                               screenState,@"y",
                               nil
                               ];
        [ret addObject:datum];
    }
    return ret;
}


@end
