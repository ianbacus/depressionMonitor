//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


// Decibel Calculation.
// https://github.com/syedhali/EZAudio/issues/50




#import "AmbientNoise.h"
#import "AudioAnalysis.h"
#import "AppDelegate.h"

static vDSP_Length const FFTViewControllerFFTWindowSize = 4096;

@implementation AmbientNoise{
    
    NSTimer *timer;
    
    int sampleSize;
    int silenceThreshold;
    
    float samplingInterval;
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
        self._name = @"AmbientNoise";
        
        self.samplingInterval = 100.0f;
        sampleSize = 30;
        silenceThreshold = 10;
        recordingSampleRate = 44100;
        
        //Processed values from raw Audio data
        maxFrequency = 0;
        db = 0;
        rms = 0;
        lastdb = 0;
        
        //If true: save audio file with collected samples
        saveRawData = NO;
        
        KEY_AUDIO_CLIP_NUMBER = @"key_audio_clip";
        
        [self createRawAudioDataDirectory];
        [self setupMicrophone];
    }
    return self;
}

/*
 *  Return [time, decibel] pairs
 */
-(NSArray*) createDataSetFromDBData:(NSArray*)dbData
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for(int dataIndex=0;dataIndex<[dbData count]; dataIndex++)
    {
        id obj = [dbData objectAtIndex:dataIndex];
        
        
        //Extract decibels from the data entry, unless silence is indicated
        NSNumber* data = nil;
        if([[obj valueForKey:@"stateVal"] isEqualToString:@"Silent"])
            data = 0;
        else
            data =  [[NSNumber alloc ] initWithDouble:
                         [[[obj valueForKey:@"stateVal"] componentsSeparatedByString:@","]
                          [0] //0:dB,1:RMS,2:Frequency
                          doubleValue] ];
        NSDictionary *datum = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [obj valueForKey:@"time"],@"x",
                               data,@"y",
                               nil
                               ];
        [ret addObject:datum];
    }
    return ret;
}

/*
 *  Save recorded audio data from one period of recording. Save decibels, RMS, and the peak frequency. If the RMS is below the silence threshold, save an entry indicating silence.
 */
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
    [self saveData:dataString];
    //if(saveRawData) { NSData * data = [NSData dataWithContentsOfURL:[self testFilePathURLWithNumber:number]]; }
}


-(BOOL) startCollectingAtInterval:(double)interval
{
    [super startCollecting];
    samplingInterval = interval;
    timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                             target:self
                                           selector:@selector(startRecording:)
                                           userInfo:[NSDictionary dictionaryWithObject:@0 forKey:KEY_AUDIO_CLIP_NUMBER]
                                            repeats:YES];
    [timer fire];
    return YES;
}

-(BOOL) startCollecting
{
    [super startCollecting];
    [self startCollectingAtInterval:self.samplingInterval];
    return YES;
}

-(BOOL) changeCollectionInterval:(double)interval
{
    if([self isCollecting])
    {
        [self stopCollecting];
        [self startCollectingAtInterval:interval];
    }
    return YES;
}

/*
 *  Set the recording sample rate, resume collection
 */
-(BOOL) changeSamplingRate:(long)samplingRate
{
    [self stopCollecting];
    recordingSampleRate = samplingRate;
    [self startCollecting];
    return YES;
}



-(BOOL) changeDutyCycle:(double)cycle
{
    sampleSize = cycle*samplingInterval;
    return YES;
}



-(BOOL) stopCollecting
{
    [super stopCollecting];
    [timer invalidate];
    timer = nil;
    
    [self.microphone stopFetchingAudio];
    [self.recorder closeAudioFile];
    self.microphone = nil;
    return YES;
}

/*
 *  Set up audio recording session, initialize microphone
 */
-(void)setupMicrophone
{
    // Setup the AVAudioSession.
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
    self.microphone = [EZMicrophone microphoneWithDelegate:self withAudioStreamBasicDescription:asbd];
}


/*
 *
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
        NSLog(@"Ambient noise sensor error: unknown userInfo format");
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

/*
 *  Manage the duty cycle of recording, stop when the specified number of collection periods have happened
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
        
        // check dutyCycle
        if( sampleSize > number )
        {
            number++;
            [self startRecording:[NSDictionary dictionaryWithObject:@(number) forKey:KEY_AUDIO_CLIP_NUMBER]];
        }
        else
        {
            number = 0;
            _isRecording = NO;
        }
    });
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


/*
 *  FFT delegate
 */
- (void)        fft:(EZAudioFFT *)fft
 updatedWithFFTData:(float *)fftData
         bufferSize:(vDSP_Length)bufferSize
{
    maxFrequency = [fft maxFrequency];
}


- (void)    microphone:(EZMicrophone *)microphone
      hasAudioReceived:(float **)buffer
        withBufferSize:(UInt32)bufferSize
// Getting audio data as an array of float buffer arrays that can be fed into the
// EZAudioPlot, EZAudioPlotGL, or whatever visualization you would like to do with
// the microphone data.
  withNumberOfChannels:(UInt32)numberOfChannels{
    
    // Calculate the FFT, will trigger EZAudioFFTDelegate
    [self.fft computeFFTWithBuffer:buffer[0] withBufferSize:bufferSize];
    
    // Calculate the RMS with buffer and bufferSize
    rms = [EZAudioUtilities RMS:*buffer length:bufferSize] * 1000;
    
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

