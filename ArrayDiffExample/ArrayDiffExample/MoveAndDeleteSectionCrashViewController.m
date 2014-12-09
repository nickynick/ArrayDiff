//
//  MoveAndDeleteSectionCrashViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "MoveAndDeleteSectionCrashViewController.h"

@implementation MoveAndDeleteSectionCrashViewController

- (void)setupItems {
    [Item setupItemsWithNames:@[ @"A1", @"B1", @"B2", @"C1" ]];
}

- (NSArray *)barButtonItems {
    return @[ [[UIBarButtonItem alloc] initWithTitle:@"Kaboom" style:UIBarButtonItemStyleBordered target:self action:@selector(kaboomBarButtonPressed)] ];
}

- (void)kaboomBarButtonPressed {
    [Item existingItemWithName:@"A1"].name = @"C2";
    [Item existingItemWithName:@"B2"].name = @"C3";
    [[Item managedObjectContext] save:NULL];
}

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    [self.tableView beginUpdates];
    
    // Delete "A" section
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
    
    // Insert "A1" (can't use move because the source section is being deleted)
    [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    // Move "B2"
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
                           toIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    
    [self.tableView endUpdates];
    
    // Exception: Invalid update: invalid number of rows in section 0.  The number of rows contained in an existing section after the update (1) must be equal to the number of rows contained in that section before the update (2), plus or minus the number of rows inserted or deleted from that section (0 inserted, 0 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
}

@end
