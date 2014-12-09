//
//  ItemsViewController.h
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemsViewController : UIViewController

@property (nonatomic, readonly) BOOL usesFRC;

- (id)initWithFRC:(BOOL)usesFRC;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForSection:(NSUInteger)section;
- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface ItemsViewController (Customization)

- (void)setupItems;
- (NSArray *)barButtonItems;
- (void)reloadWithDiff:(NNSectionsDiff *)diff;
- (NSString *)displayedNameAtIndexPath:(NSIndexPath *)indexPath;

@end