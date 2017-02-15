#import "IndexViewController.h"
#import "DataViewController.h"


@implementation IndexViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1.0];
    
    //Colors for each cell
    _onColors = [[NSArray alloc] initWithObjects:
                        [UIColor colorWithRed:.85 green:.92 blue:.93 alpha:1],
                        [UIColor colorWithRed:.42 green:.75 blue:.99 alpha:1],
                        [UIColor colorWithRed:.42 green:.55 blue:.99 alpha:1],
                        [UIColor colorWithRed:.77 green:.90 blue:.70 alpha:1],
                        [UIColor colorWithRed:.98 green:.82 blue:.48 alpha:1],
                        [UIColor colorWithRed:.42 green:.98 blue:.48 alpha:1],
                 
                     nil];
    
    //Current set colors used to paint cells: can be set to gray or to the appropriate onColor
    _currentColors = [[NSMutableArray alloc] initWithArray:_onColors copyItems:YES];
    
    //States (on/off) for each cell and its sensors, used to determine if data collection is active or has been paused
    _sensorStates =[[NSMutableArray alloc] initWithObjects:
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        nil];
    
    //Sensor titles. Displayed to user, and used as dictionary keys by data view controller to determine which sensors to collect data from. \
    If the titles are changed, change the DataViewController keys as well
    _sensorTitles = [[NSArray alloc] initWithObjects:
                        [self getSensorCellDataByName:@"Phone"],
                        [self getSensorCellDataByName:@"Social"],
                        [self getSensorCellDataByName:@"Locations"],
                        [self getSensorCellDataByName:@"Activity"],
                        [self getSensorCellDataByName:@"Ambience"],
                        [self getSensorCellDataByName:@"Battery"],
                         
                        nil];
    
    //Gesture recognizers for left and right swipes
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];

    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(rightSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer]; //Enable swipe gestures
    
    [_sensorTab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; //Prevent rendering of empty cells after last filled cell
    
}

/*
 *  Cell tap handler: when a cell is tapped, segue to data view controller to display data
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DataViewController *anotherVC = nil;
    anotherVC = [[DataViewController alloc] init ];//]initWithNibName:@"chart" bundle:nil];
    
    NSString *cellTitleText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]; //Pass title to Data VC
    _selectedSensor =cellTitleText;
    [anotherVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [anotherVC setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    
    if(indexPath.row == 2) //Locations segue to map view, everything else segues to a chart view (for now)
        [self performSegueWithIdentifier:@"mapPreview" sender:self];
    else
        [self performSegueWithIdentifier:@"chartPreview" sender:self];
    
}


/*
 *  Generate a new cell given an index into a table view. Use name and color from the initial arrays
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Cell init and update handler
    
    static NSString *CellIdentifier =@"sensorCell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor blackColor])];
    [cell setBackgroundColor:[_currentColors objectAtIndex:indexPath.row]];
    [cell.layer setCornerRadius:10.0f];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderWidth:2.0f];
    
    //Set cell text
    cell.textLabel.text = [_sensorTitles objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:24];
    cell.textLabel.textColor = [UIColor blackColor];
    
    
    return cell;
}

/*
 *  Pass the selected sensor to the data view controller when transitioning views
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //Handle segues to Map and Graph views
    if (([[segue identifier] isEqualToString:@"mapPreview"]) ||
        ([[segue identifier] isEqualToString:@"chartPreview"]) )
    {
        DataViewController *vc = [segue destinationViewController];
        vc.selectedSensor = _selectedSensor;
    }
}

/*
 *  Left swipe: turn off a sensor if it is off
 */
- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Get the location coordinates of where the user's finger hits the touchscreen, determine which cell the user swiped
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    //Check the state of the selected cell. If state == ON, perform the swipe animation and turn the sensor off
    if([[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]];//Set color to gray
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationLeft]; //Animate
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]]; //Change state to off
        [self changeSensors:indexPath toMode:NO];
    }
}

/*
 *  Right swipe: turn on a sensor if it is off
 */
- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Get the location coordinates of where the user's finger hits the touchscreen, determine which cell the user swiped
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    //Check the current state of the cell. If state == OFF, perform the swipe animation and turn its associated sensor on
    if(![[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[_onColors objectAtIndex:indexPath.row]]; //Turn color "on"
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationRight]; //Animate
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]]; //Change state to on
        [self changeSensors:indexPath toMode:YES];
    }
}

/*
 *  Turn the group of sensors associated with a cell on or off using the periodic collection callback
 */
- (void) changeSensors:(NSIndexPath *)group toMode:(bool)active
{
    SEL changeMode = nil;
    //NSString *changeMode = nil;
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if(active)
    {
        changeMode =  NSSelectorFromString(@"startPeriodicCollectionForSensor:");
    }
    else
    {
        changeMode = NSSelectorFromString(@"stopPeriodicCollectionForSensor:");
    }
    
    if ([[app sensorManager] respondsToSelector:changeMode])
    {
        switch (group.row)
        {
            case 0:
            {
                //phone use
                [[app sensorManager] performSelector:changeMode withObject:@"Screen"];
                break;
            }
            case 1:
            {
                //social
                [[app sensorManager] performSelector:changeMode withObject:@"Calls"];
                break;
            }
            case 2:
            {
                //activity, location
                [[app sensorManager] performSelector:changeMode withObject:@"Locations"];
                break;
            }
            case 3:
            {
                //activity
                [[app sensorManager] performSelector:changeMode withObject:@"Activity"];
                [[app sensorManager] performSelector:changeMode withObject:@"Pedometer"];
                break;
            }
            case 4:
            {
                //ambient sound and light
                [[app sensorManager] performSelector:changeMode withObject:@"AmbientNoise"];
                [[app sensorManager] performSelector:changeMode withObject:@"AmbientLight"];
                break;
            }
            case 5:
            {
                //social
                [[app sensorManager] performSelector:changeMode withObject:@"Battery"];
                break;
            }
        }
    }

}

/*
 *  Only one section is used: there are no subdivisions for the cells in the table
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 *  There will be as many rows in the table as there are sensor groups
 */
- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    return [_sensorTitles count];
}

/*
 *  There will be as many rows in the table as there are sensor groups
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sensorTitles count];
}

/*
 *  Get the sensor group name for the cell
 */
- (NSString *) getSensorCellDataByName:(NSString *)sensorName
{
    return sensorName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
