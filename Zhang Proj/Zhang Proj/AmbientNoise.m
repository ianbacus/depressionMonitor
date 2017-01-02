//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import "AmbientNoise.h"
#import "AudioAnalysis.h"
#import "AppDelegate.h"

static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;

@implementation AmbientNoise{
    
    NSTimer *timer;
    
    int frequencyMin;
    int sampleSize;
    int silenceThreshold;
    
    float recordingSampleRate;
    float targetSampleRate;
    float maxFrequency;
    
    double db;
    double rms;
    double lastdb;

    BOOL saveRawData;
    
    NSString * KEY_AUDIO_CLIP_NUMBER;
}

-(instancetype) initSensor
{
    self = [super init];
    if(self)
    {
        self.dataTable = [[NSMutableDictionary alloc] init];
        self._name = @"Calls";
        frequencyMin = 5;
        sampleSize = 30;
        silenceThreshold = 50;
        
        recordingSampleRate = 44100;
        targetSampleRate = 8000;
        
        maxFrequency = 0;
        db = 0;
        rms = 0;
        lastdb = 0;
        
        saveRawData = NO;
        
        KEY_AUDIO_CLIP_NUMBER = @"key_audio_clip";
        
        [self createRawAudioDataDirectory];
        [self setupMicrophone];
    }
    return self;
}


-(BOOL) startCollecting
{
    
    /*
    if(saveRawData){
        [self setFetchLimit:10];
    }else{
        [self setFetchLimit:100];
    }*/
    // currentSecond = 0;
    frequencyMin = 5;
    sampleSize = 30;
    silenceThreshold = 50;
    
    saveRawData = NO;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0f*frequencyMin
                                             target:self
                                           selector:@selector(startRecording:)
                                           userInfo:[NSDictionary dictionaryWithObject:@0 forKey:KEY_AUDIO_CLIP_NUMBER]
                                            repeats:YES];
    [timer fire];
    return YES;
}

-(BOOL) stopCollecting
{
    return YES;
}

-(void)setupMicrophone {
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers|
     AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    if (error) {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    AudioStreamBasicDescription asbd = [EZAudioUtilities floatFormatWithNumberOfChannels:1 sampleRate:recordingSampleRate];
    //AudioStreamBasicDescription absd = [self monoSIntFormatWithSampleRate:8000];
    
    self.microphone = [EZMicrophone microphoneWithDelegate:self withAudioStreamBasicDescription:asbd];
}


/**
 * Start recording ambient noise
 */
- (void) startRecording:(id)sender{
    if (self.microphone == nil) {
        [self setupMicrophone];
    }
    NSNumber * number = @-1;
    if([sender isKindOfClass:[NSTimer class]]){
        NSDictionary * userInfo = ((NSTimer *) sender).userInfo;
        number = [userInfo objectForKey:KEY_AUDIO_CLIP_NUMBER];
    }else if([sender isKindOfClass:[NSDictionary class]]){
        number = [(NSDictionary *)sender objectForKey:KEY_AUDIO_CLIP_NUMBER];
    }else{
        NSLog(@"An error at ambient noise sensor. There is an unknown userInfo format.");
    }
    
    // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
    self.fft = [EZAudioFFTRolling fftWithWindowSize:FFTViewControllerFFTWindowSize
                                         sampleRate:self.microphone.audioStreamBasicDescription.mSampleRate
                                           delegate:self];
    
    [self.microphone startFetchingAudio];
    self.recorder = [EZRecorder recorderWithURL:[self testFilePathURLWithNumber:[number intValue]]
                                   clientFormat:[self.microphone audioStreamBasicDescription]
                                       fileType:EZRecorderFileTypeM4A
                                       delegate:self];
    _isRecording = YES;
    [self performSelector:@selector(stopRecording:)
               withObject:[NSDictionary dictionaryWithObject:number forKey:KEY_AUDIO_CLIP_NUMBER]
               afterDelay:1];
}


/**
 * Stop recording ambient noise
 */
- (void) stopRecording:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        int number = -1;
        if(sender != nil){
            number = [[(NSDictionary * )sender objectForKey:KEY_AUDIO_CLIP_NUMBER] intValue];
        }
        
        // stop fetching audio
        [self.microphone stopFetchingAudio];
        // stop recording audio
        [self.recorder closeAudioFile];
        // Save audio data
        [self saveAudioDataWithNumber:number];
        
        // init variables
        self.recorder = nil;
        maxFrequency = 0;
        db = 0;
        rms = 0;
        
        // check a dutyCycle
        if( sampleSize > number ){
            number++;
            [self startRecording:[NSDictionary dictionaryWithObject:@(number) forKey:KEY_AUDIO_CLIP_NUMBER]];
        }else{
            NSLog(@"Stop Recording");
            number = 0;
            _isRecording = NO;
        }
    });
}


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

