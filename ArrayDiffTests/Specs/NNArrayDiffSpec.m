//
//  NNArrayDiffSpec.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <XCTest/XCTest.h>

SpecBegin(NNArrayDiff)

describe(@"-initWithDeleted:inserted:changed:", ^{
    it(@"should initialize diff object with given values", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                        inserted:[NSIndexSet indexSetWithIndex:2]
                                                         changed:[NSSet setWithObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove]]];
        
        expect(diff.deleted).to.equal([NSIndexSet indexSetWithIndex:1]);
        expect(diff.inserted).to.equal([NSIndexSet indexSetWithIndex:2]);
        expect(diff.changed).to.equal([NSSet setWithObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove]]);
    });
    
    it(@"should handle nil arguments properly", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:nil inserted:nil changed:nil];
        
        expect(diff.deleted).to.equal([NSIndexSet indexSet]);
        expect(diff.inserted).to.equal([NSIndexSet indexSet]);
        expect(diff.changed).to.equal([NSSet set]);
    });
});

describe(@"-isEqual:", ^{
    it(@"should return YES for equal diffs", ^{
        NNArrayDiff *diff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                        inserted:[NSIndexSet indexSetWithIndex:2]
                                                         changed:[NSSet setWithObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove]]];
        
        NNArrayDiff *anotherDiff = [[NNArrayDiff alloc] initWithDeleted:[NSIndexSet indexSetWithIndex:1]
                                                               inserted:[NSIndexSet indexSetWithIndex:2]
                                                                changed:[NSSet setWithObject:[[NNArrayDiffChange alloc] initWithBefore:3 after:4 type:NNDiffChangeMove]]];
        
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

SpecEnd