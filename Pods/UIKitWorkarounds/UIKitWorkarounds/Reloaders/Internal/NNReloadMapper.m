//
//  NNReloadMapper.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 26/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNReloadMapper.h"
#import "NNReloadOperations.h"
#import "NNIndexMapping.h"

@interface NNReloadMapper ()

@property (nonatomic, strong, readonly) NNReloadOperations *operations;

@property (nonatomic, strong, readonly) NNIndexMapping *sectionMapping;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NNIndexMapping *> *indexMappingsPerSectionBefore;

@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSNumber *> *movedSectionsBefore;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSNumber *> *movedSectionsAfter;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, NSIndexPath *> *movedIndexPathsBefore;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, NSIndexPath *> *movedIndexPathsAfter;

@end


@implementation NNReloadMapper

#pragma mark - Init

- (instancetype)initWithReloadOperations:(NNReloadOperations *)operations {
    self = [super init];
    if (!self) return nil;
    
    _operations = operations;
    
    [self calculateMappings];
    
    return self;
}

#pragma mark - Calculations

- (void)calculateMappings {
    [self saveMoves];
    [self calculateSectionMapping];
    [self calculateIndexMappings];
}

- (void)saveMoves {
    _movedSectionsBefore = [NSMutableDictionary dictionary];
    _movedSectionsAfter = [NSMutableDictionary dictionary];
    _movedIndexPathsBefore = [NSMutableDictionary dictionary];
    _movedIndexPathsAfter = [NSMutableDictionary dictionary];
    
    [self.operations enumerateSectionOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNSectionReloadOperation *operation, BOOL *stop) {
        _movedSectionsBefore[@(operation.before)] = @(operation.after);
        _movedSectionsAfter[@(operation.after)] = @(operation.before);
    }];
    
    [self.operations enumerateIndexPathOperationsOfType:NNReloadOperationTypeMove withBlock:^(NNIndexPathReloadOperation *operation, BOOL *stop) {
        _movedIndexPathsBefore[operation.before] = operation.after;
        _movedIndexPathsAfter[operation.after] = operation.before;
    }];
}

- (void)calculateSectionMapping {
    NSMutableIndexSet *deleted = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *inserted = [NSMutableIndexSet indexSet];
    
    for (NNSectionReloadOperation *operation in self.operations.sectionOperations) {
        if (operation.type == NNReloadOperationTypeDelete || operation.type == NNReloadOperationTypeMove) {
            [deleted addIndex:operation.before];
        }
        
        if (operation.type == NNReloadOperationTypeInsert || operation.type == NNReloadOperationTypeMove) {
            [inserted addIndex:operation.after];
        }
    }
    
    _sectionMapping = [[NNIndexMapping alloc] initWithDeletedIndexes:deleted insertedIndexes:inserted];
}

