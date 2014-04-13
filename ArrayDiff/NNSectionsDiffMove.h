//
//  NNSectionsDiffMove.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNSectionsDiffMove : NSObject

- (id)initWithFrom:(NSIndexPath *)from to:(NSIndexPath *)to updated:(BOOL)updated;

@property (nonatomic, readonly) NSIndexPath *from;
@property (nonatomic, readonly) NSIndexPath *to;
@property (nonatomic, readonly, getter = isUpdated) BOOL updated;

@end
