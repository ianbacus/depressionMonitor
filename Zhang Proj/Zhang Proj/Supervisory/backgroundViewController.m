#import "backgroundViewController.h"

@implementation BackgroundViewController

- (IBAction)segmentChanged:(id)sender
{
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
   
    UISegmentedControl * seg = (UISegmentedControl *)sender;
    //if (seg.selectedSegmentIndex == 0)
    //NSString *option = [seg valueForKeyPath:@"Sensor"];
    
    NSArray *options = [NSArray arrayWithObjects:@"", @"Activity", @"Calls", @"Screen", @"Locations", @"Camera", @"AmbientNoise", @"AmbientLight", nil];
    NSString* option = [options objectAtIndex:[seg tag]];
    if([seg selectedSegmentIndex]==0)
         [[app sensorManager] startPeriodicCollectionForSensor:option];
    else
        [[app sensorManager] stopPeriodicCollectionForSensor:option];
}

- (IBAction) uploadData:(id)sender
{
    AppDelegate * app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    //[[app sensorManager] uploadSensorData:[NSURL URLWithString:@"http://10.0.0.57:3000"]];
    [[app sensorManager] acceptDataFromSensors];
    [[app sensorManager] uploadSensorData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VC");
    
    //[sensorMgr initSensorManager]
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}



@end
