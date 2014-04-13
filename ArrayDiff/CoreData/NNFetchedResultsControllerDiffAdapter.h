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

- (id)initWithDelegate:(id<NNFetchedResultsControllerDiffAdapterDelegate>)delegate;

@property (nonatomic, weak) id<NNFetchedResultsControllerDiffAdapterDelegate> delegate;

@end


@protocol NNFetchedResultsControllerDiffAdapterDelegate <NSObject>

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDiff:(NNSectionsDiff *)diff;

@end
