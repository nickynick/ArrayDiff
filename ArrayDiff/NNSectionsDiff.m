//
//  NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"
#import "NNArrayDiff+DefaultBlocks.h"

@implementation NNSectionsDiff

#pragma mark - Init

- (id)init {
    return [self initWithDeletedSections:nil insertedSections:nil deleted:nil inserted:nil changed:nil];
}

- (id)initWithObjectsBefore:(NSArray *)objectsBefore
               objectsAfter:(NSArray *)objectsAfter
                    idBlock:(NNDiffObjectIdBlock)idBlock
               updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    return [self initWithSectionsBefore:@[ [[NNSectionData alloc] initWithKey:[NSNull null] objects:objectsBefore] ]
                          sectionsAfter:@[ [[NNSectionData alloc] initWithKey:[NSNull null] objects:objectsAfter] ]
                                idBlock:idBlock
                           updatedBlock:updatedBlock];
}

- (id)initWithSectionsBefore:(NSArray *)sectionsBefore
               sectionsAfter:(NSArray *)sectionsAfter
                     idBlock:(NNDiffObjectIdBlock)idBlock
                updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    self = [super init];
    if (!self) return nil;
    
    idBlock = idBlock ?: [NNArrayDiff defaultIdBlock];
    updatedBlock = updatedBlock ?: [NNArrayDiff defaultUpdatedBlock];
    
    [self calculateSectionChangesFromSections:sectionsBefore toSections:sectionsAfter];
    [self calculateChangesFromSections:sectionsBefore toSections:sectionsAfter idBlock:idBlock updatedBlock:updatedBlock];
    
    return self;
}

- (id)initWithDeletedSections:(NSIndexSet *)deletedSections
             insertedSections:(NSIndexSet *)insertedSections
                      deleted:(NSArray *)deleted
                     inserted:(NSArray *)inserted
                      changed:(NSArray *)changed
{
    self = [super init];
    if (!self) return nil;
    
    _deletedSections = [deletedSections copy] ?: [NSIndexSet indexSet];
    _insertedSections = [insertedSections copy] ?: [NSIndexSet indexSet];
    _deleted = [deleted copy] ?: @[];
    _inserted = [inserted copy] ?: @[];
    _changed = [changed copy] ?: @[];
    
    [self sanitizeDeletedAndInsertedSections];
    
    return self;
}

#pragma mark - Public

- (instancetype)diffByOffsetting:(NSUInteger)offset {
    if (offset == 0) {
        return self;
    }
    
    NSMutableIndexSet *deletedSections = [self.deletedSections mutableCopy];
    [deletedSections shiftIndexesStartingAtIndex:0 by:offset];
    
    NSMutableIndexSet *insertedSections = [self.insertedSections mutableCopy];
    [insertedSections shiftIndexesStartingAtIndex:0 by:offset];
    
    NSMutableArray *deleted = [NSMutableArray arrayWithCapacity:[self.deleted count]];
    for (NSIndexPath *indexPath in self.deleted) {
        [deleted addObject:[self offsetIndexPath:indexPath by:offset]];
    }
    
    NSMutableArray *inserted = [NSMutableArray arrayWithCapacity:[self.inserted count]];
    for (NSIndexPath *indexPath in self.inserted) {
        [inserted addObject:[self offsetIndexPath:indexPath by:offset]];
    }
    
    NSMutableArray *changed = [NSMutableArray arrayWithCapacity:[self.changed count]];
    for (NNSectionsDiffChange *change in self.changed) {
        [changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:[self offsetIndexPath:change.before by:offset]
                                                                  after:[self offsetIndexPath:change.after by:offset]
                                                                   type:change.type]];
    }
    
    return [[NNSectionsDiff alloc] initWithDeletedSections:deletedSections
                                          insertedSections:insertedSections
                                                   deleted:deleted
                                                  inserted:inserted
                                                   changed:changed];
}

#pragma mark - Private

