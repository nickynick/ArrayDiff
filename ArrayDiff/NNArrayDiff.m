//
//  NNArrayDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 02/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArrayDiff.h"
#import "NNArrayDiffChange.h"

@implementation NNArrayDiff {
    @protected
    NSIndexSet *_deleted;
    NSIndexSet *_inserted;
    NSSet *_changed;
}

#pragma mark - Init

- (instancetype)init {
    return [self initWithDeleted:nil inserted:nil changed:nil];
}

- (instancetype)initWithDeleted:(NSIndexSet *)deleted
                       inserted:(NSIndexSet *)inserted
                        changed:(NSSet *)changed
{
    self = [super init];
    if (!self) return nil;
    
    _deleted = [deleted copy] ?: [NSIndexSet indexSet];
    _inserted = [inserted copy] ?: [NSIndexSet indexSet];
    _changed = [changed copy] ?: [NSSet set];
    
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[NNArrayDiff allocWithZone:zone] initWithDeleted:self.deleted inserted:self.inserted changed:self.changed];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[NNMutableArrayDiff allocWithZone:zone] initWithDeleted:self.deleted inserted:self.inserted changed:self.changed];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNArrayDiff class]]) return NO;
    return [self isEqualToArrayDiff:other];
}

- (BOOL)isEqualToArrayDiff:(NNArrayDiff *)other {
    if (![self.deleted isEqualToIndexSet:other.deleted]) return NO;
    if (![self.inserted isEqualToIndexSet:other.inserted]) return NO;
    if (![self.changed isEqualToSet:other.changed]) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.deleted hash];
    result = prime * result + [self.inserted hash];
    result = prime * result + [self.changed hash];
    
    return result;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendString:@" {\n"];
    
    if ([self.deleted count] > 0) {
        [description appendFormat:@"  Deleted: %@\n", [self descriptionForIndexes:self.deleted]];
    }
    
    if ([self.inserted count] > 0) {
        [description appendFormat:@"  Inserted: %@\n", [self descriptionForIndexes:self.inserted]];
    }
    
    if ([self.changed count] > 0) {
        [description appendFormat:@"  Changed: %@\n", [self descriptionForChanged:self.changed]];
    }
    
    [description appendString:@"}"];
    return description;
}

- (NSString *)descriptionForIndexes:(NSIndexSet *)indexSet {
    NSMutableArray *strings = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [strings addObject:[NSString stringWithFormat:@"%@", @(idx)]];
    }];
    return [strings componentsJoinedByString:@", "];
}

- (NSString *)descriptionForChanged:(NSSet *)set {
    NSArray *sortedChanges = [[set allObjects] sortedArrayUsingComparator:^NSComparisonResult(NNArrayDiffChange *obj1, NNArrayDiffChange *obj2) {
        if (obj1.before != obj2.before) {
            return obj1.before < obj2.before ? NSOrderedAscending : NSOrderedDescending;
        }
        if (obj1.after != obj2.after) {
            return obj1.after < obj2.after ? NSOrderedAscending : NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    NSMutableArray *strings = [NSMutableArray array];
    for (NNArrayDiffChange *change in sortedChanges) {
        [strings addObject:[change description]];
    };
    return [strings componentsJoinedByString:@", "];
}

@end


@implementation NNMutableArrayDiff

- (instancetype)initWithDeleted:(NSIndexSet *)deleted inserted:(NSIndexSet *)inserted changed:(NSSet *)changed {
    self = [super initWithDeleted:deleted inserted:inserted changed:changed];
    if (!self) return nil;
    
    _deleted = [_deleted mutableCopy];
    _inserted = [_inserted mutableCopy];
    _changed = [_changed mutableCopy];
    
    return self;
}

@end