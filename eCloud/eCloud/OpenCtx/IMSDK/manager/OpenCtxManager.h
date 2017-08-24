//
//  OpenCtxManager.h
//  NewOpenCtxTest
//  IM以SDK方式集成到其它App中，因此要提供不同的接口给其它App调用，比如登录，登出，获取用户资料等
//  Created by shisuping on 16/6/24.
//  Copyright © 2016年 shisuping. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenCtxDefine.h"

@protocol OpenCtxManagerDelegate <NSObject>

/** 用户点击了退出按钮，并且确认退出后，如何切换UI */
- (void)didLogout;

@end

@class Emp;

@interface OpenCtxManager : NSObject

@property (nonatomic,assign) id<OpenCtxManagerDelegate> delegate;

/*
 功能描述：
 获取实例
 */
+ (OpenCtxManager *)getManager;

/*
 功能描述：
 使用账号和密码参数连接服务器并登录IM，并在成功或失败后回调block。
 
 参数说明：
 userName:用户账号
 password:用户密码
 
 登录结果block
 typedef void(^LoginResultBlock)(int loginResult);
 
 block参数说明
 loginResult：0 登录成功；其它失败
 
 调用方法：
 [[OpenCtxManager getManager]imLoginWithName:_user andPassword:_password completionHandler:^(int loginResult) {
    if(loginResult == 0){
// 登录成功
    }else{
// 登录失败
    }
 }
 */
- (void)imLoginWithName:(NSString *)userName andPassword:(NSString *)password completionHandler:(LoginResultBlock)completionHandler;

/*
 功能描述：
 退出IM
 
 参数说明
 userName:传nil即可
 exitType:0 能继续收到离线消息推送；1 无法收到离线消息推送
 
 调用说明
 示例代码
 
 NSString *userName = nil;
 [[OpenCtxManager getManager] imLogoutWithName:userName andExitType:0];
 */
- (void)imLogoutWithName:(NSString *)userName andExitType:(int)exitType;

/*
 功能描述：
 判断用户能不能退出，假如用户现在正在同步组织架构或者正在收取离线消息，用户选择退出时，会提示用户稍候退出
 
 参数说明：
 是一个字符串的地址，当暂时不能退出时，会把提示信息保存在次字符串中
 
 返回值说明：
 YES:可以退出
 NO：稍候退出
 
 调用说明：
 示例代码
 NSString *msg = nil;
 BOOL canLogout = [[OpenCtxManager getManager] canLogoutWithMessage:&msg];
 
 if (!canLogout) {
// 稍候退出，msg是要提示的信息
    NSLog(@"%s,%@",__FUNCTION__,msg);
 }
 else
 {
// 可以退出
    [self logout];
 }
 
 */
- (BOOL)canLogoutWithMessage:(NSString **)msg;

/*
 功能描述：
 获取某个账号的头像路径
 
 参数说明：
 userAccount:用户账号

 获取用户头像结果block
 typedef void(^GetPortraitResultBlock)(NSString *logoPath);

 block参数说明：
 logoPath：是用户的头像本地路径;如果头像不存在那么返回@“”，也不去下载了
 
 示例代码：
 [[OpenCtxManager getManager] getPortraitPath:@"_sso_t_00128" completionHandler:^(NSString *logoPath){
 NSLog(@"%@",logoPath);
 }];
 
 */
- (void)getPortraitPath:(NSString *)userAccount completionHandler:(GetPortraitResultBlock)completionHandler;

/*
 功能描述：
 设置头像的接口
 
 参数说明：
 newLogoImage:新头像
 
 设置新头像结果block
 typedef void(^SetPortraitResultBlock)(int resultCode,NSString *resultMsg);
 
 block参数说明：
 resultCode:
 0：修改成功
 -1：修改失败
 
 resultMsg:
 当resultCode为0时，resultMsg是头像路径
 当resultCode为-1时，resultMsg是错误提示
 
 示例代码：
 [[OpenCtxManager getManager] setPortrait:newLogoImage completionHandler:^(int resultCode,NSString *resultMsg)
 {
 NSLog(@"%d,%@",resultCode,resultMsg);
 }];
 
 */
- (void)setPortrait:(UIImage *)newLogoImage completionHandler:(SetPortraitResultBlock)completionHandler;

/*
 功能描述：
 后去某个账号头像缩略图或者大图的下载路径
 
 参数说明：
 userAccount:用户账号
 
 type:
 0:缩略图
 1:大图
 
 示例代码：
 NSString *_url = [[OpenCtxManager getManager]getPortrailtDownloadUrlWithUserAccount:@"_sso_t_00128" andLogoType:1];
 NSLog(@"%@",_url);
 
 */
//获取头像的下载URL
- (NSString *)getPortrailtDownloadUrlWithUserAccount:(NSString *)userAccount andLogoType:(int)type;

