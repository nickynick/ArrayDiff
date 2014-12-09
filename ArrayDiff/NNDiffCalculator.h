//
//  NNDiffCalculator.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^NNDiffObjectIdBlock)(id object);
typedef BOOL (^NNDiffObjectUpdatedBlock)(id objectBefore, id objectAfter);


@interface NNDiffCalculator : NSObject

@property (nonatomic, copy) NNDiffObjectIdBlock objectIdBlock;
@property (nonatomic, copy) NNDiffObjectUpdatedBlock objectUpdatedBlock;

@end
