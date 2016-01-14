ArrayDiff
=========
You might very well be familiar with a whole array diff concept, but here's a quick intro.

Let's say we are building a cat app. To keep things simple, let's have a `Cat` model object class like this:

```
@interface Cat : NSObject

@property (nonatomic, readonly) NSString *uid;

@property (nonatomic, readonly) NSString *name;

+ (instancetype)catWithUid:(NSString *)uid name:(NSString *)name;

@end
```

Somewhere in the app we'd have a list of cats, typically displayed via `UITableView` or `UICollectionView`. It's all straightforward until we have to animate an update. To pull this off, we need to know which items exactly were deleted, inserted, changed or moved. Here is how we can do this:

```
NSArray<Cat *> *catsBefore = @[ ... ];
NSArray<Cat *> *catsAfter = @[ ... ];
    
NNSectionsDiffCalculator *diffCalculator = [[NNSectionsDiffCalculator alloc] init];
diffCalculator.objectIdBlock = ^(Cat *cat) {
    return cat.uid;
};
    
NNSectionsDiff *diff = [diffCalculator calculateDiffForSingleSectionObjectsBefore:catsBefore andAfter:catsAfter];

// The diff object now contains all needed info about mutated indexPaths.
// The easiest way to apply it to UITableView or UICollectionView is a bunch of category methods:

[self.tableView reloadWithSectionsDiff:diff];
```

That's pretty much it! The reloading routine is highly customizable and takes care of numerous UIKit quirks & bugs which may cause crashes. 

Feel free to check out the demo project. A more detailed guide is hopefully coming soon :)
