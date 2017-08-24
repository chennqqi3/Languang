//
//  OpenCtxManager.m
//  NewOpenCtxTest
//
//  Created by shisuping on 16/6/24.
//  Copyright © 2016年 shisuping. All rights reserved.
//

#import "OpenCtxManager.h"
#import "eCloudDAO.h"
#import "ServerConfig.h"
#import "eCloudUser.h"

#import "ConnResult.h"
#import "AccessConn.h"

#import "LoginConn.h"
#import "JSONKit.h"
#import "APPConn.h"

#import "eCloudDAO.h"

#import "RemindModel.h"

#import "Emp.h"
#import "ImageUtil.h"
#import "UserDefaults.h"

#import "ApplicationManager.h"

#import "eCloudConfig.h"

#import "talkSessionUtil2.h"

#import "Conversation.h"

#import "talkSessionViewController.h"

#import "personInfoViewController.h"
#import "userInfoViewController.h"

#import "NewChooseMemberViewController.h"

#import "Reachability.h"
#import "LogUtil.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "logger.h"

#import "eCloudUser.h"
#import "ServerConfig.h"

#import "ConnResult.h"

#import "StringUtil.h"
#import "eCloudDAO.h"

#import "UserDefaults.h"
#import "conn.h"

#import "LanUtil.h"

#import "eCloudNotification.h"

#import "UIAdapterUtil.h"

#import "StatusConn.h"

#import "EmpLogoConn.h"

#import "folderSizeAndList.h"

#import "LauchChatUtil.h"

#import "EmpLogoUtil.h"

#import "NotificationUtil.h"

#import "WandaNotificationNameDefine.h"

static OpenCtxManager *openCtxManager;
@interface OpenCtxManager () <UIAlertViewDelegate>

@property (nonatomic,retain) NSString *newConvId;
@property (nonatomic,retain) NSString *newConvTitle;
@property (nonatomic,retain) NSArray *newConvEmps;


//block属性
@property (nonatomic,copy) LoginResultBlock loginResultBlock;
@property (nonatomic,copy) GetStatusResultBlock getStatusResultBlock;
@property (nonatomic,copy) GetPortraitResultBlock getPortraitResultBlock;
@property (nonatomic,copy) SetPortraitResultBlock setPortraitResultBlock;

@property (nonatomic,copy) ViewUserInfoResultBlock viewUserInfoResultBlock;
@property (nonatomic,copy) CreateAndOpenConvResultBlock createAndOpenConvResultBlock;
@property (nonatomic,copy) OpenChooseMemberViewResultBlock openChooseMemberViewResultBlock;

@end

@implementation OpenCtxManager
{
    conn *_conn;
}

@synthesize newConvId;
@synthesize newConvTitle;
@synthesize newConvEmps;

@synthesize loginResultBlock;
@synthesize getStatusResultBlock;
@synthesize getPortraitResultBlock;
@synthesize setPortraitResultBlock;

@synthesize viewUserInfoResultBlock;
@synthesize createAndOpenConvResultBlock;
@synthesize openChooseMemberViewResultBlock;

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        [self addNotification];
    }
    return self;
}
+ (OpenCtxManager *)getManager
{
    if (!openCtxManager) {
        openCtxManager = [[super alloc]init];
    }
    return openCtxManager;
}

- (void)dealloc{
    self.newConvEmps = nil;
    self.newConvId = nil;
    self.newConvTitle = nil;
    
    self.viewUserInfoResultBlock = nil;
    self.openChooseMemberViewResultBlock = nil;
    self.createAndOpenConvResultBlock = nil;
    
    self.loginResultBlock = nil;
    self.setPortraitResultBlock = nil;
    self.getPortraitResultBlock = nil;
    self.getStatusResultBlock = nil;
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:CLEAN_ORG_NOTIFICATION object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:com_wanda_ecloud_im_login object:nil];
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:com_wanda_ecloud_im_status object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:com_wanda_ecloud_im_getportrait object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:com_wanda_ecloud_im_setportrait object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


