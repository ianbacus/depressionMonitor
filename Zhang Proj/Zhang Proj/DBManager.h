//
//  DBManager.h
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SensorData.h"


@interface DBManager : NSObject

- (void) saveData:(NSDictionary*)data forSensor:(NSString*)sensorName;
- (NSArray *) getDataForSensor :(NSString*)sensorName;
- (instancetype)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL;
- (instancetype)initWithModel:(NSManagedObjectModel*)model andContext:(NSManagedObjectContext*)context;


@property (nonatomic,strong,readonly) NSManagedObjectContext* managedObjectContext;


@end
