//
//  NNCollectionViewReloader.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "NNCollectionViewReloader.h"
#import "NNReloadOperations.h"
#import "NNReloadOperationSanitizer.h"

@interface NNCollectionViewReloader ()

@property (nonatomic, copy, readonly) NNCellCustomReloadBlock cellCustomReloadBlock;

@property (nonatomic, strong) NNReloadOperations *currentOperations;

@end


@implementation NNCollectionViewReloader

#pragma mark - Init

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    return [self initWithCollectionView:collectionView cellCustomReloadBlock:nil];
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                 cellCustomReloadBlock:(NNCellCustomReloadBlock)cellCustomReloadBlock
{
    self = [super init];
    if (!self) return nil;
    
    _collectionView = collectionView;
    _cellCustomReloadBlock = [cellCustomReloadBlock copy];
    
    return self;
}

#pragma mark - Public

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion {
    [self.collectionView performBatchUpdates:^{
        self.currentOperations = [[NNReloadOperations alloc] init];
        
        updates();
        
        [NNReloadOperationSanitizer sanitizeOperations:self.currentOperations customReloadAllowed:self.cellCustomReloadBlock != nil];
        
        [self applyOperations:self.currentOperations];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
    if (self.cellCustomReloadBlock) {
        [self applyCustomReloadOperations:self.currentOperations];
    }
    
    self.currentOperations = nil;
}

- (void)insertSections:(NSIndexSet *)sections {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                                   context:nil
                                                                                                    before:NSNotFound
                                                                                                     after:idx]];
    }];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                                   context:nil
                                                                                                    before:idx
                                                                                                     after:NSNotFound]];
    }];
}

- (void)reloadSections:(NSIndexSet *)sections {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeReload
                                                                                                   context:nil
                                                                                                    before:idx
                                                                                                     after:NSNotFound]];
    }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeMove
                                                                                               context:nil
                                                                                                before:section
                                                                                                 after:newSection]];
}

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                                       context:nil
                                                                                                        before:nil
                                                                                                         after:indexPath]];
    }
}

- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                                       context:nil
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeReload
                                                                                                       context:nil
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)reloadItemsAtIndexPathsWithCustomBlock:(NSArray<NSIndexPath *> *)indexPaths {
    NSAssert(self.cellCustomReloadBlock != nil, @"Did you forget to set cellCustomReloadBlock?");
    
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeCustomReload
                                                                                                       context:nil
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeMove
                                                                                                   context:nil
                                                                                                    before:indexPath
                                                                                                     after:newIndexPath]];
}

#pragma mark - Private

- (void)applyOperations:(NNReloadOperations *)operations {
    // TODO: check if performing operations one by one is slower
    
    for (NNIndexPathReloadOperation *operation in operations.indexPathOperations) {
        switch (operation.type) {
            case NNReloadOperationTypeDelete:
                [self.collectionView deleteItemsAtIndexPaths:@[ operation.before ]];
                break;
                
            case NNReloadOperationTypeInsert:
                [self.collectionView insertItemsAtIndexPaths:@[ operation.after ]];
                break;
                
            case NNReloadOperationTypeReload:
                [self.collectionView reloadItemsAtIndexPaths:@[ operation.before ]];
                break;
                
            case NNReloadOperationTypeMove:
                [self.collectionView moveItemAtIndexPath:operation.before toIndexPath:operation.after];
                break;
                
            case NNReloadOperationTypeCustomReload:
                break;
        }
    }
    
    for (NNSectionReloadOperation *operation in operations.sectionOperations) {
        switch (operation.type) {
            case NNReloadOperationTypeDelete:
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:operation.before]];
                break;
                
            case NNReloadOperationTypeInsert:
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:operation.after]];
                break;
                
            case NNReloadOperationTypeReload:
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:operation.before]];
                break;
                
            case NNReloadOperationTypeMove:
                [self.collectionView moveSection:operation.before toSection:operation.after];
                break;
                
            case NNReloadOperationTypeCustomReload:
                break;
        }
    }
}

- (void)applyCustomReloadOperations:(NNReloadOperations *)operations {
    for (NNIndexPathReloadOperation *operation in operations.indexPathOperations) {
        if (operation.type == NNReloadOperationTypeCustomReload) {
            id cell = [self.collectionView cellForItemAtIndexPath:operation.after];
            self.cellCustomReloadBlock(cell, operation.after);
        }
    }
}

@end