/*
 功能描述：
 根据员工工号查询数据库，返回对应的用户资料
 
 参数：
 userCode:员工工号
 
 返回值：
 一个Emp类型的对象，如果没有找到用户则返回nil
 
 示例代码：
 Emp *_emp = [[OpenCtxManager getManager]getEmpInfoWithUserCode:@"_sso_t_00128"];
 if (_emp) {
    NSLog(@"emp name is %@",_emp.emp_name);
 }

 */
- (Emp *)getEmpInfoWithUserCode:(NSString *)userCode;

/*
 功能描述：
 获取应用提醒的总条数
 
 返回值：
 本地保存的应用提醒的总条数
 
 */
- (int)getAppRemindTotalCount;

/*
 功能描述：
 获取本地保存的应用提醒
 
 参数
 limit: 获取的条数
 offset: 从第几条开始获取
 
 返回值：
 返回一个数组，数组的每一个元素是RemindModel类型
 */
- (NSArray *)getAppRemindsWithLimit:(int)limit andOffset:(int)offset;

/*
 功能描述：
 生成测试用的提醒数据，需要时调用，每次调用生成50条提醒数据
 */
- (void)createTestAppRemindsData;


/*
 功能描述：
 给某个账号发送文本消息
 
 参数说明：
 messageStr:要发送的消息
 userAccount:用户账号
 
 返回值
 YES:发送成功
 NO:发送失败
 
 */

- (BOOL)sendTxtMsg:(NSString *)messageStr toUser:(NSString *)userAccount;


/*
 功能描述：
 修改提醒消息为已读
 
 参数说明：
 remindMsgId:提醒消息的消息ID
 
 */

- (void)setRemindToReadWithMsgId:(NSString *)remindMsgId;

/*
 功能描述：
 删除数据库中的提醒
 
 参数说明：
 remindMsgId:提醒消息的消息ID
 
 */

- (void)deleteRemindWithMsgId:(NSString *)remindMsgId;

/* 
 删除所有提醒
 */
- (void)deleteAllRemaid;

/*
 功能描述:
 根据登录错误码，返回登录错误信息
 
 参数说明：
 retCode:登录错误码
 
 返回值说明：
 目前有以下几种错误
 连接服务器失败
 登录超时
 无效用户
 无效密码
 用户被禁用
 未知错误
 */
- (NSString *)getErrorMsgByLoginCode:(int)retCode;

/*
 功能描述
 根据账号获取头像路径，如果本地已经下载了此用户的头像，那么就返回本地路径，如果还没有下载，则返回空
 
 参数
 userAccount: NSString类型 用户账号
 
 返回值
 如果本地已经下载了此用户头像，那么返回本地保存的路径，否则返回空
 
 示例代码
 NSString *logoPath = [[OpenCtxManager getManager]getUserLogoPathWithUserAccount:@"_sso_t_00128"];
 NSLog(@"%@",logoPath);
 
 */
- (NSString *)getUserLogoPathWithUserAccount:(NSString *)userAccount;

/*
 功能描述
 设置获取待办未读数的url
 
 参数
 url:获取待办未读数的url
 
 */
- (void)setDaibanUnreadUrl:(NSString *)url;

/*
 功能描述
 设置主服务器
 
 参数
 serverIp:主IM服务器ip或者域名
 port:主IM服务器端口
 
 使用说明
 
 在以下代码后面设置IM服务器地址和端口,示例如下

 [[ApplicationManager getManager]callWhenAppLaunch];
 
 [[OpenCtxManager getManager] initServer:@"124.238.219.84" andPort:9001];
 
 */
- (void)initServer:(NSString *)serverIp andPort:(int)port;
/*
 功能描述
 设置备服务器
 
 参数
 serverIp:备IM服务器ip或者域名
 port:备IM服务器端口
 
 使用说明
 在设置主IM服务器之后设置备IM服务器
 
 */
- (void)initSecondServer:(NSString *)serverIp andPort:(int)port;

/*
 功能描述
 设置文件服务器地址、端口和路径
 
 参数
 serverIp:IM文件服务器ip或者域名
 port:IM文件服务器端口
 serverPath:IM文件服务器路径 例如:@"/"
 
 使用说明
 在设置IM服务器之后设置文件服务器
 */
- (void)initFileServer:(NSString *)serverIp andPort:(int)port andServerPath:(NSString *)serverPath;

/*
 功能描述
 设置机器人等服务的服务器地址和端口
 
 参数
 serverIp:服务器域名或者ip
 port:服务器端口
 */
- (void)initOtherServer:(NSString *)serverIp andPort:(int)port;


/**
 设置语言

 @param lanType lan_type_cn:中文 lan_type_en：英文
 */
- (void)setLan:(int)lanType;


/**
 用户点击了退出按钮
 */
- (void)onClickExitButton;


@end
