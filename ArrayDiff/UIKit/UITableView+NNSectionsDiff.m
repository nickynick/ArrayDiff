//
//  UITableView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UITableView+NNSectionsDiff.h"
#import "NNCocoaTouchCollectionReloader.h"
#import "NNTableViewCocoaTouchCollection.h"

@implementation UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    [self reloadWithSectionsDiff:sectionsDiff
                         options:0
                       animation:UITableViewRowAnimationFade
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                     animation:(UITableViewRowAnimation)animation
                cellSetupBlock:(void (^)(id, NSIndexPath *))cellSetupBlock
{
    [self reloadWithSectionsDiff:sectionsDiff options:options animation:animation cellSetupBlock:cellSetupBlock completion:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                     animation:(UITableViewRowAnimation)animation
                cellSetupBlock:(void (^)(id, NSIndexPath *))cellSetupBlock
                    completion:(void (^)())completion
{
    NNTableViewCocoaTouchCollection *collection = [[NNTableViewCocoaTouchCollection alloc] initWithTableView:self rowAnimation:animation];

    [NNCocoaTouchCollectionReloader reloadCocoaTouchCollection:collection
                                                      withDiff:sectionsDiff
                                                       options:options
                                                cellSetupBlock:cellSetupBlock
                                                    completion:completion];
}

@end