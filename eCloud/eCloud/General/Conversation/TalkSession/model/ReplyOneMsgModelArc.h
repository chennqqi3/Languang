//
//  ReplyOneMsgModelArc.h
//  eCloud
//  定向回复消息模型
//  Created by shisuping on 17/5/8.
//  Copyright © 2017年 网信. All rights reserved.
//

/** {"content":"定向回复","type":"replyTo","msgId":4679498978344025601,"userId":493404} */

#import <Foundation/Foundation.h>
#import "TextMsgExtDefine.h"

@interface ReplyOneMsgModelArc : NSObject

/** 发送人 */
@property (nonatomic,strong) NSString *senderName;

/** 发送人显示高度 */
@property (nonatomic,assign) float senderNameHeight;

/** 回复的消息记录 */
@property (nonatomic,strong) NSArray *senderRecords;

/** 发送时间 */
@property (nonatomic,assign) int sendTime;

/** 要显示的发送时间 */
@property (nonatomic,strong) NSString *sendTimeDsp;

/** 发送的内容 */
@property (nonatomic,strong) NSString *sendMsgBody;

/** 发送内容显示高度 */
@property (nonatomic,assign) float sendMsgHeight;

/** 回复内容显示高度 */
@property (nonatomic,assign) float replayMsgHeight;

@end
