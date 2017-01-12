//
//  ViewController.m
//  Zhang Proj
//
//  Created by Ian Bacus on 11/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "dataViewController.h"

/*
@interface ViewController ()

@end
*/

@implementation DataViewController

-(NSMutableArray *) getLast:(int)n ofNSArray:(NSArray*)ary
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    if(ary){
        if([ary count] > 0)
        {
            //len = 4 [0 1 2 3]
            //n = 5: 0,4
            //n = 4: 0,4
            //n = 3: 1,3
            //
            //n = 1: 3,1
            NSUInteger len = [ary count];
            while(len < n)
                n--;
            NSArray *copyCat = [ary subarrayWithRange:NSMakeRange(len-n, n)];
            for(id obj in copyCat)
            {
                NSString* myobj = [NSString stringWithFormat:@"%@ %@", [obj valueForKey:@"time"],[obj valueForKey:@"stateVal"]];
                [result addObject:myobj];
            }
        }
    }
    while([result count] < 3)
        [result addObject:@""];
    return result;
}
- (void) populateLabels
{
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSMutableArray * callData = [self getLast:3 ofNSArray: [[app dbManager] getDataForSensor:@"Social"]];
    _call_d1.text = [callData objectAtIndex:0];
    _call_d2.text = [callData objectAtIndex:1];
    _call_d3.text = [callData objectAtIndex:2];
    
    
    NSMutableArray * screenData = [self getLast:3 ofNSArray: [[app dbManager] getDataForSensor:@"Screen"]];
    _scr_d1.text = [screenData objectAtIndex:0];
    _scr_d2.text = [screenData objectAtIndex:1];
    _scr_d3.text = [screenData objectAtIndex:2];
    
    NSMutableArray * locationData = [self getLast:3 ofNSArray: [[app dbManager] getDataForSensor:@"Location"]];
    _loc_d1.text = [locationData objectAtIndex:0];
    _loc_d2.text = [locationData objectAtIndex:1];
    _loc_d3.text = [locationData objectAtIndex:2];
    
    NSMutableArray * activityData = [self getLast:3 ofNSArray: [[app dbManager] getDataForSensor:@"Activity"]];
    _act_d1.text = [activityData objectAtIndex:0];
    _act_d2.text = [activityData objectAtIndex:1];
    _act_d3.text = [activityData objectAtIndex:2];
    //NSArray * faceData = [[app dbManager] getDataForSensor:@"Social"];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self populateLabels];
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
