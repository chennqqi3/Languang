//
//  GXViewController.h
//  test11
//
//  Created by Pain on 14-7-23.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GXViewController : UITabBarController

/**
 对应index的tabbar按钮上显示未读数

 @param bageValue 未读个数
 @param index     tabbar上的按钮索引
 */
- (void)setTabarbadgeValue:(NSString *)bageValue withIndex:(NSInteger)index;//设置tabar提示

/**
 对应index的tabbar按钮上是否已显示了未读数

 @param index  指定tabbar上的按钮索引

 @return YES:未读数已显示   NO:未读数没有显示
 */
//- (BOOL)isDidShowTabarbadgeWithIndex:(NSInteger)index;

/**
 隐藏tabbar
 */
- (void)hideTabar;

/**
 显示tabbar
 */
- (void)showTabar;

/**
 显示会话界面
 */
- (void)showChatPage;

/**
 显示办公界面
 */
- (void)showMyPage;

/**
 递归显示子视图以及对应的层级

 @param view 子视图对象
 @param i    子视图对应的层级
 */
+ (void)displaySubViewOfView:(UIView *)view andLevel:(int)i;

- (void)activationTabbar;
@end
