//
//  Sensor.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef Sensor_h
#define Sensor_h


@interface Sensor : NSObject
{
    
}

@property NSString* name;

-(instancetype) initSensor;
-(BOOL) initTable;
-(BOOL) startCollecting;
-(BOOL) stopCollecting;
-(BOOL) getStatus;

@end




#endif /* Sensor_h */
