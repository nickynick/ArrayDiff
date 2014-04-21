//
//  NNSectionData.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 21/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionData.h"

@implementation NNSectionData {
    @protected
    id _key;
    NSArray *_objects;
}

- (id)init {
    return [self initWithKey:nil objects:nil];
}

- (id)initWithKey:(id)key objects:(NSArray *)objects {
    self = [super init];
    if (!self) return nil;
    
    _key = key;
    _objects = [objects copy] ?: @[];
    
    return self;
}

- (id)key {
    return _key;
}

- (NSArray *)objects {
    return _objects;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNSectionData class]]) return NO;
    return [self isEqualToSectionData:other];
}

- (BOOL)isEqualToSectionData:(NNSectionData *)other {
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
    return [[NNSectionData allocWithZone:zone] initWithKey:self.key objects:self.objects];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[NNMutableSectionData allocWithZone:zone] initWithKey:self.key objects:self.objects];
}

@end


@implementation NNMutableSectionData

- (id)initWithKey:(id)key objects:(NSArray *)objects {
    self = [super initWithKey:key objects:objects];
    if (!self) return nil;
    
    _objects = [_objects mutableCopy];
    
    return self;
}

- (void)setKey:(id)key {
    _key = key;
}

@end