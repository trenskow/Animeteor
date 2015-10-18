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

#import "AMAnimationGroup.h"

const char AMAnimationGroupKey;
char AMAnimationGroupObserverContext;

@interface AMAnimationGroup () {
    
    NSMutableSet *_animations;
    
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
        
        _animations = [[NSMutableSet alloc] init];
        _completion = [completion copy];
        
        _finished = YES;
        
        for (id<AMAnimation> animation in animations)
            [self addAnimation:animation];
        
        /* Schedule animation begin on next run loop tick. */
        [self performSelector:@selector(beginAnimation) withObject:nil afterDelay:0.0];
        
    }
    
    return self;
    
}

#pragma mark - Internals

- (void)animationCompleted:(id<AMAnimation>)animation {
    
    self.finished = self.isFinished && animation.isFinished;
    
    /* Remove the observer */
    [(id)animation removeObserver:self forKeyPath:@"complete" context:&AMAnimationGroupObserverContext];
    
    /* Remove self association so we can get released when done. */
    objc_setAssociatedObject(animation, &AMAnimationGroupKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [_animations removeObject:animation];
    
    /* When all animations has completed, we complete the group. */
    if ([_animations count] == 0) {
        
        if (self.completion)
            self.completion(self.isFinished);
        
        self.complete = YES;
        self.animating = NO;
        
    }
    
}

#pragma mark - Managing Animations

- (void)addAnimation:(id<AMAnimation>)animation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    /* Tell animation to postpone it's animation so we can manage this in the group */
    [animation postponeAnimation];
    
    [_animations addObject:animation];
    
    /* Add observer for when animation completes */
    [(id)animation addObserver:self forKeyPath:@"complete" options:0 context:&AMAnimationGroupObserverContext];
    
    /* Associate group with animation so it will retain it as long as animation lives */
    objc_setAssociatedObject(animation, &AMAnimationGroupKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)beginAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    /* Start by cancelling any scheduled calls */
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
    if (!self.isAnimating)
        self.animating = YES;
    
    [_animations makeObjectsPerformSelector:@selector(beginAnimation)];
    
}

- (void)postponeAnimation {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginAnimation) object:nil];
    
}

- (void)cancelAnimation {
    
    AMAssertMainThread();
    
    [_animations makeObjectsPerformSelector:@selector(cancelAnimation)];
    
    self.finished = NO;
    self.complete = YES;
    
    if (self.completion)
        self.completion(NO);
    
}

#pragma mark - Properties

@synthesize duration=_duration;
@synthesize completion=_completion;

- (NSTimeInterval)duration {
    
    AMAssertMainThread();
    
    NSTimeInterval duration = .0;
    
    /* Iterate animations and find the longest running */
    for (id<AMAnimation> animation in _animations)
        duration = MAX(duration, animation.delay + animation.duration);
    
    return duration - self.delay;
    
}

- (void)setDuration:(NSTimeInterval)duration {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    NSTimeInterval delta = duration - self.duration;
    
    for (id<AMAnimation> animation in _animations)
        animation.duration += delta;
    
}

- (NSTimeInterval)delay {
    
    AMAssertMainThread();
    
    /* Finds the lowest delay of all animations */
    NSTimeInterval delay = DBL_MAX;
    
    for (id<AMAnimation> animation in _animations)
        delay = MIN(delay, animation.delay);
    
    return (delay < DBL_MAX ? delay : .0);
    
}

- (void)setDelay:(NSTimeInterval)delay {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    NSTimeInterval delta = delay - self.delay;
    
    for (id<AMAnimation> animation in _animations)
        animation.delay += delta;
    
}

- (void)setCompletion:(AMCompletionBlock)completion {
    
    AMAssertMainThread();
    AMAssertMutableState();
    
    _completion = [completion copy];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == &AMAnimationGroupObserverContext) {
        
        if ([keyPath isEqualToString:@"complete"] && [object isComplete])
            [self animationCompleted:object];
        
    } else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
}

@end
