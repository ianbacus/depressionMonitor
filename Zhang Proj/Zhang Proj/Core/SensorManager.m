//
//  SensorManager.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/22/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensorManager.h"



@implementation SensorManager

- (NSDate *) getTargetNSDate:(NSDate *) nsDate
                        hour:(int) hour
                      minute:(int) minute
                      second:(int) second
                     nextDay:(BOOL)nextDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear   |
                                   NSCalendarUnitMonth  |
                                   NSCalendarUnitDay    |
                                   NSCalendarUnitHour   |
                                   NSCalendarUnitMinute |
                                   NSCalendarUnitSecond
                                              fromDate:nsDate];
    [dateComps setDay:dateComps.day];
    [dateComps setHour:hour];
    [dateComps setMinute:minute];
    [dateComps setSecond:second];
    NSDate * targetNSDate = [calendar dateFromComponents:dateComps];
    //    return targetNSDate;
    
    if (nextDay) {
        if ([targetNSDate timeIntervalSince1970] < [nsDate timeIntervalSince1970]) {
            [dateComps setDay:dateComps.day + 1];
            NSDate * tomorrowNSDate = [calendar dateFromComponents:dateComps];
            return tomorrowNSDate;
        }else{
            return targetNSDate;
        }
    }else{
        return targetNSDate;
    }
}


- (void) activate {
    [self deactivate];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    /*
    /// Set defualt settings
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults boolForKey:@"aware_inited"]) {
        [userDefaults setBool:NO forKey:SETTING_DEBUG_STATE];                 // Default Value: NO
        [userDefaults setBool:YES forKey:SETTING_SYNC_WIFI_ONLY];             // Default Value: YES
        [userDefaults setBool:YES forKey:SETTING_SYNC_BATTERY_CHARGING_ONLY]; // Default Value: YES
        [userDefaults setDouble:60*15 forKey:SETTING_SYNC_INT];               // Default Value: 60*15 (sec)
        [userDefaults setBool:NO forKey:KEY_APP_TERMINATED];                  // Default Value: NO
        [userDefaults setInteger:0 forKey:KEY_UPLOAD_MARK];                   // Defualt Value: 0
        [userDefaults setInteger:1000 * 1000 forKey:KEY_MAX_DATA_SIZE];        // Defualt Value: 1000*1000 (byte) (1000 KB)
        [userDefaults setInteger:cleanOldDataTypeAlways forKey:SETTING_FREQUENCY_CLEAN_OLD_DATA];
        [userDefaults setBool:YES forKey:@"aware_inited"];
    }
    if (![userDefaults boolForKey:@"aware_inited_1.8.2"]) {
        [userDefaults setInteger:10000 forKey:KEY_MAX_FETCH_SIZE_MOTION_SENSOR];        // Defualt Value: 10000
        [userDefaults setInteger:10000 forKey:KEY_MAX_FETCH_SIZE_NORMAL_SENSOR];         // Defualt Value: 10000
        [userDefaults setBool:YES forKey:@"aware_inited_1.8.2"];
    }
    
    if([userDefaults integerForKey:SETTING_DB_TYPE] == AwareDBTypeUnknown){
        [userDefaults setInteger:AwareDBTypeTextFile forKey:SETTING_DB_TYPE];
    }
    
    double uploadInterval = [userDefaults doubleForKey:SETTING_SYNC_INT];
    
    */
    /**
     * Start a location sensor for background sensing.
     * On the iOS, we have to turn on the location sensor
     * for using application in the background.
     */
    
    [self initLocationSensor];
    
    // start sensors
//[_sharedSensorManager startAllSensors];
//[_sharedSensorManager startUploadTimerWithInterval:uploadInterval];
    //    [self.sharedSensorManager syncAllSensorsWithDBInBackground];
    
    /// Set a timer for a daily sync update
    /**
     * Every 2AM, AWARE iOS refresh the joining study in the background.
     * A developer can change the time (2AM to xxxAM/PM) by changing the dailyUpdateTime(NSDate) Object
     */
    NSDate* dailyUpdateTime = [self getTargetNSDate:[NSDate new] hour:2 minute:0 second:0 nextDay:YES]; //2AM
    _dailyUpdateTimer = [[NSTimer alloc] initWithFireDate:dailyUpdateTime
                                                 interval:60*60*24 // daily
                                                   target:self
                                                 selector:@selector(dailySync)
                                                 userInfo:nil
                                                  repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    //    [runLoop addTimer:dailyUpdateTimer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:_dailyUpdateTimer forMode:NSRunLoopCommonModes];
    
    // [_complianceTimer fire];
    
    // Battery Save Mode
    CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (currentVersion >= 9.0){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkCompliance)
                                                     name:NSProcessInfoPowerStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector( checkCompliance)
                                                     name:UIApplicationBackgroundRefreshStatusDidChangeNotification
                                                   object:nil];
        
    }
    
    // battery state trigger
    // Set a battery state change event to a notification center
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedBatteryState:)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    
}
-(void) dailySync
{
//perform daily sync operation
}

