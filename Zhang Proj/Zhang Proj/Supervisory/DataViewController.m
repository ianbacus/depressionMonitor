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


@interface DataViewController () <ChartViewDelegate, MKMapViewDelegate, UITabBarControllerDelegate>

//@property IBOutlet UIView* myview;

@end

@implementation DataViewController
@synthesize selectedSensor = _selectedSensor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *defaultTimeKey = @"Morning";
    _dataVisualizationSelector = NSSelectorFromString(@"renderTodaysDataForTimeKey:");
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    _timeBoundaries = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [[app sensorManager] getTargetNSDate:[NSDate new] hour:0 minute:0 second:0 nextDay:NO],@"Night",
                       [[app sensorManager] getTargetNSDate:[NSDate new] hour:6 minute:0 second:0 nextDay:NO],@"Morning",
                       [[app sensorManager] getTargetNSDate:[NSDate new] hour:12 minute:0 second:0 nextDay:NO],@"Afternoon",
                       [[app sensorManager] getTargetNSDate:[NSDate new] hour:18 minute:0 second:0 nextDay:NO],@"Evening",
                       nil
                       ];
    for(id key in _timeBoundaries)
    {
        NSDate* timenow = [NSDate new];
        if ([timenow compare:[_timeBoundaries objectForKey:key]] == NSOrderedDescending)
            defaultTimeKey = key;
    }
    
    _todaysData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                   [[NSMutableArray alloc] init],@"Morning",
                   [[NSMutableArray alloc] init],@"Afternoon",
                   [[NSMutableArray alloc] init],@"Evening",
                   [[NSMutableArray alloc] init],@"Night",
                   nil];
    
    if([_selectedSensor isEqualToString: @"Phone"])
    {
        [self appendTodaysDataForSensor:@"Screen"];
        [self setup2LineChart ];
        //[self renderTodaysDataForTimeKey:defaultTimeKey];
    }
    else if([_selectedSensor isEqualToString: @"Social"])
    {
        [self appendTodaysDataForSensor:@"Calls"];
        [self setup2LineChart ];
        //[self renderTodaysDataForTimeKey:defaultTimeKey];
    }
    else if([_selectedSensor isEqualToString:@"Locations"])
    {
        
        [_mapview setDelegate:self];
        [_mapview setShowsUserLocation:YES];
        [_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        
        [self appendTodaysDataForSensor:@"Locations"];
        //[self setup2LineChart ];
        _dataVisualizationSelector = NSSelectorFromString(@"drawRouteForTimeKey:");
        //[self drawRoute:[_todaysData[defaultTimeKey] objectAtIndex:0]];
        
    }
    else if([_selectedSensor isEqualToString:@"Activity"])
    {
        [self appendTodaysDataForSensor:@"Activity"];
        [self setup2LineChart ];
        //[self renderTodaysDataForTimeKey:defaultTimeKey];
        
    }
    else if([_selectedSensor isEqualToString:@"Ambience"])
    {
        [self appendTodaysDataForSensor:@"AmbientNoise"];
        [self appendTodaysDataForSensor:@"AmbientLight"];
        
        [self setup2LineChart ];
        //[self renderTodaysDataForTimeKey:defaultTimeKey];
    }
    [self performSelector:_dataVisualizationSelector withObject:defaultTimeKey];
}



- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    //Callback for map delegate
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        @try {
            
            MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
            routeRenderer.strokeColor = [UIColor colorWithRed:20/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
            routeRenderer.lineWidth = 3;
            [routeRenderer setNeedsDisplay];
            return routeRenderer;
        }
        @catch (NSException *exception) {
            NSLog(@"exception :%@",exception.debugDescription);
        }
        
    }
    else return nil;
}


