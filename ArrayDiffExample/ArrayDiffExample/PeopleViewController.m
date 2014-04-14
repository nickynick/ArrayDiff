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
    
    self.navigationItem.rightBarButtonItems = @[
        [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(deleteBarButtonPressed)],
        [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(updateBarButtonPressed)],
        [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addBarButtonPressed)]
    ];
}

- (void)viewWillAppear:(BOOL)animated {
    [Person setupPeople];
    
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
}

#pragma mark - NNFetchedResultsControllerDiffAdapterDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeContentWithDiff:(NNSectionsDiff *)diff {
    [self reloadWithDiff:diff];
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

- (void)reloadWithDiff:(NNSectionsDiff *)diff {
}

@end
