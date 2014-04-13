//
//  NNFetchedResultsControllerDiffAdapter.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNFetchedResultsControllerDiffAdapter.h"

@interface NNFetchedResultsControllerDiffAdapter ()

@property (nonatomic, strong) NSMutableIndexSet *deletedSections;
@property (nonatomic, strong) NSMutableIndexSet *insertedSections;
@property (nonatomic, strong) NSMutableSet *deletedRows;
@property (nonatomic, strong) NSMutableSet *insertedRows;
@property (nonatomic, strong) NSMutableSet *movedRows;
@property (nonatomic, strong) NSMutableSet *updatedRows;

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
    self.deletedRows = [NSMutableSet set];
    self.insertedRows = [NSMutableSet set];
    self.movedRows = [NSMutableSet set];
    self.updatedRows = [NSMutableSet set];
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
            [self.movedRows addObject:[[NNSectionsDiffMove alloc] initWithFrom:indexPath to:newIndexPath updated:[anObject isUpdated]]];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.updatedRows addObject:indexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:self.deletedSections
                                                          insertedSections:self.insertedSections
                                                                   deleted:self.deletedRows
                                                                  inserted:self.insertedRows
                                                                     moved:self.movedRows
                                                                   updated:self.updatedRows];
    
    [self.delegate controller:controller didChangeContentWithDiff:diff];
    
    self.deletedSections = nil;
    self.insertedSections = nil;
    self.deletedRows = nil;
    self.insertedRows = nil;
    self.movedRows = nil;
    self.updatedRows = nil;
}

@end
