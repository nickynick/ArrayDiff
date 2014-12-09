//
//  NNSectionsDiffTracker.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiffTracker.h"

@interface NNSectionsDiffTracker ()

@property (nonatomic, strong) NSArray *oldSectionIndexes;

@end


@implementation NNSectionsDiffTracker

#pragma mark - Init

- (instancetype)init {
    return [self initWithSectionsDiff:nil];
}

- (instancetype)initWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    NSParameterAssert(sectionsDiff != nil);
    
    self = [super init];
    if (!self) return nil;
    
    _sectionsDiff = sectionsDiff;
    
    return self;
}

#pragma mark - Public

- (NSUInteger)oldIndexForSection:(NSUInteger)section {
    if (!self.oldSectionIndexes) {
        self.oldSectionIndexes = [self calculateOldSectionIndexesForDiff:self.sectionsDiff];
    }
    
    if (section < [self.oldSectionIndexes count]) {
        return [self.oldSectionIndexes[section] unsignedIntegerValue];
    } else {
        return [[self.oldSectionIndexes lastObject] unsignedIntegerValue] + section + 1 - [self.oldSectionIndexes count];
    }
}

#pragma mark - Private

- (NSArray *)calculateOldSectionIndexesForDiff:(NNSectionsDiff *)diff {
    NSUInteger lastDeleted = [diff.deletedSections count] > 0 ? [diff.deletedSections lastIndex] + 1 : 0;
    NSUInteger lastInserted = [diff.insertedSections count] > 0 ? [diff.insertedSections lastIndex] + 1 : 0;
    
    NSMutableArray *indexesAfterDeleting = [NSMutableArray arrayWithCapacity:lastDeleted + 1];
    for (NSUInteger i = 0; i <= lastDeleted; ++i) {
        [indexesAfterDeleting addObject:@(i)];
    }
    [indexesAfterDeleting removeObjectsAtIndexes:diff.deletedSections];
    
    NSMutableArray *oldSectionIndexes = [NSMutableArray array];
    NSUInteger d = 0, i = 0;
    NSUInteger current = [indexesAfterDeleting[d] unsignedIntegerValue];
    
    while (d < [indexesAfterDeleting count] || i <= lastInserted) {
        if ([diff.insertedSections containsIndex:i]) {
            [oldSectionIndexes addObject:@(NSNotFound)];
        } else {
            [oldSectionIndexes addObject:@(current)];
            
            ++d;
            if (d < [indexesAfterDeleting count]) {
                current = [indexesAfterDeleting[d] unsignedIntegerValue];
            } else {
                ++current;
            }
        }
        ++i;
    }
    
    return [oldSectionIndexes copy];
}

@end
