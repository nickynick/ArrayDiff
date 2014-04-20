//
//  NSArray+NNSectionsDiffDataSource.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NSArray+NNSectionsDiffDataSource.h"

@implementation NSArray (NNSectionsDiffDataSource)

- (NSArray *)sectionKeys {
    return @[ [NSNull null] ];
}

- (NSArray *)objectsForSection:(NSUInteger)section {
    return self;
}

@end
