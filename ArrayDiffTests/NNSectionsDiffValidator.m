//
//  NNSectionsDiffValidator.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 21/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiffValidator.h"
#import "NNTestItem.h"

@implementation NNSectionsDiffValidator

+ (void)validateDiff:(NNSectionsDiff *)diff betweenSections:(NSArray *)before andSections:(NSArray *)after {
}

#pragma mark - Private

+ (NSIndexPath *)indexPathOfObject:(id)object inSections:(NSArray *)sections {
    for (NSUInteger section = 0; section < [sections count]; ++section) {
        NNSectionData *sectionData = sections[section];
        __block NSUInteger index = NSNotFound;
        
        if ([object isKindOfClass:[NNTestItem class]]) {
            [sectionData.objects enumerateObjectsUsingBlock:^(NNTestItem *item, NSUInteger idx, BOOL *stop) {
                if (item.itemId == ((NNTestItem *)object).itemId) {
                    index = idx;
                    *stop = YES;
                }
            }];
        } else {
            index = [sectionData.objects indexOfObject:object];
        }
        
        if (index != NSNotFound) {
            return [NSIndexPath indexPathForRow:index inSection:section];
        }
    }    
    return nil;
}

@end
