//
//  NNArrayDiffChange.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffChange.h"

@implementation NNArrayDiffChange

#pragma mark - Init

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not available, use -initWithBefore:after:type: instead."
                                 userInfo:nil];
}

- (id)initWithBefore:(NSUInteger)before after:(NSUInteger)after type:(NNDiffChangeType)type {
    NSParameterAssert(before != NSNotFound);
    NSParameterAssert(after != NSNotFound);
    NSParameterAssert(type != 0);
    
    self = [super init];
    if (!self) return nil;
    
    _before = before;
    _after = after;
    _type = type;
    
    return self;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNArrayDiffChange class]]) return NO;
    return [self isEqualToArrayDiffChange:other];
}

- (BOOL)isEqualToArrayDiffChange:(NNArrayDiffChange *)other {
    if (self.before != other.before) return NO;
    if (self.after != other.after) return NO;
    if (self.type != other.type) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + self.before;
    result = prime * result + self.after;
    result = prime * result + self.type;
    
    return result;
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

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
