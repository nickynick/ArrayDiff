//
//  PeopleTableViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "PeopleTableViewController.h"
#import "UITableView+NNSectionsDiff.h"

static NSString * const kCellReuseIdentifier = @"PersonCell";

@interface PeopleTableViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation PeopleTableViewController

#pragma mark - Life cycle

- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 33;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    
    self.view = self.tableView;
}

#pragma mark - PeopleViewController

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    [self.tableView reloadWithSectionsDiff:diff
                                   options:0
                                 animation:UITableViewRowAnimationFade
                            cellSetupBlock:^(id cell, NSIndexPath *indexPath) {
                                [self setupCell:cell forRowAtIndexPath:indexPath];
                            }];
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
    Person *person = [self personAtIndexPath:indexPath];
    cell.textLabel.text = person.name;
    [cell setNeedsLayout];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self titleForSection:section];
}

@end
