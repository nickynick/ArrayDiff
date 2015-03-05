//
//  NNSectionsDiffSpec.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 05/03/15.
//  Copyright (c) 2015 Nick Tymchenko. All rights reserved.
//

#import <XCTest/XCTest.h>

SpecBegin(NNSectionsDiff)

describe(@"-initWithDeletedSections:insertedSections:deleted:inserted:changed:", ^{
    it(@"should initialize diff object with given values", ^{
        NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:[NSIndexSet indexSetWithIndex:1]
                                                              insertedSections:[NSIndexSet indexSetWithIndex:2]
                                                                       deleted:[NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]
                                                                      inserted:[NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]
                                                                       changed:[NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                                                           after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                                                            type:NNDiffChangeMove]]];
        
        expect(diff.deletedSections).to.equal([NSIndexSet indexSetWithIndex:1]);
        expect(diff.insertedSections).to.equal([NSIndexSet indexSetWithIndex:2]);
        expect(diff.deleted).to.equal([NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]);
        expect(diff.inserted).to.equal([NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]);
        expect(diff.changed).to.equal([NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                  after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                   type:NNDiffChangeMove]]);
    });
    
    it(@"should handle nil arguments properly", ^{
        NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:nil insertedSections:nil deleted:nil inserted:nil changed:nil];
        
        expect(diff.deletedSections).to.equal([NSIndexSet indexSet]);
        expect(diff.insertedSections).to.equal([NSIndexSet indexSet]);
        expect(diff.deleted).to.equal([NSSet set]);
        expect(diff.inserted).to.equal([NSSet set]);
        expect(diff.changed).to.equal([NSSet set]);
    });
});

describe(@"-isEqual:", ^{
    it(@"should return YES for equal diffs", ^{
        NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:[NSIndexSet indexSetWithIndex:1]
                                                              insertedSections:[NSIndexSet indexSetWithIndex:2]
                                                                       deleted:[NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]
                                                                      inserted:[NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]
                                                                       changed:[NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                                                           after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                                                            type:NNDiffChangeMove]]];
        
        NNSectionsDiff *anotherDiff = [[NNSectionsDiff alloc] initWithDeletedSections:[NSIndexSet indexSetWithIndex:1]
                                                                     insertedSections:[NSIndexSet indexSetWithIndex:2]
                                                                              deleted:[NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]
                                                                             inserted:[NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]
                                                                              changed:[NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                                                                  after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                                                                   type:NNDiffChangeMove]]];
        
        expect([diff isEqual:anotherDiff]).to.beTruthy();
    });
    
    it(@"should return NO for different diffs", ^{
        NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithDeletedSections:[NSIndexSet indexSetWithIndex:1]
                                                              insertedSections:[NSIndexSet indexSetWithIndex:2]
                                                                       deleted:[NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]
                                                                      inserted:[NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]
                                                                       changed:[NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                                                           after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                                                            type:NNDiffChangeMove]]];
        
        NNSectionsDiff *anotherDiff = [[NNSectionsDiff alloc] initWithDeletedSections:[NSIndexSet indexSetWithIndex:1]
                                                                     insertedSections:[NSIndexSet indexSetWithIndex:2]
                                                                              deleted:[NSSet setWithObject:[NSIndexPath indexPathForRow:0 inSection:3]]
                                                                             inserted:[NSSet setWithObject:[NSIndexPath indexPathForRow:1 inSection:4]]
                                                                              changed:[NSSet setWithObject:[[NNSectionsDiffChange alloc] initWithBefore:[NSIndexPath indexPathForRow:0 inSection:5]
                                                                                                                                                  after:[NSIndexPath indexPathForRow:1 inSection:5]
                                                                                                                                                   type:NNDiffChangeUpdate]]];
        
        expect([diff isEqual:anotherDiff]).to.beFalsy();
    });
});

SpecEnd