//
//  SensorManager.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SensorData.h"


@interface DBManager : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* managedObjectContext;

- (instancetype)initWithModel:(NSManagedObjectModel*)model remoteURL:(NSURL*)dbURL coordinator:(NSPersistentStoreCoordinator*) coordinator andContext:(NSManagedObjectContext*)context;

- (void) saveData:(NSDictionary*)data forSensor:(NSString*)sensorName;
- (NSArray *) getDataForSensor :(NSString*)sensorName;
- (NSArray *) getDataForSensor:(NSString *)sensorName fromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate;
- (void)postData:(NSArray*)data forSensor:(NSString*)sensorName;
- (void)deleteAllDataForSensor:(NSString*)sensor;



@end

@interface DBManager() <NSURLSessionDelegate>;
@end


