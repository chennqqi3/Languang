//
//  TextMsgExtDefine.h
//  eCloud
//  文本消息扩展定义
//  Created by shisuping on 17/5/9.
//  Copyright © 2017年 网信. All rights reserved.
//

#ifndef TextMsgExtDefine_h
#define TextMsgExtDefine_h

/** 消息类型key */
#define KEY_MSG_TYPE @"type"


//蓝光待办、会议、新闻推送消息type定义
#define KEY_LANGUANG_DAIBAN_TYPE @"backlog"
#define KEY_LANGUANG_NEWS_TYPE @"news"
#define KEY_LANGUANG_MEETING_TYPE @"meeting"

/** 位置类型消息 */
#define LOCATION_TYPE @"location"
#define KEY_LOCATION_URL @"url"
#define KEY_LOCATION_LONGITUDE @"longitude"
#define KEY_LOCATION_LANTITUDE @"latitude"
#define KEY_LOCATION_ADDRESS @"address"

//密聊协议
//{
//    "type": "secret",
//    "data": "正文",
//    "contentType": 1,
//    "fileName": "fileName",
//    "fileUrl": "fileURL",
//    "fileSize": 100
//}

/** 密聊消息类型 */
#define KEY_MILIAO_MSG_TYPE @"secret"
/** 消息类型 */
#define KEY_MILIAO_CONTENT_TYPE @"contentType"
/** 消息内容 */
#define KEY_MILIAO_DATA @"data"
/** 文件名字 */
#define KEY_MILIAO_FILE_NAME @"filename" //@"fileName"
/** 文件大小 */
#define KEY_MILIAO_FILE_SIZE @"filesize" // @"fileSize"
/** 文件URL */
#define KEY_MILIAO_FILE_URL @"fileurl" //@"fileURL"

/** 定向消息类型 */
#define KEY_REPLY_MSG_TYPE @"replyTo"
/** 发送人id */
#define KEY_REPLY_MSG_SENDER_ID @"userId"
/** 消息id */
#define KEY_REPLY_MSG_MSG_ID @"msgId"
/** 发送人名字 */
//#define KEY_REPLY_MSG_SENDER_NAME @"userName"
/** 发送时间 */
//#define KEY_REPLY_MSG_SEND_TIME @"msgTime"
/** 发送内容 限制一定的长度 */
//#define KEY_REPLY_MSG_SEND_MSG @"msgBody"
/** 回复内容 */
#define KEY_REPLY_MSG_REPLY_MSG @"content"


/** 红包消息类型 */
#define KEY_RED_PACKET_MSG_TYPE @"redPacketMsg"
/** msg */
#define KEY_RED_PACKET_msg @"msg"

/** 祥源通告消息类型 */
#define KEY_XY_TONGGAO_MSG_TYPE @"3"
/** 祥源待办消息类型 */
#define KEY_XY_DAIBAN_MSG_TYPE @"2"
/** 祥源待办未读数类型 */
#define KEY_XY_DAIBAN_UNREAD_TYPE @"1"

#endif /* TextMsgExtDefine_h */
