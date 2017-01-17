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

-(instancetype) initSensorManagerWithDBManager:(DBManager *)dbManager
{
    self = [super init];
    if(self)
    {
        _startDate = [self getTargetNSDate:[NSDate new] hour:14 minute:0 second:0 nextDay:NO];
        _dbManager = dbManager;
        _sensorsArray = [NSArray arrayWithObjects:  [[IOSActivityRecognition alloc] initSensor], //0: activity
                                                    [[Calls alloc] initSensor],                  //1: calls
                                                    [[Screen alloc] initSensor],                 //2: screen
                                                    [[Locations alloc] initSensor],              //3: locations
                                                    [[Pedometer alloc] initSensor],              //4: pedometer
                                                    //[[Camera alloc] initSensor],                 //4: face scan
                                                    [[AmbientNoise alloc] initSensor],           //5: ambient noise
                                                    [[AmbientLight alloc] initSensor],           //6: screen brightness
                                                    [[Wifi alloc] initSensor],                   //7: wifi
                                                        nil];
        
    }
    return self;
}

-(Sensor*) getSensorByName:(NSString*)sensorName
{
    for(Sensor* sensor in _sensorsArray)
    {
        if([sensor _name] == sensorName)
        {
            return sensor;
        }
    }
    return nil;
}

- (BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName
{
    Sensor* sensor = [self getSensorByName:sensorName];
    if(![sensor isCollecting] )
        [sensor startCollecting];
    return YES;
}

-(NSArray*) createDataSetForSensor:(NSString*) sensorName fromStartDate:(NSDate *)startDate toEndDate:(NSDate*)endDate
{
    NSArray* dbData = [_dbManager getDataForSensor:sensorName fromStartDate:startDate toEndDate:endDate];
    Sensor* sensor = [self getSensorByName:sensorName];
    return [sensor createDataSetFromDBData:dbData];
}

-(BOOL) startPeriodicCollectionWithInterval:(float) interval
{
    //Make all sensors begin collecting data. On specified interval, flush the data of each sensor into the database
    [self activate];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(acceptDataFromSensors) userInfo:nil repeats:YES];
    _dailyUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:160 target:self selector:@selector(dailySync) userInfo:nil repeats:YES];
    //[_dailyUpdateTimer fire];
    for (Sensor* sensor in _sensorsArray)
    {
        [sensor startCollecting];
    }
    return YES;
}

-(BOOL) stopPeriodicCollection
{
    [self deactivate];
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    for (id sensor in _sensorsArray)
    {
        [sensor stopCollecting];
    }
    return YES;
}

- (BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName
{
    Sensor* sensor = [self getSensorByName:sensorName];
    if(![sensor isCollecting])
    {
        [sensor stopCollecting];
    }
    return YES;
}


-(void) uploadSensorData
{
    for (Sensor* sensor in _sensorsArray)
    {
        NSString *sensorName = [sensor _name];
        //NSArray* data = [_dbManager getDataForSensor:sensorName];
        NSArray* data = [_dbManager getDataForSensor:sensorName
                                       fromStartDate:_startDate
                                    toEndDate:[self getTargetNSDate:[NSDate new] hour:15 minute:30 second:0 nextDay:NO]];
        if([data count] > 0)
            [_dbManager postData:data forSensor:sensorName];
    
    }
    _startDate = [NSDate new];
}


-(void) acceptDataFromSensors
{
    //Delete local copy of data (dictionaries maintained for each sensor), store them in the SQLite database
    for (Sensor* sensor in _sensorsArray)
    {
        if([sensor hasData])
        {
            [self acceptDataFromSensor:sensor];
        }
    }
    
}

-(void) acceptDataFromSensor:(Sensor *)sensor
{
    //Delete local copy of data (dictionaries maintained for each sensor), store them in the SQLite database
    [_dbManager saveData:[sensor flushData]
                  forSensor:[sensor _name]];
    
}

//////

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
    
    
    //Use Location Sensor exploit to enable background data collection
    [self initLocationSensor];
    
    /// Set a timer for a daily sync update with specific time
    /*
    NSDate* dailyUpdateTime = [self getTargetNSDate:[NSDate new] hour:2 minute:0 second:0 nextDay:YES]; //2AM
    _dailyUpdateTimer = [[NSTimer alloc] initWithFireDate:dailyUpdateTime
                                                 interval:60*60*24 // daily
                                                   target:self
                                                 selector:@selector(dailySync)
                                                 userInfo:nil
                                                  repeats:YES];
    
    //_dailyUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(dailySync) userInfo:nil repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_dailyUpdateTimer forMode:NSRunLoopCommonModes];
    */
    
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
    //perform daily sync operation: reset all sensor and process data
    if([[_sensorsArray objectAtIndex:7] getWifiInfo])
    {
        [self acceptDataFromSensors];
        [self uploadSensorData];
    }
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


- (void) initLocationSensor {
    //Set up location sensor for background updates
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
    CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
    if(state == kCLAuthorizationStatusAuthorizedAlways){
        _sharedLocationManager.distanceFilter = 25; // meters
        [_sharedLocationManager startUpdatingLocation];
        [_sharedLocationManager startMonitoringSignificantLocationChanges];
    }
}

/**
 * The method is called by location sensor when the device location is changed.
 */
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    bool appTerminated = [userDefaults boolForKey:@"APP_TERM"];
    if (appTerminated) {
        //NSString * message = @"App closed.";
        NSLog(@"App closed.");
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"APP_TERM"];
    }else{
        // [AWAREUtils sendLocalNotificationForMessage:@"" soundFlag:YES];
        
    }
}


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
/////


@end