-(void)addNotification
{
    //   增加接收修改头像的通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processSetPortrait:) name:com_wanda_ecloud_im_setportrait object:nil];
    
    
    //    增加接收登录返回值
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLogin:) name:com_wanda_ecloud_im_login object:nil];
    
    //    增加接收万达获取状态广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processGetStatus:) name:com_wanda_ecloud_im_status object:nil];
    
    //    接收获取头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processGetPortrait:) name:com_wanda_ecloud_im_getportrait object:nil];
    
    //    全量更新通讯录的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCleanOrgAlert:) name:CLEAN_ORG_NOTIFICATION object: nil];
    
}

//处理登录返回值
- (void)processLogin:(NSNotification *)_notification
{
    NSDictionary *dic = _notification.userInfo;
    int retCode = [[dic valueForKey:key_login_ret_code]intValue];
    if (self.loginResultBlock) {
        self.loginResultBlock(retCode);
    }
}
//处理状态
- (void)processGetStatus:(NSNotification *)_notification
{
    NSDictionary *dic = _notification.userInfo;
    NSArray *statusArray = [dic valueForKey:key_online_status];
    
    if (self.getStatusResultBlock) {
        self.getStatusResultBlock(statusArray);
    }
}

//处理获取头像
- (void)processGetPortrait:(NSNotification *)_notification
{
    NSDictionary *dic = _notification.userInfo;
    NSString *logoPath = [dic valueForKey:key_logo_path];
    //        update by shisp logoPath里带了账号 用|线分割，需要把账号取出来
    NSArray *_array = [logoPath componentsSeparatedByString:@"|"];
    if (_array.count == 2)
    {
        logoPath = _array[0];
        if (logoPath.length) {
            NSString *userAccount = _array[1];
            [UserDefaults setUserLogoPath:logoPath andUserAccount:userAccount];
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s,logopath is %@",__FUNCTION__,logoPath]];
    if (self.getPortraitResultBlock)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,调用block",__FUNCTION__]];
        self.getPortraitResultBlock(logoPath);
    }
    else
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,block 为 nil",__FUNCTION__]];
    }
}

//处理修改头像通知
- (void)processSetPortrait:(NSNotification *)_notification
{
    NSDictionary *dic = _notification.object;
    NSString *newLogoPath = [dic valueForKey:key_new_logo_path];
    if (newLogoPath)
    {
        if (self.setPortraitResultBlock) {
            self.setPortraitResultBlock(0,newLogoPath);
        }
    }
    else
    {
        NSString *errorMsg = [dic valueForKey:key_update_logo_error_msg];
        if (errorMsg)
        {
            if (self.setPortraitResultBlock) {
                self.setPortraitResultBlock(-1,errorMsg);
            }
        }
    }
    
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
                    if ([_ecloud searchConversationBy:self.newConvId] == nil)
                    {
                        [talkSessionUtil2 createConversation:mutiableType andConvId:self.newConvId andTitle:self.newConvTitle andCreateTime:[_conn getSCurrentTime] andConvEmpArray:self.newConvEmps andMassTotalEmpCount:0];
                        
                        //		修改last_msg_id标志为0，-1表示没有创建
                        [_ecloud setGroupCreateFlag:self.newConvId];
                    }
                    
                    //                    打开会话窗口
                    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
                    
                    //	创建多人会话
                    talkSession.convId = self.newConvId;
                    //                在打开聊天窗口之前，先设置一个标志 需要显示 修改群组名称的按钮
                    [UserDefaults saveModifyGroupNameFlag:self.newConvId];
                    
                    talkSession.titleStr = self.newConvTitle;
                    talkSession.talkType = mutiableType;
                    talkSession.convEmps = self.newConvEmps;
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

//手动触发登录 不判断登录条件
-(void)handleLogin
{
    if([ApplicationManager getManager].isNetworkOk)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s，手动触发登录，不判断登录条件",__FUNCTION__]];
        if(_conn.connStatus == normal_type || _conn.userStatus == status_online)
        {
            [LogUtil debug:@"用户在线,return"];
            //            在线，直接发出登录成功提示
            [_conn sendWandaLoginNotification:RESULT_SUCCESS];
            return;
        }
        
        //	提示用户正在连接
        [[NotificationUtil getUtil]sendNotificationWithName:CONNECTING_NOTIFICATION andObject:nil andUserInfo:nil];
        
        if(_conn.connStatus == linking_type)
        {
            [LogUtil debug:@"current is connecting ,return"];
            return;
        }
        
        //        update by shisp 设置为正在连接
        _conn.connStatus = linking_type;
        
        [[ApplicationManager getManager] loginAction];
    }
}

