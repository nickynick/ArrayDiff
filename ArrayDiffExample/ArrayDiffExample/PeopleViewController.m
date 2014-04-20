//
//  PeopleViewController.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "PeopleViewController.h"
#import "NNFetchedResultsControllerDiffAdapter.h"
#import "NNArraySections.h"


@interface PeopleViewController () <NNFetchedResultsControllerDiffAdapterDelegate>

@property (nonatomic, strong) NNArraySections *people;

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NNFetchedResultsControllerDiffAdapter *frcDiffAdapter;

@end


@implementation PeopleViewController

#pragma mark - Init

- (id)initWithFRC:(BOOL)usesFRC {
    self = [super init];
    if (!self) return nil;
    
    _usesFRC = usesFRC;
    
    if (usesFRC) {
        self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:[Person requestForSortedPeople]
                                                       managedObjectContext:[Person managedObjectContext]
                                                         sectionNameKeyPath:@"sectionTitle"
                                                                  cacheName:nil];
        
        self.frcDiffAdapter = [[NNFetchedResultsControllerDiffAdapter alloc] initWithDelegate:self];
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
    [self setupPeople];
    
    if (self.usesFRC) {
        [self.frc performFetch:NULL];
    } else {
        self.people = [Person fetchSortedPeopleGroupedIntoSections];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:[Person managedObjectContext]];
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
    [Person addRandomPerson];
}

- (void)deleteBarButtonPressed {
    [Person deleteRandomPerson];
}

- (void)updateBarButtonPressed {
    [Person updateRandomPeople];
}

- (void)checkDisplayedData {
    for (NSUInteger section = 0; section < [self numberOfSections]; ++section) {
        for (NSUInteger row = 0; row < [self numberOfItemsInSection:section]; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            Person *person = [self personAtIndexPath:indexPath];
            NSString *displayedName = [self displayedNameAtIndexPath:indexPath];
            
            if (displayedName) {
                NSAssert([person.name isEqualToString:displayedName], @"We are displaying wrong data, something went wrong.");
            }
        }
    }
}

#pragma mark - Notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSSet *updatedPeople = notification.userInfo[NSUpdatedObjectsKey];
    
    NNArraySections *people = [Person fetchSortedPeopleGroupedIntoSections];
    NNSectionsDiff *diff = [[NNSectionsDiff alloc] initWithBefore:self.people
                                                            after:people
                                                          idBlock:^id(id object) {
                                                              return object;
                                                          } updatedBlock:^BOOL(id objectBefore, id objectAfter) {
                                                              return [updatedPeople containsObject:objectAfter];
                                                          }];
    self.people = people;
    
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
        return [self.people.sections count];
    }
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        return sectionInfo.numberOfObjects;
    } else {
        return [self.people.sections[section] count];
    }
}

- (NSString *)titleForSection:(NSUInteger)section {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
        return sectionInfo.name;
    } else {
        return self.people.sectionKeys[section];
    }
}

- (Person *)personAtIndexPath:(NSIndexPath *)indexPath {
    if (self.usesFRC) {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[indexPath.section];
        return sectionInfo.objects[indexPath.row];
    } else {
        return self.people.sections[indexPath.section][indexPath.row];
    }
}

#pragma mark - 

- (void)setupPeople {
    [Person setupPeopleWithNames:@[ @"A1", @"A2", @"A3", @"A4", @"B1", @"B2", @"B3", @"C1", @"C2", @"C3", @"C4" ]];
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
