//
//  backgroundViewController.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface BackgroundViewController : UIViewController
{
    IBOutlet UISegmentedControl *segmentedControl;
}

- (IBAction)segmentChanged:(id)sender;

@end

