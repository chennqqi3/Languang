//
//  OpenCtxUtil.m
//  eCloud
//
//  Created by shisuping on 16/1/4.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "OpenCtxUtil.h"
#import "UserDefaults.h"
#import "eCloudDefine.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "Conversation.h"
#import "Emp.h"
#import "talkSessionViewController.h"
#import "talkSessionUtil2.h"
#import "UserTipsUtil.h"

static OpenCtxUtil *openCtxUtil;

@interface OpenCtxUtil()

//新创建的讨论组id
@property (nonatomic,retain) NSString *freshConvId;

//新创建的讨论组标题
@property (nonatomic,retain) NSString *freshConvTitle;

//新创建的讨论组的成员
@property (nonatomic,retain) NSArray *freshConvEmps;

@end

@implementation OpenCtxUtil

@synthesize freshConvId;
@synthesize freshConvTitle;
@synthesize freshConvEmps;

+ (OpenCtxUtil *)getUtil
{
    if (!openCtxUtil) {
        openCtxUtil = [[super alloc]init];
    }
    return openCtxUtil;
}

- (void)createAndOpenConvWithEmpCodes:(NSArray *)empCodeArray andConvTitle:(NSString *)convTitle andCompletionHandler:(CreateAndOpenConvResultBlock)completionHandler
{
    self.createAndOpenConvResultBlock = completionHandler;
    //    增加接收群组创建通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processCreateGroup:) name:CONVERSATION_NOTIFICATION object: nil];
    
    conn *_conn = [conn getConn];
    
    if (!_conn.userId || _conn.userStatus == status_offline)
    {
        [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_user_not_login andVC:nil];
        return;
    }
    
    //    根据账号得到用户id,并且查看当前用户是否在选择的人员里面
    NSMutableArray *convEmps = [NSMutableArray array];
    eCloudDAO *db = [eCloudDAO getDatabase];
    
    BOOL containCurUser = NO;
    
    for (NSString *empCode in empCodeArray)
    {
        Emp *_emp = [db getEmpByUserAccount:empCode];
        if (!_emp) {
            [LogUtil debug:[NSString stringWithFormat:@"%s,没有找到用户 empCode is %@",__FUNCTION__,empCode]];
        }
        else
        {
            [convEmps addObject:_emp];
            
            if (!containCurUser && _emp.emp_id == _conn.userId.intValue)
            {
                containCurUser = YES;
            }
        }
    }
    
    //    把当前登录用户自己加进去
    if (!containCurUser)
    {
        [convEmps addObject:_conn.curUser];
    }
    
    if (convEmps.count <= 1) {
        [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_can_not_find_user andVC:nil];
        return;
    }
    
    if (convEmps.count == 2)
    {
        //            单聊
        NSString *convId = nil;
        NSString *convTitle = nil;
        
        for (Emp *_emp in convEmps)
        {
            if (_emp.emp_id != _conn.userId.intValue)
            {
                convId = [StringUtil getStringValue:_emp.emp_id];
                convTitle = _emp.emp_name;
                break;
            }
        }
        if (convId && convTitle)
        {
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            
            talkSession.titleStr = convTitle;
            talkSession.talkType = singleType;
            talkSession.convEmps = convEmps;
            talkSession.convId = convId;
            talkSession.needUpdateTag = 1;
            
            [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_ok andVC:talkSession];
            return;
        }
        else
        {
            [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_can_not_find_user andVC:nil];
        }
    }
    else
    {
        Conversation *oldConv = [db searchConvsationByConvEmps:convEmps];
        if (oldConv && oldConv.last_msg_id != -1)
        {
            //                有可以复用的聊天
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            
            //	创建多人会话
            talkSession.titleStr = oldConv.conv_title;
            talkSession.talkType = mutiableType;
            talkSession.convId = oldConv.conv_id;
            talkSession.convEmps = convEmps;
            talkSession.needUpdateTag = 1;
            talkSession.last_msg_id = oldConv.last_msg_id;
            [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_ok andVC:talkSession];
            return;
        }
        else
        {
            //            需要创建群组
            self.freshConvId = [talkSessionUtil2 getNewConvIdByNowTime:[_conn getSCurrentTime]];
            self.freshConvEmps = convEmps;
            if (convTitle.length > 0)
            {
                self.freshConvTitle = convTitle;
            }
            else
            {
                self.freshConvTitle = [talkSessionUtil2 getDefaultTitle:mutiableType andConvEmpArray:self.freshConvEmps];
            }
            
            if(![_conn createConversation:self.freshConvId andName:self.freshConvTitle andEmps:self.freshConvEmps])
            {
                [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_create_group_fail andVC:nil];
            }
        }
    }
}