- (void) saveAudioDataWithNumber:(int)number {
    
    NSString* dataString = nil;
    if([AudioAnalysis isSilent:rms threshold:silenceThreshold])
    {
        dataString = @"Silent";
    }
    else
    {
        dataString = [NSString stringWithFormat:@"dB:%f, RMS:%f, Frequency:%f", db, rms, maxFrequency];
    }
    NSLog(@"%@",dataString);
    //if(saveRawData) { NSData * data = [NSData dataWithContentsOfURL:[self testFilePathURLWithNumber:number]]; }
 
}

///////////////////////////////////////////////
//////////////////////////////////////////////
/**
 Returns back the buffer list containing the audio received. This occurs on the background thread so any drawing code must explicity perform its functions on the main thread.
 @param microphone       The instance of the EZMicrophone that triggered the event.
 @param bufferList       The AudioBufferList holding the audio data.
 @param bufferSize       The size of each of the buffers of the AudioBufferList.
 @param numberOfChannels The number of channels for the incoming audio.
 @warning This function executes on a background thread to avoid blocking any audio operations. If operations should be performed on any other thread (like the main thread) it should be performed within a dispatch block like so: dispatch_async(dispatch_get_main_queue(), ^{ ...Your Code... })
 */
- (void)    microphone:(EZMicrophone *)microphone
         hasBufferList:(AudioBufferList *)bufferList
        withBufferSize:(UInt32)bufferSize
  withNumberOfChannels:(UInt32)numberOfChannels{
    if (self.isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}


- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSURL *)testFilePathURLWithNumber:(int)number{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%d_%@",
                                   [self applicationDocumentsDirectory],
                                   kRawAudioDirectory,
                                   number,
                                   kAudioFilePath]];
}

- (BOOL) createRawAudioDataDirectory{
    NSString *basePath = [self applicationDocumentsDirectory];
    NSString *newCacheDirPath = [basePath stringByAppendingPathComponent:kRawAudioDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL created = [fileManager createDirectoryAtPath:newCacheDirPath
                          withIntermediateDirectories:YES
                                           attributes:nil
                                                error:&error];
    if (!created) {
        NSLog(@"failed to create directory. reason is %@ - %@", error, error.userInfo);
        return NO;
    }else{
        return YES;
    }
}


/////////////////////////////////////////////
///////////////////////////////////////////////
// FFT delegate
- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    maxFrequency = [fft maxFrequency];
    //    NSLog(@"%f", maxFrequency);
    //    [self setLatestValue:[NSString stringWithFormat:@"dB:%f, RMS:%f, Frequency:%f", db, rms, maxFrequency]];
}


- (void)    microphone:(EZMicrophone *)microphone
      hasAudioReceived:(float **)buffer
        withBufferSize:(UInt32)bufferSize
  withNumberOfChannels:(UInt32)numberOfChannels{
    __weak typeof (self) weakSelf = self;
    // Getting audio data as an array of float buffer arrays that can be fed into the
    // EZAudioPlot, EZAudioPlotGL, or whatever visualization you would like to do with
    // the microphone data.
    
    //
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    //
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    //
    // Calculate the RMS with buffer and bufferSize
    // NOTE: 1000
    //
    rms = [EZAudioUtilities RMS:*buffer length:bufferSize] * 1000;
    // NSLog(@"%f", rms);
    
    //
    // Decibel Calculation.
    // https://github.com/syedhali/EZAudio/issues/50
    //
    float one       = 1.0;
    float meanVal = 0.0;
    float tiny = 0.1;
    
    vDSP_vsq(buffer[0], 1, buffer[0], 1, bufferSize);
    vDSP_meanv(buffer[0], 1, &meanVal, bufferSize);
    vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
    
    float currentdb = 1.0 - (fabs(meanVal)/100);
    
    if (lastdb == INFINITY || lastdb == -INFINITY || isnan(lastdb)) {
        lastdb = 0.0;
    }
    db =   ((1.0 - tiny)*lastdb) + tiny*currentdb;
    lastdb = db;
    
}

//------------------------------------------------------------------------------


///////////////////////////////////////////////
///////////////////////////////////////////////
// EZRecorderDelegate
/**
 Triggers when the EZRecorder is explicitly closed with the `closeAudioFile` method.
 @param recorder The EZRecorder instance that triggered the action
 */
- (void)recorderDidClose:(EZRecorder *)recorder{
    recorder.delegate = nil;
}

/**
 Triggers after the EZRecorder has successfully written audio data from the `appendDataFromBufferList:withBufferSize:` method.
 @param recorder The EZRecorder instance that triggered the action
 */
- (void)recorderUpdatedCurrentTime:(EZRecorder *)recorder{
    //    __weak typeof (self) weakSelf = self;
    //    NSString *formattedCurrentTime = [recorder formattedCurrentTime];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        weakSelf.currentTimeLabel.text = formattedCurrentTime;
    //    });
}


@end

