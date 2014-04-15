//
//  NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNArrayDiff.h"
#import "NNSectionsDiffDataSource.h"
#import "NNSectionsDiffChange.h"

@interface NNSectionsDiff : NSObject

@property (nonatomic, readonly) NSIndexSet *deletedSections;
@property (nonatomic, readonly) NSIndexSet *insertedSections;
@property (nonatomic, readonly) NSArray *deleted;
@property (nonatomic, readonly) NSArray *inserted;
@property (nonatomic, readonly) NSArray *changed;

- (id)initWithBefore:(id<NNSectionsDiffDataSource>)before
               after:(id<NNSectionsDiffDataSource>)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (id)initWithDeletedSections:(NSIndexSet *)deletedSections
             insertedSections:(NSIndexSet *)insertedSections
                      deleted:(NSArray *)deleted
                     inserted:(NSArray *)inserted
                      changed:(NSArray *)changed;

- (instancetype)diffByOffsetting:(NSUInteger)offset;


- (NSUInteger)previousIndexForSection:(NSUInteger)section;

@end