//
//  NNCocoaTouchCollectionReloader.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 27/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNSectionsDiff.h"
#import "NNDiffReloadOptions.h"
#import "NNCocoaTouchCollection.h"

@interface NNCocoaTouchCollectionReloader : NSObject

+ (void)reloadCocoaTouchCollection:(id<NNCocoaTouchCollection>)collection
                          withDiff:(NNSectionsDiff *)diff
                           options:(NNDiffReloadOptions)options
                    cellSetupBlock:(void (^)(id cell, NSIndexPath *indexPath))cellSetupBlock
                        completion:(void (^)())completion;

@end
