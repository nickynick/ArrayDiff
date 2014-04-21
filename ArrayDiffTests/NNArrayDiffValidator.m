//
//  NNArrayDiffValidator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffValidator.h"
#import "NNTestItem.h"

@implementation NNArrayDiffValidator

+ (void)validateDiff:(NNArrayDiff *)diff betweenArray:(NSArray *)before andArray:(NSArray *)after {
    NSMutableIndexSet *deleted = [[NSMutableIndexSet alloc] initWithIndexSet:diff.deleted];
    NSMutableIndexSet *inserted = [[NSMutableIndexSet alloc] initWithIndexSet:diff.inserted];
    for (NNArrayDiffChange *change in diff.changed) {
        if (change.type & NNDiffChangeMove) {
            [deleted addIndex:change.before];
            [inserted addIndex:change.after];
        }
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:before];
    expect(array).to.equal(before);
    [array removeObjectsAtIndexes:deleted];
    [array insertObjects:[after objectsAtIndexes:inserted] atIndexes:inserted];
    expect(array).to.equal(after);
    
    
    [before enumerateObjectsUsingBlock:^(id objectBefore, NSUInteger indexBefore, BOOL *stop) {
        NSUInteger indexAfter = [self indexOfObject:objectBefore inArray:after];
        if (indexAfter == NSNotFound) return;
        id objectAfter = after[indexAfter];
        
        NSUInteger changeIndex = [diff.changed indexOfObjectPassingTest:^BOOL(NNArrayDiffChange *change, NSUInteger idx, BOOL *stop) {
            return (change.before == indexBefore && change.after == indexAfter);
        }];
        NNArrayDiffChange *change = (changeIndex != NSNotFound) ? diff.changed[changeIndex] : nil;
        
        BOOL objectUpdated = NO;
        if ([objectBefore isKindOfClass:[NNTestItem class]]) {
            objectUpdated = [(NNTestItem *)objectBefore testItemUpdated:objectAfter];
        }
        
        if (change && (change.type & NNDiffChangeUpdate)) {
            expect(objectUpdated).to.beTruthy();
        } else {
            expect(objectUpdated).to.beFalsy();
        }
    }];
}

#pragma mark - Private

+ (NSUInteger)indexOfObject:(id)object inArray:(NSArray *)array {
    return [array indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([object isKindOfClass:[NNTestItem class]]) {
            return (((NNTestItem *)obj).itemId == ((NNTestItem *)object).itemId);
        } else {
            return [obj isEqual:object];
        }
    }];
}

@end
