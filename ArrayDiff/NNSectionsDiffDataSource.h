//
//  NNSectionsDiffDataSource.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NNSectionsDiffDataSource <NSObject>

- (NSArray *)sectionKeys;
- (NSArray *)objectsForSection:(NSUInteger)section;

@end
