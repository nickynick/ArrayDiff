//
//  NNArrayDiff+DefaultBlocks.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 28/05/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiff.h"

@interface NNArrayDiff (DefaultBlocks)

+ (NNDiffObjectIdBlock)defaultIdBlock;

+ (NNDiffObjectUpdatedBlock)defaultUpdatedBlock;

@end
