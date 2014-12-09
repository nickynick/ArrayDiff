//
//  NNSectionsDiffCalculator.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffCalculator.h"

@class NNSectionsDiff;


@interface NNSectionsDiffCalculator : NNDiffCalculator

- (NNSectionsDiff *)calculateDiffForSectionsBefore:(NSArray *)sectionsBefore andAfter:(NSArray *)sectionsAfter;

- (NNSectionsDiff *)calculateDiffForSingleSectionObjectsBefore:(NSArray *)objectsBefore andAfter:(NSArray *)objectsAfter;

@end
