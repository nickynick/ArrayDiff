//
//  NNArrayDiffSpec.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NNTestItem.h"
#import "NNArrayDiffValidator.h"

SpecBegin(NNArrayDiff)

describe(@"-initWithDeleted:inserted:changed:", ^{
    it(@"should initialize diff object with given values", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                        inserted:[NSIndexSet indexSetWithIndex:2]
                                                         changed:@[ [[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove] ]];
        
        expect(diff.deleted).to.equal([NSIndexSet indexSetWithIndex:1]);
        expect(diff.inserted).to.equal([NSIndexSet indexSetWithIndex:2]);
        expect(diff.changed).to.equal(@[ [[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove] ]);
    });
    
    it(@"should handle nil arguments properly", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:nil inserted:nil changed:nil];
        
        expect(diff.deleted).to.equal([NSIndexSet indexSet]);
        expect(diff.inserted).to.equal([NSIndexSet indexSet]);
        expect(diff.changed).to.equal([NSArray array]);
    });
});

describe(@"-isEqual:", ^{
    it(@"should return YES for equal diffs", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                        inserted:[NSIndexSet indexSetWithIndex:2]
                                                         changed:@[ [[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove] ]];
        
        NNArrayDiff *anotherDiff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                               inserted:[NSIndexSet indexSetWithIndex:2]
                                                                changed:@[ [[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove] ]];
        
        expect([diff isEqual:anotherDiff]).to.beTruthy();
    });
    
    it(@"should return NO for different diffs", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                        inserted:nil
                                                         changed:nil];
        
        NNArrayDiff *anotherDiff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:42]
                                                               inserted:nil
                                                                changed:nil];
        
        expect([diff isEqual:anotherDiff]).to.beFalsy();
    });
});

describe(@"diff calculation", ^{
    it(@"should return empty diff for empty arrays", ^{
        NNArrayDiff *calculatedDiff = [[NNArrayDiff alloc] initWithBefore:@[]
                                                                    after:nil
                                                                  idBlock:nil updatedBlock:nil];
        
        NNArrayDiff *expectedDiff = [[NNArrayDiff alloc] init];
        
        expect(calculatedDiff).to.equal(expectedDiff);
    });
    
    it(@"should return diff between empty and non-empty arrays", ^{
        NNArrayDiff *calculatedDiff = [[NNArrayDiff alloc] initWithBefore:nil
                                                                    after:@[ @"1", @"2", @"3" ]
                                                                  idBlock:nil updatedBlock:nil];
        
        NNArrayDiff *expectedDiff = [[NNArrayDiff alloc] initWithDeleted:nil
                                                                inserted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
                                                                 changed:nil];
        
        expect(calculatedDiff).to.equal(expectedDiff);
    });
    
    it(@"should return diff between non-empty and empty arrays", ^{
        NNArrayDiff *calculatedDiff = [[NNArrayDiff alloc] initWithBefore:@[ @"1", @"2", @"3" ]
                                                                    after:nil
                                                                  idBlock:nil updatedBlock:nil];
        
        NNArrayDiff *expectedDiff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]
                                                                inserted:nil
                                                                 changed:nil];
        
        expect(calculatedDiff).to.equal(expectedDiff);
    });
    
    it(@"should return diff between arrays of strings", ^{
        NSArray *before = @[ @"1", @"2", @"3", @"4", @"5" ];
        NSArray *after = @[ @"2", @"cat", @"dog", @"5", @"rat", @"4", @"bat" ];
        
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithBefore:before after:after idBlock:nil updatedBlock:nil];
        
        [NNArrayDiffValidator validateDiff:diff betweenArray:before andArray:after];
    });
});

SpecEnd