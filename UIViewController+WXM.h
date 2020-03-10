//
//  UIViewController+WXM.h
//  WXMNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WXM)

@property (nonatomic, assign) IBInspectable BOOL wn_blackBarStyle;

/**  导航栏样式 */
@property (nonatomic, assign) UIBarStyle wn_barStyle;

/** 导航栏背景颜色 */
@property (nonatomic, strong) IBInspectable UIColor *wn_barTintColor;

/** 导航栏背景图片 */
@property (nonatomic, strong) IBInspectable UIImage *wn_barImage;

/** 导航栏按钮颜色 */
@property (nonatomic, strong) IBInspectable UIColor *wn_tintColor;

/** 导航栏标题属性 */
@property (nonatomic, strong) NSDictionary *wn_titleTextAttributes;

/** 导航栏背景透明度 */
@property (nonatomic, assign) IBInspectable float wn_barAlpha;

/** 是否隐藏导航栏 */
@property (nonatomic, assign) IBInspectable BOOL wn_barHidden;

/** 是否隐藏导航栏下面的阴影 */
@property (nonatomic, assign) IBInspectable BOOL wn_barShadowHidden;

/** 当前页面是否可以右滑返回，默认是 YES */
@property (nonatomic, assign) IBInspectable BOOL wn_swipeBackEnabled;

/** 是否可以点击返回按钮返回 */
/** @property (nonatomic, assign) IBInspectable BOOL wn_clickBackEnabled; */

/**  computed */
@property (nonatomic, assign, readonly) float wn_computedBarShadowAlpha;
@property (nonatomic, strong, readonly) UIColor *wn_computedBarTintColor;
@property (nonatomic, strong, readonly) UIImage *wn_computedBarImage;

/**  这个属性是内部使用的 */
@property (nonatomic, strong) UIBarButtonItem *wn_backBarButtonItem;
@property (nonatomic, assign) BOOL wn_extendedLayoutDidSet;

- (void)wn_setNeedsUpdateNavigationBar;

@end
