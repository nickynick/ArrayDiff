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
                       animation:UITableViewRowAnimationAutomatic
                      updateType:NNTableViewCellUpdateTypeReload
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                     animation:(UITableViewRowAnimation)animation
                    updateType:(NNTableViewCellUpdateType)updateType
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
{
    NSAssert(!(updateType == NNTableViewCellUpdateTypeSetup && cellSetupBlock == nil), @"NNTableViewCellUpdateTypeSetup requires a non-nil cellSetupBlock.");

    NSMutableSet *indexPathsToSetup = [NSMutableSet set];
    
    [self beginUpdates];
    
    [self deleteSections:sectionsDiff.deletedSections withRowAnimation:animation];
    [self insertSections:sectionsDiff.insertedSections withRowAnimation:animation];
    
    [self deleteRowsAtIndexPaths:[sectionsDiff.deleted allObjects] withRowAnimation:animation];
    [self insertRowsAtIndexPaths:[sectionsDiff.inserted allObjects] withRowAnimation:animation];
    
    for (NNSectionsDiffMove *move in sectionsDiff.moved) {
        if ((move.updated && cellSetupBlock) || !move.updated) {
            [self moveRowAtIndexPath:move.from toIndexPath:move.to];
            if (move.updated) {
                [indexPathsToSetup addObject:move.to];
            }
        } else {
            [self deleteRowsAtIndexPaths:@[ move.from ] withRowAnimation:animation];
            [self insertRowsAtIndexPaths:@[ move.to ] withRowAnimation:animation];
        }
    };
        
    [self endUpdates];

    switch (updateType) {
        case NNTableViewCellUpdateTypeReload:
            [self reloadRowsAtIndexPaths:[sectionsDiff.updated allObjects] withRowAnimation:animation];
            break;
        case NNTableViewCellUpdateTypeSetup:
            [indexPathsToSetup unionSet:sectionsDiff.updated];
            break;
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
