//
//  ItemsViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "ItemsViewController.h"

@interface ItemsViewController () <NNFetchedResultsControllerDiffAdapterDelegate>

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NNFetchedResultsControllerDiffAdapter *frcDiffAdapter;

@end


@implementation ItemsViewController

#pragma mark - Init

- (id)initWithFRC:(BOOL)usesFRC {
    self = [super init];
    if (!self) return nil;
    
    _usesFRC = usesFRC;
    
    if (usesFRC) {
        self.frcDiffAdapter = [[NNFetchedResultsControllerDiffAdapter alloc] init];
        self.frcDiffAdapter.delegate = self;
        
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:[Item requestForSortedItems]
                                                       managedObjectContext:[Item managedObjectContext]
                                                         sectionNameKeyPath:@"sectionTitle"
                                                                  cacheName:nil];
        self.frc.delegate = self.frcDiffAdapter;
    }
    
    return self;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItems = [self barButtonItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupItems];
    
    if (self.usesFRC) {
        [self.frc performFetch:NULL];
    } else {
        self.items = [Item fetchSortedItemSections];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:[Item managedObjectContext]];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.usesFRC) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)addBarButtonPressed {
    [Item addRandomItem];
}

- (void)deleteBarButtonPressed {
    [Item deleteRandomItem];
}

- (void)updateBarButtonPressed {
    [Item updateRandomItems];
}

- (void)checkDisplayedData {
    for (NSUInteger section = 0; section < [self numberOfSections]; ++section) {
        for (NSUInteger row = 0; row < [self numberOfItemsInSection:section]; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            Item *item = [self itemAtIndexPath:indexPath];
            NSString *displayedName = [self displayedNameAtIndexPath:indexPath];
            
            if (displayedName) {
                NSAssert([item.name isEqualToString:displayedName], @"We are displaying wrong data, something went wrong.");
            }
        }
    }
}

#pragma mark - Notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSSet *updatedItems = notification.userInfo[NSUpdatedObjectsKey];
    
    NSArray *items = [Item fetchSortedItemSections];
    
    NNSectionsDiffCalculator *diffCalculator = [[NNSectionsDiffCalculator alloc] init];
    diffCalculator.objectUpdatedBlock = ^(id objectBefore, id objectAfter) {
        return [updatedItems containsObject:objectAfter];
    };
    
    NNSectionsDiff *diff = [diffCalculator calculateDiffForSectionsBefore:self.items andAfter:items];
    
    self.items = items;
    
    [self reloadWithDiff:diff];
    [self checkDisplayedData];
}

#pragma mark - NNFetchedResultsControllerDiffAdapterDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDiff:(NNSectionsDiff *)diff {
    [self reloadWithDiff:diff];
    [self checkDisplayedData];
}

#pragma mark - Public

- (NSInteger)numberOfSections {
    if (self.usesFRC) {
        return [self.frc.sections count];
    } else {
        return [self.items count];
    }
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        return sectionInfo.numberOfObjects;
    } else {
        NNSection *sectionData = self.items[section];
        return [sectionData.objects count];
    }
}

- (NSString *)titleForSection:(NSUInteger)section {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        return sectionInfo.name;
    } else {
        NNSection *sectionData = self.items[section];
        return sectionData.key;
    }
}

- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[indexPath.section];
        return sectionInfo.objects[indexPath.row];
    } else {
        NNSection *sectionData = self.items[indexPath.section];
        return sectionData.objects[indexPath.row];
    }
}

#pragma mark - Customization

- (void)setupItems {
    [Item setupItemsWithNames:@[ @"A1", @"A2", @"A3", @"A4", @"B1", @"B2", @"B3", @"C1", @"C2", @"C3", @"C4" ]];
}

- (NSArray *)barButtonItems {
    return @[
        [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteBarButtonPressed)],
        [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(updateBarButtonPressed)],
        [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addBarButtonPressed)]
    ];
}

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
}

- (NSString *)displayedNameAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
