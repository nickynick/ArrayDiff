//
//  NNFetchedResultsControllerDiffAdapter.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"

@import CoreData;

@protocol NNFetchedResultsControllerDiffAdapterDelegate;


@interface NNFetchedResultsControllerDiffAdapter : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<NNFetchedResultsControllerDiffAdapterDelegate> delegate;

@end


@interface NNFetchedResultsControllerDiffAdapter (NSFetchedResultsControllerDelegate)

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller;
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type;
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller;

@end


@protocol NNFetchedResultsControllerDiffAdapterDelegate <NSObject>

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDiff:(NNSectionsDiff *)diff;

@end
