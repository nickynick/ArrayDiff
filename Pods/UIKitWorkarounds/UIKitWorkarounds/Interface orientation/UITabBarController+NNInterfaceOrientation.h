//
//  UITabBarController+NNInterfaceOrientation.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 11/02/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (NNInterfaceOrientation)

+ (void)nn_setupCorrectInterfaceOrientationManagement;

@end
