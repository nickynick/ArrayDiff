//
//  NNTestItem.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNTestItem.h"

@implementation NNTestItem

- (id)initWithId:(NSUInteger)itemId {
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

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] itemWithId:self.itemId name:self.name];
}

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNTestItem class]]) return NO;
    return [self isEqualToTestItem:other];
}

- (BOOL)isEqualToTestItem:(NNTestItem *)other {
    if (self.itemId != other.itemId) return NO;
    if (self.name != other.name && ![self.name isEqualToString:other.name]) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + self.itemId;
    result = prime * result + [self.name hash];
    
    return result;
}

+ (NNDiffObjectIdBlock)idBlock {
    return ^(NNTestItem *item) {
        return @(item.itemId);
    };
}
+ (NNDiffObjectUpdatedBlock)updatedBlock {
    return ^(NNTestItem *itemBefore, NNTestItem *itemAfter) {
        return (BOOL) ![itemBefore isEqualToTestItem:itemAfter];
    };
}

@end
