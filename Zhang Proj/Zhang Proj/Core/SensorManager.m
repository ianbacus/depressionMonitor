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
{
    NSTimer* periodicBatteryTestTimer;
    NSTimer* sweepSamplingRateTimer;
}

/*
 *  Create sensor manager, initialize all sensors currently being used.
 */
-(instancetype) initSensorManagerWithDBManager:(DBManager *)dbManager
{
    self = [super init];
    if(self)
    {
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"EST"]];
        _startDate = [self getTargetNSDate:[NSDate new] hour:0 minute:0 second:0 nextDay:NO];
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
                                                    [[Battery alloc] initSensor],                //8: Battery
                                                        nil];
        
    }
    return self;
}

/*
 *  Iterate over sensor array, return reference to sensor specified by name
 */
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

/*
 *  Safely begin data collection for a sensor
 */
- (BOOL) startPeriodicCollectionForSensor:(NSString*)sensorName
{
    Sensor* sensor = [self getSensorByName:sensorName];
    if(![sensor isCollecting] )
        [sensor startCollecting];
    return YES;
}

/*
 *  Convert a range of database entries for a sensor from strings to numeric values, see the createDataSetFromDBData method for each sensor for more information
 */
-(NSArray*) createDataSetForSensor:(NSString*) sensorName fromStartDate:(NSDate *)startDate toEndDate:(NSDate*)endDate
{
    NSArray* dbData = [_dbManager getDataForSensor:sensorName fromStartDate:startDate toEndDate:endDate];
    Sensor* sensor = [self getSensorByName:sensorName];
    return [sensor createDataSetFromDBData:dbData];
}

/*
 *  Begin collecting data from all sensors. At the specified interval, flush the data of each sensor into the database
 */
-(BOOL) startPeriodicCollectionWithInterval:(float) interval
{
    [self activate];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(acceptDataFromSensors) userInfo:nil repeats:YES];
    
    for (Sensor* sensor in _sensorsArray)
    {
        [sensor startCollecting];
    }
    
    return YES;
}

/*
 *  Stop data collection for sensors, stop flushing data to database
 */
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

/*
 *  Stop data collection for one sensor, given by its name
 */
- (BOOL) stopPeriodicCollectionForSensor:(NSString*)sensorName
{
    Sensor* sensor = [self getSensorByName:sensorName];
    if([sensor isCollecting])
    {
        [sensor stopCollecting];
    }
    return YES;
}

- (BOOL) setSamplingIntervalForSensor:(NSString*) sensorName toRate:(double)collectionRate
{
    Sensor* sensor = [self getSensorByName:sensorName];
    [sensor changeCollectionInterval:collectionRate];
    return YES;
}

/*
 *  Upload sensor data
 */
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

/*
 *  Store data for all sensors into database
 */
-(void) acceptDataFromSensors
{
    for (Sensor* sensor in _sensorsArray)
    {
        if([sensor hasData])
        {
            [self acceptDataFromSensor:sensor];
        }
    }
    
}

/*
 *  Empty local store for a sensor, store it in core database
 */
-(void) acceptDataFromSensor:(Sensor *)sensor
{
    [_dbManager saveData:[sensor flushData]
                  forSensor:[sensor _name]];
}

//////
/*
 *  Return an NSDate object for some input time value
 */
