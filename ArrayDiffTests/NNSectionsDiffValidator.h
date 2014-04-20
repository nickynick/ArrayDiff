//
//  NNSectionsDiffValidator.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 21/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NNSectionsDiffValidator : NSObject

+ (void)validateDiff:(NNSectionsDiff *)diff betweenSections:(NSArray *)before andSections:(NSArray *)after;

@end
