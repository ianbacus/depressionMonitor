//
//  DBManager.m
//  SQLite3DBSample
//
//  Created by Gabriel Theodoropoulos on 25/6/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "DBManager.h"
#import "AppDelegate.h"

@interface DBManager ()

@property (nonatomic) NSManagedObjectModel* managedObjectModel;
@property (nonatomic,strong,readwrite) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSURL* modelURL;
@property (nonatomic,strong) NSURL* storeURL;

@end

@implementation DBManager

- (instancetype)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
{
    self = [super init];
    if (self) {
        _storeURL = storeURL;
        _modelURL = modelURL;
        //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        //[self setupManagedObjectContext];
    }
    return self;
}

- (instancetype)initWithModel:(NSManagedObjectModel*)model andContext:(NSManagedObjectContext*)context
{
    self = [super init];
    if (self) {
        _managedObjectModel = model;
        _managedObjectContext = context;
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

/*
- (void)setupManagedObjectContext
{
    self.managedObjectContext =
    [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSError* error;
    [self.managedObjectContext.persistentStoreCoordinator
     addPersistentStoreWithType:NSSQLiteStoreType
     configuration:nil
     URL:self.storeURL
     options:nil
     error:&error];
    if (error) {
        NSLog(@"error: %@", error);
    }
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}
*/
/*
- (NSManagedObjectModel*)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}
*/
/*
- (void)initializeCoreData
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}
 */

@end
