//
//  NNArrayDiffValidator.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNArrayDiffValidator : NSObject

+ (void)validateDiff:(NNArrayDiff *)diff betweenArray:(NSArray *)before andArray:(NSArray *)after;

@end
