//
//  NNCocoaTouchCollectionReloader.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSectionsDiff.h"
#import "NNDiffReloadOptions.h"

@interface NNCocoaTouchCollectionReloader : NSObject

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)diff
                       options:(NNDiffReloadOptions)options
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
                    completion:(void (^)())completion;

@end


@interface NNCocoaTouchCollectionReloader (Abstract)

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion;

- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end