-(void)autoLogin
{
    [LogUtil debug:[NSString stringWithFormat:@"%s，自动登录",__FUNCTION__]];
    
    if([self needAutoConnect])
    {
        if(_conn.connStatus == normal_type || _conn.userStatus == status_online)
        {
            [LogUtil debug:@"用户在线,return"];
            //            在线，直接发出登录成功提示
            [_conn sendWandaLoginNotification:RESULT_SUCCESS];
            return;
        }
        
        //	提示用户正在连接
        [[NotificationUtil getUtil]sendNotificationWithName:CONNECTING_NOTIFICATION andObject:nil andUserInfo:nil];
        
        if(_conn.connStatus == linking_type)
        {
            [LogUtil debug:@"current is connecting ,return"];
            return;
        }
        
        //        update by shisp 设置为正在连接
        _conn.connStatus = linking_type;
        
        [[ApplicationManager getManager] loginAction];
    }
}

#pragma mark ===========实现接口===========

//手动触发登录IM
- (void)imLoginWithName:(NSString *)userName andPassword:(NSString *)password  completionHandler:(LoginResultBlock)completionHandler;
{
    
    if (completionHandler)
    {
        self.loginResultBlock = completionHandler;
    }
    
    [LogUtil debug:@"手动触发登录im"];
    
    //    保存账号，并发起异步登录im
    
    NSString *lastUserAccount = [UserDefaults getUserAccount];
    if (lastUserAccount && ![lastUserAccount isEqualToString:[userName lowercaseString]]) {
        //        需要关闭数据库
        [[eCloudDAO getDatabase]setDBHandleToNil];
    }
    [UserDefaults setPassword:password forAccount:[userName lowercaseString]];
    
//    查看用户是否之前登录过，如果登陆过，那么打开数据库文件，否则可能会导致会话列表会话为空
    [[ApplicationManager getManager]getAccountProperty];

    [NSThread detachNewThreadSelector:@selector(handleLogin) toTarget:self withObject:nil];
    
}


- (BOOL)canLogoutWithMessage:(NSString **)msg
{
    conn *_conn = [conn getConn];
    NSString *temp = @"";
    if(_conn.connStatus == linking_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_connecting_server"];
    }
    else if(_conn.connStatus == rcv_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_receiving_messages"];
    }
    else if(_conn.connStatus == download_org)
    {
        temp = [StringUtil getLocalizableString:@"settings_loading_organizational_structure"];
    }
    if (temp.length > 0)
    {
        *msg = [NSString stringWithFormat:@"%@",temp];
        return NO;
    }
    int ret = [[eCloudDAO getDatabase]newCloseDatabase];

    if (ret == SQLITE_OK) {
        return YES;
    }
    if (ret == SQLITE_BUSY) {
        *msg = @"正在保存数据，请稍候...";
    }else if (ret == SQLITE_LOCKED){
        *msg = @"数据库异常";
    }else{
        *msg = @"数据库错误";
    }
    return NO;
//    return YES;
}

/** 用户点击了退出按钮 那么判断状态 是否允许用户退出 */
//提示用户不能退出
#define alert_tag_can_not_exit (100)
/** 提示用户是否退出 */
#define alert_tag_exit (101)

- (void)onClickExitButton
{
    NSString *temp;
    BOOL canLogout = [self canLogoutWithMessage:&temp];
    if (canLogout) {
        UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        tipAlert.tag = alert_tag_exit;
        [tipAlert show];
        [tipAlert release];
    }else{
        UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        tipAlert.tag = alert_tag_can_not_exit;
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        [tipAlert show];
        [tipAlert release];
        tipAlert = nil;
    }
}
#pragma mark UIAlertView delegate 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == alert_tag_exit) {
        if (buttonIndex == 0) {
            [[eCloudDAO getDatabase]initDatabase:[conn getConn].userId];
        }else{
            [self imLogoutWithName:nil andExitType:1];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didLogout)]) {
                [self.delegate didLogout];
            }
        }
    }
}

