//
//  NNDiffReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffReloader.h"
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
    
    [self performUpdates:^{
        [self deleteSections:diff.deletedSections];
        [self insertSections:diff.insertedSections];
        
        [self deleteItemsAtIndexPaths:[diff.deleted allObjects]];
        [self insertItemsAtIndexPaths:[diff.inserted allObjects]];
        
        for (NNSectionsDiffChange *change in diff.changed) {
            if (change.type & NNDiffChangeUpdate) {
                if (options.useUpdateBlockForReload) {
                    [self updateItemsAtIndexPaths:@[ change.before ]];
                } else {
                    [self reloadItemsAtIndexPaths:@[ change.before ]];
                }
            }
            
            if (change.type & NNDiffChangeMove) {
                if (options.useMoveIfPossible) {
                    [self moveItemAtIndexPath:change.before toIndexPath:change.after];
                } else {
                    [self deleteItemsAtIndexPaths:@[ change.before ]];
                    [self insertItemsAtIndexPaths:@[ change.after ]];
                }
            }
        }
    } withOptions:options completion:completion];
}

#pragma mark - Abstract

#define methodNotImplemented() \
    @throw [NSException exceptionWithName:NSInternalInconsistencyException \
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                                 userInfo:nil]

- (void)performUpdates:(void (^)())updates withOptions:(NNDiffReloadOptions *)options completion:(void (^)())completion { methodNotImplemented(); }

- (void)insertSections:(NSIndexSet *)sections { methodNotImplemented(); }
- (void)deleteSections:(NSIndexSet *)sections { methodNotImplemented(); }

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)updateItemsAtIndexPaths:(NSArray *)indexPaths { methodNotImplemented(); }
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath { methodNotImplemented(); }

@end
