//
//  backgroundViewController.h
//  Zhang Proj
//
//  Created by Ian Bacus on 1/14/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SensorManager.h"
#import "AppDelegate.h"

@interface IndexViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *sensorTab;
@property NSString* selectedSensor;
@property (nonatomic,strong) NSArray *sensors;
@property NSArray *onColors;
@property NSMutableArray *currentColors;
@property NSMutableArray *sensorStates;

@property UIColor* onColor;


@end


@interface IndexViewController() <UIGestureRecognizerDelegate>
@end
