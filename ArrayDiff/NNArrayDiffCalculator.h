//
//  NNArrayDiffCalculator.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffCalculator.h"

@class NNArrayDiff;


@interface NNArrayDiffCalculator : NNDiffCalculator

- (NNArrayDiff *)calculateDiffForObjectsBefore:(NSArray *)objectsBefore andAfter:(NSArray *)objectsAfter;

@end
