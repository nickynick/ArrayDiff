//
//  NNSwizzlingUtils.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 28/01/16.
//  Based on http://nshipster.com/method-swizzling/
//

#import <Foundation/Foundation.h>

@interface NNSwizzlingUtils : NSObject

+ (void)swizzle:(Class)aClass instanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;

+ (void)swizzle:(Class)aClass classMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector;

@end
