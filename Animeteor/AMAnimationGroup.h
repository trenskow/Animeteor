//
//  AMAnimationGroup.h
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

/*!
 `AMAnimationGroup` is a class that provides the ability to group animations into a single entity. Animations can be added to the animation group - even other animation groups can be added. A completion handler can be provided on creation that gets invoked when all animations in the group has completed.
 */
@interface AMAnimationGroup : NSObject <AMAnimation>

/// ---------------------------------
/// @name Creating an Animation Group
/// ---------------------------------

- (instancetype _Nullable)new UNAVAILABLE_ATTRIBUTE;
- (instancetype _Nullable)init UNAVAILABLE_ATTRIBUTE;

/*!
 Returns an initialized animation group.
 
 @param animations An `NSArray` of id<AMAnimation> objects to group.
 @param completion An optional completion block that gets called when the animation group completes.
 
 @return An initialized animation group.
 */
- (instancetype _Nonnull)initWithAnimations:(NSArray<id<AMAnimation>> * _Nullable)animations completion:(AMCompletionBlock _Nullable)completion;

/// -----------------------
/// @name Adding Animations
/// -----------------------

/*!
 Adds an animation to the group.
 
 @param animation The animation to add to the group.
 */
- (void)addAnimation:(id<AMAnimation> _Nonnull)animation;

@end
