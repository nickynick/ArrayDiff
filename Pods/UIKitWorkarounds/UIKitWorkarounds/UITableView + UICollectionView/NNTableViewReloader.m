//
//  NNTableViewReloader.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 15/01/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "NNTableViewReloader.h"
#import "NNReloadOperations.h"
#import "NNReloadOperationSanitizer.h"

@interface NNTableViewReloader ()

@property (nonatomic, copy, readonly) NNCellCustomReloadBlock cellCustomReloadBlock;

@property (nonatomic, strong) NNReloadOperations *currentOperations;

@end


@implementation NNTableViewReloader

#pragma mark - Init

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView cellCustomReloadBlock:nil];
}

- (instancetype)initWithTableView:(UITableView *)tableView
            cellCustomReloadBlock:(NNCellCustomReloadBlock)cellCustomReloadBlock
{
    self = [super init];
    if (!self) return nil;
    
    _tableView = tableView;
    _cellCustomReloadBlock = [cellCustomReloadBlock copy];
    
    return self;
}

#pragma mark - Public

- (void)performUpdates:(void (^)())updates completion:(void (^)())completion {
    if (completion) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
    }
    
    [self.tableView beginUpdates];
    
    self.currentOperations = [[NNReloadOperations alloc] init];
    updates();
    
    [NNReloadOperationSanitizer sanitizeOperations:self.currentOperations customReloadAllowed:self.cellCustomReloadBlock != nil];
    
    [self applyOperations:self.currentOperations];
    
    [self.tableView endUpdates];
    
    if (self.cellCustomReloadBlock) {
        [self applyCustomReloadOperations:self.currentOperations];
    }
    
    self.currentOperations = nil;
    
    if (completion) {
        [CATransaction commit];
    }
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                                   context:@(animation)
                                                                                                    before:NSNotFound
                                                                                                     after:idx]];
    }];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                                   context:@(animation)
                                                                                                    before:idx
                                                                                                     after:NSNotFound]];
    }];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeReload
                                                                                                   context:@(animation)
                                                                                                    before:idx
                                                                                                     after:NSNotFound]];
    }];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self.currentOperations.sectionOperations addObject:[[NNSectionReloadOperation alloc] initWithType:NNReloadOperationTypeMove
                                                                                               context:nil
                                                                                                before:section
                                                                                                 after:newSection]];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeInsert
                                                                                                       context:@(animation)
                                                                                                        before:nil
                                                                                                         after:indexPath]];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeDelete
                                                                                                       context:@(animation)
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeReload
                                                                                                       context:@(animation)
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)reloadRowsAtIndexPathsWithCustomBlock:(NSArray<NSIndexPath *> *)indexPaths {
    NSAssert(self.cellCustomReloadBlock != nil, @"Did you forget to set cellCustomReloadBlock?");
    
    for (NSIndexPath *indexPath in indexPaths) {
        [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeCustomReload
                                                                                                       context:nil
                                                                                                        before:indexPath
                                                                                                         after:nil]];
    }
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self.currentOperations.indexPathOperations addObject:[[NNIndexPathReloadOperation alloc] initWithType:NNReloadOperationTypeMove
                                                                                                   context:nil
                                                                                                    before:indexPath
                                                                                                     after:newIndexPath]];
}

#pragma mark - Private

- (void)applyOperations:(NNReloadOperations *)operations {
    // TODO: check if performing operations one by one is slower
    
    for (NNIndexPathReloadOperation *operation in operations.indexPathOperations) {
        UITableViewRowAnimation animation = [operation.context integerValue];
        
        switch (operation.type) {
            case NNReloadOperationTypeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[ operation.before ] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeInsert:
                [self.tableView insertRowsAtIndexPaths:@[ operation.after ] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeReload:
                [self.tableView reloadRowsAtIndexPaths:@[ operation.before ] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeMove:
                [self.tableView moveRowAtIndexPath:operation.before toIndexPath:operation.after];
                break;
                
            case NNReloadOperationTypeCustomReload:
                break;
        }
    }
    
    for (NNSectionReloadOperation *operation in operations.sectionOperations) {
        UITableViewRowAnimation animation = [operation.context integerValue];
        
        switch (operation.type) {
            case NNReloadOperationTypeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:operation.before] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:operation.after] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeReload:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:operation.before] withRowAnimation:animation];
                break;
                
            case NNReloadOperationTypeMove:
                [self.tableView moveSection:operation.before toSection:operation.after];
                break;
                
            case NNReloadOperationTypeCustomReload:
                break;
        }
    }
}

- (void)applyCustomReloadOperations:(NNReloadOperations *)operations {
    for (NNIndexPathReloadOperation *operation in operations.indexPathOperations) {
        if (operation.type == NNReloadOperationTypeCustomReload) {
            id cell = [self.tableView cellForRowAtIndexPath:operation.after];
            self.cellCustomReloadBlock(cell, operation.after);
        }
    }
}

@end
