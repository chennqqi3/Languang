//
//  NetworkUtil.h
//  eCloud

//  IM以SDK方式集成到其它App，在其它App的生命周期中，需要调用IM的接口，对IM进行相应处理

//  Created by shisuping on 16/6/21.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    type_wifi,
    type_gprs
}net_type;

#define FORCE_UPDATE_ALERT_TAG (100)    // 强制升级
#define OPTION_UPDATE_ALERT_TAG (101)   // 可选升级
#define REMOVED_FROM_GROUP_TAG (102)    // 从群组被移除标识
#define DISABLE_TAG (103)               // 退出标识


@interface ApplicationManager : NSObject

/** 为了防止用户点击轻应用通知启动轻应用后，又重复弹出通知，所以当用户 点击通知 启动应用时，记下此通知 */
@property (nonatomic,retain) NSDictionary *notificationUserInfo;
/** 本地是否存在账号信息 */
@property (nonatomic,assign) BOOL hasAccount;
/** 是否进行退出 */
@property (nonatomic,assign) BOOL isExit;
/** 网络类型 0 : wifi  1 : gprs */
@property (nonatomic,assign) int netType;
/** 网络是否正常 */
@property (nonatomic,assign) BOOL isNetworkOk;
/** 升级提示框控件 */
@property (nonatomic,retain) UIAlertView *versionAlert;
/** 如果用户点击离线消息近来，那么默认激活会话界面 */
@property (nonatomic,assign) BOOL needSelectContactTab;
/** 是否需要选中办公界面 */
@property (nonatomic,assign) BOOL needSelectMyTab;
/** 如果用户点击新待办的离线消息近来，那么默认打开代办界面 */
@property (nonatomic,assign) BOOL needOpenAgent;
/** 用户点击轻应用通知启动应用，这里保存通知userinfo */
@property (nonatomic,retain) NSDictionary *appInfo;
/** 收藏tableview是否处于编辑状态 */
@property(nonatomic, assign) BOOL isEditing;
/** 记录未读个数 */
@property (assign) int noReadCount;
/** 当用户在其它移动端登录时或者通过管理台被禁用时，是否需要弹框提示 */
@property (nonatomic,assign) BOOL needShowAlertWhenUserDisable;

/** 设置导航栏标题颜色 只针对navigationItem.titleView方式 */
@property (nonatomic,retain) UIColor *navigationTitleViewFontColor;

/** 设置导航栏字体  只针对navigationItem.titleView方式*/
@property (nonatomic,retain) UIFont *navigationTitleViewFont;

/** 是否是点击应用通知启动应用的 默认值是NO*/
@property (nonatomic,assign) BOOL startAppByClickAppNotificatin;

/**
 获取ApplicationManager实例

 @return ApplicationManager实例
 */
+ (ApplicationManager *)getManager;

/**
 设置用户为退出登录的状态，否则应用程序激活时将会自动登录IM
 */
- (void)setUserIsExit;

/**
 初始化程序语言、读取应用配置、初始化数据库、增加需要接收的通知比如被踢通知、网络变化通知、被禁用通知、被移除出群组通知等、初始化百度地图等功能
 */
- (void)callWhenAppLaunch;

/**
 首先调用百度地图接口[BMKMapView didForeGround]，如果用户在线，那么发送命令给服务器，检查能否在超时时间内收到应答，如果没有收到应答，就自动重新连接。如果用户不在线，那么就在判断是否需要自动登录。
 */
- (void)callWhenAppActive;

/**
 向IOS系统申请后台运行时间，并且告诉服务器目前客户端未读消息数量
 */
- (void)callWhenAppEnterBackground;

/**
 按照百度地图SDK的要求，调用了[BMKMapView willBackGround]方法。
 */
- (void)callWhenAppWillResignActive;

/**
 应用即将进入前台运行
 */
- (void)callWhenAppWillEnterForground;


/**
 保存token，这样在登录IM时把token告知服务器，以接收APNS通知。

 @param deviceToken 获取到系统返回的token数据后，把空格和两边的尖括号去掉，作为参数给IM保存
 */
- (void)saveToken:(NSString *)deviceToken;


/**
 功能描述：
 设置应用类型，是独立版本还是和OA的融合版本
 
 参数说明：
 目前有三种应用类型，融合appstore版 融合企业证书版 独立企业证书版本，具体有宏定义
 #define combine_appstore_type @"1.01.001"
 #define combine_enterprise_type @"2.01.001"
 #define independent_enterprise_type @"3.01.001"
 
 调用示例：
 需要先导入 #import "OpenCtxDefine.h"
 
 [[ApplicationManager getManager]setUserIsExit];
 [[ApplicationManager getManager]setAppType:combine_enterprise_type];
 [[ApplicationManager getManager]callWhenAppLaunch];
 */
- (void)setAppType:(NSString *)appType;

//***************以下代码是内部使用****************
/**
 初始化网络、接收网络变化通知
 */
-(void)initNetWork;

/**
 获取登录用户及状态
 */
-(void)getAccountProperty;

/**
 启动重连timer
 */
-(void)startAutoConnTimer;

/**
 停止重连timer
 */
-(void)stopAutoConnTimer;

/**
 应用程序从后台进入到前台后，发出离线消息数量请求指令，同时开启一个timer，如果收到了离线消息数量的应答，那么取消此timer，否则尝试重连
 */
-(void)startConnCheckTimer;

/**
 进入后台或收到了离线消息数量的应答时，取消timer定时器
 */
-(void)stopConnCheckTimer;

/**
 网络超时，重新连接
 */
-(void)connCheckTimeout;

/**
 是否需要自动重连

 @return YES:需要自动连接   NO:不需要自动连接
 */
-(BOOL)needAutoConnect;

/**
 用户点击通知启动应用或者进入应用

 @param userInfo 字典内容
 */
- (void)enterAppByClickNotification:(NSDictionary *)userInfo;

- (void)startAppFromLaunchOptions:(NSDictionary *)launchOptions;

/**
 用户被禁用弹出的提示框

 @param notification 用户被禁用的通知对象
 */
- (void)userDisable:(NSNotification *)notification;

/**
 版本升级提示

 @param alertDelegate 代理对象
 */
- (void)showVersionAlert:(id)alertDelegate;

/**
 两个作用：1、开放给外部的登录接口
         2、配置中打开自动登录配置项且本地已登录过时的自动登录
 */
-(void)loginAction;

@end
