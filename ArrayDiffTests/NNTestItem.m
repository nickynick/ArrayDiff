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
    return (self.itemId == other.itemId);
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + self.itemId;
    
    return result;
}

- (BOOL)testItemUpdated:(NNTestItem *)other {
    expect(self.itemId).to.equal(other.itemId);
    return (self.name != other.name && ![self.name isEqualToString:other.name]);
}

+ (NNDiffObjectIdBlock)idBlock {
    return ^(NNTestItem *item) {
        return @(item.itemId);
    };
}
+ (NNDiffObjectUpdatedBlock)updatedBlock {
    return ^(NNTestItem *itemBefore, NNTestItem *itemAfter) {
        return [itemBefore testItemUpdated:itemAfter];
    };
}

@end
