//
//  ChartView.h
//  Zhang Proj
//
//  Created by Ian Bacus on 1/16/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//

#ifndef ChartView_h
#define ChartView_h

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "DataPresentation.h"
#import "Charts/Charts-Swift.h"

@interface DataView : DataPresentation

@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@end

#endif /* ChartView_h */
