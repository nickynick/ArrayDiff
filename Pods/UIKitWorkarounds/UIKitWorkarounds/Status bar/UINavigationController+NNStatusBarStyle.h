//
//  UINavigationController+NNStatusBarStyle.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 05/02/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (NNStatusBarStyle)

@property (nonatomic, assign) UIStatusBarStyle nn_statusBarStyle UI_APPEARANCE_SELECTOR;

@end


@interface UINavigationController (NNStatusBarStyle)

+ (void)nn_setupCorrectStatusBarStyleManagement;

@end
