//
//  UICollectionView+NNSectionsDiff.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 12/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "UICollectionView+NNSectionsDiff.h"
#import "NNSectionsDiff+CocoaTouch.h"
#import "NNCollectionViewCocoaTouchCollection.h"

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
    NNCollectionViewCocoaTouchCollection *collection = [[NNCollectionViewCocoaTouchCollection alloc] initWithCollectionView:self];
    [sectionsDiff reloadCocoaTouchCollection:collection options:options cellSetupBlock:cellSetupBlock];
}

@end
