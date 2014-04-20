//
//  NNCocoaTouchCollection.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

@protocol NNCocoaTouchCollection <NSObject>

- (void)performUpdates:(void (^)())updates;

- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end