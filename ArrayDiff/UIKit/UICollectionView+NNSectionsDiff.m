//
//  UICollectionView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UICollectionView+NNSectionsDiff.h"
#import "NNCollectionViewReloader.h"

@implementation UICollectionView (NNSectionsDiff)

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff {
    [self reloadWithSectionsDiff:sectionsDiff
                         options:0
                  cellSetupBlock:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
{
    [self reloadWithSectionsDiff:sectionsDiff
                         options:options
                  cellSetupBlock:cellSetupBlock
                      completion:nil];
}

- (void)reloadWithSectionsDiff:(NNSectionsDiff *)sectionsDiff
                       options:(NNDiffReloadOptions)options
                cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
                    completion:(void (^)())completion
{
    NNCollectionViewReloader *reloader = [[NNCollectionViewReloader alloc] initWithCollectionView:self];
    
    [reloader reloadWithSectionsDiff:sectionsDiff
                             options:options
                      cellSetupBlock:cellSetupBlock
                          completion:completion];
}

@end
