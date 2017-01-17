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
#import <UIKit/UIKit.h>

#import <sys/sysctl.h>
#import <dlfcn.h>

@implementation AppMonitor
NSTimer* _dataCollectionTimer;

- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"AppMonitor";
        self.dataTable = [[NSMutableDictionary alloc] init];
        
        int ret;
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t size = sizeof(mib)/sizeof(mib[0]);
        u_int miblen = 4;
        mib[0] = CTL_KERN;
        mib[1] = KERN_PROC;
        mib[2] = KERN_PROC_ALL;
        mib[3] = 0;
        ret = sysctl(mib, 4, NULL, &size, NULL, 0);
        int *procs = malloc(size);
        ret = sysctl(mib, 4, procs, &size, NULL, 0); /* procs is struct kinfo_proc.*/
        
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
/*

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
*/

//// TRY 2

#define UIKITPATH "/System/Library/Framework/UIKit.framework/UIKit"
#define SBSERVPATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"

- (NSArray*) listRunningProcesses
{
    mach_port_t *p;
    void *uikit = dlopen(UIKITPATH,
                         RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() =
    dlsym(uikit, "SBSSpringBoardServerPort");
    p = (mach_port_t *)SBSSpringBoardServerPort();
    dlclose(uikit);
    
    if(self.frameWorkPath == nil || self.frameWorkPath.length == 0)
    {
        self.frameWorkPath = @SBSERVPATH;
        self.frameWorkPath = [self.frameWorkPath stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    
    const char *cString = [self.frameWorkPath cStringUsingEncoding:NSUTF8StringEncoding];
    //const char *bar = [self.frameWorkPath UTF8String];
    void *sbserv = dlopen(cString, RTLD_LAZY);
    NSArray* (*SBSCopyApplicationDisplayIdentifiers)(mach_port_t* port, BOOL runningApps,BOOL debuggable) =
    dlsym(sbserv, "SBSCopyApplicationDisplayIdentifiers");
    //SBDisplayIdentifierForPID - protype assumed,verification of params done
    void* (*SBDisplayIdentifierForPID)(mach_port_t* port, int pid,char * result) =
    dlsym(sbserv, "SBDisplayIdentifierForPID");
    //SBFrontmostApplicationDisplayIdentifier - prototype assumed,verification of params done,don't call this TOO often(every second on iPod touch 4G is 'too often,every 5 seconds is not)
    void* (*SBFrontmostApplicationDisplayIdentifier)(mach_port_t* port,char * result) =
    dlsym(sbserv, "SBFrontmostApplicationDisplayIdentifier");
    
    
    
    //Get frontmost application
    char frontmostAppS[512];
    memset(frontmostAppS,sizeof(frontmostAppS),0);
    SBFrontmostApplicationDisplayIdentifier(p,frontmostAppS);
    NSString * frontmostApp=[NSString stringWithFormat:@"%s",frontmostAppS];
    
    float currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (currentVersion >= 9.0) {
        NSNumber *topmost = [NSNumber numberWithBool:YES];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        NSMutableArray  * splitted = [frontmostApp componentsSeparatedByString:@"."];
        if(frontmostApp.length > 0 && splitted != nil && splitted.count > 1 && topmost.boolValue == YES){
            NSString *appname = [splitted lastObject];
            [dict setObject:[appname capitalizedString] forKey:@"ProcessName"];
            [dict setObject:frontmostApp forKey:@"ProcessID"];
            [dict setObject:frontmostApp forKey:@"AppID"];
            [dict setObject:topmost forKey:@"isFrontmost"];
            NSLog(@"Running TOPMOST App %@",dict);
            return @[dict];
        }
        else{
            //return nil;
        }
    }
    //NSLog(@"Frontmost app is %@",frontmostApp);
    //get list of running apps from SpringBoard
    NSArray *allApplications = SBSCopyApplicationDisplayIdentifiers(p,NO, NO);
    //Really returns ACTIVE applications(from multitasking bar)
    NSLog(@"Active applications:");
    for(NSString *identifier in allApplications) {
        // NSString * locName=SBSCopyLocalizedApplicationNameForDisplayIdentifier(p,identifier);
        NSLog(@"Active Application:%@",identifier);
    }
    
    
    //get list of all apps from kernel
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t miblen = 4;
    
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
            
            return nil;
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
                    
                    int ruid=process[i].kp_eproc.e_pcred.p_ruid;
                    int uid=process[i].kp_eproc.e_ucred.cr_uid;
                    //short int nice=process[i].kp_proc.p_nice;
                    //short int u_prio=process[i].kp_proc.p_usrpri;
                    short int prio=process[i].kp_proc.p_priority;
                    NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                    
                    
                    BOOL systemProcess=YES;
                    if (ruid==501){
                        systemProcess=NO;
                    }
                    
                    
                    char * appid[256];
                    memset(appid,sizeof(appid),0);
                    int intID,intID2;
                    intID=process[i].kp_proc.p_pid,appid;
                    SBDisplayIdentifierForPID(p,intID,appid);
                    
                    NSString * appId=[NSString stringWithFormat:@"%s",appid];
                    
                    if (systemProcess==NO)
                    {
                        if ([appId isEqualToString:@""])
                        {
                            //final check.if no appid this is not springboard app
                            //NSLog(@"(potentially system)Found process with PID:%@ name %@,isSystem:%d,Priority:%d",processID,processName,systemProcess,prio);
                        }
                        else
                        {
                            
                            BOOL isFrontmost=NO;
                            if ([frontmostApp isEqualToString:appId])
                            {
                                isFrontmost=YES;
                            }
                            NSNumber *isFrontmostN=[NSNumber numberWithBool:isFrontmost];
                            NSDictionary * dict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:processID, processName,appId,isFrontmostN, nil] 
                                                                                forKeys:[NSArray arrayWithObjects:@"ProcessID", @"ProcessName",@"AppID",@"isFrontmost", nil]];
                            NSLog(@"PID:%@, name: %@, AppID:%@,isFrontmost:%d",processID,processName,appId,isFrontmost);
                            [array addObject:dict];
                        }
                    }
                }
                
                free(process);
                return array;
            }
        }
    }
    
    dlclose(sbserv);
    return nil;
}

///

@end
