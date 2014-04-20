//
//  MoveAndInsertSectionCrashViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 17/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "MoveAndInsertSectionCrashViewController.h"

@implementation MoveAndInsertSectionCrashViewController

- (void)setupPeople {
    [Person setupPeopleWithNames:@[ @"B1", @"B2", @"C1", @"C2" ]];
}

- (NSArray *)barButtonItems {
    return @[ [[UIBarButtonItem alloc] initWithTitle:@"Kaboom" style:UIBarButtonItemStyleBordered target:self action:@selector(kaboomBarButtonPressed)] ];
}

- (void)kaboomBarButtonPressed {
    [Person existingPersonWithName:@"B1"].name = @"A1";
    [Person existingPersonWithName:@"C2"].name = @"B3";
    [[Person managedObjectContext] save:NULL];
}

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    [self.tableView beginUpdates];
    
    // Delete "B1" (can't use move because the destination is newly inserted section)
    [self.tableView deleteRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    // Insert "A" section
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                  withRowAnimation:UITableViewRowAnimationFade];
    
    // Move "C2"
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]
                           toIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];

    [self.tableView endUpdates];
    
    // Exception: Invalid update: invalid number of rows in section 1.  The number of rows contained in an existing section after the update (2) must be equal to the number of rows contained in that section before the update (2), plus or minus the number of rows inserted or deleted from that section (0 inserted, 1 deleted) and plus or minus the number of rows moved into or out of that section (0 moved in, 0 moved out).
}

@end
