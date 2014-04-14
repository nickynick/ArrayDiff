//
//  UITableView+NNSectionsDiff.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 03/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"

@import UIKit;

typedef NS_OPTIONS(NSInteger, NNDiffReloadOptions) {
    NNDiffReloadUpdatedWithReload        = 1 << 0, // default
    NNDiffReloadUpdatedWithSetup         = 1 << 1,
    
    NNDiffReloadMovedWithDeleteAndInsert = 1 << 4, // default
    NNDiffReloadMovedWithMove            = 1 << 5
};


@interface UITableView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff;

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                     animation:(UITableViewRowAnimation)animation
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock;

@end
