//
//  NNSectionsDiffDataSource.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NNSectionsDiffDataSource <NSObject>

- (NSArray *)diffSectionKeys;
- (NSArray *)diffObjectsForSection:(NSUInteger)section;

@end
