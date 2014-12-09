//
//  NNArrayDiffCalculator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffCalculator.h"
#import "NNArrayDiff.h"
#import "NNArrayDiffChange.h"

@implementation NNArrayDiffCalculator

#pragma mark - Public

- (NNArrayDiff *)calculateDiffForObjectsBefore:(NSArray *)objectsBefore andAfter:(NSArray *)objectsAfter
{
    // TODO: docs!
    
    NNMutableArrayDiff *diff = [[NNMutableArrayDiff alloc] init];
    
    NSOrderedSet *before = [self idsOfObjects:objectsBefore withBlock:self.objectIdBlock];
    NSOrderedSet *after = [self idsOfObjects:objectsAfter withBlock:self.objectIdBlock];
    
    [before enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![after containsObject:obj]) {
            [diff.deleted addIndex:idx];
        }
    }];
    
    [after enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![before containsObject:obj]) {
            [diff.inserted addIndex:idx];
        }
    }];
    
    
    NSMutableOrderedSet *sameBefore = [before mutableCopy];
    [sameBefore removeObjectsAtIndexes:diff.deleted];
    
    NSMutableOrderedSet *sameAfter = [after mutableCopy];
    [sameAfter removeObjectsAtIndexes:diff.inserted];
    
    
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
        if (self.objectUpdatedBlock(objectsBefore[beforeIndex], objectsAfter[afterIndex])) {
            changeType |= NNDiffChangeUpdate;
        }
        
        if (changeType != 0) {
            NNArrayDiffChange *change = [[NNArrayDiffChange alloc] initWithBefore:beforeIndex after:afterIndex type:changeType];
            [diff.changed addObject:change];
        }
    }];
    
    return [diff copy];
}

#pragma mark - Private

- (NSOrderedSet *)idsOfObjects:(NSArray *)array withBlock:(NNDiffObjectIdBlock)block
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:[array count]];
    for (id object in array) {
        [ids addObject:block(object)];
    }
    return [NSOrderedSet orderedSetWithArray:ids];
}

@end
