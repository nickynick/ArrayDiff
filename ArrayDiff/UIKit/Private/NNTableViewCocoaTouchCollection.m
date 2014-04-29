//
//  NNTableViewCocoaTouchCollection.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNTableViewCocoaTouchCollection.h"

@interface NNTableViewCocoaTouchCollection ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

@end


@implementation NNTableViewCocoaTouchCollection

#pragma mark - Init

- (id)initWithTableView:(UITableView *)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation {
    self = [super init];
    if (!self) return nil;
    
    _tableView = tableView;
    _rowAnimation = rowAnimation;
    
    return self;
}

#pragma mark - NNCocoaTouchCollection

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion {
    [self.tableView beginUpdates];
    updates();
    [self.tableView endUpdates];
    if (completion != nil) {
        completion();
    }
}

- (void)insertSections:(NSIndexSet *)sections {
    [self.tableView insertSections:sections withRowAnimation:self.rowAnimation];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self.tableView deleteSections:sections withRowAnimation:self.rowAnimation];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:self.rowAnimation];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:self.rowAnimation];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:self.rowAnimation];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

@end
