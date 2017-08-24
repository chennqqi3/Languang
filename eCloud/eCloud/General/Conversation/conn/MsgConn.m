

#import "MsgConn.h"

#import "UserDataDAO.h"
#import "conn.h"
#import "StringUtil.h"
#import "eCloudDAO.h"
#import "eCloudNotification.h"
#import "NotificationUtil.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"

#import "MsgNotice.h"

@interface MsgConn()

/** 撤回消息对应的消息ID */
@property (nonatomic,assign) long long recallMsgNewMsgId;

/** 撤回消息里执行撤回的消息id */
@property (nonatomic,assign) long long recallMsgCancelMsgId;

/** 撤回消息里执行撤回的消息 在本地保存的id */
@property (nonatomic,retain) NSString *recallMsgLocalSrcMsgId;

/** 离线的撤回消息数组 */
@property (nonatomic,retain) NSMutableArray *offlineRecallMsgArray;

@end

static MsgConn *msgConn;

@implementation MsgConn


@synthesize recallMsgLocalSrcMsgId;

@synthesize msgReadArray;
@synthesize recallMsgNewMsgId;
@synthesize recallMsgCancelMsgId;

@synthesize offlineRecallMsgArray;

+ (MsgConn *)getConn
{
    if (!msgConn) {
        msgConn = [[MsgConn alloc]init];
    }
    return msgConn;
}

/** 收到消息已读通知的处理 */
- (void)processMsgReadNotify:(MSG_READ_SYNC *)info
{
    conn *_conn = [conn getConn];
    
//    int terminalType = info->cTerminalType;
//    int userId = info->dwUserID;
//
    NSMutableArray *mArray = [NSMutableArray array];
    
    int _num = info->wNum;
    for (int i = 0; i < _num; i ++) {
        struct session_data data =  info->aSessionData[i];
        
        NSString *convId = nil;
        int _type = data.cType;
        if (_type == 1) {
            
            /** 单聊 */
            convId = [StringUtil getStringValue:data.dwUserID] ;
            
        }
        else if(_type == 2)
        {
            /** 群聊 */
            convId = [StringUtil getStringByCString:data.aszGroupID];
        }
        
        if (convId) {
            int _timestamp = data.dwTimestamp;
            [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",[NSNumber numberWithInt:_timestamp],@"msg_timestamp", nil]];
        }
    }
    
    if (mArray.count > 0) {
        if (_conn.isOfflineMsgFinish) {
            
            /** 直接发送通知出去 */
            eCloudDAO *db = [eCloudDAO getDatabase];

            /** 修改未读为已读 */
            [db updateMsgReadFlag:mArray];

            /** 获取总的未读数 */
            int allUnreadMsgCount = [db getAllNumNotReadedMessge];

            /** 获取对应会话的未读数 */
            NSArray *unreadMsgCountArray = [db getUnreadMsgCountOfMsgReadArray:mArray];
            
            /** 发送通知 */
            eCloudNotification *_notification = [[[eCloudNotification alloc]init]autorelease];
            _notification.cmdId = receive_msg_read_notify;
            _notification.info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:allUnreadMsgCount],@"all_unread_msg_count",unreadMsgCountArray,@"unread_msg_count_array", nil];
            
            [[NotificationUtil getUtil]sendNotificationWithName:CONVERSATION_NOTIFICATION andObject:_notification andUserInfo:nil];
        }
        else
        {
            /** 保存起来，等离线消息收取完毕，保存完毕再刷新 */
            [self.msgReadArray addObjectsFromArray:mArray];
        }
    }
}

