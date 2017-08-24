//
//  CBNavigationController.h
//  eCloud
//
//  Created by shisuping on 14-12-21.
//  Copyright (c) 2014年  lyong. All rights reserved.
//  自定义导航控制器 ios7以后使用

#import <UIKit/UIKit.h>

@interface CBNavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/**
 重写系统的pushViewController方法

 @param viewController 即将进入的下一个控制器对象
 @param animated       是否需要动画
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 重写系统的popToViewController方法
 
 @param viewController 即将退回到的上一个控制器对象
 @param animated       是否需要动画
 */
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
/**
 重写系统的popToRootViewControllerAnimated方法
 
 @param animated       是否需要动画
 */
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

@end
