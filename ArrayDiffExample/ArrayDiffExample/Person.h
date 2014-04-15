//
//  Person.h
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NNArraySections.h"

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, readonly) NSString *sectionTitle;

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)requestForSortedPeople;

+ (void)setupPeople;
+ (void)addRandomPerson;
+ (void)updateRandomPeople;
+ (void)deleteRandomPerson;

+ (Person *)existingPersonWithName:(NSString *)name;

+ (NNArraySections *)fetchSortedPeopleGroupedIntoSections;

@end