//注销IM
- (void)imLogoutWithName:(NSString *)userName andExitType:(int)exitType
{
    conn *_conn = [conn getConn];
    [_conn logout:exitType];
}

//下载用户头像，头像异步下载完成后，把头像所在路径广播出去
// (void (^)(NSString *logoPath))
- (void)getPortraitPath:(NSString *)userAccount completionHandler:(GetPortraitResultBlock)completionHandler
{
    [LogUtil debug:[NSString stringWithFormat:@"%s userAccount is %@",__FUNCTION__,userAccount]];
    
    if (completionHandler) {
        self.getPortraitResultBlock = completionHandler;
    }
    [[EmpLogoConn getConn]downloadLogoByUserAccount:userAccount];
}


//获取头像的下载URL
- (NSString *)getPortrailtDownloadUrlWithUserAccount:(NSString *)userAccount andLogoType:(int)type
{
    return [[EmpLogoConn getConn]getPortrailtDownloadUrlWithUserAccount:userAccount andLogoType:type];
}

//设置头像的接口
- (void)setPortrait:(UIImage *)newLogoImage completionHandler:(SetPortraitResultBlock)completionHandler
{
//        newLogoImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"female" andType:@"png"]];
//        if (!newLogoImage)
//        {
//            return;//NO;
//        }
    
    if (completionHandler) {
        self.setPortraitResultBlock = completionHandler;
    }
    
    if (!newLogoImage) {
        if (self.setPortraitResultBlock) {
            self.setPortraitResultBlock(-1,@"头像不存在");
        }
        return;
    }
    
    EmpLogoUtil *empLogoUtil = [EmpLogoUtil getUtil];
    empLogoUtil.logoImage = newLogoImage;
    [empLogoUtil uploadImage];
}

/*
 功能描述：
 根据员工工号查询数据库，返回对应的用户资料
 
 参数：
 userCode:员工工号
 
 返回值：
 一个Emp类型的对象，
 */
- (Emp *)getEmpInfoWithUserCode:(NSString *)userCode
{
    if (userCode.length == 0) {
        return nil;
    }
    
    if ([[UserDefaults getUserAccount] isEqual:userCode])
    {
        Emp *_emp = [[eCloudDAO getDatabase]getEmpInfoByUsercode:userCode];
        if (_emp) {
            return _emp;
        }
        return [LoginConn getConn].tempEmp;
    }
    
    return [[eCloudDAO getDatabase]getEmpInfoByUsercode:userCode];
}

- (int)getAppRemindTotalCount
{
    return [[eCloudDAO getDatabase]getAppRemindTotalCount];
}
- (NSArray *)getAppRemindsWithLimit:(int)limit andOffset:(int)offset
{
    return [[eCloudDAO getDatabase]getAppRemindsWithLimit:limit andOffset:offset];
}

- (void)createTestAppRemindsData
{
//    [[eCloudDAO getDatabase]deleteAllBroadcast:appNotice_broadcast];
    
    int now = [[conn getConn]getCurrentTime];
    
    for (int i = 0; i < 50; i++) {
        NSString *senderId = [NSString stringWithFormat:@"100%i",i];
        NSString *recverID = @"123";
        NSString *msgID = [NSString stringWithFormat:@"100%i",i];
        NSString *sendTime = [NSString stringWithFormat:@"%i",(now + i)];
        NSString *msgLen = @"123";
        NSString *title = [NSString stringWithFormat:@"title %i",i];
        
        int broadcastType = appNotice_broadcast;
        
        NSString *tempUrl = [NSString stringWithFormat:@"url %i",i];
        NSString *tempTitle = [NSString stringWithFormat:@"detail %i",i];
        int *unread = 0;
        int *appPushType = 0;
        
        NSDictionary *_dic = [NSDictionary dictionaryWithObjectsAndKeys:tempUrl,APP_PUSH_URL,tempTitle,APP_PUSH_DETAIL,[NSNumber numberWithInt:unread],APP_PUSH_UNREAD,[NSNumber numberWithInt:appPushType],APP_PUSH_TYPE,nil];
        
        NSString *message = [_dic JSONString];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:senderId,@"sender_id",recverID,@"recver_id",msgID,@"msg_id",sendTime,@"sendtime",msgLen,@"msglen",title,@"asz_titile",message,@"asz_message",[NSNumber numberWithInt:broadcastType],@"broadcast_type", nil];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s %@",__FUNCTION__,[dic description]]];
        
        [[eCloudDAO getDatabase] saveBroadcast:[NSArray arrayWithObject:dic]];
        
    }
}

