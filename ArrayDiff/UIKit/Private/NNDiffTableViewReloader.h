//
//  NNDiffTableViewReloader.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNDiffReloader.h"
#import "NNTableViewDiffReloadAnimations.h"

@import UIKit;

@interface NNDiffTableViewReloader : NNDiffReloader

- (instancetype)initWithTableView:(UITableView *)tableView animations:(NNTableViewDiffReloadAnimations *)animations;

@end
