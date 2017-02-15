//
//  SensorData.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CoreData/CoreData.h"


#ifndef SensorData__h
#define SensorData__h

@interface SensorData : NSManagedObject

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *stateVal;

@end


#endif

/*
 Entries for all sensors go to the same model. The sensors' data are differentiated by their name.
 Data is stored as a string with an arbitrary format, each sensor defines methods that convert their values to numeric formats for processing and displaying on a graph
 
 name: Activity
 stateVal: activity event with confidence (stationary, walking, running, ...)
 
 name: Ambient Light
 stateVal: screen brightness(0.00 to 1.00)
 
 name: Ambient Noise
 stateVal:  decibels
 
 name: Battery
 stateVal: battery remaining (0.00 to 1.00)
 
 name: Screen
 stateVal: screenChange (on,off)
 
 name: Social
 stateVal: call event (connected, disconnected, calling, receiving call)
 
 name: Location
 stateVal: location state (latitude,longitude,accuracy)
 
 name: Wifi
 stateVal: SSID, BSSID, or connection state
 
 
 */

