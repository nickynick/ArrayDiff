//
//  MoveAndUpdateRowCrashViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 16/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "MoveAndUpdateRowCrashViewController.h"

@implementation MoveAndUpdateRowCrashViewController

- (void)setupPeople {
    [Person setupPeopleWithNames:@[ @"A1", @"A2", @"A3" ]];
}

- (NSArray *)barButtonItems {
    return @[ [[UIBarButtonItem alloc] initWithTitle:@"Kaboom" style:UIBarButtonItemStyleBordered target:self action:@selector(kaboomBarButtonPressed)] ];
}

- (void)kaboomBarButtonPressed {
    [Person existingPersonWithName:@"A2"].name = @"A0";
    [[Person managedObjectContext] save:NULL];
}

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    [self.tableView beginUpdates];
    
    // Reload "A2"
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationFade];
    
    // Move "A1"
    [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           toIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    [self.tableView endUpdates];
    
    // Exception: Attempt to create two animations for cell
}

@end
