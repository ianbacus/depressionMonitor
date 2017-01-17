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

@property NSDateFormatter* timeFormat;
@property NSString* _name;
@property NSMutableDictionary *dataTable;
@property BOOL isCollecting;

-(NSArray*) createDataSetFromDBData:(NSArray*)dbData;
-(instancetype) initSensor;
-(NSDictionary*) flushData;
-(BOOL) startCollecting;
-(BOOL) stopCollecting;
-(BOOL) getStatus;
-(BOOL) hasData;
-(void) saveData:(NSString *)dataStr;

@end




#endif /* Sensor_h */
