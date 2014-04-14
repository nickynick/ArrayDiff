//
//  NNSectionsDiffChange.m
//  ArrayDiff
//
//  Created by Nikolay Timchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiffChange.h"

@implementation NNSectionsDiffChange

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not available, use -initWithBefore:after:type: instead."
                                 userInfo:nil];
}

- (id)initWithBefore:(NSIndexPath *)before after:(NSIndexPath *)after type:(NNDiffChangeType)type {
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

    return [[super description] stringByAppendingFormat:@" %@-%@ %@ %@-%@",
            @([self.before indexAtPosition:0]), @([self.before indexAtPosition:1]),
            typeString,
            @([self.after indexAtPosition:0]), @([self.after indexAtPosition:1])];
}

@end
