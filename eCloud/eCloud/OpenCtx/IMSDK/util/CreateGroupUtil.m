//
//  CreateGroupUtil.m
//  eCloud
// 
//  Created by shisuping on 17/4/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "CreateGroupUtil.h"
#import "WXOrgUtil.h"
#import "ForwardMsgUtil.h"

#import "eCloudDefine.h"
#import "ConvRecord.h"
#import "OpenCtxDefine.h"
#import "UserDefaults.h"
#import "ApplicationManager.h"

#import "ForwardingRecentViewController.h"

#import "eCloudDAO.h"
#import "conn.h"
#import "LogUtil.h"
#import "Emp.h"
#import "talkSessionViewController.h"
#import "talkSessionUtil2.h"
#import "UserTipsUtil.h"
#import "Conversation.h"

#import "chatMessageViewController.h"
#import "UIAdapterUtil.h"
@interface CreateGroupUtil () <UIAlertViewDelegate>

@property (nonatomic,retain) NSString *freshConvTitle;
@property (nonatomic,retain) NSString *freshConvId;
@property (nonatomic,assign) int freshConvType;
@property (nonatomic,retain) NSMutableArray *nowSelectedEmpArray;

@end

static CreateGroupUtil *createGroupUtil;

@implementation CreateGroupUtil

- (id)init{
    self = [super init];
    if (self) {
        self.typeTag = -1;
        [self addObserver];
    }
    return self;
}

+ (CreateGroupUtil *)getUtil
{
    if (!createGroupUtil) {
        createGroupUtil = [[CreateGroupUtil alloc]init];
    }
    return createGroupUtil;
}


/**
 增加要处理的通知
 */
- (void)addObserver
{
    //	接收分组成员修改通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYMEBER_NOTIFICATION object:nil];
    
    //	分组成员修改 超时通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
}

#pragma mark =====创建讨论组 讨论组添加新成员 转发时从联系人界面选人====
- (void)createGroup:(NSArray *)userArray
{
    
    NSInteger _count = userArray.count;
    if (!userArray || _count == 0) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 用户不存在",__FUNCTION__]];
        return;
    }
   
    userArray = [self convertUserArray:userArray];
    
//    判断是否包含登录用户自己
    BOOL includeCurUser = [self isIncludeCurUser:userArray];
    if (_count == 1) {
        if (includeCurUser) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 只包含了一个用户而且是用户自己",__FUNCTION__]];
            return;
        }else{
//            单聊
            [self createSingleConversation:userArray];
        }
    }else if (_count == 2){
        if (includeCurUser) {
//            单聊
            [self createSingleConversation:userArray];
        }else{
//            把自己加进去群聊
            [self createGroupConversation:userArray];
        }
    }else{
        if (includeCurUser) {
//            直接发起群聊
            [self createGroupConversation:userArray];
        }else{
//            把自己加进去发起群聊
            [self createGroupConversation:userArray];
        }
    }
}

/**
 发起单聊 如果用户选择的联系人里除了自己外只有1个，那就是单聊

 @param userArray 用户选择的联系人
 */
- (void)createSingleConversation:(NSArray *)userArray{
    
//    只有一个人员
    Emp *emp = nil;
    if (userArray.count == 1) {
        emp = userArray[0];
    }else if (userArray.count == 2){
        emp = userArray[0];
        if (emp.emp_id == [conn getConn].userId.intValue) {
            emp = userArray[1];
        }
    }
    
    if (self.typeTag == type_create_conversation) {
//        发起单聊
        talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
        
        talkSession.titleStr=emp.emp_name;
        talkSession.talkType=singleType;
        
        talkSession.convEmps = [NSArray arrayWithObject:emp];
        //			如果是群聊，则不设置convId
        talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
        talkSession.needUpdateTag = 1;
        
        [self hideAndNotifyOpenTalkSession:talkSession];
    }else if (self.typeTag == type_transfer_msg_create_new_conversation){
//        转发给单人 提示用户是否转发
        self.freshConvId = [StringUtil getStringValue:emp.emp_id];
        self.freshConvTitle = emp.emp_name;
        self.freshConvType = singleType;
        
        [self showTransferAlert];
    }
}

