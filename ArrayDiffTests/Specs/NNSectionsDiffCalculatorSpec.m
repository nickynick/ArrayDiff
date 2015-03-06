//
//  NNSectionsDiffCalculatorSpec.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 05/03/15.
//  Copyright (c) 2015 Nick Tymchenko. All rights reserved.
//

#import <XCTest/XCTest.h>

SpecBegin(NNSectionsDiffCalculator)

describe(@"diff calculation", ^{
    __block NNSectionsDiffCalculator *calculator;
    
    __block NSArray *before;
    __block NSArray *after;
    __block NNMutableSectionsDiff *expectedDiff;
    
    beforeEach(^{
        calculator = [[NNSectionsDiffCalculator alloc] init];
        
        before = nil;
        after = nil;
        expectedDiff = [[NNMutableSectionsDiff alloc] init];
    });
    
    describe(@"for single sections", ^{
        afterEach(^{
            NNSectionsDiff *calculatedDiff = [calculator calculateDiffForSingleSectionObjectsBefore:before andAfter:after];
            expect(calculatedDiff).to.equal(expectedDiff);
        });
        
        it(@"should return empty diff for empty arrays", ^{
            before = @[];
            after  = nil;
        });
        
        it(@"should return diff between empty and non-empty arrays", ^{
            before = @[];
            after  = @[ @"0", @"1", @"2" ];
            
            [expectedDiff.inserted addObjectsFromArray:@[ [NSIndexPath indexPathForRow:0 inSection:0],
                                                          [NSIndexPath indexPathForRow:1 inSection:0],
                                                          [NSIndexPath indexPathForRow:2 inSection:0] ]];
        });
        
        it(@"should return diff between non-empty and empty arrays", ^{
            before = @[ @"0", @"1", @"2" ];
            after  = @[];
            
            [expectedDiff.deleted addObjectsFromArray:@[ [NSIndexPath indexPathForRow:0 inSection:0],
                                                         [NSIndexPath indexPathForRow:1 inSection:0],
                                                         [NSIndexPath indexPathForRow:2 inSection:0] ]];
        });
        
        it(@"should handle multiple moves, deletions and insertions", ^{
            before = @[ @"0", @"foo", @"1", @"2", @"3", @"dead",                                 @"4", @"5", @"bar", @"6", @"beef", @"7" ];
            after  = @[ @"0",         @"1", @"2", @"3",          @"baz", @"foo", @"bar", @"qux", @"4", @"5",         @"6",          @"7" ];
            
            [expectedDiff.deleted addObject:[NSIndexPath indexPathForRow:5 inSection:0]];
            [expectedDiff.deleted addObject:[NSIndexPath indexPathForRow:10 inSection:0]];
            
            [expectedDiff.inserted addObject:[NSIndexPath indexPathForRow:4 inSection:0]];
            [expectedDiff.inserted addObject:[NSIndexPath indexPathForRow:7 inSection:0]];
            
            [expectedDiff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:1 inSection:0]
                                                                                   after:[NSIndexPath indexPathForRow:5 inSection:0]
                                                                                    type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:8 inSection:0]
                                                                                   after:[NSIndexPath indexPathForRow:6 inSection:0]
                                                                                    type:NNDiffChangeMove]];
        });
    });
    
    describe(@"for section arrays", ^{
        afterEach(^{
            NNSectionsDiff *calculatedDiff = [calculator calculateDiffForSectionsBefore:before andAfter:after];
            expect(calculatedDiff).to.equal(expectedDiff);
        });
        
        it(@"should return an empty diff when objects are not updated", ^{
            before = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2" ]],
                        [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1" ]] ];
            after = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2" ]],
                       [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1" ]] ];
        });
        
        it(@"should spot deleted and inserted objects", ^{
            before = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2" ]],
                        [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1" ]] ];
            after = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A2" ]],
                       [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1", @"B2" ]] ];
            
            [expectedDiff.deleted addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            [expectedDiff.inserted addObject:[NSIndexPath indexPathForRow:1 inSection:1]];
        });
        
        it(@"should spot moved objects", ^{
            before = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2", @"A3" ]],
                        [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1", @"B2" ]] ];
            after = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A3", @"A1", @"A2", @"B1" ]],
                       [[NNSection alloc] initWithKey:@"B" objects:@[ @"B2" ]] ];
            
            [expectedDiff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:2 inSection:0]
                                                                                   after:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                                    type:NNDiffChangeMove]];
            [expectedDiff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                                   after:[NSIndexPath indexPathForRow:3 inSection:0]
                                                                                    type:NNDiffChangeMove]];
        });
        
        it(@"should spot deleted and inserted sections", ^{
            before = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2" ]],
                        [[NNSection alloc] initWithKey:@"B" objects:@[ @"B1", @"B2" ]],
                        [[NNSection alloc] initWithKey:@"C" objects:@[ @"C1", @"C2" ]] ];
            after = @[ [[NNSection alloc] initWithKey:@"A" objects:@[ @"A1", @"A2", @"B1" ]],
                       [[NNSection alloc] initWithKey:@"C" objects:@[ @"C1", @"C2" ]],
                       [[NNSection alloc] initWithKey:@"D" objects:@[ @"D1", @"D2", @"D3", @"D4" ]] ];
            
            [expectedDiff.deletedSections addIndex:1];
            [expectedDiff.insertedSections addIndex:2];
            [expectedDiff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                                   after:[NSIndexPath indexPathForRow:2 inSection:0]
                                                                                    type:NNDiffChangeMove]];
        });
    });
});

SpecEnd