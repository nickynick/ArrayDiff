//
//  NNArrayDiffMove.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNArrayDiffMove : NSObject

- (id)initWithFrom:(NSUInteger)from to:(NSUInteger)to updated:(BOOL)updated;

@property (nonatomic, readonly) NSUInteger from;
@property (nonatomic, readonly) NSUInteger to;
@property (nonatomic, readonly, getter = isUpdated) BOOL updated;

@end
