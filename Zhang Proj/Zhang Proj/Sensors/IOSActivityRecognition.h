//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Sensor.h"
#import "IOSActivityRecognition.h"
#import <CoreMotion/CoreMotion.h>

/*
 *  Identify stationary, walking, running, biking, driving states using motion sensors 
 */
@interface IOSActivityRecognition : Sensor
@property NSString* lastUpdate;
@end
