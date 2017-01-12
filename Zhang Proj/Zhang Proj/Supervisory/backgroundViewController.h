//
//  backgroundViewController.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SensorManager.h"
#import "AppDelegate.h"

@interface BackgroundViewController : UIViewController
{
    IBOutlet UISegmentedControl *segmentedControl;
}

- (IBAction)segmentChanged:(id)sender;
- (IBAction) uploadData:(id)sender;

@end

