//
//  Camera.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>
#import "Sensor.h"

#ifndef Camera_h
#define Camera_h


@interface Camera : Sensor
{
    bool face_detected;
    bool face_test;
    int degreeMode;
    
}


@property (nonatomic) AVCaptureSession * captureSession;
@property (strong,atomic) NSMutableArray *widths,*previous_widths;


- (CIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;
-(void) setupCaptureSession;


@end


@interface Camera() <AVCaptureVideoDataOutputSampleBufferDelegate>;
@end

#endif /* Camera_h */
