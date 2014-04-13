//
//  NNArrayDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 02/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNArrayDiffMove.h"

typedef id (^NNDiffObjectIdBlock)(id object);
typedef BOOL (^NNDiffObjectUpdatedBlock)(id objectBefore, id objectAfter);


@interface NNArrayDiff : NSObject

- (id)initWithBefore:(NSArray *)before
               after:(NSArray *)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock;

- (id)initWithDeleted:(NSIndexSet *)deleted
             inserted:(NSIndexSet *)inserted
                moved:(NSSet *)moved
              updated:(NSIndexSet *)updated;

@property (nonatomic, readonly) NSIndexSet *deleted;
@property (nonatomic, readonly) NSIndexSet *inserted;
@property (nonatomic, readonly) NSSet *moved;
@property (nonatomic, readonly) NSIndexSet *updated;

@end