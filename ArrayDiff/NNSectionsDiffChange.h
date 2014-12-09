//
//  NNSectionsDiffChange.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNDiffChangeType.h"

@interface NNSectionsDiffChange : NSObject <NSCopying>

@property (nonatomic, readonly) NSIndexPath *before;
@property (nonatomic, readonly) NSIndexPath *after;
@property (nonatomic, readonly) NNDiffChangeType type;

- (instancetype)initWithBefore:(NSIndexPath *)before after:(NSIndexPath *)after type:(NNDiffChangeType)type;

@end
