//
//  SensorManager.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"

@interface DBManager ()

@property (nonatomic) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong,readwrite) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;
//@property (nonatomic,strong) NSURL* modelURL;
//@property (nonatomic,strong) NSURL* storeURL;

@end

@implementation DBManager


- (instancetype)initWithModel:(NSManagedObjectModel*)model coordinator:(NSPersistentStoreCoordinator*) coordinator andContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self) {
        _managedObjectModel = model;
        _managedObjectContext = context;
        _persistentStoreCoordinator = coordinator;
    }
    return self;
}

- (NSArray *) getDataForSensor:(NSString *)sensorName
{
    NSEntityDescription *sensor = [NSEntityDescription entityForName:@"SensorDataEntity" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:sensor];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", sensorName]];

    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        NSLog(@"Error fetching Sensor data: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}


- (void)deleteAllDataForSensor:(NSString*)sensorName
{
    NSEntityDescription *sensor = [NSEntityDescription entityForName:@"SensorDataEntity" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"SensorDataEntity"];
    [fetchRequest setEntity:sensor];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", sensorName]];
    
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchRequest];
    
    NSError *deleteError = nil;
    [_persistentStoreCoordinator executeRequest:delete withContext:_managedObjectContext error:&deleteError];
}

-(void) saveData:(NSDictionary*)data forSensor:(NSString*)sensorName
{
    //Initialize new row for MOC (Managed Object Context)
    SensorData *sensorData = [NSEntityDescription insertNewObjectForEntityForName:@"SensorDataEntity" inManagedObjectContext:_managedObjectContext];
    
    //Populate row
    for(NSDate* timeIndex in data)
    {
        NSLog(@"%@ %@",sensorName,[data objectForKey:timeIndex]);
        [sensorData setStateVal:[data objectForKey:timeIndex]];
        [sensorData setName:sensorName];
        [sensorData setTime:timeIndex];
    }
    
    //Save the data to the database
    NSError *error = nil;
    if ([_managedObjectContext save:&error] == NO)
    {
        NSAssert(NO, @"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

-(void)postData:(NSArray*)data forSensor:(NSString*)sensorName toURL:(NSURL*)dbServer
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = dbServer;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    NSMutableArray *sensorData = [[NSMutableArray alloc] init];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyy-MM-dd (HH:mm:ss)"];
    
    for(id obj in data)
    {
        
        NSString *timeStr =[timeFormat stringFromDate:[obj valueForKey:@"time"]];
        NSString *dataStr = [obj valueForKey:@"stateVal"];
        if((timeStr != nil) && (dataStr != nil))
        {
            [sensorData addObject: [[NSDictionary alloc] initWithObjectsAndKeys:
                                        timeStr, @"date",
                                        dataStr, @"data",
                                        nil]];
        }
    }
    jsonDict [@"userName"] =[[UIDevice currentDevice] name];
    userData [@"sensorName"] = sensorName;
    userData [@"sensorData"] = sensorData;
    jsonDict [@"userData"] = userData;
    
    /*
    for(id obj in data)
    {
        NSString *timeStr =[NSString stringWithFormat:@"%@",[obj valueForKey:@"time"]];
        NSString *dataStr = [obj valueForKey:@"stateVal"];
        if((timeStr != nil) && (dataStr != nil))
        {
            [jsonDict setValue:dataStr forKey:timeStr];
        }
    }
    */
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&error];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [self deleteAllDataForSensor:sensorName];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%@",response);
    }];
    
    [postDataTask resume];
    
}




@end
