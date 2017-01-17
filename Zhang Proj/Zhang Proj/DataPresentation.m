//
//  DataPresentation.m
//  Zhang Proj
//
//  Created by Ian Bacus on 1/16/17.
//  Copyright © 2017 Ian Bacus. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  PSCustomViewFromXib.m
//  CustomView
//
//  Created by Paul Solt on 4/28/14.
//  Copyright (c) 2014 Paul Solt. All rights reserved.
//

#import "DataPresentation.h"

@implementation DataPresentation


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1. Load the .xib file .xib file must match classname
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        _customView.frame = self.bounds;
        // 2. Set the bounds if not set by programmer (i.e. init called)
        if(CGRectIsEmpty(frame)) {
            self.bounds = _customView.bounds;
        }
        
        // 3. Add as a subview
        [self addSubview:_customView];
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        
        // 1. Load .xib file
        NSString *className = NSStringFromClass([self class]);
        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        _customView.frame = self.bounds;
        // 2. Add as a subview
        [self addSubview:_customView];
        
    }
    return self;
}


@end
