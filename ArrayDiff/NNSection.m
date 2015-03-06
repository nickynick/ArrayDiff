//
//  NNSection.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 21/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSection.h"

@implementation NNSection {
    @protected
    id _key;
    NSArray *_objects;
}

- (instancetype)init {
    return [self initWithKey:nil objects:nil];
}

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects {
    self = [super init];
    if (!self) return nil;
    
    _key = key;
    _objects = [objects copy] ?: @[];
    
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    return self.objects[idx];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNSection class]]) return NO;
    return [self isEqualToSectionData:other];
}

- (BOOL)isEqualToSectionData:(NNSection *)other {
    if (self.key != other.key && ![self.key isEqual:other.key]) return NO;
    if (![self.objects isEqual:other.objects]) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.key hash];
    result = prime * result + [self.objects hash];
    
    return result;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[NNSection allocWithZone:zone] initWithKey:self.key objects:self.objects];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[NNMutableSection allocWithZone:zone] initWithKey:self.key objects:self.objects];
}

@end


@implementation NNMutableSection

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects {
    self = [super initWithKey:key objects:objects];
    if (!self) return nil;
    
    _objects = [_objects mutableCopy];
    
    return self;
}

- (void)setKey:(id)key {
    _key = key;
}

@end