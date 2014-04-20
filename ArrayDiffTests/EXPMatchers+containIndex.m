//
//  EXPMatchers+containIndex.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "EXPMatchers+containIndex.h"

EXPMatcherImplementationBegin(containIndex, (NSUInteger expected))

BOOL actualIsCompatible = [actual isKindOfClass:[NSIndexSet class]];

prerequisite(^BOOL{
    return actualIsCompatible;
});

match(^BOOL{
    if (actualIsCompatible) {
        return ([(NSIndexSet *)actual containsIndex:expected]);
    }
    return NO;
});

failureMessageForTo(^NSString *{
    if (!actualIsCompatible) return [NSString stringWithFormat:@"%@ is not an instance of NSIndexSet", EXPDescribeObject(actual)];
    return [NSString stringWithFormat:@"expected %@ to contain index %@", EXPDescribeObject(actual), @(expected)];
});

failureMessageForNotTo(^NSString *{
    if (!actualIsCompatible) return [NSString stringWithFormat:@"%@ is not an instance of NSIndexSet", EXPDescribeObject(actual)];
    return [NSString stringWithFormat:@"expected %@ not to contain index %@", EXPDescribeObject(actual), @(expected)];
});

EXPMatcherImplementationEnd