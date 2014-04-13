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
    
    NSMutableSet *indexPathsToSetup = [NSMutableSet set];
    
    [self performBatchUpdates:^{
        [self deleteSections:sectionsDiff.deletedSections];
        [self insertSections:sectionsDiff.insertedSections];
        
        [self deleteItemsAtIndexPaths:[sectionsDiff.deleted allObjects]];
        [self insertItemsAtIndexPaths:[sectionsDiff.inserted allObjects]];
        
        for (NNSectionsDiffMove *move in sectionsDiff.moved) {
            if ((move.updated && cellSetupBlock) || !move.updated) {
                [self moveItemAtIndexPath:move.from toIndexPath:move.to];
                if (move.updated) {
                    [indexPathsToSetup addObject:move.to];
                }
            } else {
                [self deleteItemsAtIndexPaths:@[ move.from ]];
                [self insertItemsAtIndexPaths:@[ move.to ]];
            }
        };
    } completion:nil];
    
    switch (updateType) {
        case NNCollectionViewCellUpdateTypeReload:
            [self reloadItemsAtIndexPaths:[sectionsDiff.updated allObjects]];
            break;
        case NNCollectionViewCellUpdateTypeSetup:
            [indexPathsToSetup unionSet:sectionsDiff.updated];
            break;
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
