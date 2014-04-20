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

#import "MoveAndUpdateRowCrashViewController.h"
#import "MoveAndInsertSectionCrashViewController.h"
#import "MoveAndDeleteSectionCrashViewController.h"


static NSString * const kCellReuseIdentifier = @"ExampleCell";


@interface ExamplesViewController ()

@property (nonatomic, strong) NSArray *sections;

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
    
    NNSectionData *examplesSection = [[NNSectionData alloc] initWithKey:@"Examples" objects:@[
        @"UITableView + array (huge!)",
        @"UITableView + manual sections",
        @"UITableView + FRC",
        @"UICollectionView + manual sections",
        @"UICollectionView + FRC"
    ]];
    
    NNSectionData *crashesSection = [[NNSectionData alloc] initWithKey:@"Crashes" objects:@[
        @"Move row + update another row",
        @"Move row + insert section",
        @"Move row + delete section"
    ]];
    
    self.sections = @[ examplesSection, crashesSection ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NNSectionData *data = self.sections[section];
    return [data.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    NNSectionData *data = self.sections[indexPath.section];
    cell.textLabel.text = data.objects[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc;

    switch (indexPath.section) {
        case 0:
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
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    vc = [[MoveAndUpdateRowCrashViewController alloc] initWithFRC:NO];
                    break;
                case 1:
                    vc = [[MoveAndInsertSectionCrashViewController alloc] initWithFRC:NO];
                    break;
                case 2:
                    vc = [[MoveAndDeleteSectionCrashViewController alloc] initWithFRC:NO];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end

