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



@interface Example : NSObject

+ (instancetype)exampleWithTitle:(NSString *)title viewControllerBlock:(UIViewController * (^)())viewControllerBlock;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) UIViewController *(^viewControllerBlock)();

@end


@implementation Example

+ (instancetype)exampleWithTitle:(NSString *)title viewControllerBlock:(UIViewController * (^)())viewControllerBlock {
    Example *example = [[self alloc] init];
    example.title = title;
    example.viewControllerBlock = viewControllerBlock;
    return example;
}

@end



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
    
    
    NNMutableSectionData *examplesSection = [[NNMutableSectionData alloc] initWithKey:@"Examples" objects:nil];
    
    [examplesSection.objects addObject:[Example exampleWithTitle:@"UITableView + huge array" viewControllerBlock:^{
        return [[StringsViewController alloc] initWithStyle:UITableViewStylePlain];
    }]];
    
    [examplesSection.objects addObject:[Example exampleWithTitle:@"UITableView + manual sections" viewControllerBlock:^{
        return [[PeopleTableViewController alloc] initWithFRC:NO];
    }]];
    
    [examplesSection.objects addObject:[Example exampleWithTitle:@"UITableView + FRC" viewControllerBlock:^{
        return [[PeopleTableViewController alloc] initWithFRC:YES];
    }]];
    
    [examplesSection.objects addObject:[Example exampleWithTitle:@"UICollectionView + manual sections" viewControllerBlock:^{
        return [[PeopleCollectionViewController alloc] initWithFRC:NO];
    }]];
    
    [examplesSection.objects addObject:[Example exampleWithTitle:@"UICollectionView + FRC" viewControllerBlock:^{
        return [[PeopleCollectionViewController alloc] initWithFRC:YES];
    }]];
    
    
    NNMutableSectionData *crashesSection = [[NNMutableSectionData alloc] initWithKey:@"UIKit bugs (carefully fixed)" objects:nil];
    
    [crashesSection.objects addObject:[Example exampleWithTitle:@"Move row + update another row" viewControllerBlock:^{
        return [[MoveAndUpdateRowCrashViewController alloc] initWithFRC:NO];
    }]];
    
    [crashesSection.objects addObject:[Example exampleWithTitle:@"Move row + insert section" viewControllerBlock:^{
        return [[MoveAndInsertSectionCrashViewController alloc] initWithFRC:NO];
    }]];
    
    [crashesSection.objects addObject:[Example exampleWithTitle:@"Move row + delete section" viewControllerBlock:^{
        return [[MoveAndDeleteSectionCrashViewController alloc] initWithFRC:NO];
    }]];
    
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NNSectionData *sectionData = self.sections[section];
    return sectionData.key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    Example *example = self.sections[indexPath.section][indexPath.row];
    cell.textLabel.text = example.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Example *example = self.sections[indexPath.section][indexPath.row];
    UIViewController *vc = example.viewControllerBlock();
    [self.navigationController pushViewController:vc animated:YES];
}

@end