/**
 判断创建讨论组，查看是否有可以复用的讨论组，如果有就不用再创建，没有则创建新讨论组
 单聊变群聊；用户选择了多个人创建群聊；转发时选择了创建新会话，都可能会用到这个。

 @param userArray 用户选择的联系人数组
 */
- (void)createGroupConversation:(NSArray *)userArray
{
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:userArray];
    
    BOOL includeCurUser = [self isIncludeCurUser:userArray];
    if (!includeCurUser) {
        [mArray addObject:[conn getConn].curUser];
    }
//    //        要获取
    self.freshConvTitle = [talkSessionUtil2 getDefaultTitle:mutiableType andConvEmpArray:mArray];
//
    self.freshConvId = nil;
//
//    //        首先检查下是否有可用的群组，如果有再判断下这个群组是否已经创建，如果已经创建则直接使用，否则发起创建
    BOOL needCreate = YES;
//
    Conversation *oldConv = [[eCloudDAO getDatabase] searchConvsationByConvEmps:mArray];
    if (oldConv) {
        self.freshConvId = oldConv.conv_id;
        needCreate = NO;
        
      //如果是创建会话，则直接进入可复用会话的聊天界面
        if (self.typeTag == type_create_conversation)
        {
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            //	创建多人会话
            talkSession.titleStr = oldConv.conv_title;
            talkSession.talkType = mutiableType;
            talkSession.convId = oldConv.conv_id;
            talkSession.convEmps = mArray;
            talkSession.needUpdateTag = 1;
            talkSession.last_msg_id = oldConv.last_msg_id;
            
            [self hideAndNotifyOpenTalkSession:talkSession];
        }else if (self.typeTag == type_add_conv_emp){
            //                如果是添加群组成员，并且找到了可以复用的群组
            
            talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
            talkSession.convId = oldConv.conv_id;
            talkSession.talkType = mutiableType;
            talkSession.titleStr = oldConv.conv_title;
            talkSession.convEmps = mArray;
            talkSession.needUpdateTag = 1;
            [talkSession refresh];
            if ([self.currentVC isKindOfClass:[chatMessageViewController class]]) {
                chatMessageViewController *chatMessage = (chatMessageViewController *)(self.currentVC);
                chatMessage.convId = oldConv.conv_id;
                chatMessage.titleStr = oldConv.conv_title;
                chatMessage.talkType = mutiableType;
                chatMessage.start_Delete = NO;
                chatMessage.dataArray= talkSession.convEmps;
                [chatMessage showMemberScrollow];
            }
            
        }else if (self.typeTag == type_transfer_msg_create_new_conversation){
//            转发消息时用户选择了多个人，并且找到了可以复用的讨论组
            self.freshConvId = oldConv.conv_id;
            self.freshConvTitle = oldConv.conv_title;
            self.freshConvType = oldConv.conv_type;
            
            [self showTransferAlert];
            
        }
    }
    
    if (needCreate) {
        
        if ([UserTipsUtil checkNetworkAndUserstatus]) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
            
            //    会话id
            if (self.freshConvId == nil) {
                self.freshConvId = [talkSessionUtil2 getNewConvIdByNowTime:[[conn getConn] getSCurrentTime]];
            }
            //
            self.nowSelectedEmpArray = [NSMutableArray arrayWithArray:mArray];
            if(![[conn getConn] createConversation:self.freshConvId andName:self.freshConvTitle andEmps:mArray])
            {
                //        提示不能创建群聊
                [UserTipsUtil hideLoadingView];
                
                [UserTipsUtil showAlertWithTitle:[StringUtil getLocalizableString:@"hint"] andMessage:[StringUtil getLocalizableString:@"group_creat_group_fail"]];
            }
        }
    }
}

