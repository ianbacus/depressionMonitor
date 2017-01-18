#import "IndexViewController.h"
#import "DataViewController.h"


@implementation IndexViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:1.0];
    _onColors = [[NSArray alloc] initWithObjects:
                     [UIColor colorWithRed:.85 green:.92 blue:.93 alpha:1],
                     [UIColor colorWithRed:.42 green:.75 blue:.99 alpha:1],
                     [UIColor colorWithRed:.42 green:.55 blue:.99 alpha:1],
                     [UIColor colorWithRed:.77 green:.90 blue:.70 alpha:1],
                     [UIColor colorWithRed:.98 green:.82 blue:.48 alpha:1],
                     nil]; //Colors for each cell
    _currentColors = [[NSMutableArray alloc] initWithArray:_onColors copyItems:YES];
    
    _sensorStates =[[NSMutableArray alloc] initWithObjects:
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        nil]; //States (on/off) for each cell and its sensors
    
    _sensorTitles = [[NSArray alloc] initWithObjects:
                   [self getSensorCellDataByName:@"Phone"],
                   [self getSensorCellDataByName:@"Social"],
                   [self getSensorCellDataByName:@"Locations"],
                   [self getSensorCellDataByName:@"Activity"],
                   [self getSensorCellDataByName:@"Ambience"],
                   nil]; //Titles for each cell
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];

    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(rightSwipe:)];
    //recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer]; //Enable swipe gestures
    
    [_sensorTab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]]; //Prevent rendering of empty cells after last filled cell
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Cell tap handler
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DataViewController *anotherVC = nil;
    anotherVC = [[DataViewController alloc] init ];//]initWithNibName:@"chart" bundle:nil];
    
    NSString *cellTitleText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]; //Pass title to Data VC
    _selectedSensor =cellTitleText;
    //[anotherVC setTitle:[NSString stringWithFormat:@"You tapped section: %ld - row: %ld - Cell Text: %@" ,(long)indexPath.section, (long)indexPath.row, cellTitleText]]; //Set title of new VC
    
    [anotherVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [anotherVC setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    
    if(indexPath.row == 2) //Locations segue to map view, everything else segues to a chart view (for now)
        [self performSegueWithIdentifier:@"mapPreview" sender:self];
    else
        [self performSegueWithIdentifier:@"chartPreview" sender:self];
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Cell init and update handler
    
    static NSString *CellIdentifier =@"sensorCell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Set cell shape and color: gradient :-)
    //CAGradientLayer *gradient = [CAGradientLayer layer];
    //gradient.frame = cell.bounds;
    //gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor]CGColor], (id)[[_currentColors objectAtIndex:indexPath.row]CGColor], nil];
   // [cell.layer insertSublayer:gradient atIndex:0];
    //[cell.layer addSublayer:gradient];
    
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

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Turn off
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location]; //Get which cell was swiped
    if([[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]];//Set color to gray
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationLeft]; //Animate
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]]; //Change state to off
        [self changeSensors:indexPath toMode:NO];
    }
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Turn on sensor
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location]; //Get which cell was swiped
    if(![[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[_onColors objectAtIndex:indexPath.row]]; //Turn color "on"
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationRight]; //Animate
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]]; //Change state to on
        [self changeSensors:indexPath toMode:YES];
    }
}

- (void) changeSensors:(NSIndexPath *)group toMode:(bool)active
{
    SEL changeMode = nil;
    //NSString *changeMode = nil;
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if(active)
    {
        changeMode =  NSSelectorFromString(@"startPeriodicCollectionForSensor:");
        //changeMode =  @"startPeriodicCollectionForSensor";
    }
    else
    {
        changeMode = NSSelectorFromString(@"stopPeriodicCollectionForSensor:");
        //changeMode = @"stopPeriodicCollectionForSensor";
    }
    
    if (![[app sensorManager] respondsToSelector:changeMode])
    {
        return;
    }
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
            
            [[app sensorManager] performSelector:changeMode withObject:@"Location"];
            
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
            
    
    }

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) numberOfRowsInSection:(NSInteger)section
{
    return [_sensorTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_sensorTitles count];
}

- (NSString *) getSensorCellDataByName:(NSString *)sensorName
{
    return sensorName;
    //return [[NSDictionary alloc] initWithObjectsAndKeys:@"Label",sensorName,@"Image",[UIImage imageNamed:sensorName], nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
