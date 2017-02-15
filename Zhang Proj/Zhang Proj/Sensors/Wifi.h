//
//  Wifi.h
//  AWARE
//
//  Created by Yuuki Nishiyama on 11/20/15.
//  Copyright © 2015 Yuuki NISHIYAMA. All rights reserved.
//

#import "Sensor.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>

extern NSString* const AWARE_PREFERENCES_STATUS_WIFI;
extern NSString* const AWARE_PREFERENCES_FREQUENCY_WIFI;

@interface Wifi : Sensor

@property NSTimer* dataCollectionTimer;
- (BOOL) getWifiInfo;
@end
