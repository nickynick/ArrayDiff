//
//  UITableView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UITableView+NNSectionsDiff.h"
#import "NNDiffTableViewReloader.h"

@implementation UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    [self reloadWithSectionsDiff:sectionsDiff options:nil animations:nil completion:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions *)options
                     animation:(UITableViewRowAnimation)animation
                    completion:(void (^)())completion
{
    NNTableViewDiffReloadAnimations *animations = [NNTableViewDiffReloadAnimations withAnimation:animation];
    [self reloadWithSectionsDiff:sectionsDiff options:options animations:animations completion:completion];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions *)options
                    animations:(NNTableViewDiffReloadAnimations *)animations
                    completion:(void (^)())completion
{
    if (!options) {
        options = [[NNDiffReloadOptions alloc] init];
    }
    
    if (!animations) {
        animations = [[NNTableViewDiffReloadAnimations alloc] init];
    }
    
    NNDiffTableViewReloader *reloader = [[NNDiffTableViewReloader alloc] initWithTableView:self animations:animations];
    [reloader reloadWithSectionsDiff:sectionsDiff options:options completion:completion];
}

@end