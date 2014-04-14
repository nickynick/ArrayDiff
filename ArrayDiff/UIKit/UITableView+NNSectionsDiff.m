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
            if (!updated || (updated && cellSetupBlock)) {
                [self moveRowAtIndexPath:change.before toIndexPath:change.after];
                if (updated) {
                    [indexPathsToSetup addObject:change.after];
                }
            } else {
                [self deleteRowsAtIndexPaths:@[ change.before ] withRowAnimation:animation];
                [self insertRowsAtIndexPaths:@[ change.after ] withRowAnimation:animation];
            }
        } else {
            [indexPathsToUpdate addObject:change.after];
        }
    };
        
    [self endUpdates];

    switch (updateType) {
        case NNTableViewCellUpdateTypeReload:
            [self reloadRowsAtIndexPaths:indexPathsToUpdate withRowAnimation:animation];
            break;
        case NNTableViewCellUpdateTypeSetup:
            [indexPathsToSetup addObjectsFromArray:indexPathsToUpdate];
            break;
    }
    
    for (NSIndexPath *indexPath in indexPathsToSetup) {
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        cellSetupBlock(cell, indexPath);
    }
}

@end
