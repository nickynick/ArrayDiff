//
//  NNIndexMapping.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 27/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "NNIndexMapping.h"

@interface NNIndexMappingData : NSObject
{
    NSMutableIndexSet *_indexes;
    NSMutableDictionary<NSNumber *, NSNumber *> *_deltasByIndexes;
}

- (void)useDelta:(NSInteger)delta startingFromIndex:(NSUInteger)index;
- (NSInteger)deltaAtIndex:(NSUInteger)index;

- (instancetype)invert;

@end


@implementation NNIndexMappingData

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _indexes = [NSMutableIndexSet indexSetWithIndex:0];
    _deltasByIndexes = [NSMutableDictionary dictionaryWithObject:@(0) forKey:@(0)];
    
    return self;
}

- (void)useDelta:(NSInteger)delta startingFromIndex:(NSUInteger)index {
    [_indexes addIndex:index];
    _deltasByIndexes[@(index)] = @(delta);
}

- (NSInteger)deltaAtIndex:(NSUInteger)index {
    NSUInteger existingIndex = [_indexes indexLessThanOrEqualToIndex:index];
    return _deltasByIndexes[@(existingIndex)].integerValue;
}

- (instancetype)invert {
    NNIndexMappingData *invertedData = [[NNIndexMappingData alloc] init];
    
    [_indexes enumerateIndexesUsingBlock:^(NSUInteger indexBefore, BOOL *stop) {
        NSInteger delta = _deltasByIndexes[@(indexBefore)].integerValue;
        
        NSUInteger indexAfter = indexBefore + delta;
        [invertedData useDelta:-delta startingFromIndex:indexAfter];
    }];
    
    return invertedData;
}

@end


@implementation NNIndexMapping
{
    NNIndexMappingData *_beforeData;
    NNIndexMappingData *_afterData;
}

- (instancetype)initWithDeletedIndexes:(NSIndexSet *)deletedIndexes
                       insertedIndexes:(NSIndexSet *)insertedIndexes
{
    self = [super init];
    if (!self) return nil;
    
    _beforeData = [self calculateBeforeMappingDataWithDeletedIndexes:[deletedIndexes mutableCopy]
                                                     insertedIndexes:[insertedIndexes mutableCopy]];
    _afterData = [_beforeData invert];
    
    return self;
}

- (NNIndexMappingData *)calculateBeforeMappingDataWithDeletedIndexes:(NSMutableIndexSet *)deleted
                                                     insertedIndexes:(NSMutableIndexSet *)inserted {
    
    NNIndexMappingData *data = [[NNIndexMappingData alloc] init];
    NSInteger currentDelta = 0;
    
    while (deleted.count > 0 || inserted.count > 0) {
        NSUInteger deletedIndex = deleted.count > 0 ? deleted.firstIndex : NSUIntegerMax;
        NSUInteger insertedIndex = inserted.count > 0 ? inserted.firstIndex - currentDelta : NSUIntegerMax;
        
        if (deletedIndex <= insertedIndex) {
            --currentDelta;
            [data useDelta:currentDelta startingFromIndex:deletedIndex + 1];
            
            [deleted removeIndex:deleted.firstIndex];
        } else {
            ++currentDelta;
            [data useDelta:currentDelta startingFromIndex:insertedIndex];
            
            [inserted removeIndex:inserted.firstIndex];
        }
    }
    
    return data;
}

- (NSUInteger)indexBeforeToIndexAfter:(NSUInteger)indexBefore {
    NSInteger delta = [_beforeData deltaAtIndex:indexBefore];
    return indexBefore + delta;
}

- (NSUInteger)indexAfterToIndexBefore:(NSUInteger)indexAfter {
    NSInteger delta = [_afterData deltaAtIndex:indexAfter];
    return indexAfter + delta;
}

@end
