//
//  ItemsTableViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "UITableView+NNSectionsDiff.h"

static NSString * const kCellReuseIdentifier = @"Cell";

@interface ItemsTableViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation ItemsTableViewController

#pragma mark - Life cycle

- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 33;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    
    self.view = self.tableView;
}

#pragma mark - ItemsViewController

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    NNDiffReloadOptions *options = [[NNDiffReloadOptions alloc] init];
    options.useMoveIfPossible = YES;
    options.cellUpdateBlock = ^(id cell, NSIndexPath *indexPath){
        [self setupCell:cell forRowAtIndexPath:indexPath];
    };
    
    [self.tableView reloadWithSectionsDiff:diff options:options animation:UITableViewRowAnimationFade completion:nil];
}

- (NSString *)displayedNameAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self setupCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = item.name;
    [cell setNeedsLayout];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSection:section];
}

@end