- (NSDate *) getTargetNSDate:(NSDate *) nsDate
                        hour:(int) hour
                      minute:(int) minute
                      second:(int) second
                     nextDay:(BOOL)nextDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDateComponents *dateComps = [calendar components:NSCalendarUnitYear   |
                                   NSCalendarUnitMonth  |
                                   NSCalendarUnitDay    |
                                   NSCalendarUnitHour   |
                                   NSCalendarUnitMinute |
                                   NSCalendarUnitSecond
                                              fromDate:nsDate];
    
    //hour -= [[NSTimeZone systemTimeZone] secondsFromGMT] / 3600.0;
    [dateComps setDay:dateComps.day];
    [dateComps setHour:hour];
    [dateComps setMinute:minute];
    [dateComps setSecond:second];
    NSDate * targetNSDate = [calendar dateFromComponents:dateComps];
    
    if (nextDay)
    {
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

/*
 *  Activate the sensor manager background mode
 */
- (void) activate
{
    [self deactivate];
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    
    //Use Location Sensor exploit to enable background data collection
    [self initLocationSensor];
    
    /// Set a timer for a daily sync update with specific time
    
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
    
    /*
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
    
    */
}

/*
 *  Flush sensor data into database,
 */
-(void) dailySync
{
    //perform daily sync operation: reset all sensor and process data
    if([[_sensorsArray objectAtIndex:7] getWifiInfo])
    {
        [self acceptDataFromSensors];
        [self uploadSensorData];
    }
}



/*
 *  disable background mode
 */
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


/*
 *  Allow background data collection by enabling location sensor
 */
- (void) initLocationSensor
{
    //Set up location sensor for background updates
    if ( _sharedLocationManager != nil)
    {
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
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
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
///// Power consumption profiling

/*
 
 //Call every 2 hours
 -(void) sweepSamplingRate
 {
 //tear sensors down, restart them with specified interval
 //change sampling interval mid collection
 _testRate *= 2;
 NSLog(@"Beginning experiment with %f",_testRate);
 //if(_batteryTestIndex == 0)
 {
 [self setSamplingIntervalForSensor:@"AmbientLight" toRate:_testRate];
 [self setSamplingIntervalForSensor:@"Screen" toRate:_testRate];
 [self setSamplingIntervalForSensor:@"Wifi" toRate:_testRate];
 }
 //else if(_batteryTestIndex <= 4)
 {
 [self setSamplingIntervalForSensor:@"AmbientNoise" toRate:_testRate];
 [(AmbientNoise*)[self getSensorByName:@"AmbientNoise" ]  changeDutyCycle:.5];
 }
 //else if(_batteryTestIndex == 5)
 {
 [self setSamplingIntervalForSensor:@"Activity" toRate:_testRate];
 [self setSamplingIntervalForSensor:@"Pedometer" toRate:_testRate];
 }
 //else if(_batteryTestIndex == 6)
 {
 [self setSamplingIntervalForSensor:@"Locations" toRate:_testRate];
 }
 
 
 }
 
 
 //Call every 6 hours
 - (void) periodicBatteryTest
 {
 _testRate = 20;
 if(_batteryTestIndex == 0)
 {
 [self stopPeriodicCollectionForSensor:@"Locations"];
 
 [self startPeriodicCollectionForSensor:@"AmbientLight"];
 [self startPeriodicCollectionForSensor:@"Screen"];
 [self startPeriodicCollectionForSensor:@"Wifi"];
 }
 else if(_batteryTestIndex == 1)
 {
 [self stopPeriodicCollectionForSensor:@"AmbientLight"];
 [self stopPeriodicCollectionForSensor:@"Screen"];
 [self stopPeriodicCollectionForSensor:@"Wifi"];
 
 [self startPeriodicCollectionForSensor:@"AmbientNoise"];
 }
 else if(_batteryTestIndex == 2)
 {
 [(AmbientNoise*)[self getSensorByName:@"AmbientNoise" ] changeSamplingRate:8000 ];
 }
 else if(_batteryTestIndex == 3)
 {
 [(AmbientNoise*)[self getSensorByName:@"AmbientNoise" ] changeSamplingRate:16000 ];
 }
 else if(_batteryTestIndex == 4)
 {
 [(AmbientNoise*)[self getSensorByName:@"AmbientNoise" ] changeSamplingRate:48000 ];
 }
 else if(_batteryTestIndex == 5)
 {
 [self stopPeriodicCollectionForSensor:@"AmbientNoise"];
 
 [self startPeriodicCollectionForSensor:@"Activity"];
 [self startPeriodicCollectionForSensor:@"Pedometer"];
 }
 else if(_batteryTestIndex == 6)
 {
 [self stopPeriodicCollectionForSensor:@"Activity"];
 [self stopPeriodicCollectionForSensor:@"Pedometer"];
 
 [self startPeriodicCollectionForSensor:@"Locations"];
 }
 
 _batteryTestIndex+=1;
 
 }
 
 //Eveyr 6 hours, change the active sensors and store the test results
 - (void) initBatteryTest
 {
 _batteryTestIndex = 0;
 _testRate = 5;
 [_dbManager deleteAllDataForSensor:@"Battery"];
 periodicBatteryTestTimer = [NSTimer scheduledTimerWithTimeInterval:60*60*6
 target:self
 selector:@selector(periodicBatteryTest)
 userInfo:nil
 repeats:YES];
 
 sweepSamplingRateTimer = [NSTimer scheduledTimerWithTimeInterval:60*60*2
 target:self
 selector:@selector(sweepSamplingRate)
 userInfo:nil
 repeats:YES];
 [periodicBatteryTestTimer fire];
 [sweepSamplingRateTimer fire];
 [self startPeriodicCollectionForSensor:@"Battery"];
 
 }

 */
@end
