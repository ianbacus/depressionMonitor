#import "IndexViewController.h"
#import "DataViewController.h"


@implementation IndexViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.onColor = [UIColor colorWithRed:(218/256) green:(236/256) blue:(239/256) alpha:1];
    self.onColors = [[NSArray alloc] initWithObjects:
                     [UIColor colorWithRed:.85 green:.92 blue:.93 alpha:1],
                     [UIColor colorWithRed:.42 green:.75 blue:.99 alpha:1],
                     [UIColor colorWithRed:.77 green:.9 blue:.7 alpha:1],
                     [UIColor colorWithRed:.98 green:.82 blue:.48 alpha:1],
                     nil];
    
    self.currentColors = [[NSMutableArray alloc] initWithArray:self.onColors copyItems:YES];
    
    self.sensorStates =[[NSMutableArray alloc] initWithObjects:
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        [NSNumber numberWithBool:YES],
                        nil];
    
    self.sensors= [[NSArray alloc] initWithObjects:
                   [self getSensorCellDataByName:@"Phone"],
                   [self getSensorCellDataByName:@"Social"],
                   [self getSensorCellDataByName:@"Activity"],
                   [self getSensorCellDataByName:@"Ambience"],
                   
                   nil];
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(leftSwipe:)];
    
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(rightSwipe:)];
    recognizer.delegate = self;
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:recognizer];
    
    [_sensorTab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Declare the view controller
    DataViewController *anotherVC = nil;
    anotherVC = [[DataViewController alloc] init ];//]initWithNibName:@"chart" bundle:nil];
    
    // Get cell textLabel string to use in new view controller title
    NSString *cellTitleText = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
    _selectedSensor =cellTitleText;
    // Set title indicating what row/section was tapped
    [anotherVC setTitle:[NSString stringWithFormat:@"You tapped section: %ld - row: %ld - Cell Text: %@" ,(long)indexPath.section, (long)indexPath.row, cellTitleText]];
    
    [anotherVC setModalPresentationStyle:UIModalPresentationFormSheet];
    [anotherVC setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    
    if(indexPath.row == 2)
        [self performSegueWithIdentifier:@"mapPreview" sender:self];
    else
        [self performSegueWithIdentifier:@"chartPreview" sender:self];
    //[self.navigationController presentViewController:anotherVC animated:YES completion:NULL];
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier =@"sensorCell";
    
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    cell.textLabel.text = [self.sensors objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Arial" size:24];
    [cell setBackgroundColor:[self.currentColors objectAtIndex:indexPath.row]];
    [cell.layer setCornerRadius:7.0f];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderWidth:2.0f];
   // cell.backgroundView = [[UIImageView alloc] initWithImage:[
   //                                                           [[self.sensors objectAtIndex:indexPath.row] objectForKey:@"Image"]
   //                                                           stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0] ];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"sensorPreview"])
    {
        DataViewController *vc = [segue destinationViewController];
        vc.selectedSensor = _selectedSensor;
    }
}

- (void)leftSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Turn off
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if([[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1]];
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationLeft];
        [self changeSensors:indexPath toMode:NO];
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)rightSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Turn on
    
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if(![[_sensorStates objectAtIndex:indexPath.row] boolValue])
    {
        [_currentColors replaceObjectAtIndex:indexPath.row withObject:[self.onColors objectAtIndex:indexPath.row]];
        [_sensorTab reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationRight];
        [self changeSensors:indexPath toMode:YES];
        [_sensorStates replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
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
            [[app sensorManager] performSelector:changeMode withObject:@"Activity"];
            [[app sensorManager] performSelector:changeMode withObject:@"Location"];
            [[app sensorManager] performSelector:changeMode withObject:@"Pedometer"];
            break;
        }
        case 3:
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
    return [self.sensors count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sensors count];
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
