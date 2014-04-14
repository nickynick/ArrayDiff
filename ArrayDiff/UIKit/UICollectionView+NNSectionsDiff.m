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
                      updateType:NNCollectionViewCellUpdateTypeReload
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                    updateType:(NNCollectionViewCellUpdateType)updateType
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
{
    NSAssert(!(updateType == NNCollectionViewCellUpdateTypeSetup && cellSetupBlock == nil), @"NNCollectionViewCellUpdateTypeSetup requires a non-nil cellSetupBlock.");
    
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
                if (!updated || (updated && cellSetupBlock)) {
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (updated) {
                        [indexPathsToSetup addObject:change.after];
                    }
                } else {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
                }
            } else {
                [indexPathsToUpdate addObject:change.after];
            }
        };
    } completion:nil];
    
    switch (updateType) {
        case NNCollectionViewCellUpdateTypeReload:
            [self reloadItemsAtIndexPaths:indexPathsToUpdate];
            break;
        case NNCollectionViewCellUpdateTypeSetup:
            [indexPathsToSetup addObjectsFromArray:indexPathsToUpdate];
            break;
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
