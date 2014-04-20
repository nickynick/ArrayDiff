//
//  NNArraySections.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNArraySections.h"

@implementation NNArraySections

#pragma mark - Init

- (id)initWithSectionKeys:(NSArray *)sectionKeys sections:(NSArray *)sections {
    self = [super init];
    if (!self) return nil;
    
    _sectionKeys = [sectionKeys copy];
    _sections = [sections copy];
    
    return self;
}

- (id)initWithSnapshotOfDataSource:(id<NNSectionsDiffDataSource>)dataSource {
    self = [super init];
    if (!self) return nil;
    
    _sectionKeys = [[dataSource sectionKeys] copy];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[_sectionKeys count]];
    for (NSUInteger i = 0; i < [_sectionKeys count]; ++i) {
        [sections addObject:[[dataSource objectsForSection:i] copy]];
    }
    _sections = [sections copy];
    
    return self;
}

#pragma mark - NNSectionsDiffDataSource

- (NSArray *)objectsForSection:(NSUInteger)section {
    return self.sections[section];
}

@end
