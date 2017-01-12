//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import "Sensor.h"
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>
#include "../EZAudio/EZAudio/EZAudio.h"

//
// By default this will record a file to the application's documents directory
// (within the application's sandbox)
//
#define kAudioFilePath @"rawAudio.m4a"
#define kRawAudioDirectory @"rawAudioData"

@interface AmbientNoise : Sensor
// The microphone component
@property (nonatomic, strong) EZMicrophone *microphone;

// The recorder component
@property (nonatomic, strong) EZRecorder *recorder;

// Used to calculate a rolling FFT of the incoming audio data.
@property (nonatomic, strong) EZAudioFFTRolling *fft;

// A flag indicating whether we are recording or not
@property (nonatomic, assign) BOOL isRecording;


@end


@interface Sensor() <EZMicrophoneDelegate, EZRecorderDelegate, EZAudioFFTDelegate>
@end
