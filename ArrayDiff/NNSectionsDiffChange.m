//
//  NNSectionsDiffChange.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 14/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiffChange.h"

@implementation NNSectionsDiffChange

#pragma mark - Init

- (instancetype)init {
    return [self initWithBefore:nil after:nil type:0];
}

- (instancetype)initWithBefore:(NSIndexPath *)before after:(NSIndexPath *)after type:(NNDiffChangeType)type {
    NSParameterAssert(before != nil);
    NSParameterAssert(after != nil);
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
    if (!other || ![other isKindOfClass:[NNSectionsDiffChange class]]) return NO;
    return [self isEqualToSectionsDiffChange:other];
}

- (BOOL)isEqualToSectionsDiffChange:(NNSectionsDiffChange *)other {
    if (![self.before isEqual:other.before]) return NO;
    if (![self.after isEqual:other.after]) return NO;
    if (self.type != other.type) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.before hash];
    result = prime * result + [self.after hash];
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

    return [NSString stringWithFormat:@"%@.%@ %@ %@.%@",
            @([self.before indexAtPosition:0]), @([self.before indexAtPosition:1]),
            typeString,
            @([self.after indexAtPosition:0]), @([self.after indexAtPosition:1])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