/*
 功能描述：
 给某个账号发送文本消息
 
 参数说明：
 messageStr:要发送的消息
 userAccount:用户账号
 
 返回值
 YES:发送成功
 NO:发送失败
 
 */

- (BOOL)sendTxtMsg:(NSString *)messageStr toUser:(NSString *)userAccount
{
    if (messageStr.length == 0 || userAccount.length == 0) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 参数不对",__FUNCTION__]];
        return NO;
    }
    
    if ([conn getConn].connStatus == not_connect_type) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 用户未登录",__FUNCTION__]];
        return NO;
    }
    
//    根据账号 找用户
    
    Emp *_emp = [[eCloudDAO getDatabase]getEmpByUserAccount:userAccount];
    if (!_emp) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到用户%@",__FUNCTION__,userAccount]];
        return NO;
    }
    
    NSString *convId = [StringUtil getStringValue:_emp.emp_id];
    
    [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:convId andTitle:_emp.emp_name];
    
    conn *_conn = [conn getConn];
    
    NSString *msgBody = [NSString stringWithFormat:@"%@",messageStr];
    
    int nowtimeInt= [_conn getCurrentTime];
    NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
    
    //		信息类型
    NSString *msgType = [StringUtil getStringValue:type_text];
    
    //		信息类型为发送信息
    NSString *msgFlag = [StringUtil getStringValue:send_msg];
    
    //		发送状态为正在发送
    NSString *sendFlag = [StringUtil getStringValue:sending];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",msgBody,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:conv_status_normal],@"receipt_msg_flag", nil];
    
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    
    NSDictionary *_dic =[_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
    
    if(_dic)
    {
        //				添加数据库成功
        //                            msgId = [_dic valueForKey:@"msg_id"];
        NSString *sendMsgId = [_dic valueForKey:@"origin_msg_id"];
        
        bool success = [_conn sendMsg:convId andConvType:singleType andMsgType:type_text andMsg:msgBody andMsgId:[sendMsgId longLongValue]  andTime:nowtimeInt andReceiptMsgFlag:conv_status_normal];
        
        if (!success) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 发送失败%@",__FUNCTION__,messageStr]];
            return NO;
        }
    }else{
        [LogUtil debug:[NSString stringWithFormat:@"%s 保存到数据库失败%@",__FUNCTION__,messageStr]];
        return NO;
    }
    
    return YES;
}


- (void)setRemindToReadWithMsgId:(NSString *)remindMsgId
{
    NSString *convId = [[eCloudDAO getDatabase]getConvIdOfBroadcastConvType:appNoticeBroadcastConvType];
    if (convId) {
        [[eCloudDAO getDatabase]updateBroadcastReadFlagToRead:remindMsgId andUpdateConvId:convId andBroadcastType:appNotice_broadcast];
    }
}

- (void)deleteRemindWithMsgId:(NSString *)remindMsgId
{
    [[eCloudDAO getDatabase] deleteRemindWithMsgId:remindMsgId];
}

- (void)deleteAllRemaid
{
    [[eCloudDAO getDatabase] deleteAllRemaid];
}


