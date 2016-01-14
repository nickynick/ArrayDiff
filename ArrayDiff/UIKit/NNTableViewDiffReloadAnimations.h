//
//  NNTableViewDiffReloadAnimations.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 08/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NNTableViewDiffReloadAnimations : NSObject

@property (nonatomic, assign) UITableViewRowAnimation rowInsertAnimation;
@property (nonatomic, assign) UITableViewRowAnimation rowDeleteAnimation;
@property (nonatomic, assign) UITableViewRowAnimation rowReloadAnimation;

@property (nonatomic, assign) UITableViewRowAnimation sectionInsertAnimation;
@property (nonatomic, assign) UITableViewRowAnimation sectionDeleteAnimation;

- (instancetype)initWithAnimation:(UITableViewRowAnimation)animation;

+ (instancetype)withAnimation:(UITableViewRowAnimation)animation;

@end