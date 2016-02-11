//
//  NNSwizzlingUtils.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 28/01/16.
//  Based on http://nshipster.com/method-swizzling/
//

#import "NNSwizzlingUtils.h"
#import <objc/runtime.h>

@implementation NNSwizzlingUtils

+ (void)swizzle:(Class)aClass instanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(aClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(aClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)swizzle:(Class)aClass classMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    [self swizzle:object_getClass(aClass) instanceMethod:originalSelector withMethod:swizzledSelector];
}

@end