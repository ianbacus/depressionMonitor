//
//  ViewController.m
//  Zhang Proj
//
//  Created by Ian Bacus on 11/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "dataViewController.h"
#import "Charts/Charts-Swift.h"
#import "../ChartView.h"


@interface DataViewController () <ChartViewDelegate, MKMapViewDelegate>

@property IBOutlet UIView* myview;

@end

@implementation DataViewController
@synthesize selectedSensor = _selectedSensor;


-(void) setupLineChart2
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

-(void) setupLineChart
{
    _chartView.delegate = self;

    _chartView.chartDescription.enabled = NO;

    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.highlightPerDragEnabled = YES;

    _chartView.backgroundColor = UIColor.whiteColor;

    _chartView.legend.enabled = NO;

    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.labelPosition = XAxisLabelPositionTopInside;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.f];
    xAxis.labelTextColor = [UIColor colorWithRed:255/255.0 green:192/255.0 blue:56/255.0 alpha:1.0];
    xAxis.drawAxisLineEnabled = NO;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.centerAxisLabelsEnabled = YES;
    xAxis.granularity = 3600.0;

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

    _chartView.rightAxis.enabled = NO;

    _chartView.legend.form = ChartLegendFormLine;

}


- (void)setDataCount
{
    int count = 10;
    double range = 20;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval hourSeconds = 3600.0;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    
    NSTimeInterval from = now - (count / 2.0) * hourSeconds;
    NSTimeInterval to = now + (count / 2.0) * hourSeconds;
    
    for (NSTimeInterval x = from; x < to; x += hourSeconds)
    {
        double y = arc4random_uniform(range) + 50;
        [values addObject:[[ChartDataEntry alloc] initWithX:x y:y]];
    }
    
    LineChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = values;
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        set1 = [[LineChartDataSet alloc] initWithValues:values label:@"DataSet 1"];
        set1.axisDependency = AxisDependencyLeft;
        set1.valueTextColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
        set1.lineWidth = 1.5;
        set1.drawCirclesEnabled = NO;
        set1.drawValuesEnabled = NO;
        set1.fillAlpha = 0.26;
        set1.fillColor = [UIColor colorWithRed:51/255.0 green:181/255.0 blue:229/255.0 alpha:1.0];
        set1.highlightColor = [UIColor colorWithRed:224/255.0 green:117/255.0 blue:117/255.0 alpha:1.0];
        set1.drawCircleHoleEnabled = NO;
        
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        [data setValueTextColor:UIColor.whiteColor];
        [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0]];
        
        _chartView.data = data;
    }
}


- (void) drawRoute:(NSArray *) path
{
    NSInteger numberOfSteps = path.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];

    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [_mapview addOverlay:polyLine];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([_selectedSensor isEqualToString: @"Phone"])
    {
        [self setupLineChart ];
        [self setDataCount];
    }
    else if([_selectedSensor isEqualToString: @"Social"])
    {
        [self setupLineChart ];
    }
    else if([_selectedSensor isEqualToString:@"Activity"])
    {
        _mapview.delegate=self;
        _mapview.showsUserLocation=YES;
        [_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        
    }
    else if([_selectedSensor isEqualToString:@"Ambience"])
    {
         [self setupLineChart ];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
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
 */

@end
