//
//  Person.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "Person.h"
#import "AppDelegate.h"

@implementation Person

@dynamic name;

- (NSString *)sectionTitle {
    return [[self.name substringToIndex:1] uppercaseString];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

+ (void)setupPeopleWithNames:(NSArray *)names {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *existingPeople = [context executeFetchRequest:[Person requestForSortedPeople] error:NULL];
    for (Person *person in existingPeople) {
        [context deleteObject:person];
    }
    
    for (NSString *name in names) {
        Person *person = [[Person alloc] initWithEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        person.name = name;
    }
    
    [context save:NULL];
}

+ (void)addRandomPerson {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Person *person = [[Person alloc] initWithEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    person.name = [self randomName];
    [context save:NULL];
}

+ (void)updateRandomPeople {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *existingPeople = [context executeFetchRequest:[Person requestForSortedPeople] error:NULL];
    if ([existingPeople count] == 0) {
        return;
    }
    
    NSUInteger count = 1 + arc4random_uniform(4);
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger randomIndex = arc4random_uniform((int32_t)[existingPeople count]);
        Person *person = existingPeople[randomIndex];
        person.name = [self randomName];
    }
    
    [context save:NULL];
}

+ (void)deleteRandomPerson {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *existingPeople = [context executeFetchRequest:[Person requestForSortedPeople] error:NULL];
    if ([existingPeople count] == 0) {
        return;
    }
    
    NSUInteger randomIndex = arc4random_uniform((int32_t)[existingPeople count]);
    Person *person = existingPeople[randomIndex];
    [context deleteObject:person];
    
    [context save:NULL];
}

+ (Person *)existingPersonWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", name];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:NULL];
    return [result firstObject];
}

+ (NSFetchRequest *)requestForSortedPeople {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ];
    return request;
}

+ (NNArraySections *)fetchSortedPeopleGroupedIntoSections {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *sortedPeople = [context executeFetchRequest:[Person requestForSortedPeople] error:NULL];

    NSMutableArray *sectionKeys = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray array];
    NSString *currentSectionTitle = nil;
    NSMutableArray *currentSection = nil;
    
    for (Person *person in sortedPeople) {
        if (![person.sectionTitle isEqualToString:currentSectionTitle]) {
            if (currentSectionTitle) {
                [sectionKeys addObject:currentSectionTitle];
                [sections addObject:currentSection];
            }
            currentSectionTitle = person.sectionTitle;
            currentSection = [NSMutableArray array];
        }
        
        [currentSection addObject:person];
    }
    
    if (currentSectionTitle) {
        [sectionKeys addObject:currentSectionTitle];
        [sections addObject:currentSection];
    }
    
    return [[NNArraySections alloc] initWithSectionKeys:sectionKeys sections:sections];
}

#pragma mark - Private

+ (NSString *)randomName {
    char letter = 'A' + arc4random_uniform(5);
    char digit1 = '0' + arc4random_uniform(10);
    char digit2 = '0' + arc4random_uniform(10);
    return [NSString stringWithFormat:@"%c%c%c", letter, digit1, digit2];
}

@end
