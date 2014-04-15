//
//  PeopleViewController.h
//  ArrayDiffExample
//
//  Created by Nick Tymchenko on 13/04/14.
//  Copyright (c) 2014 Nick Tymchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNSectionsDiff.h"
#import "Person.h"

@interface PeopleViewController : UIViewController

@property (nonatomic, readonly) BOOL usesFRC;

- (id)initWithFRC:(BOOL)usesFRC;


// For use in subclasses:
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleForSection:(NSUInteger)section;
- (Person *)personAtIndexPath:(NSIndexPath *)indexPath;

// Override in subclasses:
- (void)reloadWithDiff:(NNSectionsDiff *)diff;
- (NSString *)displayedNameAtIndexPath:(NSIndexPath *)indexPath;

@end
