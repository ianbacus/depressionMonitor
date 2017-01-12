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

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *call_d1;
@property (strong, nonatomic) IBOutlet UILabel *call_d2;
@property (strong, nonatomic) IBOutlet UILabel *call_d3;


@property (strong, nonatomic) IBOutlet UILabel *loc_d1;
@property (strong, nonatomic) IBOutlet UILabel *loc_d2;
@property (strong, nonatomic) IBOutlet UILabel *loc_d3;

@property (strong, nonatomic) IBOutlet UILabel *act_d1;
@property (strong, nonatomic) IBOutlet UILabel *act_d2;
@property (strong, nonatomic) IBOutlet UILabel *act_d3;


@property (strong, nonatomic) IBOutlet UILabel *scr_d1;
@property (strong, nonatomic) IBOutlet UILabel *scr_d2;
@property (strong, nonatomic) IBOutlet UILabel *scr_d3;


@end

