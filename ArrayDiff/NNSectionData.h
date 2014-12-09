//
//  NNSectionData.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 21/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNSectionData : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, copy, readonly) NSArray *objects;

- (instancetype)initWithKey:(id)key objects:(NSArray *)objects;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end


@interface NNMutableSectionData : NNSectionData

@property (nonatomic, strong) id key;
@property (nonatomic, copy, readonly) NSMutableArray *objects;

@end