/** 撤回消息 */
- (BOOL)recallMsg:(ConvRecord *)convRecord
{
    conn *_conn = [conn getConn];
    
    SENDMSG sendMsg;
    memset(&sendMsg, 0, sizeof(SENDMSG));

    /** 发送人 */
    sendMsg.dwUserID = convRecord.emp_id;

    /** 单聊还是群组 */
    if (convRecord.conv_type == singleType) {
        sendMsg.dwRecverID = convRecord.conv_id.intValue;
        sendMsg.cIsGroup = 0;
    }else{
        sendMsg.cIsGroup = [[UserDataDAO getDatabase]getGroupTypeValueByConvId:convRecord.conv_id];
        char *cGroupId = [StringUtil getCStringByString:convRecord.conv_id];
        strcpy(sendMsg.aszGroupID, cGroupId);
    }

    /** 消息类型 及 消息内容 */
    sendMsg.cType = type_recall_msg;
    
    static NSString *recallMsgStr = @"recall msg";
    
    const char *cMsg = [StringUtil getCStringByString:recallMsgStr];
    int len = strlen(cMsg);
    
    strcpy(sendMsg.aszMessage + 10, cMsg);
    sendMsg.dwMsgLen = len + 10;

    /** 消息id 及 要撤回的消息id */
    sendMsg.dwMsgID = [_conn getNewMsgId];
    sendMsg.dwSrcMsgID = convRecord.origin_msg_id;

    /** 发送时间 */
    sendMsg.nSendTime = [_conn getCurrentTime];
    
    int ret = CLIENT_SendSMSEx([_conn getConnCB],&sendMsg);
    if (ret == RESULT_SUCCESS) {

        self.recallMsgNewMsgId = sendMsg.dwMsgID;
        self.recallMsgCancelMsgId = sendMsg.dwSrcMsgID;
        self.recallMsgLocalSrcMsgId = convRecord.localSrcMsgId;

        
        _conn.isRecallMsgCmd = YES;
        [_conn startTimeoutTimer:5];
        return YES;
    }
    return NO;
}

- (BOOL)recallMsgOld:(ConvRecord *)convRecord
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    MSGCancel msgCancel;
    memset(&msgCancel, 0, sizeof(msgCancel));
    
    msgCancel.dwUserID = convRecord.emp_id;
    if (convRecord.conv_type == singleType) {
        msgCancel.dwRecverID = convRecord.conv_id.intValue;
        msgCancel.cIsGroup = 0;
    }else
    {
        msgCancel.cIsGroup = [[UserDataDAO getDatabase]getGroupTypeValueByConvId:convRecord.conv_id];
        char *cGroupId = [StringUtil getCStringByString:convRecord.conv_id];
        strcpy(msgCancel.aszGroupID, cGroupId);
//        msgCancel.aszGroupID = [StringUtil getCStringByString:convRecord.conv_id];
    }
    msgCancel.cType = convRecord.msg_type;
    msgCancel.dwMsgID = [_conn getNewMsgId];
    msgCancel.dwCancelMsgID = convRecord.origin_msg_id;
    
    msgCancel.nSendTime = [_conn getCurrentTime];
    
    int ret = CLIENT_SendSMSCancel(_conncb,&msgCancel);
    if (ret == RESULT_SUCCESS) {
        _conn.isRecallMsgCmd = YES;
        [_conn startTimeoutTimer:5];
        return YES;
    }
    return NO;
}

