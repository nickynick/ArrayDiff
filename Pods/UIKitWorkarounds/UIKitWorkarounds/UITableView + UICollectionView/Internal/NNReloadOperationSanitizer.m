//
//  NNReloadOperationSanitizer.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "NNReloadOperationSanitizer.h"
#import "NNReloadOperations.h"
#import "NNReloadMapper.h"
#import <UIKit/UIKit.h>

@interface NNReloadOperationSanitizer ()

@property (nonatomic, strong) NNReloadOperations *operations;
@property (nonatomic, assign) BOOL customReloadAllowed;

@property (nonatomic, strong) NNReloadMapper *mapper;

@end


@implementation NNReloadOperationSanitizer

#pragma mark - Public

+ (void)sanitizeOperations:(NNReloadOperations *)operations customReloadAllowed:(BOOL)customReloadAllowed {
    NNReloadOperationSanitizer *sanitizer = [[NNReloadOperationSanitizer alloc] init];
    sanitizer.operations = operations;
    sanitizer.customReloadAllowed = customReloadAllowed;
    
    [sanitizer sanitize];
}

#pragma mark - Private

- (void)sanitize {
    self.mapper = [[NNReloadMapper alloc] initWithReloadOperations:self.operations];
    
    [self calculateAfterIndexesForReloads];
    [self sanitizeMovedIndexPathsFromDeletedSectionsOrIntoInsertedSections];
    [self sanitizeIndexPathsMovedBetweenSections];
    [self sanitizeReloadedAndMovedIndexPaths];
    [self sanitizeExcessiveReloadedIndexPaths];
}

- (void)calculateAfterIndexesForReloads {
    [self sanitizeSectionOperationsWithBlock:^(NSMutableSet<NNSectionReloadOperation *> *badOperations, NSMutableSet<NNSectionReloadOperation *> *goodOperations) {
        for (NNSectionReloadOperation *operation in self.operations.sectionOperations) {
            if (operation.type != NNReloadOperationTypeReload && operation.type != NNReloadOperationTypeCustomReload) {
                continue;
            }
            
            if (operation.after != NSNotFound) {
                continue;
            }
            
            NSUInteger after = [self.mapper sectionBeforeToSectionAfter:operation.before];
            
            [badOperations addObject:operation];
            [goodOperations addObject:[[NNSectionReloadOperation alloc] initWithType:operation.type
                                                                             context:operation.context
                                                                              before:operation.before
                                                                               after:after]];
        }
    }];
    
    [self sanitizeIndexPathOperationsWithBlock:^(NSMutableSet<NNIndexPathReloadOperation *> *badOperations, NSMutableSet<NNIndexPathReloadOperation *> *goodOperations) {
        for (NNIndexPathReloadOperation *operation in self.operations.indexPathOperations) {
            if (operation.type != NNReloadOperationTypeReload && operation.type != NNReloadOperationTypeCustomReload) {
                continue;
            }
            
            if (operation.after) {
                continue;
            }
            
            NSIndexPath *after = [self.mapper indexPathBeforeToIndexPathAfter:operation.before];

            [badOperations addObject:operation];
            [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:operation.type
                                                                               context:operation.context
                                                                                before:operation.before
                                                                                 after:after]];
        }
    }];
}

- (void)sanitizeMovedIndexPathsFromDeletedSectionsOrIntoInsertedSections {
    // UIKit would get upset if we attempted to move an item from a section being deleted / into a section being inserted.
    // Therefore, we should break such moves into deletions + insertions.
    
    [self sanitizeIndexPathOperationsWithBlock:^(NSMutableSet<NNIndexPathReloadOperation *> *badOperations, NSMutableSet<NNIndexPathReloadOperation *> *goodOperations) {
        NSIndexSet *deletedSections = [self deletedSections];
        NSIndexSet *insertedSections = [self insertedSections];
        
        [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
            if ([deletedSections containsIndex:operation.before.section]) {
                [badOperations addObject:operation];
                
                if (![insertedSections containsIndex:operation.after.section]) {
                    [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                       context:operation.context
                                                                                        before:nil
                                                                                         after:operation.after]];
                }
            } else if ([insertedSections containsIndex:operation.after.section]) {
                [badOperations addObject:operation];
                
                [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                   context:operation.context
                                                                                    before:operation.before
                                                                                     after:nil]];
            }
        }];
    }];
}

- (void)sanitizeIndexPathsMovedBetweenSections {
    // Move animations between different sections will crash if the destination section index doesn't match its initial one.
    
    [self sanitizeIndexPathOperationsWithBlock:^(NSMutableSet<NNIndexPathReloadOperation *> *badOperations, NSMutableSet<NNIndexPathReloadOperation *> *goodOperations) {
        [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
            NSUInteger sourceSection = operation.before.section;
            NSUInteger destinationSection = operation.after.section;
            NSUInteger oldDestinationSection = [self.mapper sectionAfterToSectionBefore:destinationSection];
            
            if (sourceSection != oldDestinationSection && destinationSection != oldDestinationSection) {
                [badOperations addObject:operation];
                
                [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                   context:operation.context
                                                                                    before:operation.before
                                                                                     after:nil]];
                
                [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                   context:operation.context
                                                                                    before:nil
                                                                                     after:operation.after]];
            }
        }];
    }];
}

