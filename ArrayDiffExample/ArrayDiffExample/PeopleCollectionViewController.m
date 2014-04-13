//
//  PeopleCollectionViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "PeopleCollectionViewController.h"
#import "UICollectionView+NNSectionsDiff.h"
#import "PersonCollectionViewCell.h"
#import "PeopleCollectionViewHeader.h"

static NSString * const kHeaderReuseIdentifier = @"PeopleHeader";
static NSString * const kCellReuseIdentifier = @"PersonCell";


@interface PeopleCollectionViewController () <UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation PeopleCollectionViewController

#pragma mark - Life cycle

- (void)loadView {
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    collectionViewLayout.headerReferenceSize = CGSizeMake(0, 30);
    collectionViewLayout.itemSize = CGSizeMake(50, 50);
    collectionViewLayout.minimumInteritemSpacing = 10;
    collectionViewLayout.minimumLineSpacing = 10;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[PersonCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [self.collectionView registerClass:[PeopleCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
    
    self.view = self.collectionView;
}

#pragma mark - PersonViewController

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    [self.collectionView reloadWithSectionsDiff:diff
                                     updateType:NNCollectionViewCellUpdateTypeReload
                                 cellSetupBlock:^(id cell, NSIndexPath *indexPath) {
                                         [self setupCell:cell forItemAtIndexPath:indexPath];
                                 }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PersonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self setupCell:cell forItemAtIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(PersonCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Person *person = [self personAtIndexPath:indexPath];
    cell.nameLabel.text = person.name;
    [cell setNeedsLayout];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        PeopleCollectionViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
        
        headerView.titleLabel.text = [self titleForSection:indexPath.section];
        [headerView setNeedsLayout];

        return headerView;
    } else {
        return nil;
    }
}

@end
