//
//  WXMNavigationController.m
//  WXMNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "WXMNavigationController.h"
#import "UIViewController+WXM.h"
#import "WXMNavigationBar.h"

/** 图片是否一致 */
BOOL isImageEqual(UIImage *image1, UIImage *image2) {
    if (image1 == image2) {
        return YES;
    }
    if (image1 && image2) {
        NSData *data1 = UIImagePNGRepresentation(image1);
        NSData *data2 = UIImagePNGRepresentation(image2);
        BOOL result = [data1 isEqual:data2];
        return result;
    }
    return NO;
}

/** 是否需要动画切换导航颜色 */
BOOL shouldShowFake(UIViewController *vc, UIViewController *from, UIViewController *to) {
    if (vc != to ) {
        return NO;
    }
    
    if (from.wn_computedBarImage && to.wn_computedBarImage && isImageEqual(from.wn_computedBarImage, to.wn_computedBarImage)) {
        // have the same image
        if (ABS(from.wn_barAlpha - to.wn_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    if (!from.wn_computedBarImage && !to.wn_computedBarImage && [from.wn_computedBarTintColor.description isEqual:to.wn_computedBarTintColor.description]) {
        // no images, and the colors are the same
        if (ABS(from.wn_barAlpha - to.wn_barAlpha) > 0.1) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

BOOL colorHasAlphaComponent(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green= 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}

BOOL imageHasAlphaChannel(UIImage *image) {
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

/** 界面顶部适配 */
void adjustLayout(UIViewController *vc) {
    BOOL isTranslucent = vc.wn_barHidden || vc.wn_barAlpha < 1.0;
    if (!isTranslucent) {
        UIImage *image = vc.wn_computedBarImage;
        if (image) {
            isTranslucent = imageHasAlphaChannel(image);
        } else {
            UIColor *color = vc.wn_computedBarTintColor;
            isTranslucent = colorHasAlphaComponent(color);
        }
    }
    
    if (isTranslucent || vc.extendedLayoutIncludesOpaqueBars) {
        vc.edgesForExtendedLayout |= UIRectEdgeTop;
    } else {
        vc.edgesForExtendedLayout &= ~UIRectEdgeTop;
    }
    
    if (vc.wn_barHidden) {
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets insets = vc.additionalSafeAreaInsets;
            float height = vc.navigationController.navigationBar.bounds.size.height;
            vc.additionalSafeAreaInsets = UIEdgeInsetsMake(-height + insets.top, insets.left, insets.bottom, insets.right);
        }
    }
}

UIColor* blendColor(UIColor *from, UIColor *to, float percent) {
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed =  fromRed + (toRed - fromRed) * fminf(1, percent * 4) ;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * fminf(1, percent * 4);
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * fminf(1, percent * 4);
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * fminf(1, percent * 4);
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}

/** 导航代理 */
@interface WXMNavigationControllerDelegate : UIScreenEdgePanGestureRecognizer
<UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<UINavigationControllerDelegate> proxiedDelegate;
@property (nonatomic, weak, readonly) WXMNavigationController *nav;
- (instancetype)initWithNavigationController:(WXMNavigationController *)navigationController;
@end

/** 导航控制器 */
@interface WXMNavigationController ()
@property (nonatomic, readonly) WXMNavigationBar *navigationBar;
@property (nonatomic, strong) UIVisualEffectView *fromFakeBar;
@property (nonatomic, strong) UIVisualEffectView *toFakeBar;
@property (nonatomic, strong) UIImageView *fromFakeShadow;
@property (nonatomic, strong) UIImageView *toFakeShadow;
@property (nonatomic, strong) UIImageView *fromFakeImageView;
@property (nonatomic, strong) UIImageView *toFakeImageView;
@property (nonatomic, weak) UIViewController *poppingViewController;
@property (nonatomic, assign) BOOL transitional;
@property (nonatomic, strong) WXMNavigationControllerDelegate *navigationDelegate;
- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc;
- (void)updateNavigationBarShadowImageIAlphaForViewController:(UIViewController *)vc;
- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc;
- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController *)to;
- (void)clearFake;
- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar;
- (UIGestureRecognizer *)superInteractivePopGestureRecognizer;
@end

@implementation WXMNavigationControllerDelegate

- (instancetype)initWithNavigationController:(WXMNavigationController *)nav {
    if (self = [super init]) {
        _nav = nav;
        _nav.interactivePopGestureRecognizer.delegate = (id)self;
        _nav.interactivePopGestureRecognizer.enabled = YES;
    }
    return self;
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    WXMNavigationController *nav = (WXMNavigationController *) navigationController;
    nav.transitional = YES;
          
    /** 顶部位置适配 */
    if (!viewController.wn_extendedLayoutDidSet) {
        adjustLayout(viewController);
        viewController.wn_extendedLayoutDidSet = YES;
    }
        
    id<UIViewControllerTransitionCoordinator> coordinator = nav.transitionCoordinator;
    if (coordinator) {
        [self showViewController:viewController withCoordinator:coordinator];
    } else {
        if (!animated && nav.childViewControllers.count > 1) {
            UIViewController *lastButOne = nav.childViewControllers[nav.childViewControllers.count - 2];
            if (shouldShowFake(viewController, lastButOne, viewController)) {
                [nav showFakeBarFrom:lastButOne to:viewController];
                return;
            }
        }
        [nav updateNavigationBarForViewController:viewController];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    WXMNavigationController *nav = (WXMNavigationController *) navigationController;
    nav.transitional = NO;
    nav.interactivePopGestureRecognizer.enabled = (nav.viewControllers.count > 1 && self.nav.topViewController.wn_swipeBackEnabled);
    
    if (!animated) {
        [nav updateNavigationBarForViewController:viewController];
        [nav clearFake];
    }
    nav.poppingViewController = nil;
}

- (void)showViewController:(UIViewController *_Nonnull)viewController
           withCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIViewController *from = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *to = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [self.nav updateNavigationBarAnimatedForViewController:viewController];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        BOOL shouldFake = shouldShowFake(viewController, from, to);
        if (shouldFake) {
            [self.nav updateNavigationBarAnimatedForViewController:viewController];
            [self.nav showFakeBarFrom:from to:to];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
        self.nav.transitional = NO;
        self.nav.poppingViewController = nil;
        if (context.isCancelled) {
            if (to == viewController) [self.nav updateNavigationBarForViewController:from];
        } else {
            [self.nav updateNavigationBarForViewController:viewController];
        }
        if (to == viewController) [self.nav clearFake];
    }];
}

@end

#pragma mark 导航栏
#pragma mark 导航栏
#pragma mark 导航栏

@implementation WXMNavigationController
@dynamic navigationBar;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[WXMNavigationBar class] toolbarClass:nil]) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass {
    return [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
}

- (instancetype)init {
    return [super initWithNavigationBarClass:[WXMNavigationBar class] toolbarClass:nil];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[WXMNavigationControllerDelegate class]] || !self.navigationDelegate) {
        [super setDelegate:delegate];
    } else {
        self.navigationDelegate.proxiedDelegate = delegate;
    }
}

