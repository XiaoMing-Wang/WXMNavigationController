//
//  UIViewController+WXM.m
//  WXMNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import "UIViewController+WXM.h"
#import <objc/runtime.h>
#import "WXMNavigationController.h"

@implementation UIViewController (WXM)

- (BOOL)wn_blackBarStyle {
    return self.wn_barStyle == UIBarStyleBlack;
}

- (void)setWn_blackBarStyle:(BOOL)wn_blackBarStyle {
    self.wn_barStyle = wn_blackBarStyle ? UIBarStyleBlack : UIBarStyleDefault;
}

- (UIBarStyle)wn_barStyle {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return [obj integerValue];
    }
    return [UINavigationBar appearance].barStyle;
}

- (void)setWn_barStyle:(UIBarStyle)wn_barStyle {
    objc_setAssociatedObject(self, @selector(wn_barStyle), @(wn_barStyle), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIColor *)wn_barTintColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWn_barTintColor:(UIColor *)tintColor {
    if (CGColorEqualToColor(tintColor.CGColor, [UIColor clearColor].CGColor)) self.wn_barShadowHidden = YES;
    objc_setAssociatedObject(self, @selector(wn_barTintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)wn_barImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWn_barImage:(UIImage *)image {
    objc_setAssociatedObject(self, @selector(wn_barImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)wn_tintColor {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ?: [UINavigationBar appearance].tintColor;
}

- (void)setWn_tintColor:(UIColor *)tintColor {
    objc_setAssociatedObject(self, @selector(wn_tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)wn_titleTextAttributes {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) {
        return obj;
    }
    
    UIBarStyle barStyle = self.wn_barStyle;
    NSDictionary *attributes = [UINavigationBar appearance].titleTextAttributes;
    if (attributes) {
        if (![attributes objectForKey:NSForegroundColorAttributeName]) {
            NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
            if (barStyle == UIBarStyleBlack) {
                [mutableAttributes addEntriesFromDictionary:@{ NSForegroundColorAttributeName: UIColor.whiteColor }];
            } else {
                [mutableAttributes addEntriesFromDictionary:@{ NSForegroundColorAttributeName: UIColor.blackColor }];
            }
            return mutableAttributes;
        }
        return attributes;
    }
    
    if (barStyle == UIBarStyleBlack) {
        return @{ NSForegroundColorAttributeName: UIColor.whiteColor };
    } else {
        return @{ NSForegroundColorAttributeName: UIColor.blackColor };
    }
}

- (void)setWn_titleTextAttributes:(NSDictionary *)attributes {
    objc_setAssociatedObject(self, @selector(wn_titleTextAttributes), attributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIBarButtonItem *)wn_backBarButtonItem {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWn_backBarButtonItem:(UIBarButtonItem *)backBarButtonItem {
    objc_setAssociatedObject(self, @selector(wn_backBarButtonItem), backBarButtonItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wn_extendedLayoutDidSet {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setWn_extendedLayoutDidSet:(BOOL)didSet {
    objc_setAssociatedObject(self, @selector(wn_extendedLayoutDidSet), @(didSet), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)wn_barAlpha {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (self.wn_barHidden) {
        return 0;
    }
    return obj ? [obj floatValue] : 1.0f;
}

- (void)setWn_barAlpha:(float)alpha {
    objc_setAssociatedObject(self, @selector(wn_barAlpha), @(alpha), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)wn_barHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : NO;
}

- (void)setWn_barHidden:(BOOL)hidden {
    if (hidden) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIView new]];
        self.navigationItem.titleView = [UIView new];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.titleView = nil;
    }
    objc_setAssociatedObject(self, @selector(wn_barHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)wn_barShadowHidden {
    id obj = objc_getAssociatedObject(self, _cmd);
    return  self.wn_barHidden || obj ? [obj boolValue] : NO;
}

- (void)setWn_barShadowHidden:(BOOL)hidden {
    objc_setAssociatedObject(self, @selector(wn_barShadowHidden), @(hidden), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)wn_backInteractive {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setWn_backInteractive:(BOOL)interactive {
    objc_setAssociatedObject(self, @selector(wn_backInteractive), @(interactive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)wn_swipeBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setWn_swipeBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(wn_swipeBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)wn_clickBackEnabled {
    id obj = objc_getAssociatedObject(self, _cmd);
    return obj ? [obj boolValue] : YES;
}

- (void)setWn_clickBackEnabled:(BOOL)enabled {
    objc_setAssociatedObject(self, @selector(wn_clickBackEnabled), @(enabled), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)wn_computedBarShadowAlpha {
    return  self.wn_barShadowHidden ? 0 : self.wn_barAlpha;
}

- (UIImage *)wn_computedBarImage {
    UIImage *image = self.wn_barImage;
    if (!image) {
        if (self.wn_barTintColor) {
            return nil;
        }
        return [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    }
    return image;
}

- (UIColor *)wn_computedBarTintColor {
    if (self.wn_barImage) {
        return nil;
    }
    UIColor *color = self.wn_barTintColor;
    if (!color) {
        if ([[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]) {
            return nil;
        }
        if ([UINavigationBar appearance].barTintColor) {
            color = [UINavigationBar appearance].barTintColor;
        } else {
            color = [UINavigationBar appearance].barStyle == UIBarStyleDefault ?
            [UIColor colorWithRed:247 / 255.0
                            green:247 /255.0
                             blue:247 /255.0 alpha:0.8]:
            [UIColor colorWithRed:28 / 255.0
                            green:28 / 255.0
                             blue:28 / 255.0 alpha:0.729];
        }
    }
    return color;
}

- (void)wn_setNeedsUpdateNavigationBar {
    if (self.navigationController && [self.navigationController isKindOfClass:[WXMNavigationController class]]) {
        WXMNavigationController *nav = (WXMNavigationController *) self.navigationController;
        [nav updateNavigationBarForViewController:self];
    }
}

@end
