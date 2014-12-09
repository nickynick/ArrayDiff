//
//  Item.h
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString *name;

@property (nonatomic, readonly) NSString *sectionTitle;

+ (NSManagedObjectContext *)managedObjectContext;
+ (NSFetchRequest *)requestForSortedItems;

+ (void)setupItemsWithNames:(NSArray *)names;
+ (void)addRandomItem;
+ (void)updateRandomItems;
+ (void)deleteRandomItem;

+ (Item *)existingItemWithName:(NSString *)name;

+ (NSArray *)fetchSortedItemSections;

@end