- (void)sanitizeReloadedAndMovedIndexPaths {
    // We can't move and reload the same cell at once. There are two options:
    //
    // 1) Use custom reload to achieve reloading
    // 2) Replace move + reload with delete + insert
    
    NSSet<NSIndexPath *> *movedFromIndexPaths = [self movedFromIndexPaths];

    if (movedFromIndexPaths.count == 0) {
        // Phew, there are no moves! Bail out.
        return;
    }
    
    NSSet<NSIndexPath *> *reloadedIndexPaths = [self reloadedIndexPaths];
    
    [self sanitizeIndexPathOperationsWithBlock:^(NSMutableSet<NNIndexPathReloadOperation *> *badOperations, NSMutableSet<NNIndexPathReloadOperation *> *goodOperations) {
        [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
            if ([reloadedIndexPaths containsObject:operation.before]) {
                if (self.customReloadAllowed) {
                    [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeCustomReload
                                                                                       context:operation.context
                                                                                        before:operation.before
                                                                                         after:operation.after]];
                } else {
                    [badOperations addObject:operation];
                }
            }
        }];
        
        [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeReload withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
            [badOperations addObject:operation];
            
            if (![movedFromIndexPaths containsObject:operation.before] || !self.customReloadAllowed) {
                [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                   context:operation.context
                                                                                    before:operation.before
                                                                                     after:nil]];
                
                [goodOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                   context:operation.context
                                                                                    before:nil
                                                                                     after:operation.after]];
            }
        }];
    }];
}

- (void)sanitizeExcessiveReloadedIndexPaths {
    // Get rid of reloads which coincide with deleted/inserted sections or deletes.
    //
    // (We could also add some of these on the steps prior to this one, so this is a cleanup.)
    
    [self sanitizeIndexPathOperationsWithBlock:^(NSMutableSet<NNIndexPathReloadOperation *> *badOperations, NSMutableSet<NNIndexPathReloadOperation *> *goodOperations) {
        
        NSIndexSet *deletedSections = [self deletedSections];
        NSIndexSet *insertedSections = [self insertedSections];
        NSSet<NSIndexPath *> *deletedIndexPaths = [self deletedIndexPaths];
        
        for (NNIndexPathReloadOperation *operation in self.operations.indexPathOperations) {
            if (operation.type == NNReloadOperationTypeReload || operation.type == NNReloadOperationTypeCustomReload) {
                if ([deletedSections containsIndex:operation.before.section] ||
                    [insertedSections containsIndex:operation.after.section] ||
                    [deletedIndexPaths containsObject:operation.before])
                {
                    [badOperations addObject:operation];
                }
            }
        }
    }];
}

#pragma mark - Helpers

- (void)sanitizeSectionOperationsWithBlock:(void (^)(NSMutableSet<NNSectionReloadOperation *> *badOperations,
                                                     NSMutableSet<NNSectionReloadOperation *> *goodOperations))block
{
    NSMutableSet<NNSectionReloadOperation *> *badOperations = [NSMutableSet set];
    NSMutableSet<NNSectionReloadOperation *> *goodOperations = [NSMutableSet set];
    
    block(badOperations, goodOperations);
    
    [self.operations.sectionOperations minusSet:badOperations];
    [self.operations.sectionOperations unionSet:goodOperations];
}

- (void)sanitizeIndexPathOperationsWithBlock:(void (^)(NSMutableSet<NNIndexPathReloadOperation *> *badOperations,
                                                       NSMutableSet<NNIndexPathReloadOperation *> *goodOperations))block
{
    NSMutableSet<NNIndexPathReloadOperation *> *badOperations = [NSMutableSet set];
    NSMutableSet<NNIndexPathReloadOperation *> *goodOperations = [NSMutableSet set];
    
    block(badOperations, goodOperations);
    
    [self.operations.indexPathOperations minusSet:badOperations];
    [self.operations.indexPathOperations unionSet:goodOperations];
}

- (NSIndexSet *)deletedSections {
    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];
    [self.operations enumerateSectionOperationsOfType:NNReloadOperationTypeDelete withBlock:^(NNSectionReloadOperation *operation, BOOL *stop) {
        [sections addIndex:operation.before];
    }];
    return sections;
}

- (NSIndexSet *)insertedSections {
    NSMutableIndexSet *sections = [[NSMutableIndexSet alloc] init];
    [self.operations enumerateSectionOperationsOfType:NNReloadOperationTypeInsert withBlock:^(NNSectionReloadOperation *operation, BOOL *stop) {
        [sections addIndex:operation.after];
    }];
    return sections;
}

- (NSSet<NSIndexPath *> *)reloadedIndexPaths {
    NSMutableSet<NSIndexPath *> *indexPaths = [NSMutableSet set];
    [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeReload withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
        [indexPaths addObject:operation.before];
    }];
    return indexPaths;
}

- (NSSet<NSIndexPath *> *)deletedIndexPaths {
    NSMutableSet<NSIndexPath *> *indexPaths = [NSMutableSet set];
    [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeDelete withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
        [indexPaths addObject:operation.before];
    }];
    return indexPaths;
}

- (NSSet<NSIndexPath *> *)movedFromIndexPaths {
    NSMutableSet<NSIndexPath *> *indexPaths = [NSMutableSet set];
    [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
        [indexPaths addObject:operation.before];
    }];
    return indexPaths;
}

@end
