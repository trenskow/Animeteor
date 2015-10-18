//
//  AMDirectAnimation.h
//  Animeteor
//
//  Copyright (c) 2013-2015, Kristian Trenskow
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//  1. Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//  
//  2. Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

@import ObjectiveC.runtime;
@import UIKit;

#import "AMMacros.h"

#import "AMCurve.h"
#import "AMInterpolatable.h"

#import "AMDirectAnimation.h"

const void *AMDirectAnimationKey;

@interface AMDirectAnimation () {
    
    id _object;
    NSString *_keyPath;
    id<AMInterpolatable> _fromValue;
    id<AMInterpolatable> _toValue;
    AMCurve *_curve;
    
    CADisplayLink *_displayLink;
    NSDate *_beginTime;
    
}

@property (nonatomic,readwrite,getter = isAnimating) BOOL animating;
@property (nonatomic,readwrite,getter = isComplete) BOOL complete;
@property (nonatomic,readwrite,getter = isFinished) BOOL finished;

@end

@implementation AMDirectAnimation

#pragma mark - Setup / Teardown

- (instancetype)initWithObject:(id)object
                       keyPath:(NSString *)keyPath
                     fromValue:(id<AMInterpolatable>)fromValue
                       toValue:(id<AMInterpolatable>)toValue
                      duration:(NSTimeInterval)duration
                         delay:(NSTimeInterval)delay
                         curve:(AMCurve *)curve
                    completion:(void (^)(BOOL finished))completion {
    
    AMAssertMainThread();
    
    if ((self = [super init])) {
        
        _object = object;
        _keyPath = keyPath;
        _duration = duration;
        _delay = delay;
        _fromValue = [fromValue copyWithZone:nil];
        _toValue = [toValue copyWithZone:nil];
        _curve = (curve ?: [AMCurve linear]);
        _completion = [completion copy];
        
        objc_setAssociatedObject(self, &AMDirectAnimationKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self performSelector:@selector(beginAnimation)
                   withObject:nil
                   afterDelay:0.0
                      inModes:@[NSRunLoopCommonModes]];
        
    }
    
    return self;
    
}

#pragma mark - Internals

- (void)endAnimation:(BOOL)animationFinished {
    
    [_displayLink invalidate];
    _displayLink = nil;
    
    self.complete = YES;
    self.finished = animationFinished;
    
    if (self.completion)
        self.completion(animationFinished);
    
    objc_setAssociatedObject(self, &AMDirectAnimationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)displayDidUpdate:(CADisplayLink *)displayLink {
    
    double progress = MIN([[NSDate date] timeIntervalSinceDate:_beginTime] / self.duration, 1.0);
    
    if (progress >= 0 && progress <= 1.0)
        [_object setValue:[_fromValue interpolateWithValue:_toValue
                                                atPosition:[_curve transform:progress]]
               forKeyPath:_keyPath];
    
    if (progress == 1.0)
        [self endAnimation:YES];
    
}

#pragma mark - Properties

@synthesize animating;
@synthesize complete;
@synthesize finished;
@synthesize duration=_duration;
@synthesize delay=_delay;
@synthesize completion=_completion;

- (void)setDuration:(NSTimeInterval)duration {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    _duration = duration;
    
}

- (void)setDelay:(NSTimeInterval)delay {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    _delay = delay;
    
}

- (void)setCompletion:(AMCompletionBlock)completion {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    _completion = [completion copy];
    
}

#pragma mark - Public Methods

- (void)beginAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    if (!self.isAnimating) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
        
        _fromValue = _fromValue ?: [_object valueForKeyPath:_keyPath];
        _curve = _curve ?: [AMCurve linear];
        
        _beginTime = [NSDate dateWithTimeIntervalSinceNow:self.delay];
        
        _displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(displayDidUpdate:)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        self.animating = YES;
        
    }
    
}

- (void)postponeAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
}

- (void)cancelAnimation {
    
    AMAssertMainThread();
    
    if (!self.isComplete)
        [self endAnimation:NO];
    
}

@end
