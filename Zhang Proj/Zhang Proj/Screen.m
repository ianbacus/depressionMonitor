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
        //assert(super.dataTable
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

-(BOOL) getStatus
{
    return YES;
}




/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////


-(void)registerAppforDetectLockState {
    notify_register_dispatch("com.apple.springboard.lockstate", &_notifyTokenForDidChangeLockStatus,dispatch_get_main_queue(), ^(int token) {
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        
        NSString* screenStr = nil;
        
        if(state == 0)
        {
            //3?
            NSLog(@"screen unlocked");
            screenStr = @"Unlocked";
            //[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_SCREEN_UNLOCKED object:nil userInfo:nil];
        }
        else {
            //2?
            NSLog(@"screen locked");
            screenStr = @"Locked";
        }
        
        [self.dataTable setObject:screenStr forKey:[NSDate date]];

    });
}

- (void) registerAppforDetectDisplayStatus {
    notify_register_dispatch("com.apple.iokit.hid.displayStatus", &_notifyTokenForDidChangeDisplayStatus,dispatch_get_main_queue(), ^(int token) {
        
        uint64_t state = UINT64_MAX;
        notify_get_state(token, &state);
        NSString* screenStr = nil;
        
        if(state == 0)
        {
            NSLog(@"screen off");
            screenStr = @"Off";
            //[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_SCREEN_OFF object:nil userInfo:nil];
        }
        else
        {
            NSLog(@"screen on");
            screenStr = @"On";
            //[[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_SCREEN_ON object:nil userInfo:nil];
        }
        
        [self.dataTable setObject:screenStr forKey:[NSDate date]];
        
    });
}


@end
