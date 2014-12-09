//
//  NNDiffReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffReloader.h"
#import "NNSectionsDiffTracker.h"
#import "NNSectionsDiffChange.h"

@implementation NNDiffReloader

#pragma mark - Public

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)diff
                       options:(NNDiffReloadOptions *)options
                    completion:(void (^)())completion
{
    NSParameterAssert(diff != nil);
    NSParameterAssert(options != nil);
    
    if ([diff isEqual:[[NNSectionsDiff alloc] init]]) {
        if (completion) {
            completion();
        }
        return;
    }
    
    diff = [self sanitizeDiff:diff];
    
    NNSectionsDiffTracker *tracker = [[NNSectionsDiffTracker alloc] initWithSectionsDiff:diff];
    NSMutableArray *indexPathsToUpdateWithBlock = [NSMutableArray array];
    
    [self performUpdates:^{
        [self deleteSections:diff.deletedSections];
        [self insertSections:diff.insertedSections];
        
        [self deleteItemsAtIndexPaths:[diff.deleted allObjects]];
        [self insertItemsAtIndexPaths:[diff.inserted allObjects]];
        
        for (NNSectionsDiffChange *change in diff.changed) {
            if (change.type == NNDiffChangeUpdate) {
                if (options.useUpdateBlockForReload) {
                    [indexPathsToUpdateWithBlock addObject:change.after];
                } else {
                    if (options.useMoveIfPossible) {
                        // Have to use delete+insert for reloading purpose to co-exist with moves (thanks UIKit!)
                        [self reloadItemsAtIndexPaths:@[ change.before ] asDeleteAndInsertAtIndexPaths:@[ change.after ]];
                    } else {
                        [self reloadItemsAtIndexPaths:@[ change.before ] asDeleteAndInsertAtIndexPaths:nil];
                    }
                }
            } else {
                BOOL shouldMove = options.useMoveIfPossible;
                
                if (shouldMove) {
                    if (change.type & NNDiffChangeUpdate && !options.cellUpdateBlock) {
                        // We cannot use move because we also need to update the cell, but there is no update block.
                        shouldMove = NO;
                    }
                }
                
                if (shouldMove) {
                    // Move animations between different sections will crash if the destination section index doesn't match its initial one (thanks UIKit!)
                    NSUInteger sourceSectionIndex = [change.before indexAtPosition:0];
                    NSUInteger destinationSectionIndex = [change.after indexAtPosition:0];
                    NSUInteger oldDestinationSectionIndex = [tracker oldIndexForSection:destinationSectionIndex];
                    
                    if (sourceSectionIndex != oldDestinationSectionIndex &&
                        destinationSectionIndex != oldDestinationSectionIndex) {
                        shouldMove = NO;
                    }
                }
                
                if (shouldMove) {
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                    if (change.type & NNDiffChangeUpdate) {
                        [indexPathsToUpdateWithBlock addObject:change.after];
                    }
                } else {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
                }
            }
        }
    } completion:completion];
    
    for (NSIndexPath *indexPath in indexPathsToUpdateWithBlock) {
        id cell = [self cellForItemAtIndexPath:indexPath];
        if (cell) {
            options.cellUpdateBlock(cell, indexPath);
        }
    }
}

#pragma mark - Private

- (NNSectionsDiff *)sanitizeDiff:(NNSectionsDiff *)diff {
    // UIKit would get upset if we attempted to move an item from a section being deleted / into a section being inserted.
    // Therefore, we should break such moves into deletions+insertions.
    
    NNMutableSectionsDiff *sanitizedDiff = [diff mutableCopy];
    
    [sanitizedDiff.changed minusSet:[diff.changed objectsPassingTest:^BOOL(NNSectionsDiffChange *obj, BOOL *stop) {
        if (!(obj.type & NNDiffChangeMove)) return NO;
        
        if ([diff.deletedSections containsIndex:[obj.before indexAtPosition:0]]) {
            if (![diff.insertedSections containsIndex:[obj.after indexAtPosition:0]]) {
                [sanitizedDiff.inserted addObject:obj.after];
            }
            return YES;
        }
        
        if ([diff.insertedSections containsIndex:[obj.after indexAtPosition:0]]) {
            if (![diff.deletedSections containsIndex:[obj.before indexAtPosition:0]]) {
                [sanitizedDiff.deleted addObject:obj.before];
            }
            return YES;
        }
        
        return NO;
	}]];
    
    return sanitizedDiff;
}

#pragma mark - Abstract

#define methodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion { methodNotImplemented(); }

- (void)insertSections:(NSIndexSet *)sections { methodNotImplemented(); }
- (void)deleteSections:(NSIndexSet *)sections { methodNotImplemented(); }

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths asDeleteAndInsertAtIndexPaths:(NSArray *)insertIndexPaths { methodNotImplemented(); }
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath { methodNotImplemented(); }

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath { methodNotImplemented(); }

@end
