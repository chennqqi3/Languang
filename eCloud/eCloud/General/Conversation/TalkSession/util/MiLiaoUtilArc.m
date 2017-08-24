//
//  MiLiaoUtilArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/16.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "MiLiaoUtilArc.h"
#import "eCloudDefine.h"
#import "JSONKit.h"
#import "TextMsgExtDefine.h"
#import "talkSessionViewController.h"
#import "ConvRecord.h"
#import "LogUtil.h"
#import "eCloudDAO.h"
#import "eCloudNotification.h"
#import "NotificationUtil.h"
#import "ConvNotification.h"

static MiLiaoUtilArc *miLiaoMsgUtil;

@interface MiLiaoUtilArc (){
    /** 密聊显示时间定时器 */
    NSTimer *_miLiaoMsgTimer;
    /** 密聊消息数组 */
    NSMutableArray *miLiaoMsgArray;
}

@end

@implementation MiLiaoUtilArc

- (id)init{
    self = [super init];
    if (self) {
        miLiaoMsgArray = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
    }
    return self;
}

/** 初始化密聊消息数组 */
- (void)initMiLiaoMsgArray{
    [miLiaoMsgArray removeAllObjects];
    [self stopTimer];
    
    NSArray *tempArray = [[eCloudDAO getDatabase]getAllMiLiaoMsgs];
    for (ConvRecord *_convRecord in tempArray) {
        [miLiaoMsgArray addObject:_convRecord];
    }
    
    if (miLiaoMsgArray.count) {
        [self startTimer];
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s 初始化密聊消息数组 密聊消息条数%lu ",__FUNCTION__,(unsigned long)miLiaoMsgArray.count]];

}

/** 从密聊信息数组里获取id相同的record */
- (ConvRecord *)getRecordFromMiLiaoMsgArray:(ConvRecord *)_convRecord{
    [LogUtil debug:[NSString stringWithFormat:@"%s 从密聊消息数组里获取id相同的消息 消息id为 %d ",__FUNCTION__,_convRecord.msgId]];

    for (ConvRecord *convRecord in miLiaoMsgArray) {
        if (convRecord.msgId == _convRecord.msgId) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 获取到了",__FUNCTION__]];
            return convRecord;
        }
    }
    return nil;
}

/** 把密聊消息加到数组里 */
- (void)addToMiLiaoMsgArray:(ConvRecord *)_convRecord{
    [LogUtil debug:[NSString stringWithFormat:@"%s 加到密聊消息数组里 消息id为 %d ",__FUNCTION__,_convRecord.msgId]];

    [miLiaoMsgArray addObject:_convRecord];
    if (miLiaoMsgArray.count) {
        [self startTimer];
    }
}

/** 从数组里删除密聊消息 */
- (void)removeFromMiLiaoMsgArray:(ConvRecord *)_convRecord{
    ConvRecord *tempConvRecord = [self getRecordFromMiLiaoMsgArray:_convRecord];
    if (tempConvRecord) {
        [miLiaoMsgArray removeObject:tempConvRecord];
        [LogUtil debug:[NSString stringWithFormat:@"%s 从密聊消息列表删除 msgid is %d",__FUNCTION__,_convRecord.msgId]];
    }
    if (miLiaoMsgArray.count == 0) {
        [self stopTimer];
    }
}

/** 开启定时器 */
- (void)startTimer{
    [self performSelectorOnMainThread:@selector(startTimerOnMainThread:) withObject:nil waitUntilDone:YES];
}

/** 在主线程开启 循环定时器 每秒1次 */
-(void)startTimerOnMainThread:(NSString *)timeoutStr
{
    if (_miLiaoMsgTimer == nil) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 开启密聊消息定时器",__FUNCTION__]];

        _miLiaoMsgTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeMiLiaoMsgLeftTime) userInfo:nil repeats:YES];
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
}

/** 停止超时定时器 */
-(void)stopTimer
{
    [self performSelectorOnMainThread:@selector(stopTimerOnMainThread) withObject:nil waitUntilDone:YES];
}
-(void)stopTimerOnMainThread
{
    if(_miLiaoMsgTimer && [_miLiaoMsgTimer isValid])
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s 关闭密聊消息定时器",__FUNCTION__]];
        [_miLiaoMsgTimer invalidate];
    }
    _miLiaoMsgTimer = nil;
}

/** 密聊消息存在的时间少一秒 */
- (void)changeMiLiaoMsgLeftTime{
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
    NSArray *tempArray = [NSArray arrayWithArray:miLiaoMsgArray];
    for (ConvRecord *_convRecord in tempArray) {
        BOOL needProcess = NO;
        if (_convRecord.msg_flag == send_msg) {
            if (_convRecord.isHuiZhiMsgRead) {
                needProcess = YES;
            }
        }else{
            if (_convRecord.readNoticeFlag == 1) {
                needProcess = YES;
            }
        }
        if (needProcess) {
            if (_convRecord.miLiaoMsgLeftTime) {
                _convRecord.miLiaoMsgLeftTime--;
                if (_convRecord.miLiaoMsgLeftTime == 0) {
//                    从内存删除 从数据库删除
                    [LogUtil debug:[NSString stringWithFormat:@"%s 从密聊消息数组和数据库删除密聊信息 消息id为%d",__FUNCTION__,_convRecord.msgId]];

                    [[eCloudDAO getDatabase]deleteOneMsg:[StringUtil getStringValue:_convRecord.msgId]];
                }
            }
            
        }
    }

    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    if (talkSession.talkType == singleType && [self isMiLiaoConv:talkSession.convId]) {
        
        BOOL needRefresh = NO;
        tempArray = [NSArray arrayWithArray:talkSession.convRecordArray];
        for (ConvRecord *_convRecord in tempArray) {
            BOOL needProcess = NO;
            if (_convRecord.msg_flag == send_msg) {
                if (_convRecord.isHuiZhiMsgRead){
                    needProcess = YES;
                }
            }else{
                if (_convRecord.readNoticeFlag == 1) {
                    needProcess = YES;
                }
            }
            if (needProcess) {
                if (_convRecord.miLiaoMsgLeftTime > 0) {
                    _convRecord.miLiaoMsgLeftTime--;
                    if (_convRecord.miLiaoMsgLeftTime == 0) {
                        [talkSession.convRecordArray removeObject:_convRecord];
                    }
                    needRefresh = YES;
                }
            }
        }
        
        if (needRefresh) {
            [talkSession.chatTableView reloadData];
        }
    }
}

