//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "Sensor.h"
#import "UIKit/UIKit.h"


/*
 *  Reads user screen brightness to estimate ambient light
 */
@interface AmbientLight : Sensor

@property NSTimer* dataCollectionTimer;

@end
