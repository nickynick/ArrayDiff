//
//  NNArrayDiffChange.m
//  ArrayDiff
//
//  Created by Nikolay Timchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffChange.h"

@implementation NNArrayDiffChange

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not available, use -initWithBefore:after:type: instead."
                                 userInfo:nil];
}

- (id)initWithBefore:(NSUInteger)before after:(NSUInteger)after type:(NNDiffChangeType)type {
    NSParameterAssert(type != 0);
    
    self = [super init];
    if (!self) return nil;
    
    _before = before;
    _after = after;
    _type = type;
    
    return self;
}

- (NSString *)description {
    NSString *typeString;
    if (self.type == NNDiffChangeUpdate) {
        typeString = @"·>";
    } else if (self.type == NNDiffChangeMove) {
        typeString = @"->";
    } else {
        typeString = @"=>";
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", @(self.before), typeString, @(self.after)];
}

@end
