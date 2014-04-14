//
//  NNFetchedResultsControllerDiffAdapter.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNFetchedResultsControllerDiffAdapter.h"

@interface NNFetchedResultsControllerUpdate : NSObject

@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) NSIndexPath *indexPath;

- (id)initWithObject:(id)object indexPath:(NSIndexPath *)indexPath;

@end

@implementation NNFetchedResultsControllerUpdate

- (id)initWithObject:(id)object indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (!self) return nil;
    
    _object = object;
    _indexPath = indexPath;
    
    return self;
}

@end


@interface NNFetchedResultsControllerDiffAdapter ()

@property (nonatomic, strong) NSMutableIndexSet *deletedSections;
@property (nonatomic, strong) NSMutableIndexSet *insertedSections;
@property (nonatomic, strong) NSMutableArray *deletedRows;
@property (nonatomic, strong) NSMutableArray *insertedRows;
@property (nonatomic, strong) NSMutableArray *changedRows;

@property (nonatomic, strong) NSMutableArray *updates;

@end


@implementation NNFetchedResultsControllerDiffAdapter

- (id)initWithDelegate:(id<NNFetchedResultsControllerDiffAdapterDelegate>)delegate {
    self = [super init];
    if (!self) return nil;
    
    _delegate = delegate;
    
    return self;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.deletedSections = [NSMutableIndexSet indexSet];
    self.insertedSections = [NSMutableIndexSet indexSet];
    self.deletedRows = [NSMutableArray array];
    self.insertedRows = [NSMutableArray array];
    self.changedRows = [NSMutableArray array];
    self.updates = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSections addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.deletedSections addIndex:sectionIndex];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedRows addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.deletedRows addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.changedRows addObject:[[NNSectionsDiffChange alloc] initWithBefore:indexPath
                                                                               after:newIndexPath
                                                                                type:[anObject isUpdated] ? (NNDiffChangeUpdate | NNDiffChangeMove) : NNDiffChangeMove]];
            break;
        case NSFetchedResultsChangeUpdate:
            // We don't have newIndexPath to create NNSectionsDiffChange object, let's retrieve it later.
            [self.updates addObject:[[NNFetchedResultsControllerUpdate alloc] initWithObject:anObject indexPath:indexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    for (NNFetchedResultsControllerUpdate *update in self.updates) {
        // https://developer.apple.com/library/iOS/releasenotes/iPhone/NSFetchedResultsChangeMoveReportedAsNSFetchedResultsChangeUpdate/index.html
        // NSFetchedResultsChangeUpdate is returned for all cases when object's initial and final index paths are equal.
        // However, this doesn't mean that object hasn't moved.
        // Therefore, we should always treat this as a move.
        [self.changedRows addObject:[[NNSectionsDiffChange alloc] initWithBefore:update.indexPath
                                                                           after:[controller indexPathForObject:update.object]
                                                                            type:NNDiffChangeUpdate | NNDiffChangeMove]];
    }
    
    NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:self.deletedSections
                                                          insertedSections:self.insertedSections
                                                                   deleted:self.deletedRows
                                                                  inserted:self.insertedRows
                                                                   changed:self.changedRows];
    
    [self.delegate controller:controller didChangeContentWithDiff:diff];
    
    self.deletedSections = nil;
    self.insertedSections = nil;
    self.deletedRows = nil;
    self.insertedRows = nil;
    self.changedRows = nil;
    self.updates = nil;
}

@end
