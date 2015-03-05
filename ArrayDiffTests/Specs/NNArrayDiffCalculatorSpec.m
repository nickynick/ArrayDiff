//
//  NNArrayDiffCalculatorSpec.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 05/03/15.
//  Copyright (c) 2015 Nick Tymchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NNTestItem.h"

SpecBegin(NNArrayDiffCalculator)

describe(@"diff calculation", ^{
    __block NNArrayDiffCalculator *calculator;
    
    __block NSArray *before;
    __block NSArray *after;
    __block NNMutableArrayDiff *expectedDiff;
    
    beforeEach(^{
        before = nil;
        after = nil;
        expectedDiff = [[NNMutableArrayDiff alloc] init];
    });
    
    afterEach(^{
        NNArrayDiff *calculatedDiff = [calculator calculateDiffForObjectsBefore:before andAfter:after];
        expect(calculatedDiff).to.equal(expectedDiff);
    });
    
    describe(@"for objects without id", ^{
        beforeAll(^{
            calculator = [[NNArrayDiffCalculator alloc] init];
        });
        
        it(@"should return empty diff for empty arrays", ^{
            before = @[];
            after  = nil;
        });
        
        it(@"should return diff between empty and non-empty arrays", ^{
            before = @[];
            after  = @[ @"0", @"1", @"2" ];
            
            [expectedDiff.inserted addIndexesInRange:NSMakeRange(0, 3)];
        });
        
        it(@"should return diff between non-empty and empty arrays", ^{
            before = @[ @"0", @"1", @"2" ];
            after  = @[];
            
            [expectedDiff.deleted addIndexesInRange:NSMakeRange(0, 3)];
        });
        
        it(@"should handle multiple insertions", ^{
            before = @[         @"0", @"1",         @"2", @"3", @"4", @"5" ];
            after  = @[ @"foo", @"0", @"1", @"bar", @"2", @"3", @"4", @"5", @"baz" ];
            
            [expectedDiff.inserted addIndex:0];
            [expectedDiff.inserted addIndex:3];
            [expectedDiff.inserted addIndex:8];
        });
        
        it(@"should handle multiple deletions", ^{
            before = @[ @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9" ];
            after  = @[       @"1", @"2", @"3", @"4",             @"7", @"8" ];
            
            [expectedDiff.deleted addIndex:0];
            [expectedDiff.deleted addIndex:5];
            [expectedDiff.deleted addIndex:6];
            [expectedDiff.deleted addIndex:9];
        });
        
        it(@"should handle deletion and insertion at the same index", ^{
            before = @[ @"0", @"1", @"2", @"3", @"4",   @"5" ];
            after  = @[ @"0", @"1", @"2", @"3", @"foo", @"5" ];
            
            [expectedDiff.deleted addIndex:4];
            [expectedDiff.inserted addIndex:4];
        });
        
        it(@"should handle multiple deletions and insertions", ^{
            before = @[ @"0", @"1",         @"2", @"3",         @"4", @"5", @"6", @"7",         @"8", @"9" ];
            after  = @[       @"1", @"foo", @"2", @"3", @"bar", @"4",             @"7", @"baz", @"8" ];
            
            [expectedDiff.deleted addIndex:0];
            [expectedDiff.deleted addIndex:5];
            [expectedDiff.deleted addIndex:6];
            [expectedDiff.deleted addIndex:9];
            
            [expectedDiff.inserted addIndex:1];
            [expectedDiff.inserted addIndex:4];
            [expectedDiff.inserted addIndex:7];
        });
        
        it(@"should handle a moved object", ^{
            before = @[ @"0", @"foo", @"1", @"2",         @"3" ];
            after  = @[ @"0",         @"1", @"2", @"foo", @"3" ];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:1 after:3 type:NNDiffChangeMove]];
        });
        
        it(@"should handle a moved object in an optimal way", ^{
            before = @[         @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"foo" ];
            after  = @[ @"foo", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" ];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:9 after:0 type:NNDiffChangeMove]];
        });
        
        it(@"should handle multiple moves", ^{
            before = @[ @"0",         @"1", @"foo", @"bar", @"2", @"3", @"4",                 @"5", @"6", @"7", @"baz", @"8", @"9" ];
            after  = @[ @"0", @"baz", @"1",                 @"2", @"3", @"4", @"foo", @"bar", @"5", @"6", @"7",         @"8", @"9" ];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:2 after:6 type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:7 type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:10 after:1 type:NNDiffChangeMove]];
        });
        
        it(@"should handle multiple moves and deletions", ^{
            before = @[         @"0", @"1", @"foo", @"bar", @"2", @"3", @"4", @"5", @"baz", @"6", @"7", @"qux" ];
            after  = @[ @"foo", @"0", @"1",                 @"2", @"3", @"4", @"5",         @"6", @"7",        @"bar" ];
            
            [expectedDiff.deleted addIndex:8];
            [expectedDiff.deleted addIndex:11];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:2 after:0 type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:9 type:NNDiffChangeMove]];
        });
        
        it(@"should handle multiple moves and insertions", ^{
            before = @[ @"0", @"foo", @"1", @"2", @"3",                                 @"4", @"5", @"6", @"7", @"bar" ];
            after  = @[ @"0",         @"1", @"2", @"3", @"baz", @"foo", @"bar", @"qux", @"4", @"5", @"6", @"7" ];
            
            [expectedDiff.inserted addIndex:4];
            [expectedDiff.inserted addIndex:7];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:1 after:5 type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:9 after:6 type:NNDiffChangeMove]];
        });
        
        it(@"should handle multiple moves, deletions and insertions", ^{
            before = @[ @"0", @"foo", @"1", @"2", @"3", @"dead",                                 @"4", @"5", @"bar", @"6", @"beef", @"7" ];
            after  = @[ @"0",         @"1", @"2", @"3",          @"baz", @"foo", @"bar", @"qux", @"4", @"5",         @"6",          @"7" ];
            
            [expectedDiff.deleted addIndex:5];
            [expectedDiff.deleted addIndex:10];
            
            [expectedDiff.inserted addIndex:4];
            [expectedDiff.inserted addIndex:7];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:1 after:5 type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:8 after:6 type:NNDiffChangeMove]];
        });
    });
    
    describe(@"for objects with id", ^{
        NNTestItem * (^item)(NSInteger, NSString *) = ^(NSInteger itemId, NSString *name) {
            return [NNTestItem itemWithId:itemId name:name];
        };
        
        beforeAll(^{
            calculator = [[NNArrayDiffCalculator alloc] init];
            calculator.objectIdBlock = ^(NNTestItem *item) {
                return @(item.itemId);
            };
            calculator.objectUpdatedBlock = ^BOOL (NNTestItem *itemBefore, NNTestItem *itemAfter) {
                expect(itemBefore.itemId).to.equal(itemAfter.itemId);
                
                NSString *nameBefore = itemBefore.name ?: @"";
                NSString *nameAfter = itemAfter.name ?: @"";
                
                return [nameBefore compare:nameAfter options:NSCaseInsensitiveSearch] != NSOrderedSame;
            };
        });
        
        it(@"should return an empty diff when objects are not updated", ^{
            before = @[ item(42, @"foo") ];
            after  = @[ item(42, @"FOO") ];
        });
        
        it(@"should spot an updated object", ^{
            before = @[ item(42, @"foo") ];
            after  = @[ item(42, @"bar") ];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:0 after:0 type:NNDiffChangeUpdate]];
        });
        
        it(@"should spot a moved & updated object", ^{
            before = @[ item(42, @"foo"), item(0, @"0"), item(1, @"1") ];
            after  = @[                   item(0, @"0"), item(1, @"1"), item(42, @"bar") ];
            
            [expectedDiff.changed addObject:[[NNArrayDiffChange alloc] initWithBefore:0 after:2 type:NNDiffChangeUpdate | NNDiffChangeMove]];
        });
    });
});

SpecEnd