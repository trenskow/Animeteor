//
//  AMLayerAnimation.m
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

#import "AMMacros.h"

#import "AMAnimation.h"
#import "AMCurve.h"
#import "AMCurvedAnimation.h"
#import "AMInterpolatable.h"

#import "AMLayerAnimation.h"

#define ANIMATION_KEY_FOR_KEYPATH(x) [NSString stringWithFormat:@"layerAnimation.%@", x]

const void *AMAnimationLayerKey;

NSString *const AMLayerAnimationKey = @"AMAnimationKey";

@interface AMLayerAnimation ()

@property (nonatomic,copy) NSString *keyPath;
@property (nonatomic,copy) id<AMInterpolatable> fromValue;
@property (nonatomic,copy) id<AMInterpolatable> toValue;

@property (nonatomic,getter = isAnimating) BOOL animating;
@property (nonatomic,getter = isComplete) BOOL complete;
@property (nonatomic,getter = isFinished) BOOL finished;
@property (copy,nonatomic) AMCurve *curve;
@property (copy,nonatomic) void(^completionBlock)(BOOL finished);
@property (weak,readwrite,nonatomic) CALayer *layer;

@end

@implementation AMLayerAnimation

#pragma mark - Setup / Teardown

- (instancetype)initWithLayer:(CALayer *)layer
                      keyPath:(NSString *)keyPath
                    fromValue:(id<AMInterpolatable>)fromValue
                      toValue:(id<AMInterpolatable>)toValue
                     duration:(NSTimeInterval)duration
                        delay:(NSTimeInterval)delay
                        curve:(AMCurve *)curve
                   completion:(void (^)(BOOL finished))completion {
    
    AMAssertMainThread();
    
    if ((self = [super init])) {
        
        self.layer = layer;
        self.duration = duration;
        self.delay = delay;
        self.keyPath = keyPath;
        self.fromValue = fromValue;
        self.toValue = toValue;
        self.curve = (curve ?: [AMCurve linear]);
        self.completionBlock = completion;
        
        /* Associate animation object with view, so it won't be released doing animation */
        objc_setAssociatedObject(self.layer, &AMAnimationLayerKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    return self;
    
}

#pragma mark - Properties

@synthesize delay=_delay;

- (void)setDuration:(NSTimeInterval)duration {
    
    AMAssertMainThread();
    
    _duration = duration;
    
}

- (void)setDelay:(NSTimeInterval)delay {
    
    AMAssertMainThread();
    
    _delay = delay;
    
}

#pragma mark - Internal

- (void)animationDidStart:(AMCurvedAnimation *)anim {
    
    [self animationStarted];
    
}

- (void)animationDidStop:(AMCurvedAnimation *)anim finished:(BOOL)flag {
    
    [self animationCompleted:flag];
    
}

- (void)prepareAnimation:(AMCurvedAnimation *)animation usingKey:(NSString *)key {
    
    animation.duration = self.duration;
    animation.curve = self.curve;
    
    [animation setValue:key forKey:AMLayerAnimationKey];
    
    animation.delegate = self;
    
    [self.layer addAnimation:animation forKey:key];
    
}

- (void)beginAnimation {
    
    AMAssertMainThread();
    
    if (!self.isAnimating) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
        
        _fromValue = _fromValue ?: [_layer valueForKeyPath:_keyPath];
        _curve = _curve ?: [AMCurve linear];
        
        self.animating = YES;
        
        [self performSelector:@selector(setupAnimations)
                   withObject:nil
                   afterDelay:self.delay
                      inModes:@[NSRunLoopCommonModes]];
    }
    
}

- (void)postponeAnimation {
    
    AMAssertMainThread();
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
}

- (void)cancelAnimation {
    
    AMAssertMainThread();
    
    // Animation has not yet begun
    if (!self.isAnimating && !self.isComplete) {
        
        [self postponeAnimation];
        
    } else if (self.isAnimating && !self.isComplete) {
        
        // We need to determine if we are on a delay or on actually animating.
        // We do that by checking if the animation has been added to the layer.
        
        // Animation is in it's delay.
        if (![self.layer animationForKey:ANIMATION_KEY_FOR_KEYPATH(self.keyPath)]) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupAnimations) object:nil];
            [self animationCompleted:NO];
            
        } else { // Animation is in progress.
            
            [self.layer setValue:[self.layer.presentationLayer valueForKeyPath:self.keyPath]
                      forKeyPath:self.keyPath];
            [self.layer removeAnimationForKey:ANIMATION_KEY_FOR_KEYPATH(self.keyPath)];
            
        }
        
    }
    
}

- (void)animationStarted {
    
    [self.layer setValue:[_fromValue interpolateWithValue:_toValue
                                               atPosition:[self.curve transform:1.0]]
              forKeyPath:_keyPath];
    
}

- (void)animationCompleted:(BOOL)finished {

    if (self.completionBlock)
        self.completionBlock(finished);
    
    self.complete = YES;
    self.finished = finished;
    
    /* Remove animation from view so it can be released */
    objc_setAssociatedObject(self.layer, &AMAnimationLayerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)setupAnimations {
    
    AMCurvedAnimation *customAnimation = [AMCurvedAnimation animationWithKeyPath:_keyPath];
    customAnimation.fromValue = _fromValue;
    customAnimation.toValue = _toValue;
    
    [self.layer setValue:[_fromValue interpolateWithValue:_toValue
                                               atPosition:[self.curve transform:1.0]]
              forKeyPath:_keyPath];
    
    [self prepareAnimation:customAnimation usingKey:ANIMATION_KEY_FOR_KEYPATH(_keyPath)];
    
}

#pragma mark - Creating Animation

+ (BOOL)inProgressOn:(CALayer *)layer withKeyPath:(NSString *)keyPath {
    
    AMCurvedAnimation *animation = (AMCurvedAnimation *)[layer animationForKey:ANIMATION_KEY_FOR_KEYPATH(keyPath)];
    return (animation && [animation.keyPath isEqualToString:keyPath]);
    
}

@end
