//
//  Item.m
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import "Item.h"
#import "AppDelegate.h"

@implementation Item

@dynamic name;

- (NSString *)sectionTitle {
    return [[self.name substringToIndex:1] uppercaseString];
}

+ (NSManagedObjectContext *)managedObjectContext {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

+ (void)setupItemsWithNames:(NSArray *)names {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *existingItems = [context executeFetchRequest:[Item requestForSortedItems] error:NULL];
    for (Item *item in existingItems) {
        [context deleteObject:item];
    }
    
    for (NSString *name in names) {
        Item *item = [[Item alloc] initWithEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        item.name = name;
    }
    
    [context save:NULL];
}

+ (void)addRandomItem {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Item *item = [[Item alloc] initWithEntity:[NSEntityDescription entityForName:@"Item" inManagedObjectContext:context] insertIntoManagedObjectContext:context];
    item.name = [self randomName];
    [context save:NULL];
}

+ (void)updateRandomItems {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSArray *existingItems = [context executeFetchRequest:[Item requestForSortedItems] error:NULL];
    if ([existingItems count] == 0) {
        return;
    }
    
    NSUInteger count = 1 + arc4random_uniform(4);
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger randomIndex = arc4random_uniform((int32_t)[existingItems count]);
        Item *item = existingItems[randomIndex];
        item.name = [self randomName];
    }
    
    [context save:NULL];
}

+ (void)deleteRandomItem {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *existingItems = [context executeFetchRequest:[Item requestForSortedItems] error:NULL];
    if ([existingItems count] == 0) {
        return;
    }
    
    NSUInteger randomIndex = arc4random_uniform((int32_t)[existingItems count]);
    Item *item = existingItems[randomIndex];
    [context deleteObject:item];
    
    [context save:NULL];
}

+ (Item *)existingItemWithName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"name", name];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:NULL];
    return [result firstObject];
}

+ (NSFetchRequest *)requestForSortedItems {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)] ];
    return request;
}

+ (NSArray *)fetchSortedItemSections {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *sortedItems = [context executeFetchRequest:[Item requestForSortedItems] error:NULL];

    NSMutableDictionary *sectionsByKeys = [NSMutableDictionary dictionary];
    NSMutableOrderedSet *sectionKeys = [NSMutableOrderedSet orderedSet];
    
    for (Item *item in sortedItems) {
        [sectionKeys addObject:item.sectionTitle];
        
        NNMutableSection *section = sectionsByKeys[item.sectionTitle];
        if (!section) {
            section = [[NNMutableSection alloc] initWithKey:item.sectionTitle objects:nil];
            sectionsByKeys[item.sectionTitle] = section;
        }
        [section.objects addObject:item];
    }
    
    NSMutableArray *sections = [NSMutableArray array];
    for (NSString *sectionKey in sectionKeys) {
        [sections addObject:sectionsByKeys[sectionKey]];
    }
    
    return sections;
}

#pragma mark - Private

+ (NSString *)randomName {
    char letter = 'A' + arc4random_uniform(5);
    char digit1 = '0' + arc4random_uniform(10);
    char digit2 = '0' + arc4random_uniform(10);
    return [NSString stringWithFormat:@"%c%c%c", letter, digit1, digit2];
}

@end
