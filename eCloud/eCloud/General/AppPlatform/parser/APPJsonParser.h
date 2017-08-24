//
//  APPJsonParser.h
//  eCloud
//
//  Created by Pain on 14-6-17.
//  Copyright (c) 2014年  lyong. All rights reserved.
//  轻应用model实体解析工具类

#import <Foundation/Foundation.h>

@class APPListModel;
@class APPToken;
@class APPStateRecord;
@class APPPushNotification;

@interface APPJsonParser : NSObject

/**
 通过字典封装model实体

 @param dic 轻应用字典内容

 @return 轻应用model实体
 */
- (APPListModel *)getAPPListModelFromDictionary:(NSDictionary *)dic;

// --------------------  暂未在龙湖上使用  --------------------------
/**
 解析应用列表数据

 @param appListStr 应用列表字符串

 @return 返回应用model的数组
 */
-(NSMutableArray *)parseAPPListModel:(NSString*)appListStr;

/**
 解析token字符串信息

 @param appTokenStr 服务器下发的token相关的字符串

 @return  APPToken实体
 */
-(APPToken *)parseAPPTokenModel:(NSString*)appTokenStr;

//-(APPStateRecord *)parseAPPStateRecordModel:(NSString*)appStateRecordStr;

/**
 解析轻应用通知消息

 @param appPushNotifStr 服务器发送的轻应用通知

 @return 轻应用推送实体
 */
-(APPPushNotification *)parseAPPPushNotificationModel:(NSString*)appPushNotifStr;



@end
