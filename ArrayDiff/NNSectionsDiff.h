//
//  NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNSectionsDiff : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy, readonly) NSIndexSet *deletedSections;
@property (nonatomic, copy, readonly) NSIndexSet *insertedSections;
@property (nonatomic, copy, readonly) NSSet *deleted;
@property (nonatomic, copy, readonly) NSSet *inserted;
@property (nonatomic, copy, readonly) NSSet *changed;

- (instancetype)initWithDeletedSections:(NSIndexSet *)deletedSections
                       insertedSections:(NSIndexSet *)insertedSections
                                deleted:(NSSet *)deleted
                               inserted:(NSSet *)inserted
                                changed:(NSSet *)changed;

@end


@interface NNMutableSectionsDiff : NNSectionsDiff

@property (nonatomic, copy, readonly) NSMutableIndexSet *deletedSections;
@property (nonatomic, copy, readonly) NSMutableIndexSet *insertedSections;
@property (nonatomic, copy, readonly) NSMutableSet *deleted;
@property (nonatomic, copy, readonly) NSMutableSet *inserted;
@property (nonatomic, copy, readonly) NSMutableSet *changed;

@end


@interface NNMutableSectionsDiff (Manipulation)

- (void)shiftBySectionDelta:(NSInteger)sectionDelta rowDelta:(NSInteger)rowDelta;

@end