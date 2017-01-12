//
//  IOSActivityRecognition.h
//  Zhang Proj
//
//  Created by Ian Bacus on 12/20/16.
//  Copyright © 2016 Ian Bacus. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface AudioAnalysis : NSObject

- (instancetype) initWithBuffer:(float *)buffer bufferSize:(UInt32)bufferSize;

- (double) getRMS;
- (double) getFrequency;
- (double) getdB;
+ (BOOL) isSilent:(double)rms threshold:(int)threshold;

@end
