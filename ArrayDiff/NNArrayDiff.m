//
//  NNArrayDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 02/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiff.h"

@interface NNArrayDiff ()

@property (nonatomic, strong) NSMutableDictionary *sameObjectIndexes;

@end


@implementation NNArrayDiff

- (id)initWithBefore:(NSArray *)before
               after:(NSArray *)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    self = [super init];
    if (!self) return nil;
    
    before = before ?: @[];
    after = after ?: @[];
    idBlock = idBlock ?: ^(id object) {
        return object;
    };
    updatedBlock = updatedBlock ?: ^BOOL (id objectBefore, id objectAfter) {
        return ![objectBefore isEqual:objectAfter];
    };
    
    [self calculateChangesFromObjects:before toObjects:after idBlock:idBlock updatedBlock:updatedBlock];
    
    return self;
}

- (id)initWithDeleted:(NSIndexSet *)deleted
             inserted:(NSIndexSet *)inserted
                moved:(NSSet *)moved
              updated:(NSIndexSet *)updated
{
    self = [super init];
    if (!self) return nil;
    
    _deleted = [deleted copy] ?: [NSIndexSet indexSet];
    _inserted = [inserted copy] ?: [NSIndexSet indexSet];
    _moved = [moved copy] ?: [NSSet set];
    _updated = [updated copy] ?: [NSIndexSet indexSet];
    
    return self;
}

#pragma mark - Private

- (void)calculateChangesFromObjects:(NSArray *)objectsBefore
                          toObjects:(NSArray *)objectsAfter
                            idBlock:(NNDiffObjectIdBlock)idBlock
                       updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    // TODO: docs!
    
    NSMutableIndexSet *updated = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *deleted = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *inserted = [NSMutableIndexSet indexSet];
    NSMutableSet *moved = [NSMutableSet set];

    
    NSArray *before = [self arrayIds:objectsBefore withBlock:idBlock];
    NSArray *after = [self arrayIds:objectsAfter withBlock:idBlock];
    
    NSMapTable *beforeOrderTable = [NSMapTable strongToStrongObjectsMapTable];
    [before enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [beforeOrderTable setObject:@(idx) forKey:obj];
    }];
    
    NSMapTable *afterOrderTable = [NSMapTable strongToStrongObjectsMapTable];
    [after enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [afterOrderTable setObject:@(idx) forKey:obj];
    }];
    
    
    [before enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![afterOrderTable objectForKey:obj]) {
            [deleted addIndex:idx];
        }
    }];
    
    [after enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![beforeOrderTable objectForKey:obj]) {
            [inserted addIndex:idx];
        }
    }];
    
    
    NSMutableArray *sameBefore = [before mutableCopy];
    [sameBefore removeObjectsAtIndexes:deleted];
    
    NSMutableArray *sameAfter = [after mutableCopy];
    [sameAfter removeObjectsAtIndexes:inserted];
    
    
    // http://en.wikipedia.org/wiki/Longest_increasing_subsequence
    
    NSUInteger n = [sameBefore count];
    NSUInteger *X = malloc(sizeof(NSUInteger) * n);
    NSUInteger *M = malloc(sizeof(NSUInteger) * n);
    NSUInteger *P = malloc(sizeof(NSUInteger) * n);
    
    [sameBefore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        X[idx] = [[afterOrderTable objectForKey:obj] unsignedIntegerValue];
    }];
    
    NSInteger L = 0;
    
    for (NSUInteger i = 0; i < n; ++i) {
        NSInteger j = -1;
        
        // Find the largest j in [0; L-1] such that X[M[j]] < X[i]        
        if (L > 0 && X[M[L-1]] < X[i]) {
            j = L-1;
        } else {
            NSInteger left = 0;
            NSInteger right = L-1;
            NSInteger mid;
            while (right > left + 1) {
                mid = (left + right) / 2;
                if (X[M[mid]] < X[i]) {
                    left = mid;
                } else {
                    right = mid;
                }
            }
            
            if (L > 0) {
                if (right >= 0 && X[M[right]] < X[i]) {
                    j = right;
                } else if (X[M[left]] < X[i]) {
                    j = left;
                }
            }
        }
        
        P[i] = (j != -1) ? M[j] : -1;
        
        if (j+1 == L || X[i] < X[M[j+1]]) {
            M[j+1] = i;
            L = MAX(L, j+2);
        }
    }
    
    NSMutableIndexSet *afterStaticIndexes = [NSMutableIndexSet indexSet];
    
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < L; ++i) {
        if (index != NSNotFound) {
            index = P[index];
        } else {
            index = M[L-1];
        }
        
        NSUInteger afterIndex = X[index];
        [afterStaticIndexes addIndex:afterIndex];
    }
    
    free(X);
    free(M);
    free(P);
    
    
    [sameAfter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger beforeIndex = [[beforeOrderTable objectForKey:obj] unsignedIntegerValue];
        NSUInteger afterIndex = [[afterOrderTable objectForKey:obj] unsignedIntegerValue];
        
        id objectBefore = objectsBefore[beforeIndex];
        id objectAfter = objectsAfter[afterIndex];
        BOOL objectUpdated = updatedBlock(objectBefore, objectAfter);
        
        if ([afterStaticIndexes containsIndex:afterIndex]) {
            if (objectUpdated) {
                [updated addIndex:afterIndex];
            }
        } else {
            [moved addObject:[[NNArrayDiffMove alloc] initWithFrom:beforeIndex to:afterIndex updated:objectUpdated]];
        }
    }];
    
    
    _updated = [updated copy];
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _moved = [moved copy];
}

- (NSArray *)arrayIds:(NSArray *)array withBlock:(NNDiffObjectIdBlock)block
{
    NSMutableArray *arrayIds = [NSMutableArray arrayWithCapacity:[array count]];
    for (id object in array) {
        [arrayIds addObject:block(object)];
    }
    return arrayIds;
}

#pragma mark - Description

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendString:@" {\n"];
    
    if ([self.deleted count] > 0) {
        [description appendFormat:@"  Deleted: %@\n", [self descriptionForIndexes:self.deleted]];
    }
    
    if ([self.inserted count] > 0) {
        [description appendFormat:@"  Inserted: %@\n", [self descriptionForIndexes:self.inserted]];
    }
    
    if ([self.moved count] > 0) {
        [description appendFormat:@"  Moved: %@\n", [self descriptionForMoved:self.moved]];
    }
    
    if ([self.updated count] > 0) {
        [description appendFormat:@"  Updated: %@\n", [self descriptionForIndexes:self.updated]];
    }
    
    [description appendString:@"}"];
    return description;
}

- (NSString *)descriptionForIndexes:(NSIndexSet *)indexSet {
    NSMutableArray *strings = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [strings addObject:[NSString stringWithFormat:@"%@", @(idx)]];
    }];
    return [strings componentsJoinedByString:@", "];
}

- (NSString *)descriptionForMoved:(NSSet *)set {
    NSArray *sortedMoves = [[set allObjects] sortedArrayUsingComparator:^NSComparisonResult(NNArrayDiffMove *obj1, NNArrayDiffMove *obj2) {
        if (obj1.from != obj2.from) {
            return obj1.from < obj2.from ? NSOrderedAscending : NSOrderedDescending;
        }
        if (obj1.to != obj2.to) {
            return obj1.to < obj2.to ? NSOrderedAscending : NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    NSMutableArray *strings = [NSMutableArray array];
    for (NNArrayDiff *move in sortedMoves) {
        [strings addObject:[move description]];
    };
    return [strings componentsJoinedByString:@", "];
}

@end
