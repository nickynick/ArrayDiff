//
//  NNCollectionViewReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNCollectionViewReloader.h"

@interface NNCollectionViewReloader ()

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation NNCollectionViewReloader

#pragma mark - Init

- (id)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    
    return self;
}

#pragma mark - NNCocoaTouchCollectionReloader

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion {
    [self.collectionView performBatchUpdates:updates completion:^(__unused BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self.collectionView insertSections:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self.collectionView deleteSections:sections];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths; {
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionView cellForItemAtIndexPath:indexPath];
}

@end
