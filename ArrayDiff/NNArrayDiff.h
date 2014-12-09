//
//  NNArrayDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 02/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNArrayDiff : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, copy, readonly) NSIndexSet *deleted;
@property (nonatomic, copy, readonly) NSIndexSet *inserted;
@property (nonatomic, copy, readonly) NSSet *changed;

- (instancetype)initWithDeleted:(NSIndexSet *)deleted
                       inserted:(NSIndexSet *)inserted
                        changed:(NSSet *)changed;

@end


@interface NNMutableArrayDiff : NNArrayDiff

@property (nonatomic, copy, readonly) NSMutableIndexSet *deleted;
@property (nonatomic, copy, readonly) NSMutableIndexSet *inserted;
@property (nonatomic, copy, readonly) NSMutableSet *changed;

@end