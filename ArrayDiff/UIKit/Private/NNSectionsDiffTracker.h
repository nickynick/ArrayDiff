//
//  NNSectionsDiffTracker.h
//  ArrayDiff
//
//  Created by Nikolay Timchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSectionsDiff.h"

@interface NNSectionsDiffTracker : NSObject

@property (nonatomic, readonly) NNSectionsDiff *sectionsDiff;

- (id)initWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (NSUInteger)oldIndexForSection:(NSUInteger)section;

@end
