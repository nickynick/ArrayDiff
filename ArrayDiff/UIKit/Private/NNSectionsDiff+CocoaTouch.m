//
//  NNSectionsDiff+CocoaTouch.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff+CocoaTouch.h"

@implementation NNSectionsDiff (CocoaTouch)

- (void)reloadCocoaTouchCollection:(id<NNCocoaTouchCollection>)collection
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
    
    [collection performUpdates:^{
        [collection deleteSections:self.deletedSections];
        [collection insertSections:self.insertedSections];
        
        [collection deleteItemsAtIndexPaths:self.deleted];
        [collection insertItemsAtIndexPaths:self.inserted];
        
        for (NNSectionsDiffChange *change in self.changed) {
            if (change.type == NNDiffChangeUpdate) {
                if (options & NNDiffReloadUpdatedWithReload) {
                    if (options & NNDiffReloadMovedWithMove) {
                        // Have to use delete+insert for reloading purpose to co-exist with moves (thanks UIKit!)
                        [collection deleteItemsAtIndexPaths:@[ change.before ]];
                        [collection insertItemsAtIndexPaths:@[ change.after ]];
                    } else {
                        [collection reloadItemsAtIndexPaths:@[ change.before ]];
                    }
                } else {
                    [indexPathsToSetup addObject:change.after];
                }
            } else {
                BOOL shouldMove = (options & NNDiffReloadMovedWithMove);
                
                if (shouldMove) {
                    // Move animations between different sections will crash for this specific occasion (thanks UIKit!)
                    NSUInteger destinationSectionIndex = [change.after indexAtPosition:0];
                    NSUInteger previousDestinationSectionIndex = [self previousIndexForSection:destinationSectionIndex];
                    if (previousDestinationSectionIndex != destinationSectionIndex) {
                        shouldMove = NO;
                    }
                }
                
                if (shouldMove) {
                    [collection moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (change.type & NNDiffChangeUpdate) {
                        [indexPathsToSetup addObject:change.after];
                    }
                } else {
                    [collection deleteItemsAtIndexPaths:@[ change.before ]];
                    [collection insertItemsAtIndexPaths:@[ change.after ]];
                }
            }
        }
    }];
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        id cell = [collection cellForItemAtIndexPath:indexPath];
        if (cell) {
            cellSetupBlock(cell, indexPath);
        }
    }
}

@end