+ (MiLiaoUtilArc *)getUtil{
    if (!miLiaoMsgUtil) {
        miLiaoMsgUtil = [[super alloc]init];
    }
    return miLiaoMsgUtil;
}

- (NSString *)formatMiLiaoMsg:(int)msgType andMsg:(NSString *)msg andFileName:(NSString *)fileName andFileSize:(int)fileSize{
    
    if (msgType == type_text) {
        return [self formatMiLiaoMsg:msg];
    }
    NSDictionary *dic = @{KEY_MSG_TYPE:KEY_MILIAO_MSG_TYPE,KEY_MILIAO_CONTENT_TYPE:@(msgType),KEY_MILIAO_FILE_URL:msg,KEY_MILIAO_FILE_NAME:fileName,KEY_MILIAO_FILE_SIZE:@(fileSize)};
    
    return [dic JSONString];
}

/** 格式化密聊消息
type_text=0,
type_pic,
type_record,
type_video,
 */
/** 格式化密聊消息 */
- (NSString *)formatMiLiaoMsg:(NSString *)inputText
{
    NSDictionary *dic = @{KEY_MSG_TYPE:KEY_MILIAO_MSG_TYPE,KEY_MILIAO_CONTENT_TYPE:@(type_text),KEY_MILIAO_DATA:inputText};
    
    return [dic JSONString];
}

- (NSString *)getEmpIdWithMiLiaoConvId:(NSString *)convId
{
    NSString *empId = [[convId componentsSeparatedByString:@"_"] lastObject];
    return empId;
}

- (NSString *)getMiLiaoConvIdWithEmpId:(int)empId
{
    return [NSString stringWithFormat:@"%@%d", MILIAO_PRE, empId];
}

/** 判断是否密聊会话 */
- (BOOL)isMiLiaoConv:(NSString *)convId{
    return [convId hasPrefix:MILIAO_PRE];
}

/** 判断是否密聊会话 */
- (BOOL)LGisMiLiaoConv:(NSString *)convId{
    
    if ([convId rangeOfString:MILIAO_PRE].length > 0) {
        
        return YES;
    }
    
    return NO;

}

/** 预处理密聊消息 */
- (void)setMiLiaoPropertyOfRecord:(ConvRecord *)_convRecord{
    ConvRecord *convRecord = [self getRecordFromMiLiaoMsgArray:_convRecord];
    if (convRecord) {
        if (convRecord.miLiaoMsgLeftTime) {
            _convRecord.miLiaoMsgLeftTime = convRecord.miLiaoMsgLeftTime;
            [LogUtil debug:[NSString stringWithFormat:@"%s 设置 密聊消息剩余时间 msgid is %d",__FUNCTION__,_convRecord.msgId]];
        }
    }
}

#pragma mark ======处理通知=======
- (void)handleCmd:(NSNotification *)notification
{
    eCloudNotification *_object = notification.object;
    
    if (_object) {
        
        NSDictionary *userInfo = _object.info;
        
        if (userInfo) {
            switch (_object.cmdId) {
                case msg_read_notice:
                {
                    int msgId = [userInfo[@"MSG_ID"]intValue];
                    
                    ConvRecord *_convRecord = [[eCloudDAO getDatabase]getConvRecordByMsgId:[StringUtil getStringValue:msgId]];
                    if (_convRecord.isMiLiaoMsg) {
//                        发送的消息，收到了消息已读通知
                        ConvRecord *tempConvRecord = [self getRecordFromMiLiaoMsgArray:_convRecord];
                        if (tempConvRecord) {
                            tempConvRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME;
                            tempConvRecord.isHuiZhiMsgRead = YES;
                            
                            [[eCloudDAO getDatabase]sendNewConvNotification:[NSDictionary dictionaryWithObjectsAndKeys:tempConvRecord.conv_id,@"conv_id", nil] andCmdType:other_user_read_encrypt_msg];
                        }
                    }
                }
                    break;
                case receipt_msg_send_read_success:{
                    int msgId = [userInfo[@"MSG_ID"]intValue];
//                    接收的消息，已读已经发送成功
                    ConvRecord *_convRecord = [[eCloudDAO getDatabase]getConvRecordByMsgId:[StringUtil getStringValue:msgId]];
                    if (_convRecord.isMiLiaoMsg) {
                        ConvRecord *tempConvRecord = [self getRecordFromMiLiaoMsgArray:_convRecord];
                        if (tempConvRecord) {
                            tempConvRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME;
                            if (tempConvRecord.msg_type == type_record) {
                                tempConvRecord.miLiaoMsgLeftTime = MILIAO_MSG_LIVE_TIME + [tempConvRecord.file_size intValue];
                            }
                            tempConvRecord.readNoticeFlag = 1;
                        }
                    }
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
}

@end
