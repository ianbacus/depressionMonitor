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
 
 Activity
 - time:activityChange (stationary, walking, running, ...)
 
 Screen
 - time:screenChange (on,off)
 
 Social:
 - time:callState (started, ended)
 
 Location
 - time:locationState (gps location)
 
 Face
 - time:emotionState (happy, sad)
 
 
 */

