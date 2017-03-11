//
//  SensorManager.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"
#define DATA_LEN_MAX 200000000
@interface DBManager ()

@property int networkThreads;
@property (nonatomic) NSManagedObjectModel* managedObjectModel;
@property (nonatomic) NSURL* remoteURL;
@property (nonatomic,strong,readwrite) NSManagedObjectContext* managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end

@implementation DBManager


- (instancetype)initWithModel:(NSManagedObjectModel*)model remoteURL:(NSURL*)dbURL coordinator:(NSPersistentStoreCoordinator*) coordinator andContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self)
    {
        _networkThreads = 0;
        _remoteURL = dbURL;
        _managedObjectModel = model;
        _managedObjectContext = context;
        _persistentStoreCoordinator = coordinator;
    }
    [self reportFileSizeOfPersistentStores];
    return self;
}

/*
 *  Query the Core Data database for all entries associated with a given sensor by its name
 */
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

/*
 *  Determine the size (in bytes) of the Core Data store
 */
- (void)reportFileSizeOfPersistentStores
{
    NSArray *allStores = self.persistentStoreCoordinator.persistentStores;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for (NSPersistentStore *store in allStores)
    {
        NSString *filePath = store.URL.path;
        NSString* waljournal = [filePath stringByAppendingString :@"-wal"];
        NSString* shmjournal = [filePath stringByAppendingString :@"-shm"];
        NSDictionary *SQLiteAttrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        NSDictionary *WALAttrs = [fileManager attributesOfItemAtPath:waljournal error:nil];
        NSDictionary *SHMAttrs = [fileManager attributesOfItemAtPath:shmjournal error:nil];
        
        double fileSize = [SQLiteAttrs[NSFileSize] doubleValue] + [WALAttrs[NSFileSize] doubleValue] + [SHMAttrs[NSFileSize] doubleValue];
        NSLog(@"FileSize:%f", fileSize);
    }
}


/*
 *  Query all entries associated with a sensor by its name, captured between two time points
 */
- (NSArray *) getDataForSensor:(NSString *)sensorName fromStartDate:(NSDate*)startDate toEndDate:(NSDate*)endDate
{
    //Fetch from database for all data after start date (for a sensor)
    NSEntityDescription *sensor = [NSEntityDescription entityForName:@"SensorDataEntity" inManagedObjectContext:_managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:sensor];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (time >= %@) AND (time <= %@)",
                                sensorName, startDate, endDate]];
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        NSLog(@"Error fetching Sensor data: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return results;
}

/*
 *  Remove all entries associated with a sensor, given by its name
 */
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

/*
 *  Save a dictionary of entries { {Date:String}, ...} to the Core Data database for a sensor, specified by name
 */
-(void) saveData:(NSDictionary*)data forSensor:(NSString*)sensorName
{
    //Initialize new row for MOC (Managed Object Context)
    SensorData *sensorData = [NSEntityDescription insertNewObjectForEntityForName:@"SensorDataEntity" inManagedObjectContext:_managedObjectContext];
    
    //Populate row
    for(NSDate* timeIndex in data)
    {
        //NSLog(@"%@ %@",sensorName,[data objectForKey:timeIndex]);
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

/*
 *  Dispatch a network thread to send sensor data to the URL specified in the DBManager's constructor
 */
-(void)postData:(NSArray*)data forSensor:(NSString*)sensorName
{
    bool dataAvailable = YES;
    int dataIndex = 0;
    int dataLen = 0;
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    NSMutableArray *sensorData = [[NSMutableArray alloc] init];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"yyyy-MM-dd (HH:mm:ss)"];
    
    //Updated to use sensor-formatted data
    jsonDict [@"userName"] =[[UIDevice currentDevice] name];
    userData [@"sensorName"] = sensorName;
    userData [@"sensorData"] = data;
    jsonDict [@"userData"] = userData;
    while(_networkThreads > 5) {}
    _networkThreads += 1;
    [self uploadData:jsonDict];

    /*
    while(dataAvailable)
    {
        for(dataIndex=dataIndex;dataIndex<[data count]; dataIndex++)
        {
            id obj = [data objectAtIndex:dataIndex];
            if(dataLen > DATA_LEN_MAX)
            {
                break;
            }
            
            NSString *timeStr =[timeFormat stringFromDate:[obj valueForKey:@"time"]];
            NSString *dataStr = [obj valueForKey:@"stateVal"];
            dataLen += [dataStr length];
            if((timeStr != nil) && (dataStr != nil))
            {
                [sensorData addObject: [[NSDictionary alloc] initWithObjectsAndKeys:
                                            timeStr, @"date",
                                            dataStr, @"data",
                                            nil]];
            }
        }
        if(dataIndex >= [data count])
            dataAvailable = NO;
        jsonDict [@"userName"] =[[UIDevice currentDevice] name];
        userData [@"sensorName"] = sensorName;
        userData [@"sensorData"] = data;
        jsonDict [@"userData"] = userData;
        while(_networkThreads > 5) {}
        _networkThreads += 1;
        [self uploadData:jsonDict];
    }
     */
    //[self deleteAllDataForSensor:sensorName];
}


/*
 *  Serialize JSON data and send it to server
 */
-(void) uploadData:(NSDictionary *)postJSON
{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_remoteURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postJSON options:0 error:&error];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        _networkThreads -=1;
        if(error == nil)
        {
            NSLog(@"No post error");
            
        }
        else NSLog(@"Post error...");
    
    }];
    
    [postDataTask resume];
}




@end