- (void)calculateSectionChangesFromSections:(NSArray *)sectionsBefore toSections:(NSArray *)sectionsAfter {
    // We use section keys to identify sections, so we can calculate a diff.
    NSArray *sectionKeysBefore = [sectionsBefore valueForKey:@"key"];
    NSArray *sectionKeysAfter = [sectionsAfter valueForKey:@"key"];
    
    NNArrayDiff *sectionKeysDiff = [[NNArrayDiff alloc] initWithBefore:sectionKeysBefore
                                                                 after:sectionKeysAfter
                                                               idBlock:nil updatedBlock:nil];
    
    NSMutableIndexSet *deletedSections = [sectionKeysDiff.deleted mutableCopy];
    NSMutableIndexSet *insertedSections = [sectionKeysDiff.inserted mutableCopy];
    
    // For now, let's just treat section moves as insert/delete pairs.
    for (NNArrayDiffChange *change in sectionKeysDiff.changed) {
        [deletedSections addIndex:change.before];
        [insertedSections addIndex:change.after];
    };
    
    _deletedSections = [deletedSections copy];
    _insertedSections = [insertedSections copy];
}

- (void)calculateChangesFromSections:(NSArray *)sectionsBefore
                          toSections:(NSArray *)sectionsAfter
                             idBlock:(NNDiffObjectIdBlock)idBlock
                        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    NSMutableArray *deleted = [NSMutableArray array];
    NSMutableArray *inserted = [NSMutableArray array];
    NSMutableArray *changed = [NSMutableArray array];
    
    NSMutableArray *flatBefore = [self flattenSections:sectionsBefore];
    NSMutableArray *flatAfter = [self flattenSections:sectionsAfter];
    NSMutableArray *flatBeforeIndexPaths = [self flatIndexPathsForSections:sectionsBefore];
    NSMutableArray *flatAfterIndexPaths = [self flatIndexPathsForSections:sectionsAfter];
    
    if ([sectionsBefore count] > 1 || [sectionsAfter count] > 1) {
        // Here we need find all objects whose section key has changed.
        // Given this fact for an object, we know for sure that this object has moved.
        
        // We have to do this preprocessing because a pure diff between flat arrays may not return such changes as moves.
        
        NSMutableOrderedSet *flatBeforeIds = [NSMutableOrderedSet orderedSetWithCapacity:[flatBefore count]];
        for (id object in flatBefore) {
            [flatBeforeIds addObject:idBlock(object)];
        }
        NSMutableOrderedSet *flatAfterIds = [NSMutableOrderedSet orderedSetWithCapacity:[flatAfter count]];
        for (id object in flatAfter) {
            [flatAfterIds addObject:idBlock(object)];
        }
        
        NSMutableIndexSet *flatBeforeIndexesToRemove = [NSMutableIndexSet indexSet];
        NSMutableIndexSet *flatAfterIndexesToRemove = [NSMutableIndexSet indexSet];
        
        [flatBeforeIds enumerateObjectsUsingBlock:^(id obj, NSUInteger flatBeforeIndex, BOOL *stop) {
            NSUInteger flatAfterIndex = [flatAfterIds indexOfObject:obj];
            if (flatAfterIndex == NSNotFound) return;
            
            NSIndexPath *indexPathBefore = flatBeforeIndexPaths[flatBeforeIndex];
            NSIndexPath *indexPathAfter = flatAfterIndexPaths[flatAfterIndex];
            
            id sectionKeyBefore = ((NNSectionData *)sectionsBefore[[indexPathBefore indexAtPosition:0]]).key;
            id sectionKeyAfter = ((NNSectionData *)sectionsAfter[[indexPathAfter indexAtPosition:0]]).key;
            
            if (![sectionKeyBefore isEqual:sectionKeyAfter]) {
                NNDiffChangeType changeType = NNDiffChangeMove;
                if (updatedBlock(flatBefore[flatBeforeIndex], flatAfter[flatAfterIndex])) {
                    changeType |= NNDiffChangeUpdate;
                }
                
                [changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:indexPathBefore after:indexPathAfter type:changeType]];
                
                [flatBeforeIndexesToRemove addIndex:flatBeforeIndex];
                [flatAfterIndexesToRemove addIndex:flatAfterIndex];
            }
        }];
        
        [flatBefore removeObjectsAtIndexes:flatBeforeIndexesToRemove];
        [flatBeforeIndexPaths removeObjectsAtIndexes:flatBeforeIndexesToRemove];
        [flatAfter removeObjectsAtIndexes:flatAfterIndexesToRemove];
        [flatAfterIndexPaths removeObjectsAtIndexes:flatAfterIndexesToRemove];
    }
    
    
    NNArrayDiff *flatDiff = [[NNArrayDiff alloc] initWithBefore:flatBefore after:flatAfter idBlock:idBlock updatedBlock:updatedBlock];
    
    [flatDiff.deleted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [deleted addObject:flatBeforeIndexPaths[idx]];
    }];
    
    [flatDiff.inserted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [inserted addObject:flatAfterIndexPaths[idx]];
    }];
    
    for (NNArrayDiffChange *change in flatDiff.changed) {
        NSIndexPath *before = flatBeforeIndexPaths[change.before];
        NSIndexPath *after = flatAfterIndexPaths[change.after];
        [changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:before after:after type:change.type]];
    };
    
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _changed = [changed copy];
    
    [self sanitizeDeletedAndInsertedSections];
}

