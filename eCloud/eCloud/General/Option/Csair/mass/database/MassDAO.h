//
//  MassDAO.h
//  eCloud
//
//  Created by Richard on 14-1-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "eCloud.h"
@class ConvRecord;
@class Conversation;

@interface MassDAO : eCloud

//获取数据库的实例
+(id)getDatabase;

#pragma mark 增加一呼万应
-(void)addConversation:(NSDictionary *) dic;

#pragma mark  增加一呼万应成员
-(void)addConvMember:(NSArray *) info;

#pragma mark 增加群发消息包括发送的和收到的
-(NSDictionary*)addConvRecord:(NSDictionary*)dic;

#pragma mark 判断是不是第一次向这个群发会话发消息
-(bool)isFirstSendMsg:(NSString*)convid;

#pragma mark 修改会话信息 会话名称
-(void)updateConvTitle:(NSString*)convId andConvTitle:(NSString*)convTitle;

#pragma mark 修改会话的最后一条消息的消息内容等
-(void)updateConvLastMsg:(NSDictionary*)dic andNewMsgId:(int)_id;

#pragma mark 根据会话Id，查询某个会话的总的记录个数，但只包括发送的
-(int)getConvRecordCountBy:(NSString*)convId;

#pragma mark  根据会话id，查询会话记录，按照时间排序，最近的要排在前面，参数包括limit和offset
-(NSArray *)getConvRecordBy:(NSString *)convId andLimit:(int)_limit andOffset:(int)_offset;

#pragma mark 获取最后一条输入信息
-(NSString *)getLastInputMsgByConvId:(NSString *)conv_id;

#pragma mark 修改会话消息,图片等上传成功后，不修改时间，而是修改状态为正在sending
-(void)updateConvRecord:(NSString *)msgId andMSG:(NSString*)msg_body andFileName:(NSString*)file_name andMsgType:(int)msgType;

#pragma mark 根据消息的id查询
-(NSString *)getMsgIdByOriginMsgId:(NSString*)_originMsgId;

#pragma mark 根据群发会话id获取成员
-(NSArray*)getConvMemberByConvId:(NSString*)convId;

#pragma mark 点击头像进入相应用户的单聊会话 根据消息id，根据用户id，
-(void)transferMassMsgByMsgId:(int)msgId andEmpId:(int)empId andReplyCount:(int)replyCount;

#pragma mark 把群发相关的消息入到普通的单人会话记录中
-(void)transferMassMsg:(ConvRecord*)_convRecord;

#pragma mark  修改消息状态，发送失败还是成功，发送或接受的状态
-(void)updateSendFlagByMsgId:(NSString*)msgId andSendFlag:(int)flag;

#pragma mark 获取所有发送的广播
-(NSArray *)getAllMassConversation;
#pragma mark 获取广播的每条消息的成员  三级正及以上级别
-(NSArray *)getEmpsEqAndAboveTreeRankByConvID:(NSString*)conv_id andMsgId:(int)msg_id;
#pragma mark 获取广播的每条消息的成员  三级正以下级别
-(NSArray *)getEmpsEqAndBelowTreeRankByConvID:(NSString*)conv_id andMsgId:(int)msg_id;
//未读回复
-(int)getUnReadNumByEmpId:(int)emp_id andMsgId:(int)msg_id;
#pragma mark   三级正以下级别,已回复的
-(NSArray *)getEmpsEqAndBelowTreeRankByMsgId:(int)msg_id;
#pragma mark 广播的所有未读数量
-(int)getAllUnReadNum;

#pragma mark 更新最后输入信息
-(void)updateLastInputMsgByConvId:(NSString *)conv_id LastInputMsg:(NSString *)lastInputMsg;
#pragma mark 更新最后输入信息时间
-(void)updateLastInputMsgTimeByConvId:(NSString *)conv_id nowTime:(NSString *)nowTime;
#pragma mark 临时部门及人员
-(void)createTempDeptAndEmpByConvID:(NSString*)conv_id andMsgId:(int)msg_id;
//-(NSMutableArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected;
-(BOOL)isInTheSameDept;
-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andMsgId:(int)msg_id;
-(NSMutableArray *)getTempDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected andMsgId:(int)msg_id;
#pragma mark 三级以下未读回复数量
-(int)getUnReadNumByConvID:(NSString*)conv_id andMsgId:(int)msg_id;
#pragma mark 某条广播的未读回复数量
-(int)getUnReadNumByMsgId:(int)msg_id;
#pragma mark 级正以下级别 人数
-(int)getBelowThreeEmpNum;

#pragma remark 合并一呼万应的消息，如果收到的消息超过了 72小时，那么合并到单聊会话
- (BOOL)mergeMassMessageToSingleConv:(Conversation *)conv;

#pragma mark  根据会话id，查询会话记录里面的图片记录，按照时间排序，最近的要排在前面
-(NSArray *)getPicConvRecordBy:(NSString *)convId;

#pragma mark  根据msgId获取一条会话记录
-(ConvRecord *)getConvRecordByMsgId:(NSString*)msgId;

@end
