/** 和消息相关的conn程序 */

#import <Foundation/Foundation.h>
#import "client.h"

@class MsgNotice;
@class ConvRecord;

/** 撤回消息应答通知名称 */
#define RECALL_MSG_RESULT_NOTIFICATION @"RECALL_MSG_RESULT"

/** 撤回消息应答结果定义 */
typedef enum
{
    recall_msg_success = 200,
    recall_msg_fail,
    recall_msg_timeout
}recall_msg_result;

/** 保存撤回消息ID值对应的KEY */
#define KEY_RECALL_MSG_ID @"RECALL_MSG_ID"

////撤回消息通知 名称
//#define RECEIVE_RECALL_MSG_NOTIFICATION @"RECEIVE_RECALL_MSG"
//#define KEY_RECALL_MSG_ID_ARRAY @"RECALL_MSG_ID_ARRAY"
//#define KEY_RECALL_MSG_CONV_ID @"CONV_ID"


@interface MsgConn : NSObject

/** 消息已读数据 */
@property (nonatomic,retain) NSMutableArray *msgReadArray;

/** 懒加载 */
+ (MsgConn *)getConn;

/**
 功能描述
 收到消息已读通知的处理
 
 参数 info 广播通知消息结构体指针
 */
- (void)processMsgReadNotify:(MSG_READ_SYNC *)info;

/**
 功能描述
 撤回消息
 
 参数 convRecord 消息实体
 
 返回值 
 */
- (BOOL)recallMsg:(ConvRecord *)convRecord;

/**
 功能描述
 处理撤回消息应答
 
 参数 info 广播通知消息结构体指针
 返回值 YES 成功撤回 NO 撤回失败
 */
- (BOOL)processMsgCancelAck:(SENDMSGACK *)info;


- (void)processMsgCancelAckOld:(MSGCancelACK *)info;


/**
 功能描述
 处理撤回消息通知
 如果离线消息已经处理完了，那么可以直接处理，否则保存在内存里，等离线消息处理完，再在处理
 
 参数 msgNotice 消息实体
 */
- (void)processMsgCancelNotice:(MsgNotice *)msgNotice;

/** 已废弃 */
- (void)processMsgCancelNoticeOld:(MSGCancelNotice *)info;

/**
 功能描述
 初始化 离线的撤回消息数组

 */
- (void)initOfflineRecallMsgArray;

/**
 功能描述
 保存 离线的撤回消息

 */
- (void)saveOfflineRecallMsgs;


@end
