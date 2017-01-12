//
//  AppMonitor.m
//  Zhang Proj
//
//  Created by Ian Bacus on 1/9/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/sysctl.h>
#import "AppMonitor.h"

@implementation AppMonitor
NSTimer* _dataCollectionTimer;

- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"AppMonitor";
        self.dataTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(listRunningProcesses) userInfo:nil repeats:YES];
    return YES;
}
-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    return YES;
}


- (void)listRunningProcesses {
    NSArray *ret = [[NSArray alloc] init];
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    u_int miblen = 4;
    size_t size;
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    
    do {
        size += size / 10;
        newprocess = realloc(process, size);
        
        if (!newprocess){
            if (process){
                free(process);
            }
            return;
        }
        
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0){
        if (size % sizeof(struct kinfo_proc) == 0){
            int nprocess = size / sizeof(struct kinfo_proc);
            
            if (nprocess){
                NSMutableArray * array = [[NSMutableArray alloc] init];
                for (int i = nprocess - 1; i >= 0; i--){
                    NSString * processID   = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    NSDictionary * dict    = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName, nil]
                                                                           forKeys:[NSArray arrayWithObjects:@"PID", @"PName", nil]];
                    [array addObject:dict];
                }
                
                free(process);
                ret = array;
            }
        }
    }
    
    ret = nil;
    NSString *appsString = [[ret valueForKey:@"description"] componentsJoinedByString:@""];
    [self saveData:appsString];
}


@end
