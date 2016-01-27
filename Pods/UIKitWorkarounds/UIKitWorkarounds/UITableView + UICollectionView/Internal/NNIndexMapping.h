//
//  NNIndexMapping.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 27/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NNIndexMapping : NSObject

- (instancetype)initWithDeletedIndexes:(NSIndexSet *)deletedIndexes
                       insertedIndexes:(NSIndexSet *)insertedIndexes NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (NSUInteger)indexBeforeToIndexAfter:(NSUInteger)indexBefore;
- (NSUInteger)indexAfterToIndexBefore:(NSUInteger)indexAfter;

@end


NS_ASSUME_NONNULL_END