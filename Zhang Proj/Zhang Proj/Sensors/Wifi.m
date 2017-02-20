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



- (instancetype)initSensor
{
    self = [super init];
    if (self) {
        self._name = @"Wifi";
        self.dataTable = [[NSMutableDictionary alloc] init];
        self.samplingInterval = 20.0f;
    }
    return self;
}


-(BOOL) startCollecting
{
    [super startCollecting];
    return [self startCollectingAtInterval:self.samplingInterval];
}


- (BOOL)startCollectingAtInterval:(double) interval{
    // Set and start a data upload interval
    [super startCollecting];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                            target:self
                                                          selector:@selector(collectWifiInfo)
                                                          userInfo:nil
                                                           repeats:YES];
    [self getWifiInfo];
    
    return YES;
}

-(BOOL) changeCollectionInterval:(double)interval
{
    [super changeCollectionInterval:interval];
    if([self isCollecting])
    {
        [self stopCollecting];
        [self startCollectingAtInterval:interval];
    }
    return YES;
}


-(BOOL) stopCollecting
{
    [super stopCollecting];
    if (_dataCollectionTimer != nil) {
        [_dataCollectionTimer invalidate];
        _dataCollectionTimer = nil;
    }
    return YES;
}

- (BOOL) getWifiInfo
{
    
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
        
    }
    return ret;
}

-(BOOL) collectWifiInfo
{
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
    }
    return ret;
}




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