- (NSMutableArray *)flattenSections:(NSArray *)sections {
    NSMutableArray *objects = [NSMutableArray array];
    for (NNSectionData *section in sections) {
        [objects addObjectsFromArray:section.objects];
    }
    return objects;
}

- (NSMutableArray *)flatIndexPathsForSections:(NSArray *)sections {
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    [sections enumerateObjectsUsingBlock:^(NNSectionData *section, NSUInteger idx, BOOL *stop) {
        for (NSUInteger row = 0; row < [section.objects count]; ++row) {
            NSUInteger indexes[] = { idx, row };
            [indexPaths addObject:[NSIndexPath indexPathWithIndexes:indexes length:2]];
        }
    }];
    
    return indexPaths;
}

- (NSIndexPath *)offsetIndexPath:(NSIndexPath *)indexPath by:(NSUInteger)offset {
    NSUInteger indexes[] = { [indexPath indexAtPosition:0] + offset, [indexPath indexAtPosition:1] };
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (void)sanitizeDeletedAndInsertedSections {
    // If a section has been deleted, it makes no sense to have separate deletions for its rows.
    // The same thing about inserts.
    
    _deleted = [_deleted objectsAtIndexes:[_deleted indexesOfObjectsPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		return ![_deletedSections containsIndex:[obj indexAtPosition:0]];
	}]];
    
    _inserted = [_inserted objectsAtIndexes:[_inserted indexesOfObjectsPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		return ![_insertedSections containsIndex:[obj indexAtPosition:0]];
	}]];
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
    if (![self.deleted isEqualToArray:other.deleted]) return NO;
    if (![self.inserted isEqualToArray:other.inserted]) return NO;
    if (![self.changed isEqualToArray:other.changed]) return NO;
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

- (NSString *)descriptionForIndexPaths:(NSArray *)array {
    NSArray *sortedIndexPaths = [array sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(compare:)] ]];
    
    NSMutableArray *strings = [NSMutableArray array];
    for (NSIndexPath *indexPath in sortedIndexPaths) {
        [strings addObject:[NSString stringWithFormat:@"%@.%@",
                            @([indexPath indexAtPosition:0]),
                            @([indexPath indexAtPosition:1])]];
    };
    return [strings componentsJoinedByString:@", "];
}

- (NSString *)descriptionForChanged:(NSArray *)array {
    NSArray *sortedChanges = [array sortedArrayUsingComparator:^NSComparisonResult(NNSectionsDiffChange *obj1, NNSectionsDiffChange *obj2) {
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
