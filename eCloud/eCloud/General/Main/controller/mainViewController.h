//
//  mainViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//  app主视图控制器

#import <UIKit/UIKit.h>
@class GXViewController;
@interface mainViewController : UIViewController<UITabBarControllerDelegate,UITabBarDelegate>

/**
 (已作废)
 返回到上一个界面
 */
-(void)back;

/**
 返回到登录界面
 */
-(void)backRoot;

/**
 根据ios版本是否支持侧滑功能(ios7及以后的版本才有的这个代理方法)，返回对应的nav导航控制器
 
 @param root 要进行处理的控制器对象
 
 @return 自定义导航控制器
 */
+ (UINavigationController *)getNavigationVCwithRootVC:(UIViewController *)root;

/**
 显示水印
 */
- (void)showWaterMark;

/**
 隐藏水印
 */
- (void)hideWaterMark;

@end
