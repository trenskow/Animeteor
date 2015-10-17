//
//  AMAnimationGroup.m
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

#import "NSMutableArray+AMAnimationGroupAdditions.h"
#import "NSMutableDictionary+AMAnimationGroupAdditions.h"

#import "AMAnimation.h"

#import "AMAnimationGroup.h"

const char AMAnimationGroupKey;
char AMAnimationGroupObserverContext;

@interface AMAnimationGroup () {
    
    NSMutableArray *_animations;
    BOOL _animationFinished;
    BOOL _beginsImmediately;
    
}
@property (nonatomic,getter = isAnimating) BOOL animating;
@property (nonatomic,getter = isComplete) BOOL complete;
@property (nonatomic,getter = hasFinished) BOOL finished;

@end

@implementation AMAnimationGroup

#pragma mark - Setup / Teardown

- (instancetype)initWithAnimations:(NSArray *)animations completion:(void(^)(BOOL finished))completion {
    
    AMAssertMainThread();
    
    if ((self = [super init])) {
        
        _animations = [[NSMutableArray alloc] init];
        _completion = [completion copy];
        
        _animationFinished = YES;
        
        for (id<AMAnimation> animation in animations)
            [self addAnimation:animation animateAfter:nil];
        
    }
    
    return self;
    
}

#pragma mark - Internals

- (NSMutableArray *)animationGroupsForAnimation:(id<AMAnimation>)animation {
    
    NSMutableArray *animationGroups = objc_getAssociatedObject(animation, &AMAnimationGroupKey);
    if (!animationGroups) {
        animationGroups = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(animation, &AMAnimationGroupKey, animationGroups, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return animationGroups;
    
}

#pragma mark - Managing Animations

- (void)addAnimation:(id<AMAnimation>)animation animateAfter:(id<AMAnimation>)animateAfter {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    /* Check if an actual animation is being added */
    if (animation) {
        
        /* Tell animation to postpone it's animation so we can manage this in the group */
        [animation postponeAnimation];
        
        [_animations addObject:[NSMutableDictionary dictionaryWithAnimation:animation animatedAfter:animateAfter]];
        
        /* Add observer for when animation completes */
        [(id)animation addObserver:self forKeyPath:@"complete" options:0 context:&AMAnimationGroupObserverContext];
        
        /* Associate group with animation so it will retain it as long as animation lives */
        [[self animationGroupsForAnimation:animation] addObject:self];
        
    }
    
}

- (void)addAnimation:(id<AMAnimation>)animation {
    
    [self addAnimation:animation animateAfter:nil];
    
}

- (void)beginAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    /* Start by cancelling any scheduled calls */
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
    if ([_animations count] > 0) {
        
        if (!self.isAnimating)
            self.animating = YES;
        
        /* Create a copy in order to prevent mutation exceptions while enumerating */
        NSArray *animations = [_animations copy];
        
        for (NSMutableDictionary *a in animations)
            if (!a.animatedAfter && !a.animation.isAnimating)
                [a.animation beginAnimation];
        
    } else {
        
        
        if (self.completion)
            self.completion(_animationFinished);
        
        self.finished = _animationFinished;
        self.complete = YES;
        self.animating = NO;
        
    }
    
}

- (void)postponeAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
}

- (void)cancelAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    while ([_animations count] > 0)
        [[[_animations firstObject] animation] cancelAnimation];
    
}

#pragma mark - Properties

@synthesize completion=_completion;

- (NSTimeInterval)duration {
    
    AMAssertMainThread();
    
    NSTimeInterval duration = .0;
    
    /* Iterate animations and find the longest running */
    for (NSMutableDictionary *a in _animations) {
        NSTimeInterval animDuration = a.animation.delay + a.animation.duration;
        if (a.animatedAfter)
            animDuration += a.animatedAfter.delay + a.animatedAfter.duration;
        duration = MAX(duration, animDuration);
        
    }
    
    return duration - self.delay;
    
}

/* Finds the lowest delay of all animations */
- (NSTimeInterval)delay {
    
    AMAssertMainThread();
    
    NSTimeInterval delay = DBL_MAX;
    
    for (NSMutableDictionary *a in _animations)
        if (!a.animatedAfter)
            delay = MIN(delay, a.animation.delay);
    
    return (delay < DBL_MAX ? delay : .0);
    
}

- (void)setDelay:(NSTimeInterval)delay {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    NSTimeInterval delayDiff = MAX(delay, .0) - self.delay;
    
    for (NSMutableDictionary *a in _animations)
        if (!a.animatedAfter)
            a.animation.delay += delayDiff;
    
}

- (void)setCompletion:(AMCompletionBlock)completion {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    _completion = [completion copy];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == &AMAnimationGroupObserverContext) {
        
        /* We really only observe once kind of value */
        [object removeObserver:self forKeyPath:@"complete" context:&AMAnimationGroupObserverContext];
        [_animations removeAnimation:object];
        
        /* Find all animations waiting on this animation and remove them */
        for (NSMutableDictionary *a in _animations)
            if (a.animatedAfter == object)
                a.animatedAfter = nil;
        
        BOOL finished = [object isFinished];
        _animationFinished = _animationFinished && finished;
        
        /* Call beginAnimation again to start any waiting animations */
        [self beginAnimation];
        
        /* Remove association with animation in order to get released when all animations are done */
        [[self animationGroupsForAnimation:object] removeObject:self];
        
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
}

@end
