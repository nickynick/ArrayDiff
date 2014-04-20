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

- (id)init {
    return [self initWithDeleted:nil inserted:nil changed:nil];
}

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
              changed:(NSArray *)changed
{
    self = [super init];
    if (!self) return nil;
    
    _deleted = [deleted copy] ?: [NSIndexSet indexSet];
    _inserted = [inserted copy] ?: [NSIndexSet indexSet];
    _changed = [changed copy] ?: @[];
    
    return self;
}

#pragma mark - Private

- (void)calculateChangesFromObjects:(NSArray *)objectsBefore
                          toObjects:(NSArray *)objectsAfter
                            idBlock:(NNDiffObjectIdBlock)idBlock
                       updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    // TODO: docs!
    
    NSMutableIndexSet *deleted = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *inserted = [NSMutableIndexSet indexSet];
    NSMutableArray *changed = [NSMutableArray array];

    
    NSOrderedSet *before = [self idsOfObjects:objectsBefore withBlock:idBlock];
    NSOrderedSet *after = [self idsOfObjects:objectsAfter withBlock:idBlock];
    
    [before enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![after containsObject:obj]) {
            [deleted addIndex:idx];
        }
    }];
    
    [after enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![before containsObject:obj]) {
            [inserted addIndex:idx];
        }
    }];
    
    
    NSMutableOrderedSet *sameBefore = [before mutableCopy];
    [sameBefore removeObjectsAtIndexes:deleted];
    
    NSMutableOrderedSet *sameAfter = [after mutableCopy];
    [sameAfter removeObjectsAtIndexes:inserted];
    
    
    // http://en.wikipedia.org/wiki/Longest_increasing_subsequence
    
    NSUInteger n = [sameBefore count];
    NSUInteger *X = malloc(sizeof(NSUInteger) * n);
    NSUInteger *M = malloc(sizeof(NSUInteger) * n);
    NSUInteger *P = malloc(sizeof(NSUInteger) * n);
    
    [sameBefore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        X[idx] = [after indexOfObject:obj];
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
        NSUInteger beforeIndex = [before indexOfObject:obj];
        NSUInteger afterIndex = [after indexOfObject:obj];
                
        NNDiffChangeType changeType = 0;
        if (![afterStaticIndexes containsIndex:afterIndex]) {
            changeType |= NNDiffChangeMove;
        }
        if (updatedBlock(objectsBefore[beforeIndex], objectsAfter[afterIndex])) {
            changeType |= NNDiffChangeUpdate;
        }
        
        if (changeType != 0) {
            NNArrayDiffChange *change = [[NNArrayDiffChange alloc] initWithBefore:beforeIndex after:afterIndex type:changeType];
            [changed addObject:change];
        }
    }];
    
    
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _changed = [changed copy];
}

- (NSOrderedSet *)idsOfObjects:(NSArray *)array withBlock:(NNDiffObjectIdBlock)block
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[array count]];
    for (id object in array) {
        [ids addObject:block(object)];
    }
    return [NSOrderedSet orderedSetWithArray:ids];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNArrayDiff class]]) return NO;
    return [self isEqualToArrayDiff:other];
}

- (BOOL)isEqualToArrayDiff:(NNArrayDiff *)other {
    if (![self.deleted isEqualToIndexSet:other.deleted]) return NO;
    if (![self.inserted isEqualToIndexSet:other.inserted]) return NO;
    if (![self.changed isEqualToArray:other.changed]) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.deleted hash];
    result = prime * result + [self.inserted hash];
    result = prime * result + [self.changed hash];
    
    return result;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendString:@" {\n"];
    
    if ([self.deleted count] > 0) {
        [description appendFormat:@"  Deleted: %@\n", [self descriptionForIndexes:self.deleted]];
    }
    
    if ([self.inserted count] > 0) {
        [description appendFormat:@"  Inserted: %@\n", [self descriptionForIndexes:self.inserted]];
    }
    
    if ([self.changed count] > 0) {
        [description appendFormat:@"  Changed: %@\n", [self descriptionForChanged:self.changed]];
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

- (NSString *)descriptionForChanged:(NSArray *)array {
    NSArray *sortedChanges = [array sortedArrayUsingComparator:^NSComparisonResult(NNArrayDiffChange *obj1, NNArrayDiffChange *obj2) {
        if (obj1.before != obj2.before) {
            return obj1.before < obj2.before ? NSOrderedAscending : NSOrderedDescending;
        }
        if (obj1.after != obj2.after) {
            return obj1.after < obj2.after ? NSOrderedAscending : NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    NSMutableArray *strings = [NSMutableArray array];
    for (NNArrayDiffChange *change in sortedChanges) {
        [strings addObject:[change description]];
    };
    return [strings componentsJoinedByString:@", "];
}

@end
