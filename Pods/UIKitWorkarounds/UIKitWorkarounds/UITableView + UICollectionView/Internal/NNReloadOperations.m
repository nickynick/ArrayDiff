//
//  NNReloadOperations.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNReloadOperations.h"

static NSString *NNReloadOperationTypeToString(NNReloadOperationType type) {
    switch (type) {
        case NNReloadOperationTypeDelete:
            return @"delete";
        case NNReloadOperationTypeInsert:
            return @"insert";
        case NNReloadOperationTypeReload:
            return @"reload";
        case NNReloadOperationTypeMove:
            return @"move";
        case NNReloadOperationTypeCustomReload:
            return @"custom reload";
    }
}


@implementation NNReloadOperation

- (instancetype)initWithType:(NNReloadOperationType)type context:(id)context {
    self = [super init];
    if (!self) return nil;
    
    _type = type;
    _context = context;
    
    return self;
}

@end


@implementation NNIndexPathReloadOperation

- (instancetype)initWithType:(NNReloadOperationType)type
                     context:(nullable id)context
                      before:(nullable NSIndexPath *)before
                       after:(nullable NSIndexPath *)after
{
    self = [super initWithType:type context:context];
    if (!self) return nil;
    
    _before = before;
    _after = after;
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{ %@ from %@.%@ to %@.%@ }",
            NNReloadOperationTypeToString(self.type),
            self.before ? @(self.before.section) : @"-",
            self.before ? @(self.before.row) : @"-",
            self.after ? @(self.after.section) : @"-",
            self.after ? @(self.after.row) : @"-"];
}

@end


@implementation NNSectionReloadOperation

- (instancetype)initWithType:(NNReloadOperationType)type
                     context:(nullable id)context
                      before:(NSUInteger)before
                       after:(NSUInteger)after
{
    NSAssert(type != NNReloadOperationTypeCustomReload, @"Custom reload is not applicable to sections.");
    
    self = [super initWithType:type context:context];
    if (!self) return nil;
    
    _before = before;
    _after = after;
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{ %@ from %@ to %@ }",
            NNReloadOperationTypeToString(self.type),
            self.before != NSNotFound ? @(self.before) : @"-",
            self.after != NSNotFound ? @(self.after) : @"-"];
}

@end


@implementation NNReloadOperations

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _indexPathOperations = [NSMutableSet set];
    _sectionOperations = [NSMutableSet set];
    
    return self;
}

- (void)enumerateIndexPathOperationsOfType:(NNReloadOperationType)type withBlock:(void (^)(NNIndexPathReloadOperation *operation, BOOL *stop))block {
    BOOL stop = NO;
    
    for (NNIndexPathReloadOperation *operation in self.indexPathOperations) {
        if (operation.type == type) {
            block(operation, &stop);
            
            if (stop) {
                break;
            }
        }
    }
}

- (void)enumerateSectionOperationsOfType:(NNReloadOperationType)type withBlock:(void (^)(NNSectionReloadOperation *operation, BOOL *stop))block {
    BOOL stop = NO;
    
    for (NNSectionReloadOperation *operation in self.sectionOperations) {
        if (operation.type == type) {
            block(operation, &stop);
            
            if (stop) {
                break;
            }
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"{\nsection operations: %@,\nindexPath operations: %@}",
            self.sectionOperations,
            self.indexPathOperations];
}

@end