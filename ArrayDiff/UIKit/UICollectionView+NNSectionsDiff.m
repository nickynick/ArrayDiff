//
//  UICollectionView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UICollectionView+NNSectionsDiff.h"

@implementation UICollectionView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    [self reloadWithSectionsDiff:sectionsDiff
                         options:0
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
{
    if (!(options & (NNDiffReloadUpdatedWithReload | NNDiffReloadUpdatedWithSetup))) {
        options |= NNDiffReloadUpdatedWithReload;
    }
    if (!(options & (NNDiffReloadMovedWithDeleteAndInsert | NNDiffReloadMovedWithMove))) {
        options |= NNDiffReloadMovedWithDeleteAndInsert;
    }
    
    NSAssert(!((options & NNDiffReloadUpdatedWithSetup) && cellSetupBlock == nil), @"NNDiffReloadUpdatedWithSetup requires a non-nil cellSetupBlock.");
    NSAssert(!((options & NNDiffReloadMovedWithMove) && cellSetupBlock == nil), @"NNDiffReloadMovedWithMove requires a non-nil cellSetupBlock.");
    
    
    // TODO: describe how reloads and moves do not play together
    
    NSMutableArray *indexPathsToSetup = [NSMutableArray array];
    
    
    [self performBatchUpdates:^{
        [self deleteSections:sectionsDiff.deletedSections];
        [self insertSections:sectionsDiff.insertedSections];
        
        [self deleteItemsAtIndexPaths:sectionsDiff.deleted];
        [self insertItemsAtIndexPaths:sectionsDiff.inserted];
        
        for (NNSectionsDiffChange *change in sectionsDiff.changed) {
            if (change.type == NNDiffChangeUpdate) {
                if (options & NNDiffReloadUpdatedWithReload) {
                    if (options & NNDiffReloadMovedWithMove) {
                        // Have to use delete+insert to co-exist with moves (thanks UIKit!)
                        [self deleteItemsAtIndexPaths:@[ change.before ]];
                        [self insertItemsAtIndexPaths:@[ change.after ]];
                    } else {
                        [self reloadItemsAtIndexPaths:@[ change.before ]];
                    }
                } else {
                    [indexPathsToSetup addObject:change.after];
                }
            } else {
                // Move animations between different sections may crash (thanks UIKit!), so we may need to use delete+insert instead of move
                if ((options & NNDiffReloadMovedWithDeleteAndInsert) ||
                    [sectionsDiff previousIndexForSection:change.after.section] != change.after.section) {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
                } else {
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (change.type & NNDiffChangeUpdate) {
                        [indexPathsToSetup addObject:change.after];
                    }
                }
            }
        }
    } completion:nil];
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
