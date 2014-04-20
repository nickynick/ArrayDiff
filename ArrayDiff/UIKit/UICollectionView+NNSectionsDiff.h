//
//  UICollectionView+NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"
#import "UITableView+NNSectionsDiff.h"

@import UIKit;

@interface UICollectionView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock;

@end