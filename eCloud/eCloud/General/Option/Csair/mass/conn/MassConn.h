//
//  MassConn.h
//  eCloud
//
//  Created by Richard on 14-1-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"
@class ConvRecord;
@class MsgNotice;
@class NewMsgNotice;
@interface MassConn : NSObject

+(BOOL)sendMassMsg:(CONNCB *)_conncb andConvEmpArray:(NSArray*)convEmpArray andConvRecord:(ConvRecord *)_convRecord;

+(MsgNotice*)getMsgNoticeObject:(BROADCASTNOTICE *)_msgNotice;

#pragma mark 收到一呼万应的消息，保存为一个新的会话，返回新会话的convId
+(NSString*)createNewConversation:(MsgNotice*)msgNotice;

#pragma mark 保存收到的群发消息，如果成功则返回msgid
+(NSString*)saveRcvMassMsg:(MsgNotice*)msgNotice;

#pragma mark 保存用户对一呼万应消息的回复
+(NewMsgNotice*)saveReplyMessage:(MsgNotice*)msgNotice;

@end
