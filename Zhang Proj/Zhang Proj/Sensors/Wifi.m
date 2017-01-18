//
//  Wifi.m
//  AWARE
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//
//http://www.heapoverflow.me/question-how-to-get-wifi-ssid-in-ios9-after-captivenetwork-is-depracted-and-calls-for-wif-31555640

#import "Sensor.h"
#import "Wifi.h"
#import "AppDelegate.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Wifi
{
    NSTimer * sensingTimer;
    double defaultInterval;
}


- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Wifi";
        self.dataTable = [[NSMutableDictionary alloc] init];
        defaultInterval = 60.0f; // 60sec. = 1min.
    }
    return self;
}


-(BOOL) startCollecting
{
    [super startCollecting];
    return [self startSensorWithInterval:defaultInterval];
}


-(BOOL) stopCollecting
{
    [super stopCollecting];
    if (sensingTimer != nil) {
        [sensingTimer invalidate];
        sensingTimer = nil;
    }
    return YES;
}


- (BOOL)startSensorWithInterval:(double) interval{
    // Set and start a data upload interval
    NSLog(@"[%@] Start Wifi Sensor", [self _name]);
    sensingTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                    target:self
                                                  selector:@selector(getWifiInfo)
                                                  userInfo:nil
                                                   repeats:YES];
    [self getWifiInfo];
    
    return YES;
}



///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////


- (BOOL) getWifiInfo
{
    //[self broadcastRequestScan];
    //[self broadcastScanStarted];
    
    
    bool ret = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSString *bssid = @"";
        NSString *ssid = @"";
        
        if (info[@"BSSID"]) {
            bssid = info[@"BSSID"];
        }
        if(info[@"SSID"]){
            ssid = info[@"SSID"];
        }
        
        NSMutableString *finalBSSID = [[NSMutableString alloc] init];
        NSArray *arrayOfBssid = [bssid componentsSeparatedByString:@":"];
        for(int i=0; i<arrayOfBssid.count; i++){
            NSString *element = [arrayOfBssid objectAtIndex:i];
            if(element.length == 1){
                [finalBSSID appendString:[NSString stringWithFormat:@"0%@:",element]];
            }else if(element.length == 2){
                [finalBSSID appendString:[NSString stringWithFormat:@"%@:",element]];
            }else{
            }
        }
        if (finalBSSID.length > 0) {
            [finalBSSID deleteCharactersInRange:NSMakeRange([finalBSSID length]-1, 1)];
        } else{
        }
        
        NSString* wifiString;
        if([self isWiFiEnabled])
        {
            wifiString = [NSString stringWithFormat:@"%@ (%@)",ssid, finalBSSID];
            ret = YES;
        }
        else
        {
            wifiString = [NSString stringWithFormat:@"Wifi module is powered off"];
            ret = NO;
        }
        [self saveData:wifiString];
        //[self broadcastDetectedNewDevice];
        
    }
    return ret;
}



///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

/*

- (void) broadcastDetectedNewDevice{
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_WIFI_NEW_DEVICE
                                                        object:nil
                                                      userInfo:nil];
}

- (void) broadcastScanStarted{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_WIFI_SCAN_STARTED
                                                        object:nil
                                                      userInfo:nil];
}

- (void) broadcastScanEnded{
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_WIFI_SCAN_ENDED
                                                        object:nil
                                                      userInfo:nil];
}

- (void) broadcastRequestScan{
    [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_WIFI_REQUEST_SCAN
                                                        object:nil
                                                      userInfo:nil];
}

*/


- (BOOL) isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    if(cset != nil)
        return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
    else
        return NO;
}

- (NSDictionary *) wifiDetails {
    return
    (__bridge NSDictionary *)
        CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex( CNCopySupportedInterfaces(), 0));
}


@end
