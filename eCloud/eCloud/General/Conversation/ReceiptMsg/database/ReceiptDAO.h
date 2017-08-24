//
//  ReceiptDAO.h
//  eCloud
//  和回执消息有关的DAO
//  Created by Richard on 13-12-12.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eCloud.h"
@class ConvRecord;

@interface ReceiptDAO : eCloud
+(id)getDataBase;

/**
 增加并初始化消息状态为未读

 @param msgId 回执消息id
 @param userList 人员列表
 @return 初始化成功再返回YES，否则返回NO
 */
-(BOOL)addMsgReadState:(int)msgId andUserList:(NSArray*)userList;

/**
 修改消息状态为已读

 @param msgId 消息id
 @param empId 人员id
 @param readTime 已读时间
 */
-(void)updateMsgReadState:(int)msgId andEmpId:(int)empId andReadTime:(int)readTime;

/**
 统计消息的已读情况

 @param convRecord 回执消息模型
 @return 在聊天界面显示回执消息的已读情况
 */
-(NSString *)getReadStateOfMsg:(ConvRecord*)convRecord;

/**
 根据msgId删除对应的记录

 @param msgId 回执消息的id
 */
-(void)deleteReadStateOfMsg:(int)msgId;

/**
 查询已读或未读人员

 @param msgId 回执消息id
 @param readFlag 已读还是未读
 @return 已读或未读人员列表
 */
-(NSArray *)getReceiptUser:(int)msgId andReadFlag:(int)readFlag;

/**
 获得回执消息对应的总人数

 @param msgId 回执消息id
 @return 对应的总人数
 */
-(int)getTotalUserCountOfMsg:(int)msgId;

/**
 获得回执消息对应的已读的人数

 @param msgId 回执消息id
 @return 回执消息对应的已读的人数
 */
-(int)getReadUserCountOfMsg:(int)msgId;

/**
 根据会话id，查询会话的状态 (回执消息都是发完之后立即变为正常状态的，所以这个方法已经没有什么用处)

 @param convId 会话id
 @return 是正常的状态，还是回执消息的状态
 */
-(int)getConvStatus:(NSString*)convId;

//

/**
 设置会话的状态(回执消息都是发完之后立即变为正常状态的，所以这个方法已经没有什么用处)

 @param convId 会话id
 @param convStatus 正常状态还是回执消息状态
 */
-(void)setConvStatus:(NSString*)convId andStatus:(int)convStatus;

/**
 修改数据库，设置一呼百应消息已发送已读

 @param msgIdArray 已读发送成功后，修改为已发送
 */
-(void)updateMsgReadNoticeFlag:(NSArray*)msgIdArray;

//获取所有已发送的回执消息

/**
 查询某个会话所有的回执消息

 @param convId 会话id
 @return 会话所有的回执消息
 */
- (NSArray *)getReceiptMsgByconvID:(NSInteger)convId;

@end
