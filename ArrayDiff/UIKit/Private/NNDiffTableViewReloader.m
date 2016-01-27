//
//  NNDiffTableViewReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNDiffTableViewReloader.h"
#import <UIKitWorkarounds/NNTableViewReloader.h>

@interface NNDiffTableViewReloader ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NNTableViewDiffReloadAnimations *animations;

@property (nonatomic, strong) NNTableViewReloader *reloader;

@end


@implementation NNDiffTableViewReloader

#pragma mark - Init

- (instancetype)initWithTableView:(UITableView *)tableView animations:(NNTableViewDiffReloadAnimations *)animations {
    NSParameterAssert(animations != nil);
    
    self = [super init];
    if (!self) return nil;
    
    _tableView = tableView;
    _animations = animations ?: [[NNTableViewDiffReloadAnimations alloc] init];
    
    return self;
}

#pragma mark - NNDiffReloader

- (void)performUpdates:(void (^)())updates withOptions:(NNDiffReloadOptions *)options completion:(void (^)())completion {
    self.reloader = [[NNTableViewReloader alloc] initWithTableView:self.tableView
                                             cellCustomReloadBlock:options.cellUpdateBlock];
    
    [self.reloader performUpdates:updates completion:^{
        if (completion) {
            completion();
        }
        
        self.reloader = nil;
    }];
}

- (void)insertSections:(NSIndexSet *)sections {
    [self.reloader insertSections:sections withRowAnimation:self.animations.sectionInsertAnimation];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self.reloader deleteSections:sections withRowAnimation:self.animations.sectionDeleteAnimation];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader insertRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowInsertAnimation];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader deleteRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowDeleteAnimation];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader reloadRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowReloadAnimation];
}

- (void)updateItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.reloader reloadRowsAtIndexPathsWithCustomBlock:indexPaths];
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.reloader moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

@end
