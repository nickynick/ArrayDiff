//
//  NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNArrayDiff.h"
#import "NNSectionsDiffChange.h"
#import "NNSectionData.h"

@interface NNSectionsDiff : NSObject

@property (nonatomic, readonly) NSIndexSet *deletedSections;
@property (nonatomic, readonly) NSIndexSet *insertedSections;
@property (nonatomic, readonly) NSArray *deleted;
@property (nonatomic, readonly) NSArray *inserted;
@property (nonatomic, readonly) NSArray *changed;

- (id)initWithSectionsBefore:(NSArray *)sectionsBefore
               sectionsAfter:(NSArray *)sectionsAfter
                     idBlock:(NNDiffObjectIdBlock)idBlock
                updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (id)initWithObjectsBefore:(NSArray *)objectsBefore
               objectsAfter:(NSArray *)objectsAfter
                    idBlock:(NNDiffObjectIdBlock)idBlock
               updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (instancetype)diffByOffsetting:(NSUInteger)offset;

@end


@interface NNSectionsDiff (Handmade)

- (id)initWithDeletedSections:(NSIndexSet *)deletedSections
             insertedSections:(NSIndexSet *)insertedSections
                      deleted:(NSArray *)deleted
                     inserted:(NSArray *)inserted
                      changed:(NSArray *)changed;

@end