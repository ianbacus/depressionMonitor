//
//  VisitLocations.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#ifndef VisitLocations_h
#define VisitLocations_h


#import <CoreLocation/CoreLocation.h>
#import "Sensor.h"

@interface VisitLocations : Sensor

@end

@interface VisitLocations() <CLLocationManagerDelegate>;
@end


#endif