/** 添加讨论组成员 */
- (void)addConvEmp:(NSArray *)userArray{
    
    BOOL isGroupCreate = YES;
    //		把从成员列表页面带过来的convId保存起来
    if([talkSessionViewController getTalkSession].talkType == singleType)
    {
        isGroupCreate = NO;
    }
    NSString *_convId = [talkSessionViewController getTalkSession].convId;
    
    userArray = [self convertUserArray:userArray];
    
    self.nowSelectedEmpArray = [NSMutableArray arrayWithArray:userArray];

    if(isGroupCreate)
    {
//        群组已经创建了，执行加人的操作
        if ([UserTipsUtil checkNetworkAndUserstatus]) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
            
            if(![[conn getConn] modifyGroupMember:_convId andEmps:userArray andOperType:0])
            {
                [UserTipsUtil hideLoadingView];
                [UserTipsUtil showAlertWithTitle:[StringUtil getAlertTitle] andMessage:[StringUtil getLocalizableString:@"specialChoose_request_failed"]];
            }
        }
    }
    else
    {
        if ([self.currentVC isKindOfClass:[chatMessageViewController class]]) {
            //        群组还未创建，先创建群组
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:((chatMessageViewController *)self.currentVC).dataArray];
            [mArray addObjectsFromArray:userArray];
            //        用户选择的人员在加上原来的人员，用来创建一个新的讨论组
            self.nowSelectedEmpArray = [NSMutableArray arrayWithArray:mArray];
            
            [self createGroupConversation:mArray];
        }
    }
}

/** 转发消息给选择的用户 */
- (void)forwardRecordsToUsers:(NSArray *)userArray{

    [self createGroup:userArray];
}


#pragma mark =====公共方法======
/**
 转换数组元素的类型 如果是Emp类型就不用转换；如果是Dic类型，则需要转换

 @param userArray 用户选择的人员
 
 @return 返回Emp类型的userArray
 */
- (NSArray *)convertUserArray:(NSArray *)userArray{
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:userArray.count];
    
    for (NSDictionary *dic in userArray) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:dic];
            if (_emp) {
                [tempArray addObject:_emp];
            }
        }else if ([dic isKindOfClass:[Emp class]]){
            Emp *_emp = (Emp *)dic;
            [tempArray addObject:_emp];
        }
    }
    return tempArray;
}

/**
 数组里是否已包含用户自己
 
 @param userArray 用户选择的人员
 @return 如果包含自己返回YES，否则返回NO
 */
- (BOOL)isIncludeCurUser:(NSArray *)userArray{
    for (Emp *_emp in userArray) {
        if (_emp.emp_id == [conn getConn].userId.intValue) {
            return YES;
        }
    }
    return NO;
}

/**
 发送通知给会话列表界面，打开会话界面
 
 @param talkSession 要打开的会话界面
 */
- (void)hideAndNotifyOpenTalkSession:(talkSessionViewController *)talkSession
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
}

