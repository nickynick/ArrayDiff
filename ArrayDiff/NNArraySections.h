//
//  NNArraySections.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSectionsDiffDataSource.h"

@interface NNArraySections : NSObject <NNSectionsDiffDataSource>

- (id)initWithSectionKeys:(NSArray *)sectionKeys sections:(NSArray *)sections;

- (id)initWithSnapshotOfDataSource:(id<NNSectionsDiffDataSource>)dataSource;

@property (nonatomic, copy) NSArray *sectionKeys;
@property (nonatomic, copy) NSArray *sections; // array of arrays

@end
