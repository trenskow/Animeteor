//
//  AMMacros.h
//  Animeteor
//
//  Created by Kristian Trenskow on 10/10/15.
//  Copyright © 2015 Kristian Trenskow. All rights reserved.
//

#define AMAssertMainThread() NSAssert([NSThread isMainThread], @"Animeteor is only accessible using main thread.")