#pragma mark 处理通知
- (void)handleCmd:(NSNotification *)notification
{
    [UserTipsUtil hideLoadingView];
    
    if (self.typeTag == -1) {
        //        [LogUtil debug:[NSString stringWithFormat:@"%s 现在不需要处理通知",__FUNCTION__]];
        return;
    }
    
    eCloudNotification *cmd = (eCloudNotification *)[notification object];
    
    NSDictionary *tempDic = cmd.info;
    //            0 是添加 1是删除
    int operType = [tempDic[@"oper_type"]intValue];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s cmd id is %d operType is %d",__FUNCTION__,cmd.cmdId,operType]];
    
    switch (cmd.cmdId)
    {
        case modify_group_success:
        {
            if (operType == 0) {
                NSMutableArray *tempArray = [NSMutableArray array];
                
                NSMutableString *newMemberName = [NSMutableString string];
                
                for(Emp *_emp in self.nowSelectedEmpArray)
                {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[talkSessionViewController getTalkSession].convId,@"conv_id",[StringUtil getStringValue:_emp.emp_id ],@"emp_id", nil];
                    [tempArray addObject:dic];
                    [newMemberName appendString:[_emp getEmpName]];
                    [newMemberName appendString:@","];
                }
                [[eCloudDAO getDatabase] addConvEmp:tempArray];
                
                if(newMemberName.length > 1)
                {
                    [newMemberName deleteCharactersInRange:NSMakeRange(newMemberName.length - 1, 1)];
                    
                    NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_you_invite_x_join_group"],newMemberName];
                    
                    [[conn getConn] saveGroupNotifyMsg:[talkSessionViewController getTalkSession].convId andMsg:msgBody andMsgTime:[[conn getConn] getSCurrentTime]];
                }
                
                if ([self.currentVC isKindOfClass:[chatMessageViewController class]]) {
                    //                从聊天信息界面选择添加成员，添加成功后，刷新聊天信息界面
                    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                    chatMessageViewController *chatMessageView = ((chatMessageViewController*)self.currentVC);
                    
                    //    目前的总人数
                    [self.nowSelectedEmpArray addObjectsFromArray:chatMessageView.dataArray];
                    
                    talkSession.convEmps = self.nowSelectedEmpArray;
                    talkSession.needUpdateTag = 1;
                    [talkSession refresh];
                    
                    chatMessageView.start_Delete = NO;
                    chatMessageView.dataArray= self.nowSelectedEmpArray;
                    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                    chatMessageView.dataArray = [[eCloudDAO getDatabase] getAllConvEmpBy:[talkSessionViewController getTalkSession].convId];
#endif
                    
                    [chatMessageView showMemberScrollow];
                }
            }
        }
            break;
        case modify_group_failure:
        {
            if (operType == 0) {
                [UserTipsUtil showAlertWithTitle:[StringUtil getLocalizableString:@"hint"] andMessage:[StringUtil getLocalizableString:@"specialChoose_addMember_fail"]];
            }
        }
            break;
        case create_group_success:
        {
            if ([[eCloudDAO getDatabase] searchConversationBy:self.freshConvId] == nil)
            {
                [talkSessionUtil2 createConversation:mutiableType andConvId:self.freshConvId andTitle:self.freshConvTitle andCreateTime:[[conn getConn] getSCurrentTime] andConvEmpArray:self.nowSelectedEmpArray andMassTotalEmpCount:0];
                
                //		修改last_msg_id标志为0，-1表示没有创建
                [[eCloudDAO getDatabase] setGroupCreateFlag:self.freshConvId];
            }
            
            if(self.typeTag == type_create_conversation)
            {
                talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                
                //	创建多人会话
                talkSession.convId = self.freshConvId;
                //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                [UserDefaults saveModifyGroupNameFlag:self.freshConvId];
                
                talkSession.titleStr = self.freshConvTitle;
                talkSession.talkType = mutiableType;
                talkSession.convEmps = self.nowSelectedEmpArray;
                talkSession.needUpdateTag = 1;
                talkSession.last_msg_id = 0;
                
                [self hideAndNotifyOpenTalkSession:talkSession];
            }
            else if (self.typeTag == type_add_conv_emp){
                if ([self.currentVC isKindOfClass:[chatMessageViewController class]]) {
                    //                单聊变群聊
                    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                    chatMessageViewController *chatMessageView = ((chatMessageViewController*)self.currentVC);
                    
                    talkSession.convId = self.freshConvId;
                    //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                    [UserDefaults saveModifyGroupNameFlag:self.freshConvId];
                    
                    talkSession.talkType = mutiableType;
                    talkSession.titleStr = self.freshConvTitle;
                    talkSession.convEmps = self.nowSelectedEmpArray;
                    talkSession.needUpdateTag = 1;
                    [talkSession refresh];
                    
                    chatMessageView.convId = self.freshConvId;
                    chatMessageView.start_Delete = NO;
                    chatMessageView.dataArray= self.nowSelectedEmpArray;
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
                    chatMessageView.dataArray = [[eCloudDAO getDatabase] getAllConvEmpBy:[talkSessionViewController getTalkSession].convId];
#endif
                    
                    chatMessageView.talkType = mutiableType;
                    chatMessageView.create_emp_id = [conn getConn].userId.intValue;
                    chatMessageView.titleStr = self.freshConvTitle;
                    [chatMessageView showMemberScrollow];
                }
            }
            else if (self.typeTag == type_transfer_msg_create_new_conversation){
                //            转发消息时用户选择了多个人，并且已经创建成功
                self.freshConvType = mutiableType;
                [self showTransferAlert];
            }
        }
            break;
        case create_group_timeout:
        {
            [UserTipsUtil showAlertWithTitle:[StringUtil getLocalizableString:@"hint"] andMessage:[StringUtil getLocalizableString:@"group_creat_group_timeout"]];
        }
            break;
        case create_group_failure:
        {
            [UserTipsUtil showAlertWithTitle:[StringUtil getLocalizableString:@"hint"] andMessage:[StringUtil getLocalizableString:@"group_creat_group_fail"]];
        }
            break;
        case cmd_timeout:
        {
            if (operType == 0) {
                [UserTipsUtil showAlertWithTitle:[StringUtil getAlertTitle] andMessage:[StringUtil getLocalizableString:@"specialChoose_Communication_timeout"]];
            }
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark =====转发相关====

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel Button Pressed");
            break;
        case 1:
        {
            //            update by shisp
            if (self.freshConvType == singleType)
            {
                //                检查本地是否存在此单聊会话
                [[talkSessionUtil2 getTalkSessionUtil] createSingleConversation:self.freshConvId andTitle:self.freshConvTitle];
            }
            
            if ([self saveAndSendForwardMsg]) {
                
                if (self.isComeFromFileAssistant){
                    //                    如果发自文件助手，那么直接打开转发的会话
                    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                    
                    talkSession.talkType = self.freshConvType;
                    talkSession.titleStr = self.freshConvTitle;
                    talkSession.convId = self.freshConvId;
                    talkSession.needUpdateTag = 1;
                    
                    // 关闭当前界面
                    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
                    
                    //刷新文件助手页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_ASSISTANT_REFRESH object:nil];
                    return;
                }
                
                if(self.forwardingDelegate && [self.forwardingDelegate respondsToSelector:@selector(showTransferTips)] ) {
                    [self.forwardingDelegate showTransferTips];
                }
            }
            return;
            
        }
            break;
        default:
            break;
    }
}
    


