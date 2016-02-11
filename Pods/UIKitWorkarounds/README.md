UIKitWorkarounds
================

This repository is a collection of typical fixes & workarounds I find useful for various UIKit classes. While UIKit is a great framework, sometimes you bump into something that doesn't work exactly how it should. Thankfully, often it is possible to fix the behaviour without digging into the private APIs and shady stuff like that.

It's worth to note this isn't a typical "category bag" toolbelt. You'll not find the obligatory `UIColor+Hex` or `UIView+Geometry` categories here :) The goal is to fix the broken / poorly thought out stuff, and not to bring new features.

Without further ado, here's a quick overview of the modules.

  * [Interface orientation forwarding](#interface-orientation-forwarding)
  * [UINavigationController's status bar style](#uinavigationcontrollers-status-bar-style)
  * [UITableView / UICollectionView reloaders](#uitableview--uicollectionview-reloaders)

Interface orientation forwarding
--------------------------------

I've long been annoyed by the fact that the stock container view controllers don't automatically forward `supportedIntefaceOrientations` to their currently active child. We're supposed to use delegates for this, and this quickly turns into a mess - the moment you need to use a delegate for something else.

Two category methods are currently present to modify this behaviour and setup a proper child forwarding:

```
// Put this somewhere early in the app life cycle
[UINavigationController nn_setupCorrectInterfaceOrientationManagement];
[UITabBarController nn_setupCorrectInterfaceOrientationManagement];
```

UINavigationController's status bar style
-----------------------------------------

In your typical `UINavigationController` setup, the navigation bar sits on top of everything and forms a background for the application's status bar. Therefore, it makes perfect sense that status bar style should depend on the appearance of this particular navigation bar. In other words, you'd want to have a dark status bar over a light navigation bar and vice versa. 

This brings us to the category:

```
@interface UINavigationBar (NNStatusBarStyle)

@property (nonatomic, assign) UIStatusBarStyle nn_statusBarStyle UI_APPEARANCE_SELECTOR;

@end
```

The usage is very simple:

```
// Put this somewhere early to activate the behaviour
[UINavigationController nn_setupCorrectStatusBarStyleManagement];

[UINavigationBar appearance].nn_statusBarStyle = UIStatusBarStyleLightContent;
```

The important part of the implementation is to know when we should give up status bar style management. That is, if the navigation bar is currently hidden, then status bar style management is given to the top child view controller - because it's the one who's forming the status bar background now.

UITableView / UICollectionView reloaders
----------------------------------------

Unfortunately, `UITableView` and `UICollectionView` batch updates are broken. Likely being driven by the same engine behind the scenes, they suffer from a number of similar bugs which under certain unfortunate circumstances will lead to crashes or incorrect displayed data.

To deal with it, `NNTableViewReloader` and `NNCollectionViewReloader` classes come to rescue. Think of them as disposable wrappers around respective views, having the same reload API:

```
@interface NNCollectionViewReloader : NSObject

- (void)performUpdates:(void (^)())updates completion:(nullable void (^)())completion;

- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)reloadItemsAtIndexPathsWithCustomBlock:(NSArray<NSIndexPath *> *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

@end
```

You might have noticed an extra method, `reloadItemsAtIndexPathsWithCustomBlock:`. It lets you reload a cell using your own block which you may provide on reloader creation. This may be useful in various scenarios, one being a case where you'd like to move and reload the cell at the same time - normally this is not supported and leads to bad things.

The example usage:

```
NNTableViewReloader *reloader = [[NNTableViewReloader alloc] initWithTableView:self.tableView];

[reloader performUpdates:^{
    [reloader insertRowsAtIndexPaths:@[ ... ] withRowAnimation:UITableViewRowAnimationFade];
    [reloader deleteRowsAtIndexPaths:@[ ... ] withRowAnimation:UITableViewRowAnimationAutomatic];
    // etc.
} completion:nil];
```

A more detailed description of bugs taken care of (with live examples) is coming soon.