//- (void) drawRoute:(NSArray *) path
- (void) drawRouteForTimeKey:(NSString*)timeKey
{
    //Render GPS data on map
    NSArray* path = _todaysData[timeKey][0];
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

- (void)renderTodaysDataForTimeKey:(NSString*)timeKey
{
    //Render plot data
    NSArray *colors = @[ChartColorTemplates.vordiplom[0], ChartColorTemplates.vordiplom[1], ChartColorTemplates.vordiplom[2]];

    NSMutableArray *dataSetList = [[NSMutableArray alloc] init];
    
    NSArray *dataCopy = _todaysData[timeKey];
    
    for(int z=0; z<[dataCopy count]; z++ )
    {
        NSArray* singlePlot = [dataCopy objectAtIndex:z];
        NSMutableArray* values = [[NSMutableArray alloc] init];
        if([singlePlot count] == 0) continue;
        double lastPoint = [[singlePlot objectAtIndex:0][@"y"] doubleValue ];
        for(int singlePlotIndex=0;singlePlotIndex<[singlePlot count]; singlePlotIndex++)
        {
            
            NSTimeInterval secondsBetween = [ [singlePlot objectAtIndex:singlePlotIndex][@"x"] timeIntervalSinceDate:_timeBoundaries[timeKey]];
            
            [values addObject:[[ChartDataEntry alloc] initWithX:secondsBetween-1 y: lastPoint]];
            lastPoint =[[singlePlot objectAtIndex:singlePlotIndex][@"y"] doubleValue ];
            [values addObject:[[ChartDataEntry alloc] initWithX:secondsBetween y: lastPoint]];
        }
        
        LineChartDataSet *dataSet = [[LineChartDataSet alloc] initWithValues:values label:[NSString stringWithFormat:@"DataSet %d", z + 1]];
        dataSet.lineWidth = 2.5;
        dataSet.circleRadius = 1.0;
        dataSet.circleHoleRadius = .5;
        
        UIColor *color = colors[z % colors.count];
        [dataSet setColor:color];
        [dataSet setCircleColor:color];
        [dataSetList addObject:dataSet];
    }
    
    LineChartData *plot = [[LineChartData alloc] initWithDataSets:dataSetList];
    [plot setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:7.f]];
    _chartView.data = plot;
}


-(void) setup2LineChart
{
    //Setup 2d Plot
    _chartView.delegate = self;
    
    _chartView.chartDescription.enabled = NO;
    
    _chartView.leftAxis.enabled = NO;
    _chartView.rightAxis.drawAxisLineEnabled = NO;
    _chartView.rightAxis.drawGridLinesEnabled = NO;
    _chartView.xAxis.drawAxisLineEnabled = NO;
    _chartView.xAxis.drawGridLinesEnabled = NO;
    
    _chartView.drawGridBackgroundEnabled = NO;
    _chartView.drawBordersEnabled = NO;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:YES];
    _chartView.pinchZoomEnabled = NO;
    
    ChartLegend *l = _chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    long selectedTag=item.tag;
    
    switch(selectedTag)
    {
        case 0://morning
            [self performSelector:_dataVisualizationSelector withObject:@"Morning"];//[self renderTodaysDataForTimeKey:@"Morning"];
            break;
        case 1://afternoon
            [self performSelector:_dataVisualizationSelector withObject:@"Afternoon"];//[self renderTodaysDataForTimeKey:@"Afternoon"];
            break;
        case 2://evening
            [self performSelector:_dataVisualizationSelector withObject:@"Evening"];//[self renderTodaysDataForTimeKey:@"Evening"];
            break;
        case 3://night
            [self performSelector:_dataVisualizationSelector withObject:@"Night"];//[self renderTodaysDataForTimeKey:@"Night"];
            break;
        case 4://full day
            break;
    }
}

- (void) appendTodaysDataForSensor:(NSString*)sensorName
{
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    //beginning of boundaries stored in timeBoundaries
    
    
    [_todaysData [@"Night"] addObject: [[app sensorManager] createDataSetForSensor:sensorName
                                fromStartDate:_timeBoundaries[@"Night"]
                                toEndDate:_timeBoundaries[@"Morning"]]];
    
    [_todaysData [@"Morning"]  addObject:[[app sensorManager] createDataSetForSensor:sensorName
                                fromStartDate:_timeBoundaries[@"Morning"]
                                toEndDate:_timeBoundaries[@"Afternoon"]]];

    
    [_todaysData [@"Afternoon"] addObject: [[app sensorManager] createDataSetForSensor:sensorName
                                fromStartDate:_timeBoundaries[@"Afternoon"]
                                toEndDate:_timeBoundaries[@"Evening"] ]];
    
    
    [_todaysData [@"Evening"] addObject: [[app sensorManager] createDataSetForSensor:sensorName
                                fromStartDate:_timeBoundaries[@"Evening"]
                                toEndDate:[[app sensorManager] getTargetNSDate:[NSDate new] hour:24 minute:0 second:0 nextDay:NO] ]];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*

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


*/

@end
