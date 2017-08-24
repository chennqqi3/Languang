//
//  MsgSyncUtil.m
//  OpenCtx2017
//
//  Created by shisuping on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "MsgSyncUtil.h"
#import "UserTipsUtil.h"
#import "conn.h"
#import "eCloudNotification.h"
#import "eCloudDefine.h"
#import "StringUtil.h"

@interface MsgSyncUtil (){
    
}
/** 设置消息同步的block */
@property (nonatomic,copy) SetMsgSyncFlagResultBlock setMsgSyncFlagResultBlock;
@property (nonatomic,assign) int userMsgSyncFlag;

@end

static MsgSyncUtil *msgSyncUtil;

@implementation MsgSyncUtil

- (void)addObserver{
    //    增加接收修改用户资料的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];

}

- (id)init{
    self = [super init];
    if (self) {
        [self addObserver];
    }
    return self;
}

/** 获取单例 */
+ (MsgSyncUtil *)getUtil{
    if (!msgSyncUtil) {
        msgSyncUtil = [[super alloc]init];
    }
    return msgSyncUtil;
}

/*
 功能描述：
 设置消息同步开关的接口
 
 参数说明：
 msgSyncFlag:同步消息开关
 rcv_msg_when_pc_leave_or_offline
 rcv_msg_all_the_time
 
 示例代码：
 [[OpenCtxManager getManager] setMsgSyncFlag:rcv_msg_all_the_time completionHandler:^(int resultCode,NSString *resultMsg)
 {
 NSLog(@"%d,%@",resultCode,resultMsg);
 }];
 
 */
- (void)setMsgSyncFlag:(int)msgSyncFlag completionHandler:(SetMsgSyncFlagResultBlock)completionHandler{
    self.setMsgSyncFlagResultBlock = nil;
    
    if (completionHandler) {
        self.setMsgSyncFlagResultBlock = completionHandler;
    }
    
    if (msgSyncFlag == rcv_msg_when_pc_leave_or_offline || msgSyncFlag == rcv_msg_all_the_time) {
        
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        
        self.userMsgSyncFlag = msgSyncFlag;
        
        if(![[conn getConn]modifyUserInfo:12 andNewValue:[StringUtil getStringValue:msgSyncFlag]]) //修改消息同步标志
        {
            [UserTipsUtil hideLoadingView];
            self.setMsgSyncFlagResultBlock(-1,[StringUtil getLocalizableString:@"specialChoose_request_failed"]);
        }
    }else{
        self.setMsgSyncFlagResultBlock(-1,@"参数不正确");
    }
}


#pragma mark ======处理修改用户资料的通知========

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
    eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
    switch (cmd.cmdId)
    {
        case modify_userinfo_success:
        {
            [conn getConn].userRcvMsgFlag = self.userMsgSyncFlag;
            if (self.setMsgSyncFlagResultBlock) {
                self.setMsgSyncFlagResultBlock(0,@"设置成功");
            }
        }
            break;
        case modify_userinfo_failure:
        {
            if (self.setMsgSyncFlagResultBlock) {
                self.setMsgSyncFlagResultBlock(-1,[StringUtil getLocalizableString:@"usual_failed_to_modify"]);
            }
        }
            break;
        case cmd_timeout:
        {
            if (self.setMsgSyncFlagResultBlock) {
                self.setMsgSyncFlagResultBlock(-1,[StringUtil getLocalizableString:@"modifyGroupName_modify_timeout"]);
            }
        }
            break;
        default:
            break;
    }
    
}

- (int)getMsgSyncFlag{
    return [conn getConn].userRcvMsgFlag;
}


@end
