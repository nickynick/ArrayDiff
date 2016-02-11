//
//  NNReloadOperations.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, NNReloadOperationType) {
    NNReloadOperationTypeDelete,
    NNReloadOperationTypeInsert,
    NNReloadOperationTypeReload,
    NNReloadOperationTypeMove,
    NNReloadOperationTypeCustomReload
};


@interface NNReloadOperation : NSObject

@property (nonatomic, readonly) NNReloadOperationType type;
@property (nonatomic, nullable, readonly) id context;

- (instancetype)initWithType:(NNReloadOperationType)type context:(nullable id)context NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end


@interface NNIndexPathReloadOperation : NNReloadOperation

@property (nonatomic, nullable, readonly) NSIndexPath *before;
@property (nonatomic, nullable, readonly) NSIndexPath *after;

- (instancetype)initWithType:(NNReloadOperationType)type
                     context:(nullable id)context
                      before:(nullable NSIndexPath *)before
                       after:(nullable NSIndexPath *)after NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(NNReloadOperationType)type context:(nullable id)context NS_UNAVAILABLE;

@end


@interface NNSectionReloadOperation : NNReloadOperation

@property (nonatomic, readonly) NSUInteger before;
@property (nonatomic, readonly) NSUInteger after;

- (instancetype)initWithType:(NNReloadOperationType)type
                     context:(nullable id)context
                      before:(NSUInteger)before
                       after:(NSUInteger)after NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithType:(NNReloadOperationType)type context:(nullable id)context NS_UNAVAILABLE;

@end


@interface NNReloadOperations : NSObject

@property (nonatomic, readonly) NSMutableSet<NNIndexPathReloadOperation *> *indexPathOperations;
@property (nonatomic, readonly) NSMutableSet<NNSectionReloadOperation *> *sectionOperations;

- (void)enumerateIndexPathOperationsOfType:(NNReloadOperationType)type withBlock:(void (^)(NNIndexPathReloadOperation *operation, BOOL *stop))block;
- (void)enumerateSectionOperationsOfType:(NNReloadOperationType)type withBlock:(void (^)(NNSectionReloadOperation *operation, BOOL *stop))block;

@end


NS_ASSUME_NONNULL_END