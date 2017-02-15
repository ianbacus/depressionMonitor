//
//  Battery.h
//  Zhang Proj
//
//  Created by Ian Bacus on 1/26/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//

#ifndef Battery_h
#define Battery_h

#import <UIKit/UIKit.h>
#import "Sensor.h"

@interface Battery : Sensor

@property NSTimer* dataCollectionTimer;

@end

#endif /* Battery_h */
