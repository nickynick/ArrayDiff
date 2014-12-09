//
//  NNFetchedResultsControllerDiffAdapter.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNFetchedResultsControllerDiffAdapter.h"
#import "NNSectionsDiff.h"
#import "NNSectionsDiffChange.h"

@interface NNFetchedResultsControllerUpdate : NSObject

@property (nonatomic, readonly) id object;
@property (nonatomic, readonly) NSIndexPath *indexPath;

@end

@implementation NNFetchedResultsControllerUpdate

- (instancetype)initWithObject:(id)object indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (!self) return nil;
    
    _object = object;
    _indexPath = indexPath;
    
    return self;
}

@end


@interface NNFetchedResultsControllerDiffAdapter ()

@property (nonatomic, strong) NNMutableSectionsDiff *diff;
@property (nonatomic, strong) NSMutableArray *updates;

@end


@implementation NNFetchedResultsControllerDiffAdapter

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.diff = [[NNMutableSectionsDiff alloc] init];
    self.updates = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.diff.insertedSections addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.diff.deletedSections addIndex:sectionIndex];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.diff.inserted addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.diff.deleted addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.diff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:indexPath
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
        [self.diff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:update.indexPath
                                                                            after:[controller indexPathForObject:update.object]
                                                                             type:NNDiffChangeUpdate | NNDiffChangeMove]];
    }
    
    [self.delegate controller:controller didChangeContentWithDiff:[self.diff copy]];
    
    self.diff = nil;
    self.updates = nil;
}

@end
