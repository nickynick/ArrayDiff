//
//  NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"

@implementation NNSectionsDiff

#pragma mark - Init

- (id)initWithBefore:(id<NNSectionsDiffDataSource>)before
               after:(id<NNSectionsDiffDataSource>)after
             idBlock:(NNDiffObjectIdBlock)idBlock
        updatedBlock:(NNDiffObjectUpdatedBlock)updatedBlock
{
    self = [super init];
    if (!self) return nil;
    
    // TODO: don't copy defaults from NNArrayDiff, do something smart
    idBlock = idBlock ?: ^(id object) {
        return object;
    };
    updatedBlock = updatedBlock ?: ^BOOL (id objectBefore, id objectAfter) {
        return ![objectBefore isEqual:objectAfter];
    };
    
    
    // TODO: docs!
    
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *insertedSections = [NSMutableIndexSet indexSet];
    NSMutableArray *deleted = [NSMutableArray array];
    NSMutableArray *inserted = [NSMutableArray array];
    NSMutableArray *changed = [NSMutableArray array];
    
    
    NSArray *beforeSectionKeys = [before diffSectionKeys];
    NSArray *afterSectionKeys = [after diffSectionKeys];
    
    NNArrayDiff *sectionKeysDiff = [[NNArrayDiff alloc] initWithBefore:beforeSectionKeys after:afterSectionKeys idBlock:nil updatedBlock:nil];
    
    [deletedSections addIndexes:sectionKeysDiff.deleted];
    [insertedSections addIndexes:sectionKeysDiff.inserted];
    
    for (NNArrayDiffChange *change in sectionKeysDiff.changed) {
        [deletedSections addIndex:change.before];
        [insertedSections addIndex:change.after];
    };
    
    
    NSMutableArray *flatBefore = [self flattenDataSource:before];
    NSMutableArray *flatAfter = [self flattenDataSource:after];
    NSMutableArray *flatBeforeIndexPaths = [self flatIndexPathsForDataSource:before];
    NSMutableArray *flatAfterIndexPaths = [self flatIndexPathsForDataSource:after];
    
    if ([beforeSectionKeys count] > 1 || [afterSectionKeys count] > 1) {
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
            
            id sectionKeyBefore = beforeSectionKeys[[indexPathBefore indexAtPosition:0]];
            id sectionKeyAfter = afterSectionKeys[[indexPathAfter indexAtPosition:0]];
            
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
    

    _deletedSections = [deletedSections copy];
    _insertedSections = [insertedSections copy];
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _changed = [changed copy];
    
    [self sanitizeRowDiffs];
    
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
    
    [self sanitizeRowDiffs];
    
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

- (NSMutableArray *)flattenDataSource:(id<NNSectionsDiffDataSource>)dataSource {
    NSMutableArray *objects = [NSMutableArray array];
    
    NSUInteger sectionsCount = [[dataSource diffSectionKeys] count];
    for (NSUInteger i = 0; i < sectionsCount; ++i) {
        [objects addObjectsFromArray:[dataSource diffObjectsForSection:i]];
    }
    
    return objects;
}

- (NSMutableArray *)flatIndexPathsForDataSource:(id<NNSectionsDiffDataSource>)dataSource {
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSUInteger sectionsCount = [[dataSource diffSectionKeys] count];
    for (NSUInteger section = 0; section < sectionsCount; ++section) {
        NSUInteger objectsCount = [[dataSource diffObjectsForSection:section] count];
        for (NSUInteger row = 0; row < objectsCount; ++row) {
            NSUInteger indexes[] = { section, row };
            [indexPaths addObject:[NSIndexPath indexPathWithIndexes:indexes length:2]];
        }
    }
    
    return indexPaths;
}

- (NSIndexPath *)offsetIndexPath:(NSIndexPath *)indexPath by:(NSUInteger)offset {
    NSUInteger indexes[] = { [indexPath indexAtPosition:0] + offset, [indexPath indexAtPosition:1] };
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (void)sanitizeRowDiffs {
    NSMutableArray *additionalDeleted = [NSMutableArray array];
    NSMutableArray *additionalInserted = [NSMutableArray array];
    
    _changed = [_changed objectsAtIndexes:[_changed indexesOfObjectsPassingTest:^BOOL(NNSectionsDiffChange *obj, NSUInteger idx, BOOL *stop) {
        if ((obj.type & NNDiffChangeMove) == 0) return YES;
        
        if ([_deletedSections containsIndex:[obj.before indexAtPosition:0]]) {
            [additionalInserted addObject:obj.after];
            return NO;
        }
        
        if ([_insertedSections containsIndex:[obj.after indexAtPosition:0]]) {
            [additionalDeleted addObject:obj.before];
            return NO;
        }
        
        return YES;
	}]];
    
    if ([additionalDeleted count] > 0) {
        _deleted = [_deleted arrayByAddingObjectsFromArray:additionalDeleted];
    }
    
    if ([additionalInserted count] > 0) {
        _inserted = [_inserted arrayByAddingObjectsFromArray:additionalInserted];
    }
    
    _deleted = [_deleted objectsAtIndexes:[_deleted indexesOfObjectsPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		return ![_deletedSections containsIndex:[obj indexAtPosition:0]];
	}]];
    
    _inserted = [_inserted objectsAtIndexes:[_inserted indexesOfObjectsPassingTest:^BOOL(NSIndexPath *obj, NSUInteger idx, BOOL *stop) {
		return ![_insertedSections containsIndex:[obj indexAtPosition:0]];
	}]];
}

#pragma mark - Description

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
