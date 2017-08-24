//
//  APPConn.h
//  eCloud
//
//  Created by Pain on 14-6-23.
//  Copyright (c) 2014年  lyong. All rights reserved.
//  轻应用与服务器交互的连接类

/** 提醒类型 */
#define APP_PUSH_TYPE @"app_push_type"

/** 提醒内容 */
#define APP_PUSH_DETAIL @"app_push_detail"

/** 提醒URL */
#define APP_PUSH_URL @"app_puash_url"

/** 未读数 */
#define APP_PUSH_UNREAD @"app_push_unread"
// 获取轻应用的json信息apphomepage的value值中的关键字，若存在这个关键字代表可通过NewMyViewControllerOfCustomTableview的unReadForAllApp方法获取未读数，目前只有待办的轻应用需要这么做
// 如："apphomepage":"http://moapproval.longfor.com:39649/moapproval/PAGE_APP/list.html?SHOW_COUNT_NUM&20160112124785612"
#define SHOW_COUNT_NUM @"SHOW_COUNT_NUM"

#import <Foundation/Foundation.h>
#import "client.h"

@class NewMsgNotice;
@class APPStateRecord;

@interface APPConn : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

/**
 //同步应用请求(新，龙湖版)

 @param _conncb  服务器连接结构体指针
 @param fromUser 当前用户id
 */
+ (void)appSyncRequestOption:(CONNCB *)_conncb andFromUser:(NSString*)fromUser;

/**
 处理收到的新代办的通知  龙湖

 @param info 广播通知消息结构体指针
 */
+ (void)processBroadcastNotice:(BROADCASTNOTICE*)info;

/**
 (已废弃)
 同步应用请求(应用平台)
 
 @param _conncb  服务器连接结构体指针
 @param fromUser 当前用户id
 */
+(void)appSyncRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser;

/**
 (已废弃)
 发送统计上报(应用平台)
 
 @param _conncb     服务器连接结构体指针
 @param fromUser    当前用户id
 @param appStateRec 上报实体
 */
+(void)sendAPPStateRecordRequest:(CONNCB *)_conncb andFromUser:(NSString*)fromUser  andAPPStateRecord:(APPStateRecord*)appStateRec;

/**
 (已废弃)
 保存同步的应用列表(应用平台)
 
 @param resStr 服务器消息内容
 */
+(void)parseAndSaveAPPListInfo:(NSString*)resStr;

/**
 (已废弃)
 保存应用推送消息(应用平台)
 
 @param psMsg 服务端下发的推送消息
 
 @return 保存后封装的新消息实体
 */
+(NewMsgNotice*)saveAPPMsg:(NSString*)psMsg;

/**
 (已废弃)
 保存token通知(应用平台)
 
 @param appTokenStr 服务器下发的token内容
 */
+ (void)saveAppToken:(NSString *)appTokenStr;
@end