/** 处理撤回消息应答 */
/** 如果是撤回消息 那么就返回yes */
- (BOOL)processMsgCancelAck:(SENDMSGACK *)info
{
    conn *_conn = [conn getConn];
    
    BOOL success = NO;
    
    /** 发送撤回消息的应答吗 */
    BOOL isRecallMsg = NO;
    
    long long msgId = info->dwMsgID;
    if (self.recallMsgNewMsgId && self.recallMsgNewMsgId == msgId) {
        
        [LogUtil debug:@"收到了消息撤回应答"];
        isRecallMsg = YES;

        /** 停止超时检测 */
        _conn.isRecallMsgCmd = NO;
        [_conn stopTimeoutTimer];
        
        if (info->result == RESULT_SUCCESS) {
            
            NSString *msgId = [[eCloudDAO getDatabase]getMsgIdByOriginMsgId:self.recallMsgLocalSrcMsgId];
            if (msgId) {
                success = [[eCloudDAO getDatabase]recallMsgWithMsgId:msgId];
            }
            
            if (!success) {
                eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                _notificationObject.cmdId = recall_msg_fail;
                
                [[NotificationUtil getUtil]sendNotificationWithName:RECALL_MSG_RESULT_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
            }
        }
        self.recallMsgNewMsgId = 0;
        self.recallMsgCancelMsgId = 0;
        self.recallMsgLocalSrcMsgId = nil;

    }
    return isRecallMsg;
}

- (void)processMsgCancelAckOld:(MSGCancelACK *)info
{
    long long cancelMsgId = info->dwCancelMsgID;
    
    NSString *msgId = [[eCloudDAO getDatabase]getMsgIdByOriginMsgId:[NSString stringWithFormat:@"%lld",cancelMsgId]];
    
    if (info->result == RESULT_SUCCESS) {
        BOOL save = [[eCloudDAO getDatabase]recallMsgWithMsgId:msgId];
        if (save) {
            return;
        }
    }
    
    eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
    _notificationObject.cmdId = recall_msg_fail;
    
    [[NotificationUtil getUtil]sendNotificationWithName:RECALL_MSG_RESULT_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
}


- (void)executeRecallMsg:(MsgNotice *)msgNotice
{
    [LogUtil debug:[NSString stringWithFormat:@"%s 撤销消息",__FUNCTION__]];
    
    conn *_conn = [conn getConn];
    long long recallMsgId = msgNotice.srcMsgIdOfMassMsg;
    
    int senderId = msgNotice.senderId;
    
    NSArray *msgIds = [[eCloudDAO getDatabase]getMsgIdArrayByOriginMsgId:[NSString stringWithFormat:@"%lld",recallMsgId] andSenderId:senderId];
    
    for (NSString *msgId in msgIds) {
        [[eCloudDAO getDatabase]recallMsgWithMsgId:msgId];
    }
    
    CLIENT_SendMsgNoticeAck([_conn getConnCB], msgNotice.msgId, msgNotice.netID);
}

/** 处理撤回消息通知 */
- (void)processMsgCancelNotice:(MsgNotice *)msgNotice
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    conn *_conn = [conn getConn];

    /** 如果离线消息已经处理完了，那么可以直接处理，否则保存在内存里，等离线消息处理完，再在处理 */
    if (_conn.isOfflineMsgFinish) {
        [self executeRecallMsg:msgNotice];
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s 撤销类型消息 离线消息还未处理完，因此先缓存起来",__FUNCTION__]];
        [self.offlineRecallMsgArray addObject:msgNotice];
    }
}

- (void)processMsgCancelNoticeOld:(MSGCancelNotice *)info
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    conn *_conn = [conn getConn];

    long long recallMsgId = info->dwCancelMsgID;

    int senderId = info->dwSenderID;
    
    NSArray *msgIds = [[eCloudDAO getDatabase]getMsgIdArrayByOriginMsgId:[NSString stringWithFormat:@"%lld",recallMsgId] andSenderId:senderId];
    
    for (NSString *msgId in msgIds) {
        [[eCloudDAO getDatabase]recallMsgWithMsgId:msgId];
    }
    
    CLIENT_SendCancelNoticeAck([_conn getConnCB], info->dwMsgID, recallMsgId, info->dwNetID);
    
////    如果有多条，那么应该只留一条，并且修改为通知消息
//    
//    NSString *convId = nil;
//    if (cIsGroup == 0) {//单聊
//        if (senderId == _conn.userId.intValue) {
//            convId = [StringUtil getStringValue:info->dwRecverID];
//        }
//        else
//        {
//            convId = [StringUtil getStringValue:info->dwSenderID];
//        }
//    }else{
//        convId = [StringUtil getStringByCString:info->aszGroupID];
//    }
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,KEY_RECALL_MSG_CONV_ID,msgIds,KEY_RECALL_MSG_ID_ARRAY, nil];
//    
//    [[NotificationUtil getUtil]sendNotificationWithName:RECEIVE_RECALL_MSG_NOTIFICATION andObject:nil andUserInfo:dic];
}

- (void)initOfflineRecallMsgArray
{
    self.offlineRecallMsgArray = [NSMutableArray array];
}

- (void)saveOfflineRecallMsgs
{
    for (MsgNotice *msgNotice in self.offlineRecallMsgArray) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 批量处理撤销消息 要撤回的消息id is %lld",__FUNCTION__,msgNotice.srcMsgIdOfMassMsg]];
        [self executeRecallMsg:msgNotice];
        //        [self processMsgCancelNotice:msgNotice];
    }
}
@end
