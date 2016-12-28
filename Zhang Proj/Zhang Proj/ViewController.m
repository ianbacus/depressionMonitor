//
//  ViewController.m
//  Zhang Proj
//
//  Created by Ian Bacus on 11/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "ViewController.h"
#import "SensorManager.h"

/*
@interface ViewController ()

@end
*/

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    SensorManager *sensorMgr = [[SensorManager alloc] initSensorManager];
    
    //[sensorMgr initSensorManager]
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
