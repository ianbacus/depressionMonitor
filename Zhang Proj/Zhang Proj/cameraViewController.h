//
//  UIViewController_CameraViewController.h
//  TEXAS_INSTRUMENTS
//
//  Created by Ian Bacus on 2/19/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>


//@interface CameraViewController : UIViewController
@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    bool face_detected;
    bool face_test;
    int degreeMode;
    IBOutlet UISegmentedControl *segmentedControl;
    
}

//@property (nonatomic) AVCaptureVideoPreviewLayer * previewLayer;
//@property (nonatomic) CAShapeLayer * drawLayer;
//@property (nonatomic) UIBezierPath* trianglePath;


@property (nonatomic) AVCaptureSession * captureSession;
@property (strong,atomic) NSMutableArray *widths,*previous_widths;

//@property (nonatomic) IBOutlet UIView *cameraPreviewView;
//@property (nonatomic, retain) IBOutlet UILabel *sampleLabel;

//@property (strong, nonatomic) IBOutlet UISegmentedControl * segmentedControl;

/*
- (IBAction)segmentChanged:(id)sender;
-(BOOL) getFeatureWidth:(CIImage *)frame_sample;
- (void)drawme ;
*/

- (CIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;
-(void) setupCaptureSession;


@end


//@interface CameraViewController() <AVCaptureVideoDataOutputSampleBufferDelegate>;
//@end
