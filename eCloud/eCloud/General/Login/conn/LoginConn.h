// 处理和登录有关的流程
//  LoginConn.h
//  eCloud
//
//  Created by shisuping on 14-9-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"
#import "ASIHTTPRequest.h"

@class Emp;

@interface LoginConn : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>

/** 登录应答里包括登录用户的用户id，姓名，性别，把这些属性保存在tempEmp对象里，在其它程序使用 */
@property (nonatomic,retain) Emp *tempEmp;

/**
 功能描述
 处理登录应答的通讯程序
 */
+ (LoginConn *)getConn;

/**
 功能描述
 判断登录成功还是失败，并且进行相应的处理
 如果登录失败，那么记录失败的原因，并发出失败通知
 如果登录成功，进行如下处理
   判断是否更换了用户，如果更换了，则关闭前一个用户的数据库
   保存用户的用户id，账号和密码到用户数据库表
   根据用户的id创建用户的目录
   判断是否需要下载服务器侧的通讯录文件，如果不需要下载则直接打开并且初始化数据库
   发出登录成功的通知
   设置用户状态为在线
   初始化一些属性
   如果需要下载数据库文件，则异步下载数据库，并且检测下载状态
   不需要下载数据库或者下载数据库失败或下载成功后的处理
 */
- (void)processLoginAck:(LOGINACK *)info;

/**
 功能描述
 打开用户数据库
 保存或者更新当前登录用户资料
 获取消息同步标志到内存
 处理保存用户权限 包括 创建群组的最大人数，移动端发送文件大小等
 */
- (void)saveCurUser:(LOGINACK *)info;

/**
 功能描述
 取出登录应答里的各中最新时间戳保存在内存里，后续同步使用
 */
- (void)saveUpdateTime:(LOGINACK *)info;

/**
 功能描述
 保存登录应答里的服务器时间和本地的时间，发送消息等操作时，通过计算获取和服务器一致的时间
 */
- (void)saveServerTime:(LOGINACK *)info;

/**
 功能描述
 保存登录应答里的系统参数
 */
- (void)saveSysParam:(LOGINACK *)info;

@end
