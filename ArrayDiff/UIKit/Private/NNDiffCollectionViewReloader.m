//
//  NNDiffCollectionViewReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffCollectionViewReloader.h"
#import <UIKitWorkarounds/UIKitWorkarounds.h>

@interface NNDiffCollectionViewReloader ()

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NNCollectionViewReloader *reloader;

@end


@implementation NNDiffCollectionViewReloader

#pragma mark - Init

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    
    return self;
}

#pragma mark - NNDiffReloader

- (void)performUpdates:(void (^)())updates withOptions:(NNDiffReloadOptions *)options completion:(void (^)())completion {
    self.reloader = [[NNCollectionViewReloader alloc] initWithCollectionView:self.collectionView
                                                       cellCustomReloadBlock:options.cellUpdateBlock];
    
    [self.reloader performUpdates:updates completion:^{
        if (completion) {
            completion();
        }
        
        self.reloader = nil;
    }];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self.reloader insertSections:sections];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self.reloader deleteSections:sections];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader insertItemsAtIndexPaths:indexPaths];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader deleteItemsAtIndexPaths:indexPaths];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader reloadItemsAtIndexPaths:indexPaths];
}

- (void)updateItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader reloadItemsAtIndexPathsWithCustomBlock:indexPaths];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.reloader moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
}

@end
