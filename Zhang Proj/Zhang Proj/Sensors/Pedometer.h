//
//  Pedometer.h
//  Zhang Proj
//
//  Created by Ian Bacus on 1/3/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//
#import "Sensor.h"
#import "CoreMotion/CoreMotion.h"


#ifndef Pedometer_h
#define Pedometer_h

/*
 *  Capture steps in the background. Request the number of steps over some time interval
 */
@interface Pedometer : Sensor

@end


#endif /* Pedometer_h */
