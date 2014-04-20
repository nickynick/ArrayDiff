//
//  NNArrayDiffValidator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffValidator.h"
#import "NNTestItem.h"
#import "EXPMatchers+containIndex.h"

@implementation NNArrayDiffValidator

+ (void)validateDiff:(NNArrayDiff *)diff betweenArray:(NSArray *)before andArray:(NSArray *)after {
    NSMutableIndexSet *deleted = [[NSMutableIndexSet alloc] initWithIndexSet:diff.deleted];
    NSMutableIndexSet *inserted = [[NSMutableIndexSet alloc] initWithIndexSet:diff.inserted];
    
    [before enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self indexOfObject:obj inArray:after] == NSNotFound) {
            expect(diff.deleted).to.containIndex(idx);
        }
    }];
    
    [after enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([self indexOfObject:obj inArray:before] == NSNotFound) {
            expect(diff.inserted).to.containIndex(idx);
        }
    }];
    
    for (NNArrayDiffChange *change in diff.changed) {
        if (change.type & NNDiffChangeMove) {
            [deleted addIndex:change.before];
            [inserted addIndex:change.after];
        }
        
        id objectBefore = [before objectAtIndex:change.before];
        id objectAfter = [after objectAtIndex:change.after];
        
        expect(change.after).to.equal([self indexOfObject:objectBefore inArray:after]);
        
        if (change.type & NNDiffChangeUpdate) {
            expect(objectBefore).notTo.equal(objectAfter);
        } else {
            expect(objectBefore).to.equal(objectAfter);
        }
    }

    NSMutableArray *sameBefore = [before mutableCopy];
    [sameBefore removeObjectsAtIndexes:deleted];
    
    NSMutableArray *sameAfter = [after mutableCopy];
    [sameAfter removeObjectsAtIndexes:inserted];

    expect([sameBefore count]).to.equal([sameAfter count]);
    
    [sameBefore enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        expect(idx).to.equal([self indexOfObject:obj inArray:sameAfter]);
        expect(obj).to.equal(sameAfter[idx]);
    }];
}

#pragma mark - Private

+ (NSUInteger)indexOfObject:(id)object inArray:(NSArray *)array {
    if ([object isKindOfClass:[NNTestItem class]]) {
        __block NSUInteger index = NSNotFound;
        [array enumerateObjectsUsingBlock:^(NNTestItem *item, NSUInteger idx, BOOL *stop) {
            if (item.itemId == ((NNTestItem *)object).itemId) {
                index = idx;
                *stop = YES;
            }
        }];
        return index;
    } else {
        return [array indexOfObject:object];
    }
}

@end
