//
//  AMCurve.h
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

@import Foundation;

/*!
 The `AMCurve` class provides curvature for animations. Use one of the many build-in curves or create your own customized curves either using a block or by subclassing this class.
 */
@interface AMCurve : NSObject <NSCopying>

/// ---------------------
/// @name Build-in Curves
/// ---------------------

/*!
 Returns a linear curve.
 
 @return A linear curve.
 */
+ (AMCurve *)linear;

/*!
 Returns a curve that eases in quad.
 
 @return A curve that eases in quad.
 */
+ (AMCurve *)easeInQuad;

/*!
 Returns a curve that eases out quad.
 
 @return A curve that eases out quad.
 */
+ (AMCurve *)easeOutQuad;

/*!
 Returns a curve that eases in and out quad.
 
 @return A curve that eases in and out quad.
 */
+ (AMCurve *)easeInOutQuad;

/*!
 Returns a curve that eases in cubic.
 
 @return A curve that eases in cubic.
 */
+ (AMCurve *)easeInCubic;

/*!
 Returns a curve that eases out cubic.
 
 @return A curve that eases out cubic.
 */
+ (AMCurve *)easeOutCubic;

/*!
 Returns a curve that eases in and out cubic.
 
 @return A curve that eases in and out cubic.
 */
+ (AMCurve *)easeInOutCubic;

/*!
 Returns a curve that eases in quart.
 
 @return A curve that eases in quart.
 */
+ (AMCurve *)easeInQuart;

/*!
 Returns a curve that eases out quart.
 
 @return A curve that eases out quart.
 */
+ (AMCurve *)easeOutQuart;

/*!
 Returns a curve that eases in and out quart.
 
 @return A curve that eases in and out quart.
 */
+ (AMCurve *)easeInOutQuart;

/*!
 Returns a curve that eases in quint.
 
 @return A curve that eases in quint.
 */
+ (AMCurve *)easeInQuint;

/*!
 Returns a curve that eases out quint.
 
 @return A curve that eases out quint.
 */
+ (AMCurve *)easeOutQuint;

/*!
 Returns a curve that eases in and out quint.
 
 @return A curve that eases in and out quint.
 */
+ (AMCurve *)easeInOutQuint;

/*!
 Returns a curve that eases in using sine.
 
 @return A curve that eases in using sine.
 */
+ (AMCurve *)easeInSine;

/*!
 Returns a curve that eases out using sine.
 
 @return A curve that eases out using sine.
 */
+ (AMCurve *)easeOutSine;

/*!
 Returns a curve that eases in and out using sine.
 
 @return A curve that eases in and out using sine.
 */
+ (AMCurve *)easeInOutSine;

/*!
 Returns a curve that eases in expo.
 
 @return A curve that eases in expo.
 */
+ (AMCurve *)easeInExpo;

/*!
 Returns a curve that eases out expo.
 
 @return A curve that eases out expo.
 */
+ (AMCurve *)easeOutExpo;

/*!
 Returns a curve that eases in and out expo.
 
 @return A curve that eases in and out expo.
 */
+ (AMCurve *)easeInOutExpo;

/*!
 Returns a curve that eases in circular.
 
 @return A curve that eases in circular.
 */
+ (AMCurve *)easeInCirc;

/*!
 Returns a curve that ease out circular.
 
 @return A curve that ease out circular.
 */
+ (AMCurve *)easeOutCirc;

/*!
 Returns a curve that eases in and out circular.
 
 @return A curve that eases in and out circular.
 */
+ (AMCurve *)easeInOutCirc;

/*!
 Returns a curve that eases in elasticly.
 
 @return A curve that eases in elasticly.
 */
+ (AMCurve *)easeInElastic;

/*!
 Returns a curve that eases out elasticly.
 
 @return A curve that eases out elasticly.
 */
+ (AMCurve *)easeOutElastic;

/*!
 Returns a curve that eases in and out elasticly.
 
 @return A curve that eases in and out elasticly.
 */
+ (AMCurve *)easeInOutElastic;

/*!
 Returns a curve that eases in with an overshoot.
 
 @return A curve that eases in with an overshoot.
 */
+ (AMCurve *)easeInBack;

/*!
 Returns a curve that eases out with an overshoot.
 
 @return A curve that eases out with an overshoot.
 */
+ (AMCurve *)easeOutBack;

/*!
 Returns a curve that eases in and out with an overshoot.
 
 @return A curve that eases in and out with an overshoot.
 */
+ (AMCurve *)easeInOutBack;

/*!
 Returns a curve that bounces in.
 
 @return A curve that bounces in.
 */
+ (AMCurve *)easeInBounce;

/*!
 Returns a curve that bounces out.
 
 @return A curve that bounces out.
 */
+ (AMCurve *)easeOutBounce;

/*!
 Returns a curve that bounces in and out.
 
 @return A curve that bounces in and out.
 */
+ (AMCurve *)easeInOutBounce;

/// ---------------------
/// @name Creating Curves
/// ---------------------

/*!
 Creates and returns a new curve using a block.
 
 @param block A block that takes a value in time *t* between one and zero and returns the relative position on the curve.
 
 @return A curve.
 */
+ (instancetype)curveWithBlock:(double (^)(double t))block;

/// ------------------------
/// @name Calculating Curves
/// ------------------------

/*!
 Transforms a value in time into a curved position.
 
 @param positionInTime Position in time between one and zero.
 
 @discussion Override this if you want to create a custom curve without using blocks.
 
 @return The position on the curve relative to `positionInTime`.
 */
- (double)transform:(double)positionInTime;

@end
