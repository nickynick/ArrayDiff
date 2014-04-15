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
                       animation:UITableViewRowAnimationFade
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                     animation:(UITableViewRowAnimation)animation
                cellSetupBlock:(void (^)(id, NSIndexPath *))cellSetupBlock
{
    if (!(options & (NNDiffReloadUpdatedWithReload | NNDiffReloadUpdatedWithSetup))) {
        options |= NNDiffReloadUpdatedWithReload;
    }
    if (!(options & (NNDiffReloadMovedWithDeleteAndInsert | NNDiffReloadMovedWithMove))) {
        options |= NNDiffReloadMovedWithDeleteAndInsert;
    }
    
    NSAssert(!((options & NNDiffReloadUpdatedWithSetup) && cellSetupBlock == nil), @"NNDiffReloadUpdatedWithSetup requires a non-nil cellSetupBlock.");
    NSAssert(!((options & NNDiffReloadMovedWithMove) && cellSetupBlock == nil), @"NNDiffReloadMovedWithMove requires a non-nil cellSetupBlock.");
    
    
    NSMutableArray *indexPathsToSetup = [NSMutableArray array];
    
    [self beginUpdates];
    
    [self deleteSections:sectionsDiff.deletedSections withRowAnimation:animation];
    [self insertSections:sectionsDiff.insertedSections withRowAnimation:animation];
    
    [self deleteRowsAtIndexPaths:sectionsDiff.deleted withRowAnimation:animation];
    [self insertRowsAtIndexPaths:sectionsDiff.inserted withRowAnimation:animation];
    
    for (NNSectionsDiffChange *change in sectionsDiff.changed) {
        if (change.type == NNDiffChangeUpdate) {
            if (options & NNDiffReloadUpdatedWithReload) {
                if (options & NNDiffReloadMovedWithMove) {
                    // Have to use delete+insert to co-exist with moves (thanks UIKit!)
                    [self deleteRowsAtIndexPaths:@[ change.before ] withRowAnimation:animation];
                    [self insertRowsAtIndexPaths:@[ change.after ] withRowAnimation:animation];
                } else {
                    [self reloadRowsAtIndexPaths:@[ change.before ] withRowAnimation:animation];
                }
            } else {
                [indexPathsToSetup addObject:change.after];
            }
        } else {
            BOOL shouldMove = (options & NNDiffReloadMovedWithMove);
            
            if (shouldMove) {
                // Move animations between different sections will crash for this specific occasion (thanks UIKit!)
                NSUInteger destinationSectionIndex = change.after.section;
                NSUInteger previousDestinationSectionIndex = [sectionsDiff previousIndexForSection:destinationSectionIndex];
                if (previousDestinationSectionIndex != destinationSectionIndex) {
                    shouldMove = NO;
                }
            }
            
            if (shouldMove) {
                [self moveRowAtIndexPath:change.before toIndexPath:change.after];
                if (change.type & NNDiffChangeUpdate) {
                    [indexPathsToSetup addObject:change.after];
                }
            } else {
                [self deleteRowsAtIndexPaths:@[ change.before ] withRowAnimation:animation];
                [self insertRowsAtIndexPaths:@[ change.after ] withRowAnimation:animation];
            }
        }
    }
        
    [self endUpdates];
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
