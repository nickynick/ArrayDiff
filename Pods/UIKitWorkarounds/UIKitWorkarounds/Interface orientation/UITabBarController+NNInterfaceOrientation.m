//
//  UITabBarController+NNInterfaceOrientation.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 11/02/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "UITabBarController+NNInterfaceOrientation.h"
#import "NNSwizzlingUtils.h"

@implementation UITabBarController (NNInterfaceOrientation)

#pragma mark - Public

+ (void)nn_setupCorrectInterfaceOrientationManagement {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self nn_interfaceOrientation_swizzleMethods];
    });
}

#pragma mark - Swizzling

+ (void)nn_interfaceOrientation_swizzleMethods {
    [NNSwizzlingUtils swizzle:[UITabBarController class]
               instanceMethod:@selector(supportedInterfaceOrientations)
                   withMethod:@selector(nn_interfaceOrientation_supportedInterfaceOrientations)];
}

- (UIInterfaceOrientationMask)nn_interfaceOrientation_supportedInterfaceOrientations {
    if (self.selectedViewController) {
        return [self.selectedViewController supportedInterfaceOrientations];
    } else {
        return [self nn_interfaceOrientation_supportedInterfaceOrientations];
    }
}

@end