//
//  NNArrayDiffMove.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiffMove.h"

@implementation NNArrayDiffMove

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"-init is not available, use -initWithFrom:to:updated: instead."
                                 userInfo:nil];
}

- (id)initWithFrom:(NSUInteger)from to:(NSUInteger)to updated:(BOOL)updated {
    self = [super init];
    if (!self) return nil;
    
    _from = from;
    _to = to;
    _updated = updated;
    
    return self;
}

- (NSString *)description {
    return [[super description] stringByAppendingFormat:@" %@ %@ %@",
            @(self.from),
            (self.updated ? @"=>" : @"->"),
            @(self.to)];
}

@end
