//
//  NNSectionsDiffCalculator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 07/12/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiffCalculator.h"
#import "NNSectionsDiff.h"
#import "NNSectionsDiffChange.h"
#import "NNSectionData.h"
#import "NNArrayDiff.h"
#import "NNArrayDiffChange.h"
#import "NNArrayDiffCalculator.h"

@implementation NNSectionsDiffCalculator

#pragma mark - Public

- (NNSectionsDiff *)calculateDiffForSectionsBefore:(NSArray *)sectionsBefore andAfter:(NSArray *)sectionsAfter {
    NNMutableSectionsDiff *diff = [[NNMutableSectionsDiff alloc] init];
    [self calculateSectionChangesForDiff:diff withSectionsBefore:sectionsBefore andAfter:sectionsAfter];
    [self calculateIndexPathChangesForDiff:diff withSectionsBefore:sectionsBefore andAfter:sectionsAfter];
    return [diff copy];
}

- (NNSectionsDiff *)calculateDiffForSingleSectionObjectsBefore:(NSArray *)objectsBefore andAfter:(NSArray *)objectsAfter {
    return [self calculateDiffForSectionsBefore:@[ [[NNSectionData alloc] initWithKey:[NSNull null] objects:objectsBefore] ]
                                       andAfter:@[ [[NNSectionData alloc] initWithKey:[NSNull null] objects:objectsAfter] ]];
}

#pragma mark - Private

- (void)calculateSectionChangesForDiff:(NNMutableSectionsDiff *)diff withSectionsBefore:(NSArray *)sectionsBefore andAfter:(NSArray *)sectionsAfter {
    NNArrayDiffCalculator *sectionsDiffCalculator = [[NNArrayDiffCalculator alloc] init];
    sectionsDiffCalculator.objectIdBlock = ^(NNSectionData *sectionData) {
        return sectionData.key;
    };
    sectionsDiffCalculator.objectUpdatedBlock = ^(id objectBefore, id objectAfter) {
        return NO;
    };
    
    NNArrayDiff *sectionsDiff = [sectionsDiffCalculator calculateDiffForObjectsBefore:sectionsBefore andAfter:sectionsAfter];
    
    [diff.deletedSections addIndexes:sectionsDiff.deleted];
    
    [diff.insertedSections addIndexes:sectionsDiff.inserted];
    
    // For now, let's just treat section moves as insert/delete pairs.
    for (NNArrayDiffChange *change in sectionsDiff.changed) {
        [diff.deletedSections addIndex:change.before];
        [diff.insertedSections addIndex:change.after];
    };
}

- (void)calculateIndexPathChangesForDiff:(NNMutableSectionsDiff *)diff withSectionsBefore:(NSArray *)sectionsBefore andAfter:(NSArray *)sectionsAfter {
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
            [flatBeforeIds addObject:self.objectIdBlock(object)];
        }
        NSMutableOrderedSet *flatAfterIds = [NSMutableOrderedSet orderedSetWithCapacity:[flatAfter count]];
        for (id object in flatAfter) {
            [flatAfterIds addObject:self.objectIdBlock(object)];
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
                if (self.objectUpdatedBlock(flatBefore[flatBeforeIndex], flatAfter[flatAfterIndex])) {
                    changeType |= NNDiffChangeUpdate;
                }
                
                [diff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:indexPathBefore after:indexPathAfter type:changeType]];
                
                [flatBeforeIndexesToRemove addIndex:flatBeforeIndex];
                [flatAfterIndexesToRemove addIndex:flatAfterIndex];
            }
        }];
        
        [flatBefore removeObjectsAtIndexes:flatBeforeIndexesToRemove];
        [flatBeforeIndexPaths removeObjectsAtIndexes:flatBeforeIndexesToRemove];
        [flatAfter removeObjectsAtIndexes:flatAfterIndexesToRemove];
        [flatAfterIndexPaths removeObjectsAtIndexes:flatAfterIndexesToRemove];
    }
    
    
    NNArrayDiffCalculator *flatDiffCalculator = [[NNArrayDiffCalculator alloc] init];
    flatDiffCalculator.objectIdBlock = self.objectIdBlock;
    flatDiffCalculator.objectUpdatedBlock = self.objectUpdatedBlock;
    
    NNArrayDiff *flatDiff = [flatDiffCalculator calculateDiffForObjectsBefore:flatBefore andAfter:flatAfter];
    
    [flatDiff.deleted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [diff.deleted addObject:flatBeforeIndexPaths[idx]];
    }];
    
    [flatDiff.inserted enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [diff.inserted addObject:flatAfterIndexPaths[idx]];
    }];
    
    for (NNArrayDiffChange *change in flatDiff.changed) {
        NSIndexPath *before = flatBeforeIndexPaths[change.before];
        NSIndexPath *after = flatAfterIndexPaths[change.after];
        [diff.changed addObject:[[NNSectionsDiffChange alloc] initWithBefore:before after:after type:change.type]];
    };
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

@end
