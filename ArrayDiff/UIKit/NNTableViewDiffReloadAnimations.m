//
//  NNTableViewDiffReloadAnimations.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 08/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNTableViewDiffReloadAnimations.h"

@implementation NNTableViewDiffReloadAnimations

- (instancetype)init {
    return [self initWithAnimation:UITableViewRowAnimationAutomatic];
}

- (instancetype)initWithAnimation:(UITableViewRowAnimation)animation {
    self = [super init];
    if (!self) return nil;
    
    _rowInsertAnimation = animation;
    _rowDeleteAnimation = animation;
    _rowReloadAnimation = animation;
    _sectionInsertAnimation = animation;
    _sectionDeleteAnimation = animation;
    
    return self;
}

+ (instancetype)withAnimation:(UITableViewRowAnimation)animation {
    return [[self alloc] initWithAnimation:animation];
}

@end