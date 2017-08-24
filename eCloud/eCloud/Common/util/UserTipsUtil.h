//
//  AlertUtil.h
//  eCloud
//  提示用户 请稍候 ，已转发，还要一些弹框提示 的工具类
//  Created by shisuping on 14-9-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define tips_no_connect @"未连接"

@interface UserTipsUtil : NSObject

//+ (void)showNoConnectAlert;

/**
 功能描述
 弹框提示用户 UIAlertView
 
 参数
 message:在提示框上显示的用户提示信息
 */
+ (void)showAlert:(NSString *)message;


/**
 弹框提示用户 UIAlertView

 @param title AlertView的标题
 @param message AlertView提示的内容
 */
+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message;


/**
 功能描述
 某些同步操作，需要用户等待，比如创建讨论组、设置为常用联系人等， LCLLoadingView
 
 参数
 message:用户等待时的显示的用户内容 内容不能太长，否则显示不全
 */
+ (void)showLoadingView:(NSString *)message;

/**
 功能描述
 同步操作有应答或者超时后，因此提示框
 
 */
+ (void)hideLoadingView;

/**
 功能描述
 弹出用户提示，过一会儿自动消失 
 
 参数
 message:提示消息内容
 autoDismiss: 是否自动消失，目前没有进行实际的处理
 
 */
+ (void)showAlert:(NSString *)message autoDimiss:(BOOL)autoDimiss;

/**
 查询时如果用户输入字符少于2个字符则提示用户
 */
+ (void)showSearchTip;

/**
 提示有无搜索结果

 @param title             提示标题
 @param currentController 当前控制器
 */
+ (void)setSearchResultsTitle:(NSString *)title andCurrentViewController:(UIViewController *)currentController;

/**
 用户不在群组中 无法发送任何类型的消息 talksessionView 和 forwardingRecentView 用到
 */
+ (void)sendMsgForbidden;

/**
 检查网络是否正常及用户状态是否离线 add by shisp

 @return 网络是否连通或用户是否离线
 */
+ (BOOL)checkNetworkAndUserstatus;

/**
 提示转发消息已发送 稍后关闭
 */
+ (void)showForwardTips;

/**
 提示消息，稍后关闭

 @param message 提示信息
 */
+ (void)showForwardTips:(NSString *)message;

@end