- (void)LGcreateAndOpenConvWithEmpCodes:(NSArray *)empCodeArray andConvTitle:(NSString *)convTitle groupID:(NSString *)groupID andCompletionHandler:(CreateAndOpenConvResultBlock)completionHandler{
    
    self.createAndOpenConvResultBlock = completionHandler;
    //    增加接收群组创建通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processCreateGroup:) name:CONVERSATION_NOTIFICATION object: nil];
    
    conn *_conn = [conn getConn];
    
    if (!_conn.userId || _conn.userStatus == status_offline)
    {
        [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_user_not_login andVC:nil];
        return;
    }
    
    //    根据账号得到用户id,并且查看当前用户是否在选择的人员里面
    NSMutableArray *convEmps = [NSMutableArray array];
    eCloudDAO *db = [eCloudDAO getDatabase];
    
    BOOL containCurUser = NO;
    
    for (NSString *empCode in empCodeArray)
    {
        Emp *_emp = [db getEmpByUserAccount:empCode];
        if (!_emp) {
            [LogUtil debug:[NSString stringWithFormat:@"%s,没有找到用户 empCode is %@",__FUNCTION__,empCode]];
        }
        else
        {
            [convEmps addObject:_emp];
            
            if (!containCurUser && _emp.emp_id == _conn.userId.intValue)
            {
                containCurUser = YES;
            }
        }
    }
    
    //    把当前登录用户自己加进去
    if (!containCurUser)
    {
        [convEmps addObject:_conn.curUser];
    }
    
    if (convEmps.count <= 1) {
        [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_can_not_find_user andVC:nil];
        return;
    }
    
    if (convEmps.count == 2)
    {
        //单聊不做处理
        [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_create_group_fail andVC:nil];;
    }
    else
    {
        Conversation *oldConv = [db getConversationByConvId:groupID];
        if (oldConv && oldConv.last_msg_id != -1)
        {
            //                有可以复用的聊天
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            
            //	创建多人会话
            talkSession.titleStr = oldConv.conv_title;
            talkSession.talkType = mutiableType;
            talkSession.convId = oldConv.conv_id;
            talkSession.convEmps = convEmps;
            talkSession.needUpdateTag = 1;
            talkSession.last_msg_id = oldConv.last_msg_id;
            [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_ok andVC:talkSession];
            return;
        }
        else
        {
            //            需要创建群组
            self.freshConvId = groupID;
            self.freshConvEmps = convEmps;
            if (convTitle.length > 0)
            {
                self.freshConvTitle = convTitle;
            }
            else
            {
                self.freshConvTitle = [talkSessionUtil2 getDefaultTitle:mutiableType andConvEmpArray:self.freshConvEmps];
            }
            
            if(![_conn createConversation:self.freshConvId andName:self.freshConvTitle andEmps:self.freshConvEmps])
            {
                [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_create_group_fail andVC:nil];
            }
        }
    }
    
}

- (void)callCreateAndOpenConvResultBlock:(int)result andVC:(UIViewController *)vc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    self.createAndOpenConvResultBlock(result,vc);
    self.createAndOpenConvResultBlock = nil;
}


- (void)processCreateGroup:(NSNotification *)notification
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    if (self.createAndOpenConvResultBlock)
    {
        eCloudNotification *cmd =(eCloudNotification *)[notification object];
        if (cmd)
        {
            switch (cmd.cmdId) {
                case create_group_success:
                {
                    //            首先判断下群组是否已经存在，如果存在，那么就不用创建了
                    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                    conn *_conn = [conn getConn];
                    if ([_ecloud searchConversationBy:self.freshConvId] == nil)
                    {
                        [talkSessionUtil2 createConversation:mutiableType andConvId:self.freshConvId andTitle:self.freshConvTitle andCreateTime:[_conn getSCurrentTime] andConvEmpArray:self.freshConvEmps andMassTotalEmpCount:0];
                        
                        //		修改last_msg_id标志为0，-1表示没有创建
                        [_ecloud setGroupCreateFlag:self.freshConvId];
                    }
                    
                    //                    打开会话窗口
                    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                    
                    //	创建多人会话
                    talkSession.convId = self.freshConvId;
                    //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                    [UserDefaults saveModifyGroupNameFlag:self.freshConvId];
                    
                    talkSession.titleStr = self.freshConvTitle;
                    talkSession.talkType = mutiableType;
                    talkSession.convEmps = self.freshConvEmps;
                    talkSession.needUpdateTag = 1;
                    talkSession.last_msg_id = 0;
                    [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_ok andVC:talkSession];
                    
                }
                    break;
                case create_group_timeout:
                {
                    [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_create_group_timeout andVC:nil];
                }
                    break;
                case create_group_failure:
                {
                    [self callCreateAndOpenConvResultBlock:createAndOpenConvResult_create_group_fail andVC:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s block为空",__FUNCTION__]];
    }
}

@end
