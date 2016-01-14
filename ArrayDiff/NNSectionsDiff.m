//
//  NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"
#import "NNSectionsDiffChange.h"

@implementation NNSectionsDiff {
    @protected
    NSIndexSet *_deletedSections;
    NSIndexSet *_insertedSections;
    NSSet *_deleted;
    NSSet *_inserted;
    NSSet *_changed;
}

#pragma mark - Init

- (instancetype)init {
    return [self initWithDeletedSections:nil insertedSections:nil deleted:nil inserted:nil changed:nil];
}

- (instancetype)initWithDeletedSections:(NSIndexSet *)deletedSections
                       insertedSections:(NSIndexSet *)insertedSections
                                deleted:(NSSet *)deleted
                               inserted:(NSSet *)inserted
                                changed:(NSSet *)changed
{
    self = [super init];
    if (!self) return nil;
    
    _deletedSections = [deletedSections copy] ?: [NSIndexSet indexSet];
    _insertedSections = [insertedSections copy] ?: [NSIndexSet indexSet];
    _deleted = [deleted copy] ?: [NSSet set];
    _inserted = [inserted copy] ?: [NSSet set];
    _changed = [changed copy] ?: [NSSet set];
    
    [self sanitizeDeletedAndInsertedSections];
    
    return self;
}

- (void)sanitizeDeletedAndInsertedSections {
    // If a section has been deleted, it makes no sense to have separate deletions for its rows.
    // The same thing about inserts.
    
    _deleted = [_deleted objectsPassingTest:^BOOL(NSIndexPath *obj, BOOL *stop) {
        return ![_deletedSections containsIndex:[obj indexAtPosition:0]];
    }];
    
    _inserted = [_inserted objectsPassingTest:^BOOL(NSIndexPath *obj, BOOL *stop) {
        return ![_insertedSections containsIndex:[obj indexAtPosition:0]];
    }];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[NNSectionsDiff allocWithZone:zone] initWithDeletedSections:self.deletedSections
                                                       insertedSections:self.insertedSections
                                                                deleted:self.deleted
                                                               inserted:self.inserted
                                                                changed:self.changed];
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[NNMutableSectionsDiff allocWithZone:zone] initWithDeletedSections:self.deletedSections
                                                              insertedSections:self.insertedSections
                                                                       deleted:self.deleted
                                                                      inserted:self.inserted
                                                                       changed:self.changed];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self) return YES;
    if (!other || ![other isKindOfClass:[NNSectionsDiff class]]) return NO;
    return [self isEqualToSectionsDiff:other];
}

- (BOOL)isEqualToSectionsDiff:(NNSectionsDiff *)other {
    if (![self.deletedSections isEqualToIndexSet:other.deletedSections]) return NO;
    if (![self.insertedSections isEqualToIndexSet:other.insertedSections]) return NO;
    if (![self.deleted isEqualToSet:other.deleted]) return NO;
    if (![self.inserted isEqualToSet:other.inserted]) return NO;
    if (![self.changed isEqualToSet:other.changed]) return NO;
    return YES;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.deletedSections hash];
    result = prime * result + [self.insertedSections hash];
    result = prime * result + [self.deleted hash];
    result = prime * result + [self.inserted hash];
    result = prime * result + [self.changed hash];
    
    return result;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithString:[super description]];
    [description appendString:@" {\n"];
    
    if ([self.deleted count] > 0) {
        [description appendFormat:@"  Deleted: %@\n", [self descriptionForIndexPaths:self.deleted]];
    }
    
    if ([self.deletedSections count] > 0) {
        [description appendFormat:@"  Deleted sections: %@\n", [self descriptionForSections:self.deletedSections]];
    }
    
    if ([self.insertedSections count] > 0) {
        [description appendFormat:@"  Inserted sections: %@\n", [self descriptionForSections:self.insertedSections]];
    }
    
    if ([self.inserted count] > 0) {
        [description appendFormat:@"  Inserted: %@\n", [self descriptionForIndexPaths:self.inserted]];
    }
    
    if ([self.changed count] > 0) {
        [description appendFormat:@"  Changed: %@\n", [self descriptionForChanged:self.changed]];
    }
    
    [description appendString:@"}"];
    return description;
}

