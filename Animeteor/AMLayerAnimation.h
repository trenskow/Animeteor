//
//  AMLayerAnimation.h
//  Animeteor
//
//  Copyright (c) 2013-2014, Kristian Trenskow
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

@import QuartzCore;

#import "AMAnimation.h"

@protocol AMInterpolatable;
@class AMCurve;

/*!
 The `AMLayerAnimation` provides animation on any animatable property of CALayer. Use this animation if you need to do custom animations on a layer that is not directly implemented in Animeteor as an explicit animation.
 */
@interface AMLayerAnimation : NSObject <AMAnimation>

/// -------------------------------
/// @name Creating Layer Animations
/// -------------------------------

/*!
 Returns an initialized layer animation object.
 
 @param layer      The layer to animate.
 @param keyPath    The keyPath of the layer to animate.
 @param fromValue  Animates from this value. Providing `nil` will default to keyPaths current value on the layer.
 @param toValue    Animates to this value.
 @param duration   The duration of the animation.
 @param delay      The delay before the animation begins.
 @param curve      The curve of the animation. Providing `nil` will default to a linear curve.
 @param completion An optional completion block to get called when the animation completes.
 
 @return An initialized layer animation object.
 */
- (instancetype)initWithLayer:(CALayer *)layer
                      keyPath:(NSString *)keyPath
                    fromValue:(id<AMInterpolatable>)fromValue
                      toValue:(id<AMInterpolatable>)toValue
                     duration:(NSTimeInterval)duration
                        delay:(NSTimeInterval)delay
                        curve:(AMCurve *)curve
                   completion:(void (^)(BOOL finished))completion;

/// --------------------------------
/// @name Examining Views and Layers
/// --------------------------------

/*!
*  Checks if an animation is in progress on a `UIView` or `CALayer` instance at a perticular property.
*
*  @param layer       The `CALayer` you want to examine.
*  @param keyPath     The key path of the property that you want to examine.
*
*  @return Returns `YES` if the `UIView` or `CALayer` is animating on the property of `keyPath`.
*/
+ (BOOL)inProgressOn:(CALayer *)layer withKeyPath:(NSString *)keyPath;

///------------------------------------
/// @name Getting Animation Information
///------------------------------------

/*!
 Returns the animated layer.
 */
@property (weak,readonly,nonatomic) CALayer *layer;

/*!
 The duration of the animation.
 */
@property (nonatomic) NSTimeInterval duration;

@end
