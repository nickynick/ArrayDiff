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
    NSMutableSet *deleted = [NSMutableSet set];
    NSMutableSet *inserted = [NSMutableSet set];
    NSMutableSet *moved = [NSMutableSet set];
    NSMutableSet *updated = [NSMutableSet set];
    
    
    NSArray *beforeSectionKeys = [before diffSectionKeys];
    NSArray *afterSectionKeys = [after diffSectionKeys];
    
    NNArrayDiff *sectionKeysDiff = [[NNArrayDiff alloc] initWithBefore:beforeSectionKeys after:afterSectionKeys idBlock:nil updatedBlock:nil];
    
    [deletedSections addIndexes:sectionKeysDiff.deleted];
    [insertedSections addIndexes:sectionKeysDiff.inserted];
    
    for (NNArrayDiffMove *move in sectionKeysDiff.moved) {
        [deletedSections addIndex:move.from];
        [insertedSections addIndex:move.to];
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
                id objectBefore = flatBefore[flatBeforeIndex];
                id objectAfter = flatAfter[flatAfterIndex];
                BOOL objectUpdated = updatedBlock(objectBefore, objectAfter);
                [moved addObject:[[NNSectionsDiffMove alloc] initWithFrom:indexPathBefore to:indexPathAfter updated:objectUpdated]];
                
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
    
    [flatDiff.updated enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [updated addObject:flatAfterIndexPaths[idx]];
    }];
    
    for (NNArrayDiffMove *move in flatDiff.moved) {
        NSIndexPath *from = flatBeforeIndexPaths[move.from];
        NSIndexPath *to = flatAfterIndexPaths[move.to];
        [moved addObject:[[NNSectionsDiffMove alloc] initWithFrom:from to:to updated:move.updated]];
    };
    

    _deletedSections = [deletedSections copy];
    _insertedSections = [insertedSections copy];
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _moved = [moved copy];
    _updated = [updated copy];
    
    [self sanitizeRowDiffs];
    
    return self;
}

- (id)initWithDeletedSections:(NSIndexSet *)deletedSections
             insertedSections:(NSIndexSet *)insertedSections
                      deleted:(NSSet *)deleted
                     inserted:(NSSet *)inserted
                        moved:(NSSet *)moved
                      updated:(NSSet *)updated
{
    self = [super init];
    if (!self) return nil;
    
    _deletedSections = [deletedSections copy] ?: [NSIndexSet indexSet];
    _insertedSections = [insertedSections copy] ?: [NSIndexSet indexSet];
    _deleted = [deleted copy] ?: [NSSet set];
    _inserted = [inserted copy] ?: [NSSet set];
    _moved = [moved copy] ?: [NSSet set];
    _updated = [updated copy] ?: [NSSet set];
    
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
    
    NSMutableSet *deleted = [NSMutableSet setWithCapacity:[self.deleted count]];
    for (NSIndexPath *indexPath in self.deleted) {
        [deleted addObject:[self offsetIndexPath:indexPath by:offset]];
    }
    
    NSMutableSet *inserted = [NSMutableSet setWithCapacity:[self.inserted count]];
    for (NSIndexPath *indexPath in self.inserted) {
        [deleted addObject:[self offsetIndexPath:indexPath by:offset]];
    }
    
    NSMutableSet *updated = [NSMutableSet setWithCapacity:[self.updated count]];
    for (NSIndexPath *indexPath in self.updated) {
        [deleted addObject:[self offsetIndexPath:indexPath by:offset]];
    }
    
    NSMutableSet *moved = [NSMutableSet setWithCapacity:[self.moved count]];
    for (NNSectionsDiffMove *move in self.moved) {
        [moved addObject:[[NNSectionsDiffMove alloc] initWithFrom:[self offsetIndexPath:move.from by:offset]
                                                               to:[self offsetIndexPath:move.to by:offset]
                                                          updated:move.updated]];
    }
    
    return [[NNSectionsDiff alloc] initWithDeletedSections:deletedSections
                                          insertedSections:insertedSections
                                                   deleted:deleted
                                                  inserted:inserted
                                                     moved:moved
                                                   updated:updated];
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
    NSMutableSet *deleted = [_deleted mutableCopy];
    NSMutableSet *inserted = [_inserted mutableCopy];
    NSMutableSet *moved = [_moved mutableCopy];
    
    for (NSIndexPath *indexPath in _deleted) {
        if ([_deletedSections containsIndex:[indexPath indexAtPosition:0]]) {
            [deleted removeObject:indexPath];
        }
    }
    for (NSIndexPath *indexPath in _inserted) {
        if ([_insertedSections containsIndex:[indexPath indexAtPosition:0]]) {
            [inserted removeObject:indexPath];
        }
    }
    
    for (NNSectionsDiffMove *move in _moved) {
        if ([_deletedSections containsIndex:[move.from indexAtPosition:0]]) {
            [inserted addObject:move.to];
            [moved removeObject:move];
        }
        if ([_insertedSections containsIndex:[move.to indexAtPosition:0]]) {
            [deleted addObject:move.from];
            [moved removeObject:move];
        }
    }
    
    _deleted = [deleted copy];
    _inserted = [inserted copy];
    _moved = [moved copy];
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
    
    if ([self.moved count] > 0) {
        [description appendFormat:@"  Moved: %@\n", [self descriptionForMoved:self.moved]];
    }
    
    if ([self.updated count] > 0) {
        [description appendFormat:@"  Updated: %@\n", [self descriptionForIndexPaths:self.updated]];
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

- (NSString *)descriptionForMoved:(NSSet *)set {
    NSArray *sortedMoves = [[set allObjects] sortedArrayUsingComparator:^NSComparisonResult(NNSectionsDiffMove *obj1, NNSectionsDiffMove *obj2) {
        if ([obj1.from compare:obj2.from] != NSOrderedSame) {
            return [obj1.from compare:obj2.from];
        } else {
            return [obj1.to compare:obj2.to];
        }
    }];

    NSMutableArray *strings = [NSMutableArray array];
    for (NNSectionsDiffMove *move in sortedMoves) {
        [strings addObject:[move description]];
    };
    return [strings componentsJoinedByString:@", "];
}

@end