//根据登录返回码 返回错误信息
- (NSString *)getErrorMsgByLoginCode:(int)retCode
{
    NSString *errMsg = nil;
    
    switch (retCode) {
        case -1:
        {
            errMsg = [AccessConn getConn].errMsg;
            if (errMsg.length == 0) {
                errMsg = [StringUtil getLocalizableString:@"Connection_failed"];
            }
        }
            break;
        default:{
            ConnResult *_connResult = [[[ConnResult alloc]init]autorelease];
            _connResult.resultCode = retCode;
            errMsg = [_connResult getResultMsg];
        }
            break;
    }
    if (errMsg.length) {
        return errMsg;
    }
    return [StringUtil getLocalizableString:@"connResult_unkonwmError"];
}

/*
 功能描述
 根据账号获取头像路径，如果本地已经下载了此用户的头像，那么就返回本地路径，如果还没有下载，则返回空
 
 参数
 userAccount: NSString类型 用户账号
 
 返回值
 如果本地已经下载了此用户头像，那么返回本地保存的路径，否则返回空
 */
- (NSString *)getUserLogoPathWithUserAccount:(NSString *)userAccount
{
    conn *_conn = [conn getConn];
    
    Emp *_emp = [_conn getEmpByEmpCode:userAccount];
    
    if (!_emp) {
        int empId = [[eCloudUser getDatabase] getUserIdByUserAccount:userAccount];
        if (empId > 0) {
            _emp = [[[Emp alloc]init]autorelease];
            _emp.emp_id = empId;
        }
        else
        {
            empId = [[eCloudDAO getDatabase] getEmpIdByUserAccount:userAccount];
            if (empId > 0) {
                _emp = [[[Emp alloc]init]autorelease];
                _emp.emp_id = empId;
            }
        }
    }
    
    if (_emp && _conn.userId) {
        NSString *empId = [StringUtil getStringValue:_emp.emp_id];
        NSString *logo = default_emp_logo;// _emp.emp_logo;
        NSString *logoPath = [StringUtil getLogoFilePathBy:empId andLogo:logo];
        UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
        if (img)
        {
            return logoPath;
        }
    }
    
    Emp *emp = [[OpenCtxManager getManager] getEmpInfoWithUserCode:userAccount];
    NSString *sex = emp.emp_sex ? @"male.png" : @"female.png";
    return [[StringUtil getBundle] pathForResource:sex ofType:nil];
}

- (void)setDaibanUnreadUrl:(NSString *)url
{
    [UserDefaults setDaibanUnreadRul:url];
}

- (void)initServer:(NSString *)serverIp andPort:(int)port
{
    //    保存参数中的地址和端口
    [eCloudConfig getConfig].primaryServerUrl = serverIp;
    [eCloudConfig getConfig].primaryServerPort = [NSNumber numberWithInt:port];
    
    //    默认 备服务器和主服务器相同
    [eCloudConfig getConfig].secondServerUrl = serverIp;
    [eCloudConfig getConfig].secondServerPort = [NSNumber numberWithInt:port];
}

- (void)initSecondServer:(NSString *)serverIp andPort:(int)port
{
    //    保存参数中的地址和端口
    [eCloudConfig getConfig].primaryServerUrl = serverIp;
    [eCloudConfig getConfig].secondServerPort = [NSNumber numberWithInt:port];
}

//增加一个方法 设置文件服务器 地址 端口 路径
- (void)initFileServer:(NSString *)serverIp andPort:(int)port andServerPath:(NSString *)serverPath
{
    [eCloudConfig getConfig].fileServerUrl = serverIp;
    [eCloudConfig getConfig].fileServerPort = [NSNumber numberWithInt:port];
    [eCloudConfig getConfig].fileServerPath = serverPath;
}

//增加一个方法 设置 机器人 等服务的服务器地址和端口
- (void)initOtherServer:(NSString *)serverIp andPort:(int)port
{
    [eCloudConfig getConfig].otherServerUrl = serverIp;
    [eCloudConfig getConfig].otherServerIp = serverIp;
    [eCloudConfig getConfig].otherServerPort = [NSNumber numberWithInt:port];
}

- (void)setLan:(int)lanType{
    if (lanType == lan_type_cn) {
        [LanUtil setUserlanguage : @"zh-Hans"];
    }else{
        [LanUtil setUserlanguage :@"en"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:REFREASH_CONACTS_LANGUAGE object:nil];
}
@end
