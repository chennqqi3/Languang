//
//  MsgNotice.h
//  eCloud
//
//  Created by Richard on 13-8-3.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RobotResponseModel;

@interface MsgNotice : NSObject
{
}
@property(nonatomic,assign) int senderId;           /** 消息发送者ID */
@property(nonatomic,assign) int rcvId;              /** 接收人ID */
@property(nonatomic,retain) NSString* groupId;      /** 会话ID */
@property(nonatomic,assign) long long msgId;        /** 消息ID */
@property(nonatomic,assign) int isGroup;            /** 会话类型 0、单聊 1、群聊 2、固定群组 */
@property(nonatomic,assign) int msgType;            /** 消息类型 */
@property(nonatomic,assign) int isOffline;          /** 是否离线 */
@property(nonatomic,assign) int msgTotal;           /** 总消息数 */
@property(nonatomic,assign) int msgSeq;             /**  */
@property(nonatomic,assign) int offMsgTotal;        /** 离线消息总数 */
@property(nonatomic,assign) int offMsgSeq;          /**  */
@property(nonatomic,assign) int msgLen;             /** 消息长度 */
@property(nonatomic,assign) int msgTime;            /** 消息时间 */
@property(nonatomic,retain) NSString *msgBody;      /** 消息体 */
@property(nonatomic,assign) int fileSize;           /** 文件大小 */
@property(nonatomic,retain) NSString *fileName;     /** 文件名 */
@property(nonatomic,retain) NSString *msgGroupTime; /**  */

@property(nonatomic,assign)int receiptMsgFlag;      /** 回执消息标志 */

//一呼万应消息
//源消息id
@property(nonatomic,assign) long long srcMsgIdOfMassMsg;
//是否一呼万应消息
@property(nonatomic,assign) BOOL isMassMsg;

//是否发自微信公众号的消息
@property(nonatomic,assign) BOOL isMsgFromWX;

//具体的公众号
@property(nonatomic,retain) NSString *psCodeFromWX;

//具体的微信号
@property(nonatomic,retain) NSString *userCodeFromWX;

//具体的消息id
@property(nonatomic,retain) NSString *msgIdFromWX;

//netid
@property (nonatomic,assign) int netID;

// 代办本地通知显示title
@property(nonatomic,retain) NSString* msgTitle;

//机器人回复模型
@property (nonatomic,retain) RobotResponseModel *robotResponseModel;

/** 是否密聊消息 */
@property (nonatomic,assign) BOOL isEncryptMsg;

/** 是否需要创建单聊会话 蓝光待办不需要创建 */
@property (nonatomic,assign) BOOL needCreateSingleConv;

@end
