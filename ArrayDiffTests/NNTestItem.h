//
//  NNTestItem.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNTestItem : NSObject <NSCopying>

@property (nonatomic, readonly) NSUInteger itemId;
@property (nonatomic, strong) NSString *name;

- (id)initWithId:(NSUInteger)itemId;
+ (instancetype)itemWithId:(NSUInteger)itemId name:(NSString *)name;

- (BOOL)testItemUpdated:(NNTestItem *)other;

+ (NNDiffObjectIdBlock)idBlock;
+ (NNDiffObjectUpdatedBlock)updatedBlock;

@end
