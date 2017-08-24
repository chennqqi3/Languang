//
//  AppDelegate.h
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginViewController.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>


#define root_login (1)
#define root_main (2)
//typedef enum 
//{
//	type_wifi,
//	type_gprs
//}net_type;

//#define FORCE_UPDATE_ALERT_TAG (100)    // 强制升级
//#define OPTION_UPDATE_ALERT_TAG (101)   // 可选升级
//#define REMOVED_FROM_GROUP_TAG (102)    // 从群组被移除标识
//#define DISABLE_TAG (103)               // 退出标识
@class loginViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    loginViewController *loginController;   //deprecated
    UINavigationController *navigation; // 主窗口的根控制器变量
//	BOOL _isNetworkOk;
	conn *_conn;    // 与服务器通讯的连接类
	
//	NSString *notificationName;//通知名称
//	eCloudNotification *notificationObject;//通知带的对象
    UILabel *tiplabel;  // 网络未连接window上的未连接label控件
//    UIAlertView *broadcastAlert;
//    UIAlertView *revcieFileAlert;
//    UIAlertView *offalert;
//    BOOL loginFromLoginController;
//    UIAlertView *helperAlert;
    
//    BMKMapManager* _mapManager;

}

//如果用户点击离线消息近来，那么默认激活会话界面
//@property (nonatomic,assign) BOOL needSelectContactTab;
//@property (nonatomic,assign) BOOL needSelectMyTab;
////如果用户点击新待办的离线消息近来，那么默认打开代办界面
//@property (nonatomic,assign) BOOL needOpenAgent;
////用户点击轻应用通知启动应用，这里保存通知userinfo
//@property (nonatomic,retain) NSDictionary *appInfo;

//@property (assign) int netType;
// 作为计算点击主界面tabbar的个数，应用于泰禾项目，比如点击了  首页  切换到  会话  再切换到  首页 此变量加1
//@property (nonatomic,assign) int changeAppCtrlCount;
//deprecated
@property (nonatomic,assign) int rootType;
@property (strong, nonatomic) UIWindow *window;
// 是否允许屏幕旋转  0是不支持旋转，1是支持旋转   在轻应用打开文件及第三方图片查看时使用
@property (nonatomic,assign) int allowRotation;
//@property BOOL isNetworkOk;
//@property (nonatomic,retain) UIAlertView *versionAlert;

// Add by toxicanty 15/06/05
//@property(nonatomic,assign)long long fileLength;

//
////启动重连timer
//-(void)startAutoConnTimer;
//
////停止重连timer
//-(void)stopAutoConnTimer;
//
////应用程序从后台进入到前台后，发出离线消息数量请求指令，同时开启一个timer，如果收到了离线消息数量的应答，那么取消此timer，否则尝试重连
//-(void)startConnCheckTimer;
//
//-(void)stopConnCheckTimer;
//
////网络超时，重新连接
//-(void)connCheckTimeout;
//
//-(BOOL)needAutoConnect;
//
//- (void)showVersionAlert:(id)alertDelegate;
//
//- (void)userDisable:(NSNotification *)notification;

/*
 功能描述
 打开 从其它app 转发过来的文件
 */
- (void)openUrlFromOtherApp;
/*
 功能描述
 设置主屏幕的根控制器
 进入根控制器，首先根据不同的公司将登陆控制器置为导航控制器的根控制器，根据本地是否已有账号和用户非退出状态下进入主界面
 */
- (void)gotoRootViewCtrl;
//@property (strong, nonatomic) UIView *lunchView;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url ;

@end
