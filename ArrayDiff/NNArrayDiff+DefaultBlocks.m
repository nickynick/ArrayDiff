//
//  NNArrayDiff+DefaultBlocks.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 28/05/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiff+DefaultBlocks.h"

@implementation NNArrayDiff (DefaultBlocks)

+ (NNDiffObjectIdBlock)defaultIdBlock {
    static id sharedBlock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlock = [^(id object) {
            return object;
        } copy];
    });
    
    return sharedBlock;
}

+ (NNDiffObjectUpdatedBlock)defaultUpdatedBlock {
    static id sharedBlock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBlock = [^(id objectBefore, id objectAfter) {
            return ![objectBefore isEqual:objectAfter];
        } copy];
    });
    
    return sharedBlock;
}

@end
