//
//  VisitLocations.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//



#import "VisitLocations.h"

@implementation VisitLocations
{
    IBOutlet CLLocationManager *locationManager;
}


- (instancetype)init
{
    return self;
}

- (BOOL) startCollecting
{
    // Initialize a location sensor
    if (locationManager == nil){
        locationManager = [[CLLocationManager alloc] init];
        
        // One of the following numbers: 100 (High accuracy); 102 (balanced); 104 (low power); 105 (no power, listens to others location requests)
        // http://stackoverflow.com/questions/3411629/decoding-the-cllocationaccuracy-consts
        //    GPS - kCLLocationAccuracyBestForNavigation;
        //    GPS - kCLLocationAccuracyBest;
        //    GPS - kCLLocationAccuracyNearestTenMeters;
        //    WiFi (or GPS in rural area) - kCLLocationAccuracyHundredMeters;
        //    Cell Tower - kCLLocationAccuracyKilometer;
        //    Cell Tower - kCLLocationAccuracyThreeKilometers;
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        /*
        if ([AWAREUtils getCurrentOSVersionAsFloat] >= 9.0) {
            //This variable is an important method for background sensing after iOS9
            locationManager.allowsBackgroundLocationUpdates = YES;
        }
        locationManager.activityType = CLActivityTypeOther;
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
         */
        // Set a movement threshold for new events.
        [locationManager startMonitoringVisits]; // This method calls didVisit.
    }
    return YES;
}

- (BOOL)stopCollecting{
    if (locationManager != nil) {
        [locationManager stopMonitoringVisits];
    }
    return YES;
}

///////////////////////////

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit {
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:visit.coordinate.latitude longitude:visit.coordinate.longitude]; //insert your coordinates
    [ceo reverseGeocodeLocation:loc
      completionHandler:^(NSArray *placemarks, NSError *error) {
          CLPlacemark * placemark = nil;
          NSString * name = @"";
          NSString * address = @"";
          if (placemarks.count > 0) {
              placemark = [placemarks objectAtIndex:0];
              address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
              //NSString* visitMsg = [NSString stringWithFormat:@"I am currently at %@", address];
              // Set name
              if (placemark.name != nil) {
                  //[visitDic setObject:placemark.name forKey:@"name"];
                  name = placemark.name;
              }
          }
          
          //NSNumber * timestamp = [AWAREUtils getUnixTimestamp:[NSDate new]];
          //NSNumber * depature = [AWAREUtils getUnixTimestamp:[visit departureDate]];
          //NSNumber * arrival = [AWAREUtils getUnixTimestamp:[visit arrivalDate]];
          
          /*
           *  arrivalDate
           *    The date when the visit began.  This may be equal to [NSDate distantPast] if the true arrival date isn't available.
           */
          if([[visit departureDate] isEqualToDate:[NSDate distantPast]]){
              //arrival = @-1;
              //[self sendLocalNotificationForMessage:[NSString stringWithFormat:@"departure date is %@",[NSDate distantPast]] soundFlag:NO];
          }
          
          /*
           *  departureDate
           *  Discussion:
           *    The date when the visit ended.  This is equal to [NSDate distantFuture] if the device hasn't yet left.
           */
          
          if([[visit arrivalDate] isEqualToDate:[NSDate distantFuture]]){
              //departure = @-1;
              //[self sendLocalNotificationForMessage:[NSString stringWithFormat:@"departure date is %@",[NSDate distantFuture]] soundFlag:NO];
          }
          
          dispatch_async(dispatch_get_main_queue(), ^{
              NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
              //[dict setObject:[self getDeviceId] forKey:@"device_id"];
              //[dict setObject:timestamp forKey:@"timestamp"];
              [dict setObject:@(visit.coordinate.latitude) forKey:@"double_latitude"];
              [dict setObject:@(visit.coordinate.longitude) forKey:@"double_longitude"];// = [NSNumber numberWithDouble:];
              [dict setObject:@"" forKey:@"provider"]; //visitData.provider = @"fused";
              [dict setObject:@(visit.horizontalAccuracy) forKey:@"accuracy"];// visitData.accuracy = [NSNumber numberWithInt:visit.horizontalAccuracy];
              [dict setObject:address forKey:@"address"];// visitData.address = address;
              [dict setObject:name forKey:@"name"]; //forKey:(nonnull id<NSCopying>]visitData.name = name;
              //[dict setObject:arrival forKey:@"double_arrival"];//visitData.double_arrival = arrival;
              //[dict setObject:depature forKey:@"double_departure"]; // visitData.double_departure = depature;
              [dict setObject:@"" forKey:@"label"]; //visitData.label = @"";
              
              //[self saveData:dict];
              //[self setLatestData:dict];
              
          });
          return;
      }];
}



@end
