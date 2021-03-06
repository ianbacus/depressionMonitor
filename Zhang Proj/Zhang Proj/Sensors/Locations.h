//
//  Locations.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#ifndef Locations_h
#define Locations_h

#import <CoreLocation/CoreLocation.h>
#import "Sensor.h"

/*
 *  Determine GPS coordinates. Configure to automatically update or poll sensor
 */
@interface Locations : Sensor
@end

@interface Locations() <CLLocationManagerDelegate>;
@end


#endif
