//
//  PSConn.h
//  eCloud
//
//  Created by Richard on 13-10-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"

@class ServiceMessage;
@class NewMsgNotice;
@class MsgNotice;

@interface PSConn : NSObject
+(void)psSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser;

//保存同步账号
+(void)parseAndSavePS:(NSString*)resStr andFromUser:(NSString*)fromUser;

//保存同步消息
+(NewMsgNotice*)savePSMsg:(NSString*)psMsg;


#pragma mark 向公众号发送消息
+(BOOL)sendPSMsg:(CONNCB *)_conncb andFromUser:(NSString*)fromUser andServiceMessage:(ServiceMessage*)message;


#pragma mark - 同步公众号菜单
+(void)psMenuListSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser;
+(void)parseAndSavePSMenuList:(NSString*)resStr andFromUser:(NSString*)fromUser;//保存同步公众号菜单
+(BOOL)sendPSMenuMsg:(CONNCB *)_conncb andFromUser:(NSString*)fromUser andServiceMessage:(ServiceMessage*)message;// 发送菜单命令

//add by shisp 把公众号的推送消息 由一个结构体 转换为 一个对象
+ (MsgNotice*)getMsgNoticeObject:(ECWX_PUSH_NOTICE *)psPushNotice;

@end
