//
//  ExamplesViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "ExamplesViewController.h"
#import "StringsViewController.h"
#import "PeopleTableViewController.h"
#import "PeopleCollectionViewController.h"

static NSString * const kCellReuseIdentifier = @"ExampleCell";


@interface ExamplesViewController ()

@property (nonatomic, strong) NSArray *exampleTitles;

@end


@implementation ExamplesViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    
    self.title = @"ArrayDiff examples";
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    
    self.exampleTitles = @[
        @"UITableView + array (huge!)",
        @"UITableView + manual sections",
        @"UITableView + FRC",
        @"UICollectionView + manual sections",
        @"UICollectionView + FRC",
    ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.exampleTitles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    cell.textLabel.text = self.exampleTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc;
    
    switch (indexPath.row) {
        case 0:
            vc = [[StringsViewController alloc] initWithStyle:UITableViewStylePlain];
            break;
        case 1:
            vc = [[PeopleTableViewController alloc] initWithFRC:NO];
            break;
        case 2:
            vc = [[PeopleTableViewController alloc] initWithFRC:YES];
            break;
        case 3:
            vc = [[PeopleCollectionViewController alloc] initWithFRC:NO];
            break;
        case 4:
            vc = [[PeopleCollectionViewController alloc] initWithFRC:YES];
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
