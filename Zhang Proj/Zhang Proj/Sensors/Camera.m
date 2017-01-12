//
//  Camera.m
//  Zhang Proj
//
//  Created by Ian Bacus on 12/28/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"
@import Foundation;

@implementation Camera


@synthesize captureSession = _captureSession;
@synthesize widths = _widths;

//@synthesize face_bool = _face_bool;

//This is the callback for the video buffer queue
//Compliant with protocol set in the SetupCaptureSession function when the queue is configured

-(instancetype) initSensor
{
    self = [super init];
    if(self)
    {
        self._name = @"Camera";
        [self setupCaptureSession];
        [self ConfigCamera];
        
    }
    return self;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    //-- Start the camera
    [_captureSession startRunning];
    return YES;
}

-(BOOL) stopCollecting
{
    [super stopCollecting];
    [_captureSession stopRunning];
    return YES;
}


-(void) setupCaptureSession
{
    //Enable back-facing camera and set up a capture session, generate a stream out output frames and pass them to a callback serial queue
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == AVCaptureDevicePositionFront) backFacingCamera = device;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    
    // Add the video input
    NSError *error = nil;
    AVCaptureDeviceInput* videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    if ([_captureSession canAddInput:videoInput]) [_captureSession addInput:videoInput];
    
    // Add the video frame output
    AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured \
    A serial dispatch queue guarantees that video frames will be delivered in order
    
    dispatch_queue_t videoOutputQueue = dispatch_queue_create("VideoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoOutput setSampleBufferDelegate:self queue:videoOutputQueue];
    
    videoOutput.videoSettings =
    [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    
    //Set minFrameDuration to cap framerate
    if ( [_captureSession canAddOutput:videoOutput] ) [_captureSession addOutput:videoOutput];
    else NSLog(@"Couldn't add video output");
    
    // Start capturing
    [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    if (![_captureSession isRunning]) [_captureSession startRunning];
}

- (void) ConfigCamera
{
    //-- Setup Capture Session.
    _captureSession = [[AVCaptureSession alloc] init];
    
    //-- Creata a video device and input from that Device.  Add the input to the capture session.
    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice == nil) assert(0);
    
    //-- Add the device to the session.
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if(error) assert(0);
    
    [_captureSession addInput:input];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    //TODO: allow to work for multiple camera orientations
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    CIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    //Do processing
    [self getTrianglePoints:image];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        if(face_test)
        {
            face_detected = true;
        }
        else
        {
            face_detected = false;
        }
    }];
}

- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Create a UIImage from sample buffer data
- (CIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock (load a copy of) the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row and byte width/height for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //scaley = (sizeOfCamera.height)/height;
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    // Unlock the pixel buffer, free contexts
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    CIImage *image = [CIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

-(BOOL) getTrianglePoints:(CIImage *)frame_sample
{
    CIImage * image = frame_sample;
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    NSArray* features = [detector featuresInImage:image];
    
    for(CIFaceFeature* faceFeature in features)
    {
        if(faceFeature.hasLeftEyePosition && faceFeature.hasMouthPosition && faceFeature.hasRightEyePosition)
        {
            face_test = true;
        }
        else
        {
            face_test = false;
        }
    }
    return true;
}

@end
