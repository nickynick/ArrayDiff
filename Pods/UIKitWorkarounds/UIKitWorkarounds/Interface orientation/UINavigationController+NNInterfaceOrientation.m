//
//  UINavigationController+NNInterfaceOrientation.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 11/02/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "UINavigationController+NNInterfaceOrientation.h"
#import "NNSwizzlingUtils.h"

@implementation UINavigationController (NNInterfaceOrientation)

#pragma mark - Public

+ (void)nn_setupCorrectInterfaceOrientationManagement {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self nn_interfaceOrientation_swizzleMethods];
    });
}

#pragma mark - Swizzling

+ (void)nn_interfaceOrientation_swizzleMethods {
    [NNSwizzlingUtils swizzle:[UINavigationController class]
               instanceMethod:@selector(supportedInterfaceOrientations)
                   withMethod:@selector(nn_interfaceOrientation_supportedInterfaceOrientations)];
}

- (UIInterfaceOrientationMask)nn_interfaceOrientation_supportedInterfaceOrientations {
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    } else {
        return [self nn_interfaceOrientation_supportedInterfaceOrientations];
    }
}

@end
