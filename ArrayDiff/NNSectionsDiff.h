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
#import "NNSectionsDiffMove.h"

@interface NNSectionsDiff : NSObject

- (id)initWithBefore:(id<NNSectionsDiffDataSource>)before
               after:(id<NNSectionsDiffDataSource>)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (id)initWithDeletedSections:(NSIndexSet *)deletedSections
             insertedSections:(NSIndexSet *)insertedSections
                      deleted:(NSSet *)deleted
                     inserted:(NSSet *)inserted
                        moved:(NSSet *)moved
                      updated:(NSSet *)updated;

- (instancetype)diffByOffsetting:(NSUInteger)offset;

@property (nonatomic, readonly) NSIndexSet *deletedSections;
@property (nonatomic, readonly) NSIndexSet *insertedSections;

@property (nonatomic, readonly) NSSet *deleted;
@property (nonatomic, readonly) NSSet *inserted;
@property (nonatomic, readonly) NSSet *moved;
@property (nonatomic, readonly) NSSet *updated;

@end