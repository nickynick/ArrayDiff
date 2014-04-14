//
//  UITableView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UITableView+NNSectionsDiff.h"

@implementation UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    [self reloadWithSectionsDiff:sectionsDiff
                         options:0
                       animation:UITableViewRowAnimationAutomatic
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                     animation:(UITableViewRowAnimation)animation
                cellSetupBlock:(void (^)(id, NSIndexPath *))cellSetupBlock
{
    NSAssert(!((options & NNDiffReloadUpdatedWithSetup) && cellSetupBlock == nil), @"NNDiffReloadUpdatedWithSetup requires a non-nil cellSetupBlock.");

    NSMutableArray *indexPathsToSetup = [NSMutableArray array];
    NSMutableArray *indexPathsToUpdate = [NSMutableArray array];
    
    [self beginUpdates];
    
    [self deleteSections:sectionsDiff.deletedSections withRowAnimation:animation];
    [self insertSections:sectionsDiff.insertedSections withRowAnimation:animation];
    
    [self deleteRowsAtIndexPaths:sectionsDiff.deleted withRowAnimation:animation];
    [self insertRowsAtIndexPaths:sectionsDiff.inserted withRowAnimation:animation];
    
    for (NNSectionsDiffChange *change in sectionsDiff.changed) {
        if (change.type & NNDiffChangeMove) {
            BOOL updated = change.type & NNDiffChangeUpdate;
            
            if ((options & NNDiffReloadMovedWithDeleteAndInsert) || (updated && !cellSetupBlock)) {
                [self deleteRowsAtIndexPaths:@[ change.before ] withRowAnimation:animation];
                [self insertRowsAtIndexPaths:@[ change.after ] withRowAnimation:animation];
            } else {
                [self moveRowAtIndexPath:change.before toIndexPath:change.after];
                if (updated) {
                    [indexPathsToSetup addObject:change.after];
                }
            }
        } else {
            [indexPathsToUpdate addObject:change.after];
        }
    };
        
    [self endUpdates];

    if (options & NNDiffReloadUpdatedWithSetup) {
        [indexPathsToSetup addObjectsFromArray:indexPathsToUpdate];
    } else {
        [self reloadRowsAtIndexPaths:indexPathsToUpdate withRowAnimation:animation];
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
