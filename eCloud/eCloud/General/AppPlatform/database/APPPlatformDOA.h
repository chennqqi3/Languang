//
//  APPPlatformDOA.h
//  eCloud
//
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//  第三方应用的数据库操作

#import "eCloud.h"
@class APPListModel;
@class APPPushNotification;
@class APPStateRecord;
@class Conversation;

@interface APPPlatformDOA : eCloud

/**
 获取DOA对象实体

 @return APPPlatformDOA对象实体
 */
+(id)getDatabase;

/**
 保存应用列表信息

 @param info 应用列表

 @return YES:成功  NO:失败
 */
-(bool)saveAPPListInfo:(NSArray *)info;

/**
 获取所有应用的列表

 @param appShowflag 0:未添加到我的页面 1:已添加到我的页面

 @return 对应的应用列表
 */
-(NSMutableArray *)getAPPListWithAppShowflag:(int)appShowflag;

/**
 获取所有应用

 @return 所有应用的列表
 */
-(NSMutableArray *)getAPPList;

/**
 更新应用是否被添加状态

 @param appId       指定应用的id
 @param appShowflag 0:删除   1:添加
 */
-(void)updateHasAddedOfAPPModel:(NSString *)appId withAppShowflag:(int)appShowflag;

/**
 设置应用已点击

 @param appId 应用id
 */
-(void)setAPPModelRead:(NSString *)appId;

/**
 标记应用已下载

 @param appId 应用id
 */
-(void)setAPPModelDownLoadFlag:(NSString *)appId;

/**
 图标下载完成

 @param appModel 应用实体
 */
-(void)updateDownLoadFlag:(APPListModel *)appModel;

/**
 获取所有新应用的数目

 @return 新应用个数
 */
-(NSInteger)getAllNewAppsCount;

/**
 根据appid获取应用信息

 @param appId 应用id

 @return 对应的应用实体
 */
-(APPListModel*)getAPPModelByAppid:(NSInteger )appId;

/**
 逻辑删除应用

 @param appModel 应用实体
 */
-(void)deleteAPPModelUpdatetype:(APPListModel *)appModel;

/**
 物理删除应用  包含应用图标、推送消息、会话记录

 @param appModel 应用实体
 */
-(void)deleteAPPModel:(APPListModel *)appModel;

/**
 保存应用推送信息

 @param appPushNotif 推送信息

 @return  YES:成功  NO:失败
 */
-(bool)saveAPPPushNotification:(APPPushNotification*)appPushNotif;

/**
 获取某一应用的所有推送消息(包括已读和未读)

 @param appId 应用id

 @return 获取对应应用的推送消息
 */
-(NSMutableArray *)getAPPPushNotificationWithAppid:(NSString *)appId;

/**
 分页获取指定应用消息

 @param appId   应用id
 @param _limit  查询多少条
 @param _offset 查询的起始位置

 @return 获取对应应用推送消息的集合
 */
-(NSArray*)getAPPPushNotificationWithAppid:(NSString *)appId andLimit:(int)_limit andOffset:(int)_offset;

/**
 获取某应用未读消息数目

 @param appId 应用id

 @return 指定应用的推送个数
 */
-(NSInteger)getAllNewPushNotiCountWithAppid:(NSString *)appId;

/**
 获取所有未读消息数目

 @return 所有应用的推送个数
 */
-(NSInteger)getAllNewPushNotiCount;

/**
 获取所有不在我的页面应用未读消息数目

 @return  不在我的页面应用未读消息数目
 */
-(NSInteger)getAllNewPushNotiCountOutOfMine;

/**
 获取显示在会话列表应用未读消息数目

 @return 在会话列表应用未读消息数目
 */
-(NSInteger)getAllNewPushCountOfAPPInContactList;

/**
 把某一个应用的所有的未读消息修改为已读

 @param appId 应用id
 */
-(void)updateReadFlagOfAPPNoti:(NSString *)appId;

/**
 把某一个应用的一条未读消息修改为已读

 @param appPushNotif 推送信息
 */
-(void)updateReadFlagOfAPPPushNotification:(APPPushNotification*)appPushNotif;

/**
 设置会话列表里面的所有应用消息为已读
 */
-(void)setAllAppMsgInContactListToRead;

/**
 删除一条推送消息

 @param appPushNotif 推送消息
 */
-(void)deleteAPPPushNotification:(APPPushNotification*)appPushNotif;

/**
 根据appid删除某一个应用所有的推送消息

 @param appId 应用id
 */
-(void)deleteAPPPushByAppid:(NSString *)appId;

/**
 获取某个应用收到的消息的条数

 @param appId 指定轻应用id

 @return 消息条数
 */
- (int)getMsgCountByAppId:(NSString *)appId;

/**
 保存一条统计数据上报

 @param appStateRecord 轻应用统计记录model对象

 @return YES:成功  NO:失败
 */
-(bool)saveOneAPPStateRecord:(APPStateRecord*)appStateRecord;

/**
 获取某一应用最近一条统计记录

 @param appid 指定轻应用id

 @return 记录实体
 */
-(APPStateRecord *)getLatestAPPStateRecordOfApp:(NSString *)appid;

/**
 初始化应用数据
 */
-(void)initAppData;

/**
 查询数据库中apps_list中是否有101轻应用

 @param appid 指定轻应用id

 @return YES:存在   NO:不存在
 */
-(BOOL)isExistAppByAppId:(int)appid;

/**
 功能描述
 查询收到的国美的应用消息
 
 需要取到应用名称，应用图标，最近一条消息的title，最近一条消息的时间，未读消息条数
 
 首先查询广播表，查看有哪些应用收到了推送，然后根据id找到应用名称，找到最近一条消息的时间，和未读消息数
 
 然后再对所有记录按照最近一条时间倒序
 
 应用名称 可以保存在conv_title
 应用id 可以保存在conv_id
 
 应用图标 可以 根据应用id获取
 
 返回结果
 Conversation类型的数组
 
 */
- (NSArray *)getGOMEAppMsgList;


/**
 查询某一个应用的未读消息条数

 @param appId 应用id
 @return 该应用的未读消息数
 */
- (NSInteger)getUnreadAppMsgCount:(NSString *)appId;

/**
 功能描述
 应用消息列表界面 某一个应用的最近消息
 
 参数
 appId:应用id
 
 返回值
 conversation:最近一条消息对应的模型
 
 */
- (Conversation *)getLastAppMsg:(NSString *)appId;

/**
 功能描述
 删除某一个应用的所有消息 删除后 需要通知会话列表界面更新
 
 参数
 appId:应用id
 
 */
- (void)deleteAllMsgOfApp:(NSString *)appId;

/**
 功能描述
 删除一条应用的消息 会话列表界面 应用消息一级界面需要处理通知
 
 */
-(void)removeOneAppMsgByMsgId:(NSString *)msg_id;

/**
 功能描述
 设置某一个应用的所有消息为已读
 
 参数：应用id
 */
- (void)setAppMsgReadOfApp:(NSString *)appId;

/**
 功能描述
 隐藏或者显示某一个应用，并且发出通知
 
 参数
 AppListModel:appModel
 int:appShowFlag
 
 */

- (void)updateApp:(APPListModel *)appModel withShowFlag:(int)appShowFlag;

/**
 功能描述
 删除应用表内所有的应用
 下载了通讯录数据库文件后，查看有没有之前同步下来的应用，如果有则删除
 
 */
- (void)removeAllApp;

/** 根据搜索条件搜索国美应用 */
- (NSArray *)searchGomeAppBy:(NSString *)searchStr;

@end