-(void) checkCompliance
{
    
}

- (void) changedBatteryState:(id) sender{
    NSInteger batteryState = [UIDevice currentDevice].batteryState;
    if (batteryState == UIDeviceBatteryStateCharging || batteryState == UIDeviceBatteryStateFull) {
        NSLog(@"Battery is charging or full.");
    }
}

- (void) deactivate{
    //[_sharedSensorManager stopAndRemoveAllSensors];
    [_sharedLocationManager stopUpdatingLocation];
    [_dailyUpdateTimer invalidate];
    //
    CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (currentVersion >= 9.0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSProcessInfoPowerStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationBackgroundRefreshStatusDidChangeNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
}

////////////////////////////////////////////////////////////////////////////////////

/**
 * This method is an initializers for a location sensor.
 * On the iOS, we have to turn on the location sensor
 * for using application in the background.
 * And also, this sensing interval is the most low level.
 */
- (void) initLocationSensor {
    // NSLog(@"start location sensing!");
    // CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // if ( _sharedLocationManager == nil) {
    if ( _sharedLocationManager != nil) {
        [_sharedLocationManager stopUpdatingHeading];
        [_sharedLocationManager stopMonitoringVisits];
        [_sharedLocationManager stopUpdatingLocation];
        [_sharedLocationManager stopMonitoringSignificantLocationChanges];
        // _sharedLocationManager = nil;
    }
    
    _sharedLocationManager  = [[CLLocationManager alloc] init];
    _sharedLocationManager.delegate = self;
    _sharedLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    _sharedLocationManager.pausesLocationUpdatesAutomatically = NO;
    _sharedLocationManager.activityType = CLActivityTypeOther;
    
    CGFloat currentVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (currentVersion >= 9.0){
        /// After iOS 9.0, we have to set "YES" for background sensing.
        _sharedLocationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    //    if ([_sharedLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    //        [_sharedLocationManager requestAlwaysAuthorization];
    //    }
    
    CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
    if(state == kCLAuthorizationStatusAuthorizedAlways){
        // Set a movement threshold for new events.
        _sharedLocationManager.distanceFilter = 25; // meters
        [_sharedLocationManager startUpdatingLocation];
        [_sharedLocationManager startMonitoringSignificantLocationChanges];
    }
    // }
}

/**
 * The method is called by location sensor when the device location is changed.
 */
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool appTerminated = [userDefaults boolForKey:@"APP_TERM"];
    if (appTerminated) {
        NSString * message = @"AWARE client iOS is rebooted";
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"APP_TERM"];
    }else{
        // [AWAREUtils sendLocalNotificationForMessage:@"" soundFlag:YES];
        //NSLog(@"Base Location Sensor.");
        //        if ([userDefaults boolForKey: SETTING_DEBUG_STATE]) {
        //            for (CLLocation * location in locations) {
        //                NSLog(@"%@",location.description);
        //
        //            }
        //        }
    }
}

/**
 * This method returns application condition (background or foreground).
 *
 * @return 'YES' is foreground. 'NO' is background.
 */
