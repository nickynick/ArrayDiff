//
//  UINavigationController+NNStatusBarStyle.m
//  UIKitWorkarounds
//
//  Created by Nick Tymchenko on 05/02/16.
//  Copyright © 2016 Nick Tymchenko. All rights reserved.
//

#import "UINavigationController+NNStatusBarStyle.h"
#import "NNSwizzlingUtils.h"
#import <objc/runtime.h>

@implementation UINavigationBar (NNStatusBarStyle)

#pragma mark - Public

static const char kStatusBarStyleKey;

- (UIStatusBarStyle)nn_statusBarStyle {
    return [objc_getAssociatedObject(self, &kStatusBarStyleKey) integerValue];
}

- (void)setNn_statusBarStyle:(UIStatusBarStyle)statusBarStyle {
    objc_setAssociatedObject(self, &kStatusBarStyleKey, @(statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Swizzling

+ (void)nn_statusBarStyle_swizzleMethods {
    // Make .window KVO-compliant, okay?
    
    [NNSwizzlingUtils swizzle:[UINavigationBar class] instanceMethod:@selector(willMoveToWindow:)
                   withMethod:@selector(nn_statusBarStyle_willMoveToWindow:)];
    
    [NNSwizzlingUtils swizzle:[UINavigationBar class] instanceMethod:@selector(didMoveToWindow)
                   withMethod:@selector(nn_statusBarStyle_didMoveToWindow)];
}

- (void)nn_statusBarStyle_willMoveToWindow:(UIWindow *)newWindow {
    [self nn_statusBarStyle_willMoveToWindow:newWindow];
    
    [self willChangeValueForKey:@"window"];
}

- (void)nn_statusBarStyle_didMoveToWindow {
    [self nn_statusBarStyle_didMoveToWindow];
    
    [self didChangeValueForKey:@"window"];
}

@end


@interface UINavigationController ()

@property (nonatomic, assign) BOOL nn_statusBarStyle_navigationBarHidden;

@property (nonatomic, assign, readonly) BOOL nn_statusBarStyle_isRemoteController;

@property (nonatomic, assign) BOOL nn_statusBarStyle_hasPendingAppearanceUpdate;

@end


@implementation UINavigationController (NNStatusBarStyle)

#pragma mark - Public

+ (void)nn_setupCorrectStatusBarStyleManagement {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self nn_statusBarStyle_swizzleMethods];
        [UINavigationBar nn_statusBarStyle_swizzleMethods];
    });
}

#pragma mark - Swizzling

+ (void)nn_statusBarStyle_swizzleMethods {
    Class aClass = [UINavigationController class];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(viewDidLoad)
                                         withMethod:@selector(nn_statusBarStyle_viewDidLoad)];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(childViewControllerForStatusBarStyle)
                                         withMethod:@selector(nn_statusBarStyle_childViewControllerForStatusBarStyle)];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(childViewControllerForStatusBarHidden)
                                         withMethod:@selector(nn_statusBarStyle_childViewControllerForStatusBarHidden)];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(preferredStatusBarStyle)
                                         withMethod:@selector(nn_statusBarStyle_preferredStatusBarStyle)];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(prefersStatusBarHidden)
                                         withMethod:@selector(nn_statusBarStyle_prefersStatusBarHidden)];
    
    [NNSwizzlingUtils swizzle:aClass instanceMethod:@selector(observeValueForKeyPath:ofObject:change:context:)
                                         withMethod:@selector(nn_statusBarStyle_observeValueForKeyPath:ofObject:change:context:)];
}

- (void)nn_statusBarStyle_viewDidLoad {
    [self nn_statusBarStyle_viewDidLoad];
    
    [self nn_statusBarStyle_setupTracking];
}

- (UIViewController *)nn_statusBarStyle_childViewControllerForStatusBarStyle {
    return [self nn_statusBarStyle_isInChargeOfStatusBar] ? nil : self.topViewController;
}

- (UIViewController *)nn_statusBarStyle_childViewControllerForStatusBarHidden {
    return [self nn_statusBarStyle_isInChargeOfStatusBar] ? nil : self.topViewController;
}

- (UIStatusBarStyle)nn_statusBarStyle_preferredStatusBarStyle {
    return self.navigationBar.nn_statusBarStyle;
}

- (BOOL)nn_statusBarStyle_prefersStatusBarHidden {
    if ([self isKindOfClass:[UIImagePickerController class]]) {
        if (((UIImagePickerController *)self).sourceType == UIImagePickerControllerSourceTypeCamera) {
            return YES;
        }
    }
    return NO;
}

