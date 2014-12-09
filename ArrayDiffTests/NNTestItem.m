//
//  NNTestItem.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNTestItem.h"

@implementation NNTestItem

- (instancetype)initWithId:(NSUInteger)itemId {
    self = [super init];
    if (!self) return nil;
    
    _itemId = itemId;
    
    return self;
}

+ (instancetype)itemWithId:(NSUInteger)itemId name:(NSString *)name {
    NNTestItem *item = [[NNTestItem alloc] initWithId:itemId];
    item.name = name;
    return item;
}

@end