- (NSString *)descriptionForSections:(NSIndexSet *)indexSet {
    NSMutableArray *strings = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [strings addObject:[NSString stringWithFormat:@"%@", @(idx)]];
    }];
    return [strings componentsJoinedByString:@", "];
}

- (NSString *)descriptionForIndexPaths:(NSSet *)set {
    NSArray *sortedIndexPaths = [set sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(compare:)] ]];
    
    NSMutableArray *strings = [NSMutableArray array];
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        [strings addObject:[NSString stringWithFormat:@"%@.%@",
                            @([indexPath indexAtPosition:0]),
                            @([indexPath indexAtPosition:1])]];
    };
    return [strings componentsJoinedByString:@", "];
}

- (NSString *)descriptionForChanged:(NSSet *)set {
    NSArray *sortedChanges = [[set allObjects] sortedArrayUsingComparator:^NSComparisonResult(NNSectionsDiffChange *obj1, NNSectionsDiffChange *obj2) {
        if ([obj1.before compare:obj2.before] != NSOrderedSame) {
            return [obj1.before compare:obj2.before];
        } else {
            return [obj1.after compare:obj2.after];
        }
    }];

    NSMutableArray *strings = [NSMutableArray array];
    for (NNSectionsDiffChange *change in sortedChanges) {
        [strings addObject:[change description]];
    };
    return [strings componentsJoinedByString:@", "];
}

@end


@implementation NNMutableSectionsDiff

- (instancetype)initWithDeletedSections:(NSIndexSet *)deletedSections
                       insertedSections:(NSIndexSet *)insertedSections
                                deleted:(NSSet *)deleted
                               inserted:(NSSet *)inserted
                                changed:(NSSet *)changed
{
    self = [super initWithDeletedSections:deletedSections insertedSections:insertedSections deleted:deleted inserted:inserted changed:changed];
    if (!self) return nil;
    
    _deletedSections = [_deletedSections mutableCopy];
    _insertedSections = [_insertedSections mutableCopy];
    _deleted = [_deleted mutableCopy];
    _inserted = [_inserted mutableCopy];
    _changed = [_changed mutableCopy];
    
    return self;
}

@dynamic deletedSections;
@dynamic insertedSections;
@dynamic deleted;
@dynamic inserted;
@dynamic changed;

@end


@implementation NNMutableSectionsDiff (Manipulation)

- (void)shiftBySectionDelta:(NSInteger)sectionDelta rowDelta:(NSInteger)rowDelta;
{
    [self.deletedSections shiftIndexesStartingAtIndex:0 by:sectionDelta];
    [self.insertedSections shiftIndexesStartingAtIndex:0 by:sectionDelta];
    
    NSMutableSet *deleted = [NSMutableSet setWithCapacity:[self.deleted count]];
    for (NSIndexPath *indexPath in self.deleted) {
        [deleted addObject:[self shiftIndexPath:indexPath bySectionDelta:sectionDelta rowDelta:rowDelta]];
    }
    _deleted = deleted;
    
    NSMutableSet *inserted = [NSMutableSet setWithCapacity:[self.inserted count]];
    for (NSIndexPath *indexPath in self.inserted) {
        [inserted addObject:[self shiftIndexPath:indexPath bySectionDelta:sectionDelta rowDelta:rowDelta]];
    }
    _inserted = inserted;
    
    NSMutableSet *changed = [NSMutableSet setWithCapacity:[self.changed count]];
    for (NNSectionsDiffChange *change in self.changed) {
        NSIndexPath *before = [self shiftIndexPath:change.before bySectionDelta:sectionDelta rowDelta:rowDelta];
        NSIndexPath *after = [self shiftIndexPath:change.after bySectionDelta:sectionDelta rowDelta:rowDelta];
        [changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:before after:after type:change.type]];
    }
    _changed = changed;
}

- (NSIndexPath *)shiftIndexPath:(NSIndexPath *)indexPath bySectionDelta:(NSInteger)sectionDelta rowDelta:(NSInteger)rowDelta
{
    NSUInteger indexes[] = {
        [indexPath indexAtPosition:0] + sectionDelta,
        [indexPath indexAtPosition:1] + rowDelta
    };
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

@end