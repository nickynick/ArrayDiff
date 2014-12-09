//
//  NNCollectionViewReloader.h 
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNDiffReloader.h"

@import UIKit;

@interface NNCollectionViewReloader : NNDiffReloader

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

@end
