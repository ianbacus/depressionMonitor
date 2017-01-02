//
//  AmbientLight.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import "AmbientLight.h"

@implementation AmbientLight


- (instancetype)init
{
    if (self) {
        self.dataTable = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) startcollecting
{
    [super startCollecting];
    _dataCollectionTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(getScreenBrightness) userInfo:nil repeats:YES];
    return YES;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_dataCollectionTimer invalidate];
    _dataCollectionTimer = nil;
    return YES;
}

-(void) getScreenBrightness
{
    NSString* brightnessStr = [NSString stringWithFormat:@"%f",[[UIScreen mainScreen] brightness]];
    NSLog(@"Screen Brightness: %@",brightnessStr);
    [self.dataTable setObject:brightnessStr forKey:[NSDate date]];
}

@end



