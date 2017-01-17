//
//  ViewController.h
//  Zhang Proj
//
//  Created by Ian Bacus on 11/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DBManager.h"
#import "Charts/Charts.h"
 #import <MapKit/MapKit.h>

//#import "ChartsDemo-Swift.h"

@interface DataViewController : UIViewController


@property NSString* selectedSensor;
@property IBOutlet MKMapView* mapview;
@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@end

