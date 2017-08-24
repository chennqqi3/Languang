

#import "LauchChatUtil.h"
#import "LaunchChatParm.h"
#import "conn.h"
#import "Emp.h"
#import "NewChooseMemberViewController.h"
#import "Conversation.h"
#import "eCloudDAO.h"
#import "talkSessionViewController.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "ConvRecord.h"
#import "talkSessionUtil2.h"
#import "LogUtil.h"
#import "WXOrgUtil.h"

@interface LauchChatUtil ()

@property (nonatomic,retain) NSString *newConvId;
@property (nonatomic,retain) NSString *newConvTitle;
@property (nonatomic,assign) int newConvType;

@end

static LauchChatUtil *lauchChatUtil;

@implementation LauchChatUtil
{
    eCloudDAO *_ecloud;
}

@synthesize newConvId;
@synthesize newConvTitle;
@synthesize newConvType;

+ (LauchChatUtil *)getLauchChatUtil
{
    if (lauchChatUtil == nil) {
        lauchChatUtil = [[super alloc]init];
    }
    return lauchChatUtil;
}

- (id)init
{
    id _id = [super init];
    if (_id) {
        _ecloud = [eCloudDAO getDatabase];
    }
    return _id;
}

- (BOOL)lauchChatWithUserAccounts:(NSArray *)userAccounts andMsg:(NSString *)messageStr andOpenType:(int)openType andIsSelect:(BOOL)isSelect andVC:(UIViewController *)viewController
{
    if (viewController == nil)
    {
        [LogUtil debug:@"view controller is nil"];
        return NO;
    }
    
    LaunchChatParm *_parm = [[[LaunchChatParm alloc]init]autorelease];
    
    //    保存消息
    if (messageStr && messageStr.length > 0)
    {
        [LogUtil debug:[NSString stringWithFormat:@"有消息参数:%@",messageStr]];
        _parm.hasMessage = YES;
        _parm.messageStr = messageStr;
    }
    
    if (!_parm.hasMessage && openType == 0) {
        [LogUtil debug:@"消息为空，并且不打开会话，属于参数错误"];
        return NO;
    }

//    保存账号
    if (userAccounts && userAccounts.count > 0)
    {
        _parm.hasUserAccounts = YES;
        
        _parm.userAccounts = userAccounts;
        
        conn *_conn = [conn getConn];
        
        NSMutableArray *empArray = [NSMutableArray array];
        
        for (NSString *empCode in userAccounts) {
            Emp *_emp = [_conn getEmpByEmpCode:empCode];
            if (_emp && _emp.emp_id != _conn.userId.intValue)
            {
                [empArray addObject:_emp];
            }
            else
            {
                return NO;
            }
        }
        
        _parm.empArray = empArray;
        [LogUtil debug:[NSString stringWithFormat:@"有账号参数:%@",_parm.userAccounts]];
    }
    
    if (!_parm.hasUserAccounts && !isSelect) {
        [LogUtil debug:@"没有传用户，并且不需要选择，属于参数错误"];
        return NO;
    }

    _parm.openType = openType;
    _parm.isSelect = isSelect;
    _parm.viewController = viewController;
    
    
    if (isSelect)
    {
        [LogUtil debug:@"需要打开选人界面"];
        [self openSelectMember:_parm];
    }
    else
    {
        [self openTalksession:_parm];
    }
    return YES;
}

//打开选择成员界面 并且要传参数进入
- (void)openSelectMember:(LaunchChatParm *)_parm
{
    NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
//    _controller.typeTag = type_from_wanda_app;
//    _controller.lanchChatParm = _parm;
	[_parm.viewController.navigationController pushViewController:_controller animated:YES];
    [_controller release];
}

