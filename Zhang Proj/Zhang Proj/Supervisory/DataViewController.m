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

@end

@implementation DataViewController
@synthesize selectedSensor = _selectedSensor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *defaultTimeKey = @"Morning";
    _dataVisualizationSelector = NSSelectorFromString(@"renderTodaysDataForTimeKey:");
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    //Time boundaries for time-of-day filtering on displayed data
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
    
    //The selectedSensor key is sent from the view controller that segues to this view controller
    if([_selectedSensor isEqualToString: @"Phone"])
    {
        [self appendTodaysDataForSensor:@"Screen"];
        [self setupMultiLineChart ];
    }
    else if([_selectedSensor isEqualToString: @"Social"])
    {
        [self appendTodaysDataForSensor:@"Calls"];
        [self setupMultiLineChart ];
    }
    else if([_selectedSensor isEqualToString:@"Locations"])
    {
        [_mapview setDelegate:self];
        [_mapview setShowsUserLocation:YES];
        [_mapview setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        
        [self appendTodaysDataForSensor:@"Locations"];
        _dataVisualizationSelector = NSSelectorFromString(@"drawRouteForTimeKey:");
    }
    else if([_selectedSensor isEqualToString:@"Activity"])
    {
        [self appendTodaysDataForSensor:@"Activity"];
        [self setupMultiLineChart ];
    }
    else if([_selectedSensor isEqualToString:@"Ambience"])
    {
        [self appendTodaysDataForSensor:@"AmbientNoise"];
        [self appendTodaysDataForSensor:@"AmbientLight"];
        [self setupMultiLineChart ];
    }
    else if([_selectedSensor isEqualToString:@"Battery"])
    {
        [self appendTodaysDataForSensor:@"Battery"];
        [self setupMultiLineChart ];
    }
    
    [self performSelector:_dataVisualizationSelector withObject:defaultTimeKey];
}


/*
 *  Callback function for rendering a route on a Map View. Configure the properties of the rendered route line here
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
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

/*
 *  Render a trace of GPS locations visited by a user onto the map view. Filter the paths by the time of day
 */
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

/*
 *  Render a data set on the chart
 */
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

/*
 *  Configure multi line chart grid, gesture interactions, display
 */
-(void) setupMultiLineChart
{
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

/*
 *  Respond to tab selections by the user on the time-of-day filter tabs
 */
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

/*
 *  Query (numeric) formatted data from each sensor, organize it in the todaysData dictionary by the time of day it was collected. Use the time boundaries
 */
- (void) appendTodaysDataForSensor:(NSString*)sensorName
{
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
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

@end
