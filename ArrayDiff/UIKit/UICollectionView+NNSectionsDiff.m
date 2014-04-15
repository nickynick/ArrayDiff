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
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (change.type & NNDiffChangeUpdate) {
                        [indexPathsToSetup addObject:change.after];
                    }
                } else {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
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
