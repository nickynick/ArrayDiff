//
//  NNDiffCalculator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffCalculator.h"

@implementation NNDiffCalculator

- (NNDiffObjectIdBlock)objectIdBlock {
    if (!_objectIdBlock) {
        _objectIdBlock = [^(id object) {
            return object;
        } copy];
    }
    return _objectIdBlock;
}

- (NNDiffObjectUpdatedBlock)objectUpdatedBlock {
    if (!_objectUpdatedBlock) {
        _objectUpdatedBlock = [^(id objectBefore, id objectAfter) {
            return ![objectBefore isEqual:objectAfter];
        } copy];
    }
    return _objectUpdatedBlock;
}

@end