+ (BOOL) getAppState {
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    switch (appState) {
        case UIApplicationStateActive:
            NSLog(@"Application is in the foreground!");
            return YES;
        case UIApplicationStateInactive:
            NSLog(@"Application is in the foreground!");
            return YES;
        case UIApplicationStateBackground:
            NSLog(@"Application is in the background!");
            return NO;
        default:
            return NO;
    }
}



/**
 * This method sets application is in the foreground or not.
 *
 * @return state 'YES' is foreground. 'NO' is background.
 */
+ (BOOL)isForeground{
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    switch (appState) {
        case UIApplicationStateActive:
            NSLog(@"Application is in the foreground!(active)");
            return YES;
        case UIApplicationStateInactive:
            NSLog(@"Application is in the background!(inactive)");
            return NO;
        case UIApplicationStateBackground:
            NSLog(@"Application is in the background!(background)");
            return NO;
        default:
            return NO;
    }
}

/**
 * This method sets application condition in the background or not.
 *
 * @return state 'YES' is background, on the other hand 'NO' is foreground.
 */
+ (BOOL)isBackground{
    UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
    switch (appState) {
        case UIApplicationStateActive:
            NSLog(@"Application is in the foreground!");
            return NO;
        case UIApplicationStateInactive:
            NSLog(@"Application is in the foreground!");
            return NO;
        case UIApplicationStateBackground:
            NSLog(@"Application is in the background!");
            return YES;
        default:
            return NO;
    }
}

- (NSURL*)storeURL
{
    NSURL* documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL];
    return [documentsDirectory URLByAppendingPathComponent:@"db.sqlite"];
}

- (NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"NestedTodoList" withExtension:@"momd"];
}

-(instancetype) initSensorManagerWithDBManager:(DBManager *)dbManager
{
    self = [super init];
    if(self)
    {
        _dbManager = dbManager;
        _sensorsArray = [NSArray arrayWithObjects:  [[IOSActivityRecognition alloc] initSensor], //0: activity
                                                    [[Calls alloc] initSensor],                  //1: calls
                                                    [[Screen alloc] initSensor],                 //2: screen
                                                    [[Locations alloc] initSensor],              //3: locations
                                                    [[Camera alloc] initSensor],                 //4: face scan
                                                    [[AmbientNoise alloc] initSensor],           //5: ambient noise
                                                    [[AmbientLight alloc] initSensor],           //6: screen brightness
                                                        nil];
        
    }
    return self;
}

- (BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName
{
    [self activate ];
    for(Sensor* sensor in _sensorsArray)
    {
        if([sensor _name] == sensorName){
            [sensor startCollecting];
        }
    }
    return YES;
}

- (BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName
{
    [self deactivate];
    for(Sensor* sensor in _sensorsArray)
    {
        if([sensor _name] == sensorName){
           [sensor stopCollecting];
        }
    }
    return YES;
}

-(BOOL) startPeriodicCollectionWithInterval:(float) interval
{
    //Make all sensors begin collecting data. On specified interval, flush the data of each sensor into the database
    
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(acceptDataFromSensors) userInfo:nil repeats:YES];
    for (Sensor* sensor in _sensorsArray)
    {
        [sensor startCollecting];
    }
    return YES;
}

-(BOOL) stopPeriodicCollection
{
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    for (id sensor in _sensorsArray)
    {
        [sensor stopCollecting];
    }
    return YES;
}

-(void) acceptDataFromSensors
{
    for (Sensor* sensor in _sensorsArray)
    {
        if([sensor isCollecting])
        {
            [self acceptDataFromSensor:sensor];
        }
    }
    
}


-(void) uploadSensorData:(NSURL*)dbServer
{
    for (Sensor* sensor in _sensorsArray)
    {
        if([sensor isCollecting])
        {
            NSString *sensorName = [sensor _name];
            NSArray* data = [_dbManager getDataForSensor:sensorName];
            [_dbManager postData:data forSensor:sensorName toURL:dbServer];
        }
    }
}


-(void) acceptDataFromSensor:(Sensor *)sensor
{
    [_dbManager saveData:[sensor flushData]
                  forSensor:[sensor _name]];
    
}


@end
