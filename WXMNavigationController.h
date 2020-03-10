//
//  WXMNavigationController.h
//  WXMNavigationBar
//
//  Created by Listen on 2018/3/23.
//

#import <UIKit/UIKit.h>
#import "UIViewController+WXM.h"

/** 导航控制器 */
@interface WXMNavigationController : UINavigationController
- (void)updateNavigationBarForViewController:(UIViewController *)vc;
@end

/** 导航分类 */
@interface UINavigationController (UINavigationBar) <UINavigationBarDelegate>
@end

/** 导航代理 */
@protocol WXMNavigationTransitionProtocol <NSObject>
- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)pan;
@end
