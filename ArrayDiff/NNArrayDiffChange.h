//
//  NNArrayDiffChange.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNDiffChangeType.h"

@interface NNArrayDiffChange : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger before;
@property (nonatomic, readonly) NSUInteger after;
@property (nonatomic, readonly) NNDiffChangeType type;

- (instancetype)initWithBefore:(NSUInteger)before after:(NSUInteger)after type:(NNDiffChangeType)type;

@end
