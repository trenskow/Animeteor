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

#import "AMAnimation.h"

@protocol AMInterpolatable;

/*!
 The `AMDirectAnimation` class enables animating anything not normally animatable. The `AMDirectAnimation` does not use Core Animation. Instead it sets the values of properties directly on objects. This is useful when you want to animate as an example the `contentOffset` of a `UIScrollView` instance - or the `volume` property of a `AVAudioPlayer` instance.
 */
@interface AMDirectAnimation : NSObject <AMAnimation>

/// ---------------------------
/// @name Creating an Animation
/// ---------------------------

- (instancetype _Nullable)init UNAVAILABLE_ATTRIBUTE;

/*!
 Returns an initialized direct animation object.
 
 @param object     The object to animate.
 @param keyPath    The keypath of the object to animate.
 @param fromValue  Animate from this value. Providing `nil` will default to keyPaths current value on the object.
 @param toValue    Animate to this value.
 @param duration   The duration of the animation.
 @param delay      The delay of the animation.
 @param curve      The curve of the animation. Providing `nil` will default to a linear curve.
 @param completion An optional completion block that gets called when the animation completes.
 
 @return An initialized direct animation object.
 */
- (instancetype _Nonnull)initWithObject:(id _Nonnull)object
                                keyPath:(NSString * _Nonnull)keyPath
                              fromValue:(id<AMInterpolatable> _Nullable)fromValue
                                toValue:(id<AMInterpolatable> _Nonnull)toValue
                               duration:(NSTimeInterval)duration
                                  delay:(NSTimeInterval)delay
                                  curve:(AMCurve * _Nullable)curve
                             completion:(AMCompletionBlock _Nullable)completion;

@end
