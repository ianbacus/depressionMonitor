//
//  ChartView.m
//  Zhang Proj
//
//  Created by Ian Bacus on 1/16/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.


#import "ChartView.h"

@interface DataView () <ChartViewDelegate>
@end

@implementation DataView

-(void) setupLineChart
{
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = YES;
    _chartView.highlightPerDragEnabled = YES;
    
    _chartView.backgroundColor = UIColor.whiteColor;
    
    _chartView.legend.enabled = NO;
    
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionTopInside;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxis.drawAxisLineEnabled = YES;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.granularity = 3600.0;
    //  xAxis.valueFormatter = [[DateValueFormatter alloc] init];
    
    ChartYAxis *leftAxis = _chartView.leftAxis;
    leftAxis.labelPosition = YAxisLabelPositionInsideChart;
    leftAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
    leftAxis.labelTextColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
    leftAxis.drawGridLinesEnabled = YES;
    leftAxis.granularityEnabled = YES;
    leftAxis.axisMinimum = 0.0;
    leftAxis.axisMaximum = 170.0;
    leftAxis.yOffset = -9.0;
    leftAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    
    _chartView.rightAxis.enabled = YES;
    
    _chartView.legend.form = ChartLegendFormLine;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        // Call a common method to setup gesture and state of UIView
        [self setup];
    }
    return self;
}

// Called when loading from embedded .xib UIView
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // Call a common method to setup gesture and state of UIView
        [self setup];
    }
    return self;
}

- (void)setup {
    // Add a gesture to show that touch input works on full bounds of UIView
    [self setupLineChart];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}



@end
