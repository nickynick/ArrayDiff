//
//  NNArrayDiffChange.h
//  ArrayDiff
//
//  Created by Nikolay Timchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, NNDiffChangeType) {
    NNDiffChangeUpdate = 1 << 0,
    NNDiffChangeMove   = 1 << 1
};


@interface NNArrayDiffChange : NSObject

@property (nonatomic, readonly) NSUInteger before;
@property (nonatomic, readonly) NSUInteger after;
@property (nonatomic, readonly) NNDiffChangeType type;

- (id)initWithBefore:(NSUInteger)before after:(NSUInteger)after type:(NNDiffChangeType)type;

@end
