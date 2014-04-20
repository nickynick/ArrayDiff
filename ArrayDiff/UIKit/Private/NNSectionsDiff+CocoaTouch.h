//
//  NNSectionsDiff+CocoaTouch.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNSectionsDiff.h"
#import "NNDiffReloadOptions.h"
#import "NNCocoaTouchCollection.h"

@interface NNSectionsDiff (CocoaTouch)

- (void)reloadCocoaTouchCollection:(id<NNCocoaTouchCollection>)collection
                           options:(NNDiffReloadOptions)options
                    cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock;

@end