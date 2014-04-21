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
    before = [before valueForKey:@"mutableCopy"];
    after = [after valueForKey:@"mutableCopy"];
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[before count]];
    for (NNMutableSectionData *sectionData in before) {
        [sections addObject:sectionData];
    }
    
    // Delete rows
    for (NSUInteger section = 0; section < [before count]; ++section) {
        NSMutableIndexSet *deleted = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in diff.deleted) {
            if (indexPath.section == section) {
                [deleted addIndex:indexPath.row];
            }
        }
        for (NNSectionsDiffChange *change in diff.changed) {
            if (change.type & NNDiffChangeMove && change.before.section == section) {
                [deleted addIndex:change.before.row];
            }
        }
        
        NNMutableSectionData *sectionData = sections[section];
        [sectionData.objects removeObjectsAtIndexes:deleted];
    }
    
    // Delete sections
    [sections removeObjectsAtIndexes:diff.deletedSections];
    
    // Insert sections
    [sections insertObjects:[after objectsAtIndexes:diff.insertedSections] atIndexes:diff.insertedSections];
    
    // Insert rows
    for (NSUInteger section = 0; section < [after count]; ++section) {
        NSMutableIndexSet *inserted = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in diff.inserted) {
            if (indexPath.section == section) {
                [inserted addIndex:indexPath.row];
            }
        }
        for (NNSectionsDiffChange *change in diff.changed) {
            if (change.type & NNDiffChangeMove && change.after.section == section) {
                [inserted addIndex:change.after.row];
            }
        }
        
        NNMutableSectionData *sectionData = sections[section];
        [sectionData.objects insertObjects:[((NNSectionData *)after[section]).objects objectsAtIndexes:inserted] atIndexes:inserted];
    }
    
    expect(sections).to.equal(after);
    
    
    [before enumerateObjectsUsingBlock:^(NNSectionData *sectionData, NSUInteger section, BOOL *stop) {
        [sectionData.objects enumerateObjectsUsingBlock:^(id objectBefore, NSUInteger row, BOOL *stop) {
            NSIndexPath *indexPathBefore = [NSIndexPath indexPathForRow:row inSection:section];
            NSIndexPath *indexPathAfter = [self indexPathOfObject:objectBefore inSections:after];
            
            if (!indexPathAfter) return;
            
            id objectAfter = ((NNSectionData *)after[indexPathAfter.section]).objects[indexPathAfter.row];
            
            NSUInteger changeIndex = [diff.changed indexOfObjectPassingTest:^BOOL(NNSectionsDiffChange *change, NSUInteger idx, BOOL *stop) {
                return ([change.before isEqual:indexPathBefore] && [change.after isEqual:indexPathAfter]);
            }];
            NNSectionsDiffChange *change = (changeIndex != NSNotFound) ? diff.changed[changeIndex] : nil;
            
            BOOL objectUpdated = NO;
            if ([objectBefore isKindOfClass:[NNTestItem class]]) {
                objectUpdated = [(NNTestItem *)objectBefore testItemUpdated:objectAfter];
            }
            
            if (change && (change.type & NNDiffChangeUpdate)) {
                expect(objectUpdated).to.beTruthy();
            } else {
                expect(objectUpdated).to.beFalsy();
            }
        }];
    }];
}

#pragma mark - Private

+ (NSIndexPath *)indexPathOfObject:(id)object inSections:(NSArray *)sections {
    for (NSUInteger section = 0; section < [sections count]; ++section) {
        NNSectionData *sectionData = sections[section];
        NSUInteger index = [sectionData.objects indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([object isKindOfClass:[NNTestItem class]]) {
                return (((NNTestItem *)obj).itemId == ((NNTestItem *)object).itemId);
            } else {
                return [obj isEqual:object];
            }
        }];
        if (index != NSNotFound) {
            return [NSIndexPath indexPathForRow:index inSection:section];
        }
    }
    return nil;
}

@end
