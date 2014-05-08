//
//  NNTableViewReloader.h
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NNCocoaTouchCollectionReloader.h"

@import UIKit;

@interface NNTableViewReloader : NNCocoaTouchCollectionReloader

- (id)initWithTableView:(UITableView *)tableView rowAnimation:(UITableViewRowAnimation)rowAnimation;

@end
