//
//  UITableView+NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"
#import "NNDiffReloadOptions.h"
#import "NNTableViewDiffReloadAnimations.h"

@import UIKit;

@interface UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions *)options
                     animation:(UITableViewRowAnimation)animation
                    completion:(void (^)())completion;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions *)options
                    animations:(NNTableViewDiffReloadAnimations *)animations
                    completion:(void (^)())completion;

@end