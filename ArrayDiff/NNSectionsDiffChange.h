//
//  NNSectionsDiffChange.h
//  ArrayDiff
//
//  Created by Nikolay Timchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNArrayDiffChange.h"

@interface NNSectionsDiffChange : NSObject

@property (nonatomic, readonly) NSIndexPath *before;
@property (nonatomic, readonly) NSIndexPath *after;
@property (nonatomic, readonly) NNDiffChangeType type;

- (id)initWithBefore:(NSIndexPath *)before after:(NSIndexPath *)after type:(NNDiffChangeType)type;

@end
