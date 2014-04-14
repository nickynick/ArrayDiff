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
    NSAssert(!((options & NNDiffReloadUpdatedWithSetup) && cellSetupBlock == nil), @"NNDiffReloadUpdatedWithSetup requires a non-nil cellSetupBlock.");
    
    NSMutableArray *indexPathsToSetup = [NSMutableArray array];
    NSMutableArray *indexPathsToUpdate = [NSMutableArray array];
    
    [self performBatchUpdates:^{
        [self deleteSections:sectionsDiff.deletedSections];
        [self insertSections:sectionsDiff.insertedSections];
        
        [self deleteItemsAtIndexPaths:sectionsDiff.deleted];
        [self insertItemsAtIndexPaths:sectionsDiff.inserted];
        
        for (NNSectionsDiffChange *change in sectionsDiff.changed) {
            if (change.type & NNDiffChangeMove) {
                BOOL updated = change.type & NNDiffChangeUpdate;
                
                if ((options & NNDiffReloadMovedWithDeleteAndInsert) || (updated && !cellSetupBlock)) {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
                } else {
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (updated) {
                        [indexPathsToSetup addObject:change.after];
                    }
                }
            } else {
                [indexPathsToUpdate addObject:change.after];
            }
        };
    } completion:nil];
    
    if (options & NNDiffReloadUpdatedWithSetup) {
        [indexPathsToSetup addObjectsFromArray:indexPathsToUpdate];
    } else {
        [self reloadItemsAtIndexPaths:indexPathsToUpdate];
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