- (void)nn_statusBarStyle_observeValueForKeyPath:(NSString *)keyPath
                                             ofObject:(id)object
                                               change:(NSDictionary<NSString *, id> *)change
                                              context:(void *)context {
    if (context == &kNavigationBarKVOContext) {
        self.nn_statusBarStyle_navigationBarHidden = [self nn_statusBarStyle_calculateIsNavigationBarHidden];
    } else {
        [self nn_statusBarStyle_observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Status bar logic

static char kNavigationBarKVOContext;

- (void)nn_statusBarStyle_setupTracking {
    // Here be dragons!
    // UIKit properties are not guaranteed to be KVO-compliant, but these actually work fine.
    // Not too likely, but it may break in the future, so we'll have to seek other options.
    
    [self.navigationBar addObserver:self forKeyPath:@"window" options:0 context:&kNavigationBarKVOContext];
    [self.navigationBar addObserver:self forKeyPath:@"layer.bounds" options:0 context:&kNavigationBarKVOContext];
    [self.navigationBar addObserver:self forKeyPath:@"layer.position" options:0 context:&kNavigationBarKVOContext];
    [self.navigationBar addObserver:self forKeyPath:@"alpha" options:0 context:&kNavigationBarKVOContext];
    [self.navigationBar addObserver:self forKeyPath:@"hidden" options:0 context:&kNavigationBarKVOContext];
    
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(nn_statusBarStyle_interactivePopGestureRecognizerChanged:)];
}

- (void)nn_statusBarStyle_interactivePopGestureRecognizerChanged:(UIGestureRecognizer *)recognizer {
    // There is a crazy bug related to interactive pop.
    // Navigation bar may become corrupt if we update status bar at the very start of a gesture, and then user cancels pop.
    // (Yeah, I know.)
    //
    // Why is this important? If you hide/show navigation bar in navigationController:willShowViewController:animated:
    // triggered by interactive pop, this is exactly what happens.
    
    if (recognizer.state != UIGestureRecognizerStateBegan && self.nn_statusBarStyle_hasPendingAppearanceUpdate) {
        self.nn_statusBarStyle_hasPendingAppearanceUpdate = NO;
            
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)nn_statusBarStyle_calculateIsNavigationBarHidden {
    // Why do we have to do all this instead of, e.g. swizzling setNavigationBarHidden:?
    //
    // There are private methods which are also being used for hiding navigation bar, so it's not reliable.
    // One example is UISearchController-related navigation bar animations.
    
    if (!self.navigationBar.window) {
        return YES;
    }
    
    if (self.navigationBar.hidden || self.navigationBar.alpha <= 0.01) {
        return YES;
    }
    
    CGRect intersectionRect = CGRectIntersection(self.view.bounds,
                                                 [self.view convertRect:self.navigationBar.bounds fromView:self.navigationBar]);
    
    BOOL isEmptyIntersection = (CGRectEqualToRect(intersectionRect, CGRectNull) ||
                                intersectionRect.size.width == 0 ||
                                intersectionRect.size.height == 0);
    
    if (isEmptyIntersection) {
        return YES;
    }
    
    return NO;
}

- (BOOL)nn_statusBarStyle_isInChargeOfStatusBar {
    if (self.nn_statusBarStyle_isRemoteController) {
        return YES;
    } else {
        return !self.nn_statusBarStyle_navigationBarHidden;
    }
}

- (BOOL)nn_statusBarStyle_checkIfRemoteController {
    // Remote view controllers, being in use since iOS 6, are another tricky case.
    // While they are subclasses of UINavigationController, in fact there's nothing of navigation controller in there.
    // The actual subviews come from the different process, so there's no navigation bar for us to observe.
    
    static NSArray<Class> *remoteControllerClasses;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remoteControllerClasses = [[self class] nn_statusBarStyle_remoteControllerClasses];
    });
    
    for (Class aClass in remoteControllerClasses) {
        if ([self isKindOfClass:aClass]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSArray<Class> *)nn_statusBarStyle_remoteControllerClasses {
    NSArray<NSString *> *classNames = @[ @"MFMailComposeViewController",
                                         @"MFMessageComposeViewController",
                                         @"GKFriendRequestComposeViewController" ];
    
    NSMutableArray<Class> *classes = [NSMutableArray array];
    for (NSString *className in classNames) {
        Class aClass = NSClassFromString(className);
        if (aClass) {
            [classes addObject:aClass];
        }
    }
    
    return [classes copy];
}

#pragma mark - Properties

static const char kNavigationBarHiddenKey;
static const char kIsRemoteControllerKey;
static const char kHasPendingAppearanceUpdateKey;

- (BOOL)nn_statusBarStyle_navigationBarHidden {
    return [objc_getAssociatedObject(self, &kNavigationBarHiddenKey) boolValue];
}

- (void)setNn_statusBarStyle_navigationBarHidden:(BOOL)navigationBarHidden {
    if (self.nn_statusBarStyle_navigationBarHidden == navigationBarHidden) {
        return;
    }
    
    objc_setAssociatedObject(self, &kNavigationBarHiddenKey, @(navigationBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.interactivePopGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        self.nn_statusBarStyle_hasPendingAppearanceUpdate = YES;
    }
}

- (BOOL)nn_statusBarStyle_isRemoteController {
    NSNumber *cachedResult = objc_getAssociatedObject(self, &kIsRemoteControllerKey);
    if (!cachedResult) {
        cachedResult = @([self nn_statusBarStyle_checkIfRemoteController]);
        objc_setAssociatedObject(self, &kIsRemoteControllerKey, cachedResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cachedResult.boolValue;
}

- (BOOL)nn_statusBarStyle_hasPendingAppearanceUpdate {
    return [objc_getAssociatedObject(self, &kHasPendingAppearanceUpdateKey) boolValue];
}

- (void)setNn_statusBarStyle_hasPendingAppearanceUpdate:(BOOL)hasPendingAppearanceUpdate {
    objc_setAssociatedObject(self, &kHasPendingAppearanceUpdateKey, @(hasPendingAppearanceUpdate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
