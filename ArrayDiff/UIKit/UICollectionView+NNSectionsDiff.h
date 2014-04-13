//
//  UICollectionView+NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"

@import UIKit;

typedef NS_ENUM(NSInteger, NNCollectionViewCellUpdateType) {
    NNCollectionViewCellUpdateTypeReload = 0,
    NNCollectionViewCellUpdateTypeSetup  = 1
};


@interface UICollectionView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                    updateType:(NNCollectionViewCellUpdateType)updateType
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock;

@end