- (void)calculateIndexMappings {
    _indexMappingsPerSectionBefore = [NSMutableDictionary dictionary];
    
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    
    for (NNSectionReloadOperation *operation in self.operations.sectionOperations) {
        if (operation.type == NNReloadOperationTypeDelete) {
            [deletedSections addIndex:operation.before];
        } else if (operation.type == NNReloadOperationTypeInsert) {
            [insertedSections addIndex:operation.after];
        }
    }
    
    NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *deletedIndexesPerSectionBefore = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *insertedIndexesPerSectionBefore = [NSMutableDictionary dictionary];
    NSMutableIndexSet *affectedSectionsBefore = [NSMutableIndexSet indexSet];
    
    for (NNIndexPathReloadOperation *operation in self.operations.indexPathOperations) {
        if ((operation.type == NNReloadOperationTypeDelete || operation.type == NNReloadOperationTypeMove) &&
            ![deletedSections containsIndex:operation.before.section])
        {
            NSInteger sectionBefore = operation.before.section;
            
            NSMutableIndexSet *deletedIndexes = deletedIndexesPerSectionBefore[@(sectionBefore)];
            if (!deletedIndexes) {
                deletedIndexes = [NSMutableIndexSet indexSet];
                deletedIndexesPerSectionBefore[@(sectionBefore)] = deletedIndexes;
                
                [affectedSectionsBefore addIndex:sectionBefore];
            }
            
            [deletedIndexes addIndex:operation.before.row];
        }
        
        if ((operation.type == NNReloadOperationTypeInsert || operation.type == NNReloadOperationTypeMove) &&
            ![insertedSections containsIndex:operation.after.section])
        {
            NSInteger sectionBefore = [_sectionMapping indexAfterToIndexBefore:operation.after.section];
            
            NSMutableIndexSet *insertedIndexes = insertedIndexesPerSectionBefore[@(sectionBefore)];
            if (!insertedIndexes) {
                insertedIndexes = [NSMutableIndexSet indexSet];
                insertedIndexesPerSectionBefore[@(sectionBefore)] = insertedIndexes;
                
                [affectedSectionsBefore addIndex:sectionBefore];
            }
            
            [insertedIndexes addIndex:operation.after.row];
        }
    }
    
    [affectedSectionsBefore enumerateIndexesUsingBlock:^(NSUInteger sectionBefore, BOOL *stop) {
        NSIndexSet *deletedIndexes = deletedIndexesPerSectionBefore[@(sectionBefore)] ?: [NSIndexSet indexSet];
        NSIndexSet *insertedIndexes = insertedIndexesPerSectionBefore[@(sectionBefore)] ?: [NSIndexSet indexSet];
        
        _indexMappingsPerSectionBefore[@(sectionBefore)] = [[NNIndexMapping alloc] initWithDeletedIndexes:deletedIndexes
                                                                                          insertedIndexes:insertedIndexes];
    }];
}

#pragma mark - Public

- (NSUInteger)sectionBeforeToSectionAfter:(NSUInteger)sectionBefore {
    NSNumber *moved = self.movedSectionsBefore[@(sectionBefore)];
    return moved ? moved.unsignedIntegerValue : [self.sectionMapping indexBeforeToIndexAfter:sectionBefore];
}

- (NSUInteger)sectionAfterToSectionBefore:(NSUInteger)sectionAfter {
    NSNumber *moved = self.movedSectionsAfter[@(sectionAfter)];
    return moved ? moved.unsignedIntegerValue : [self.sectionMapping indexAfterToIndexBefore:sectionAfter];
}

- (NSIndexPath *)indexPathBeforeToIndexPathAfter:(NSIndexPath *)indexPathBefore {
    NSIndexPath *moved = self.movedIndexPathsBefore[indexPathBefore];
    if (moved) {
        return moved;
    }
    
    NSUInteger sectionAfter = [self sectionBeforeToSectionAfter:indexPathBefore.section];
    
    NNIndexMapping *indexMapping = self.indexMappingsPerSectionBefore[@(indexPathBefore.section)];
    NSUInteger indexAfter = indexMapping ? [indexMapping indexBeforeToIndexAfter:indexPathBefore.row] : indexPathBefore.row;
    
    return [NSIndexPath indexPathForRow:indexAfter inSection:sectionAfter];
}

- (NSIndexPath *)indexPathAfterToIndexPathBefore:(NSIndexPath *)indexPathAfter {
    NSIndexPath *moved = self.movedIndexPathsAfter[indexPathAfter];
    if (moved) {
        return moved;
    }
    
    NSUInteger sectionBefore = [self sectionAfterToSectionBefore:indexPathAfter.section];
    
    NNIndexMapping *indexMapping = self.indexMappingsPerSectionBefore[@(sectionBefore)];
    NSUInteger indexBefore = indexMapping ? [indexMapping indexAfterToIndexBefore:indexPathAfter.row] : indexPathAfter.row;
    
    return [NSIndexPath indexPathForRow:indexBefore inSection:sectionBefore];
}

@end