//打开会话窗口发送消息 或者使用会话窗口发送消息
- (BOOL)openTalksession:(LaunchChatParm *)_parm
{
    conn *_conn = [conn getConn];

    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.fromType = talksession_from_wandaapp;
//    talkSession.lauchChatParm = _parm;

    if (_parm.empArray.count > 1)
    {
        [LogUtil debug:@"会话为群聊类型"];
//        群聊
        self.newConvType = mutiableType;
        
//        把当前用户加到数组里
        NSMutableArray *_empArray = [NSMutableArray arrayWithArray:_parm.empArray];
        [_empArray addObject:_conn.curUser];
        
//        给talkSession 的 convEmps 赋值
        talkSession.convEmps = _empArray;

//        检查是否存在可复用的群组
        Conversation *oldConv = [_ecloud searchConvsationByConvEmps:_empArray];
        if (oldConv)
        {
//            有可复用的群组，可能已经创建，也可能没有创建
            self.newConvId = oldConv.conv_id;
            self.newConvTitle = oldConv.conv_title;
            talkSession.last_msg_id = oldConv.last_msg_id;
            if (oldConv.last_msg_id == -1)
            {
                [LogUtil debug:@"群聊已经存在，但还未真正创建"];
            }
            else
            {
                [LogUtil debug:@"群聊已经存在，并已经创建"];
            }
        }
        else
        {
//            没有可复用的群组，需要新创建群组
            self.newConvTitle = [talkSessionUtil2 getDefaultTitle:self.newConvType andConvEmpArray:_empArray];
            self.newConvId = [talkSessionUtil2 getNewConvIdByNowTime:[_conn getSCurrentTime]];
            talkSession.last_msg_id = -1;
            
            [talkSessionUtil2 createConversation:self.newConvType andConvId:self.newConvId andTitle:self.newConvTitle andCreateTime:[_conn getSCurrentTime] andConvEmpArray:_empArray andMassTotalEmpCount:0];
            
            [LogUtil debug:@"群聊不存在，先在本地创建"];
        }
    }
    else
    {
//        单聊
        Emp *_emp = [_parm.empArray objectAtIndex:0];
        self.newConvType = singleType;
        self.newConvId = [StringUtil getStringValue:_emp.emp_id];
        self.newConvTitle = _emp.emp_name;
        talkSession.convEmps = _parm.empArray;
        [LogUtil debug:@"会话为单聊类型"];
        
        //                检查本地是否存在此单聊会话
        [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:self.newConvId andTitle:self.newConvTitle];

    }
    
    
    if (_parm.hasMessage)
    {
//        保存消息
        ConvRecord *_convRecord = [[ConvRecord alloc]init];
        _convRecord.conv_id = self.newConvId;
        _convRecord.conv_type = self.newConvType;
        _convRecord.msg_type = type_text;
        _convRecord.msg_body = _parm.messageStr;
        _parm.convRecord = _convRecord;
        [_convRecord release];
       
        BOOL saveSuccess = [talkSession saveMsgFromWanda];
        if (!saveSuccess)
        {
            return NO;
        }
//        有消息时，并且打开会话界面时 需要设置标志，并发送消息
        if (_parm.openType == 1)
        {
            [LogUtil debug:@"需要打开会话，那么在打开会话时启用消息发送"];
//            talkSession.sendMsgFromWandaFlag = YES;
        }
    }

    talkSession.titleStr = self.newConvTitle;
    talkSession.talkType = self.newConvType;
    talkSession.convId = self.newConvId;

    if (_parm.openType == 0)
    {
        [LogUtil debug:@"不需要打开会话，那么直接调用发送"];
        [talkSession sendMsgFromWanda];
    }
    else
    {
        talkSession.needUpdateTag = 1;
        [_parm.viewController.navigationController pushViewController:talkSession animated:YES];
    }
    return YES;
}

/** 华夏自己管理通讯录，打开联系人资料时，可以发起单聊接口 */
- (void)openSingleConvFromHXEmpInfo:(NSDictionary *)dic{
    Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:dic];
    
    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.talkType = singleType;
    talkSession.titleStr = _emp.emp_name;
    talkSession.needUpdateTag = 1;
    talkSession.convId = [NSString stringWithFormat:@"%d",_emp.emp_id];
    talkSession.convEmps = [NSArray arrayWithObject:_emp];
    [[NSNotificationCenter defaultCenter] postNotificationName:BACK_TO_CONTACTVIEW_FROM_NEWCHOOSE object:talkSession];
}
@end
