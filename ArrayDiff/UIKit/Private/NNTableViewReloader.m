//
//  NNTableViewReloader.m
//  ArrayDiff
//
//  Created by Nick Tymchenko on 20/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "NNTableViewReloader.h"

@interface NNTableViewReloader ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NNTableViewDiffReloadAnimations *animations;

@end


@implementation NNTableViewReloader

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

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion {
    if (completion) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
    }
    
    [self.tableView beginUpdates];
    updates();
    [self.tableView endUpdates];
    
    if (completion) {
        [CATransaction commit];
    }
}

- (void)insertSections:(NSIndexSet *)sections {
    [self.tableView insertSections:sections withRowAnimation:self.animations.sectionInsertAnimation];
}

- (void)deleteSections:(NSIndexSet *)sections {
    [self.tableView deleteSections:sections withRowAnimation:self.animations.sectionDeleteAnimation];
}

- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowInsertAnimation];
}

- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowDeleteAnimation];
}

- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths asDeleteAndInsertAtIndexPaths:(NSArray *)insertIndexPaths {
    if (insertIndexPaths) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowReloadAnimation];
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:self.animations.rowReloadAnimation];
    } else {
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:self.animations.rowReloadAnimation];
    }    
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (id)cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

@end
