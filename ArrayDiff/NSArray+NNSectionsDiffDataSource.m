//
//  NSArray+NNSectionsDiffDataSource.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NSArray+NNSectionsDiffDataSource.h"

@implementation NSArray (NNSectionsDiffDataSource)

- (NSArray *)diffSectionKeys {
    return @[ [NSNull null] ];
}

- (NSArray *)diffObjectsForSection:(NSUInteger)section {
    return self;
}

@end