- (UIGestureRecognizer *)superInteractivePopGestureRecognizer {
    return [super interactivePopGestureRecognizer];
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UINavigationBar appearance].shadowImage];
    self.navigationDelegate = [[WXMNavigationControllerDelegate alloc] initWithNavigationController:self];
    
    /** 转场动画用 */
    self.navigationDelegate.proxiedDelegate = self.delegate;
    self.delegate = self.navigationDelegate;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
    if (!coordinator) [self updateNavigationBarForViewController:self.topViewController];
}

/** 重置一下导航栏上面的视图透明度 */
//- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
//    if (self.viewControllers.count > 1 && self.topViewController.navigationItem == item ) {
//        if (!self.topViewController.wn_clickBackEnabled) {
//            [self resetSubviewsInNavBar:self.navigationBar];
//            return NO;
//        }
//    }
//    return [super navigationBar:navigationBar shouldPopItem:item];
//}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    return [super popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    self.poppingViewController = self.topViewController;
    return [super popToRootViewControllerAnimated:animated];
}

/** 重置导航栏上的view的透明度 */
//- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
//    if (@available(iOS 11, *)) {
//        // empty
//    } else {
//        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
//        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView *subview, NSUInteger idx, BOOL *stop) {
//            if (subview.alpha < 1.0) {
//                [UIView animateWithDuration:.25 animations:^{ subview.alpha = 1.0; }];
//            }
//        }];
//    }
//}

- (void)updateNavigationBarForViewController:(UIViewController *)vc {
    [self updateNavigationBarAlphaForViewController:vc];
    [self updateNavigationBarColorOrImageForViewController:vc];
    [self updateNavigationBarShadowImageIAlphaForViewController:vc];
    [self updateNavigationBarAnimatedForViewController:vc];
}

/** 设置导航栏为顶部的vc的属性 */
- (void)updateNavigationBarAnimatedForViewController:(UIViewController *)vc {
    self.navigationBar.tintColor = vc.wn_tintColor;
    self.navigationBar.barStyle = vc.wn_barStyle;
    self.navigationBar.titleTextAttributes = vc.wn_titleTextAttributes;
}

/** 设置导航栏透明度 */
- (void)updateNavigationBarAlphaForViewController:(UIViewController *)vc {
    if (vc.wn_computedBarImage) {
        self.navigationBar.fakeView.alpha = 0;
        self.navigationBar.backgroundImageView.alpha = vc.wn_barAlpha;
    } else {
        self.navigationBar.fakeView.alpha = vc.wn_barAlpha;
        self.navigationBar.backgroundImageView.alpha = 0;
    }
    self.navigationBar.shadowImageView.alpha = vc.wn_computedBarShadowAlpha;
}

- (void)updateNavigationBarColorOrImageForViewController:(UIViewController *)vc {
    self.navigationBar.barTintColor = vc.wn_computedBarTintColor;
    self.navigationBar.backgroundImageView.image = vc.wn_computedBarImage;
}

