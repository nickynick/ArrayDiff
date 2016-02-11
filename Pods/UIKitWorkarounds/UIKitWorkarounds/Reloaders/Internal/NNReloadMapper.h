//
//  NNReloadMapper.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 26/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NNReloadOperations;

NS_ASSUME_NONNULL_BEGIN


@interface NNReloadMapper : NSObject

- (instancetype)initWithReloadOperations:(NNReloadOperations *)operations NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (NSUInteger)sectionBeforeToSectionAfter:(NSUInteger)sectionBefore;
- (NSUInteger)sectionAfterToSectionBefore:(NSUInteger)sectionAfter;

- (NSIndexPath *)indexPathBeforeToIndexPathAfter:(NSIndexPath *)indexPathBefore;
- (NSIndexPath *)indexPathAfterToIndexPathBefore:(NSIndexPath *)indexPathAfter;

@end


NS_ASSUME_NONNULL_END