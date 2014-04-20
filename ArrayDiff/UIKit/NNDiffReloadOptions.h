//
//  NNDiffReloadOptions.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

typedef NS_OPTIONS(NSInteger, NNDiffReloadOptions) {
    NNDiffReloadUpdatedWithReload        = 1 << 0, // default
    NNDiffReloadUpdatedWithSetup         = 1 << 1,
    
    NNDiffReloadMovedWithDeleteAndInsert = 1 << 4, // default
    NNDiffReloadMovedWithMove            = 1 << 5
};
