//
//  TabbarUtil.h
//  eCloud
//  和程序使用的tabbar有关的工具类
//  Created by shisuping on 15-10-21.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioPlayForIOS6;

@interface TabbarUtil : NSObject
//获取tabbarController引用
+ (UITabBarController *)getTabbarController;

//保存tabbarcontroller引用
+ (void)setTabbarController:(UITabBarController *)_tabbarController;

//对应tab上的未读数是否已显示
//+ (BOOL)isDidShowTabbarBageWithIndex:(int)index;

//设置tabbar badge
+ (void)setTabbarBage:(NSString *)badgeValue andTabbarIndex:(int)index;

//选中我的界面
+ (void)showMyPage;

//点击轻应用通知时，需要根据通知带的信息确定是直接打开URL还是打开轻应用的首页，还是什么都不做
+ (void)saveStartAppInfo:(NSDictionary *)appInfo;

//自动打开代办列表
+ (void)autoOpenAgentList;

//选中会话列表界面
+ (void)showChatPage;

//判断当被从群组中移除时，是否需要弹框提示
+ (BOOL)needAlertWhenRemoveFromGroup:(NSString *)grpId;

//弹出被移除提示，确定后回到会话列表界面
+ (void)backToRootContact;

//是否正在显示泰禾首页
+ (BOOL)displayTaiHeHomePage;

//刷新工作圈界面
+ (void)refreshFoundInterface;


/**
 获取会话列表标签页栈里目前显示的是哪个VC

 @return 目前显示的VC
 */
+ (UIViewController *)getConvTabTopVC;


@end
