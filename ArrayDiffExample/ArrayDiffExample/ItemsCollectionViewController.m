//
//  ItemsCollectionViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "ItemsCollectionViewController.h"
#import "UICollectionView+NNSectionsDiff.h"
#import "ItemCollectionViewCell.h"
#import "ItemCollectionViewHeader.h"

static NSString * const kHeaderReuseIdentifier = @"Header";
static NSString * const kCellReuseIdentifier = @"Cell";


@interface ItemsCollectionViewController () <UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation ItemsCollectionViewController

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
    [self.collectionView registerClass:[ItemCollectionViewCell class] forCellWithReuseIdentifier:kCellReuseIdentifier];
    [self.collectionView registerClass:[ItemCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier];
    
    self.view = self.collectionView;
}

#pragma mark - ItemsViewController

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
    NNDiffReloadOptions *options = [[NNDiffReloadOptions alloc] init];
    options.useMoveIfPossible = YES;
    options.cellUpdateBlock = ^(id cell, NSIndexPath *indexPath){
        [self setupCell:cell forItemAtIndexPath:indexPath];
    };
    
    [self.collectionView reloadWithSectionsDiff:diff options:options completion:nil];
}

- (NSString *)displayedNameAtIndexPath:(NSIndexPath *)indexPath {
    return ((ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath]).nameLabel.text;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [self setupCell:cell forItemAtIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(ItemCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    Item *item = [self itemAtIndexPath:indexPath];
    cell.nameLabel.text = item.name;
    [cell setNeedsLayout];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ItemCollectionViewHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderReuseIdentifier forIndexPath:indexPath];
        
        headerView.titleLabel.text = [self titleForSection:indexPath.section];
        [headerView setNeedsLayout];

        return headerView;
    } else {
        return nil;
    }
}

@end
