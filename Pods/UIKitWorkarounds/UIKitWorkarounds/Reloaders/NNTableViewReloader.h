//
//  NNTableViewReloader.h
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NNCellCustomReloadBlock.h"

NS_ASSUME_NONNULL_BEGIN


@interface NNTableViewReloader : NSObject

@property (nonatomic, strong, readonly) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

- (instancetype)initWithTableView:(UITableView *)tableView
            cellCustomReloadBlock:(nullable NNCellCustomReloadBlock)cellCustomReloadBlock NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;


- (void)performUpdates:(void (^)())updates completion:(nullable void (^)())completion;

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRowsAtIndexPathsWithCustomBlock:(NSArray<NSIndexPath *> *)indexPaths;
- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

@end


NS_ASSUME_NONNULL_END