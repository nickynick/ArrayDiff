//
//  UITableView+NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"

@import UIKit;

typedef NS_ENUM(NSInteger, NNTableViewCellUpdateType) {
    NNTableViewCellUpdateTypeReload = 0,
    NNTableViewCellUpdateTypeSetup  = 1
};


@interface UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                     animation:(UITableViewRowAnimation)animation
                    updateType:(NNTableViewCellUpdateType)updateType
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock;

@end
