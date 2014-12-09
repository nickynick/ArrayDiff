//
//  NNDiffChangeType.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

typedef NS_OPTIONS(NSInteger, NNDiffChangeType) {
    NNDiffChangeUpdate = 1 << 0,
    NNDiffChangeMove   = 1 << 1
};