- (void)updateNavigationBarShadowImageIAlphaForViewController:(UIViewController *)vc {
    self.navigationBar.shadowImageView.alpha = vc.wn_computedBarShadowAlpha;
}

- (void)showFakeBarFrom:(UIViewController *)from to:(UIViewController * _Nonnull)to {
    [UIView setAnimationsEnabled:NO];
    self.navigationBar.fakeView.alpha = 0;
    self.navigationBar.shadowImageView.alpha = 0;
    self.navigationBar.backgroundImageView.alpha = 0;
    [self showFakeBarFrom:from];
    [self showFakeBarTo:to];
    [UIView setAnimationsEnabled:YES];
}

- (void)showFakeBarFrom:(UIViewController *)from {
    self.fromFakeImageView.image = from.wn_computedBarImage;
    self.fromFakeImageView.alpha = from.wn_barAlpha;
    self.fromFakeImageView.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeImageView];

    self.fromFakeBar.subviews.lastObject.backgroundColor = from.wn_computedBarTintColor;
    self.fromFakeBar.alpha = from.wn_barAlpha == 0 || from.wn_computedBarImage ? 0.01:from.wn_barAlpha;
    if (from.wn_barAlpha == 0 || from.wn_computedBarImage) {
        self.fromFakeBar.subviews.lastObject.alpha = 0.01;
    }
    self.fromFakeBar.frame = [self fakeBarFrameForViewController:from];
    [from.view addSubview:self.fromFakeBar];

    self.fromFakeShadow.alpha = from.wn_computedBarShadowAlpha;
    self.fromFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.fromFakeBar.frame];
    [from.view addSubview:self.fromFakeShadow];
}

- (void)showFakeBarTo:(UIViewController * _Nonnull)to {
    self.toFakeImageView.image = to.wn_computedBarImage;
    self.toFakeImageView.alpha = to.wn_barAlpha;
    self.toFakeImageView.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeImageView];

    self.toFakeBar.subviews.lastObject.backgroundColor = to.wn_computedBarTintColor;
    self.toFakeBar.alpha = to.wn_computedBarImage ? 0 : to.wn_barAlpha;
    self.toFakeBar.frame = [self fakeBarFrameForViewController:to];
    [to.view addSubview:self.toFakeBar];

    self.toFakeShadow.alpha = to.wn_computedBarShadowAlpha;
    self.toFakeShadow.frame = [self fakeShadowFrameWithBarFrame:self.toFakeBar.frame];
    [to.view addSubview:self.toFakeShadow];
}

- (UIVisualEffectView *)fromFakeBar {
    if (!_fromFakeBar) {
        _fromFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _fromFakeBar;
}

- (UIVisualEffectView *)toFakeBar {
    if (!_toFakeBar) {
        _toFakeBar = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _toFakeBar;
}

- (UIImageView *)fromFakeImageView {
    if (!_fromFakeImageView) {
        _fromFakeImageView = [[UIImageView alloc] init];
    }
    return _fromFakeImageView;
}

- (UIImageView *)toFakeImageView {
    if (!_toFakeImageView) {
        _toFakeImageView = [[UIImageView alloc] init];
    }
    return _toFakeImageView;
}

- (UIImageView *)fromFakeShadow {
    if (!_fromFakeShadow) {
        _fromFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _fromFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _fromFakeShadow;
}

- (UIImageView *)toFakeShadow {
    if (!_toFakeShadow) {
        _toFakeShadow = [[UIImageView alloc] initWithImage:self.navigationBar.shadowImageView.image];
        _toFakeShadow.backgroundColor = self.navigationBar.shadowImageView.backgroundColor;
    }
    return _toFakeShadow;
}

- (void)clearFake {
    [_fromFakeBar removeFromSuperview];
    [_toFakeBar removeFromSuperview];
    [_fromFakeShadow removeFromSuperview];
    [_toFakeShadow removeFromSuperview];
    [_fromFakeImageView removeFromSuperview];
    [_toFakeImageView removeFromSuperview];
    _fromFakeBar = nil;
    _toFakeBar = nil;
    _fromFakeShadow = nil;
    _toFakeShadow = nil;
    _fromFakeImageView = nil;
    _toFakeImageView = nil;
}

- (CGRect)fakeBarFrameForViewController:(UIViewController *)vc {
    UIView *back = self.navigationBar.subviews[0];
    CGRect frame = [self.navigationBar convertRect:back.frame toView:vc.view];
    frame.origin.x = 0;
    if ((vc.edgesForExtendedLayout & UIRectEdgeTop) == 0) {
        frame.origin.y = -frame.size.height;
    }

    /** fix issue for pushed to UIViewController whose root view is UIScrollView. */
    if ([vc.view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollview = (UIScrollView *)vc.view;
        scrollview.clipsToBounds = NO;
        if (scrollview.contentOffset.y == 0) {
            frame.origin.y = -frame.size.height;
        }
    }
    return frame;
}

- (CGRect)fakeShadowFrameWithBarFrame:(CGRect)frame {
    return CGRectMake(frame.origin.x, frame.size.height + frame.origin.y - 0.5, frame.size.width, 0.5);
}

@end