- (BOOL)saveAndSendForwardMsg
{
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    //        修改转发记录的convid和convtype
    for (int i = 0; i < self.forwardRecordsArray.count; i ++) {
        ConvRecord *_convRecord = self.forwardRecordsArray[i];
        _convRecord.conv_id = self.freshConvId;
        _convRecord.conv_type = self.freshConvType;
        _convRecord.receiptMsgFlag = conv_status_normal;
    }
    if ([self.freshConvId isEqualToString:talkSession.convId])
    {
        talkSession.needUpdateTag = 1;
    }
    //     保存并转发多个
    [[ForwardMsgUtil getUtil]saveAndSendForwardMsgArray:self.forwardRecordsArray];
    
    if ([self.currentVC isKindOfClass:[ForwardingRecentViewController class]]) {
        ForwardingRecentViewController *_vc = (ForwardingRecentViewController *)(self.currentVC);
        [_vc dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    return YES;
}

/** 转发提醒，如果是移动网络，还要提示流量 */
- (void)showTransferAlert{
    
    NSString *convTitle = self.freshConvTitle;
    if (self.freshConvType == mutiableType) {
        int convEmpCount = [[eCloudDAO getDatabase]getAllConvEmpNumByConvId:self.freshConvId];
        convTitle = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_groupChats_d"],convEmpCount];
    }
    
    UIAlertView *sendAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"group_sure_sendTo"] message:convTitle delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    
    int netType = [ApplicationManager getManager].netType;
    
    if(netType == type_gprs)
    {
        NSString *sizeStr = [ForwardingRecentViewController getForwardFilesTotalSize:self.forwardRecordsArray];
        if (sizeStr) {
//            只有size不为空才提示，比如文本类型的消息
            sendAlert.title = [NSString stringWithFormat:@"%@%@",[StringUtil getLocalizableString:@"group_sure_sendTo"],convTitle];
            sendAlert.message = [NSString stringWithFormat:[StringUtil getLocalizableString:@"forward_gprs_tips"],[ForwardingRecentViewController getForwardFilesTotalSize:self.forwardRecordsArray]];
        }
    }
    
    [sendAlert show];
    [sendAlert release];
}

@end
