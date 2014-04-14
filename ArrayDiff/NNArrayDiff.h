//
//  NNArrayDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 02/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNArrayDiffChange.h"

typedef id (^NNDiffObjectIdBlock)(id object);
typedef BOOL (^NNDiffObjectUpdatedBlock)(id objectBefore, id objectAfter);


@interface NNArrayDiff : NSObject

@property (nonatomic, readonly) NSIndexSet *deleted;
@property (nonatomic, readonly) NSIndexSet *inserted;
@property (nonatomic, readonly) NSArray *changed;

- (id)initWithBefore:(NSArray *)before
               after:(NSArray *)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (id)initWithDeleted:(NSIndexSet *)deleted
             inserted:(NSIndexSet *)inserted
              changed:(NSArray *)changed;

@end