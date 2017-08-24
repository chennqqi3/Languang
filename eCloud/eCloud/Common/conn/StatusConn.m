//

#import "StatusConn.h"
#import "UserDefaults.h"
#import "StatusDAO.h"
#import "conn.h"
#import "talkSessionViewController.h"
#import "contactViewController.h"
#import "Conversation.h"
#import "Emp.h"
#import "personInfoViewController.h"
#import "LogUtil.h"
#import "client.h"
#import "chatMessageViewController.h"
#import "NewOrgViewController.h"
#import "eCloudDAO.h"
#import "Dept.h"
#import "eCloudDefine.h"

StatusConn *_statusConn;

@interface StatusConn()
{
    
}
@property (nonatomic,retain) NSTimer *getStatusTimer;

@end;

@implementation StatusConn

@synthesize commonEmpArray;
@synthesize curViewController;
@synthesize getStatusTimer;

+ (StatusConn *)getConn
{
    if (!_statusConn) {
        _statusConn = [[StatusConn alloc]init];
    }
    return _statusConn;
}

- (void)dealloc
{
    self.curViewController = nil;
    self.commonEmpArray = nil;
    self.getStatusTimer = nil;
    [super dealloc];
}

#pragma mark---获取用户状态---
/** 获取固定订阅者的状态 */
- (BOOL)getCommonEmpStatus
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    if (_conncb == nil) {
        return NO;
    }
    TGetStatusReq getStatusReq;
    memset(&getStatusReq, 0, sizeof(getStatusReq));
    
    getStatusReq.dwCompID = [UserDefaults getCompId];
    getStatusReq.cTerminalType = TERMINAL_IOS;
    getStatusReq.uUserId = _conn.userId.intValue;
    
    /** 请求用户类别拉取范围：1字节
     0-返回全部用户状态
     1-只返回固定订阅关系状态
     2-部门列表
     3-用户列表 */
    
    getStatusReq.cUserType = 1;
    
    int ret = CLIENT_GetUserStatusReq(_conncb,&getStatusReq);
    if (ret == 0) {
        [self performSelectorOnMainThread:@selector(startGetStatusTimer) withObject:nil waitUntilDone:YES];
        return YES;
    }
    return NO;
}

/** 获取某部门的用户的状态 */
- (BOOL)getDeptStatus:(int)deptId
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    if (_conncb == nil) {
        return NO;
    }
    
    TGetStatusReq getStatusReq;
    memset(&getStatusReq, 0, sizeof(getStatusReq));
    
    getStatusReq.dwCompID = [UserDefaults getCompId];
    getStatusReq.cTerminalType = TERMINAL_IOS;
    getStatusReq.uUserId = _conn.userId.intValue;
    
    /** 请求用户类别拉取范围：1字节
     0-返回全部用户状态
     1-只返回固定订阅关系状态
     2-部门列表
     3-用户列表 */
    
    getStatusReq.cUserType = 2;
    getStatusReq.nUserNum = 1;
    getStatusReq.aUserId[0] = deptId;
    
    int ret = CLIENT_GetUserStatusReq(_conncb,&getStatusReq);
    if (ret == 0) {
        NSLog([NSString stringWithFormat:@"获取部门用户状态，部门id是：%d",deptId]);
        
        return YES;
    }
    return NO;
}

/** 获取某些用户的状态 */
- (BOOL)getEmpStatus:(NSArray *)empIdArray
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    if (_conncb == nil) {
        return NO;
    }
    TGetStatusReq getStatusReq;
    memset(&getStatusReq, 0, sizeof(getStatusReq));
    
    getStatusReq.dwCompID = [UserDefaults getCompId];
    getStatusReq.cTerminalType = TERMINAL_IOS;
    getStatusReq.uUserId = _conn.userId.intValue;
    
    /** 请求用户类别拉取范围：1字节
     0-返回全部用户状态
     1-只返回固定订阅关系状态
     2-部门列表
     3-用户列表 */
    
    getStatusReq.cUserType = 3;
    getStatusReq.nUserNum = empIdArray.count;
    for (int i = 0; i < empIdArray.count; i++) {
        getStatusReq.aUserId[i] = [[empIdArray objectAtIndex:i]intValue];
    }
    
    int ret = CLIENT_GetUserStatusReq(_conncb,&getStatusReq);
    if (ret == 0) {
        NSLog([NSString stringWithFormat:@"获取状态：有%d个用户",empIdArray.count]);

        return YES;
    }
    return NO;
}
- (void)getStatus
{
    StatusDAO *statusDAO = [StatusDAO getDatabase];
    conn *_conn = [conn getConn];
    
    /** 用户在线 前台运行状态 没有下载组织架构，也没有收取离线消息 */
    if ((_conn.userStatus == status_online) && ([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive) && (_conn.connStatus == normal_type))
    {
        NSMutableArray *empArray = [NSMutableArray array];
        if (self.curViewController) {
            if ([self.curViewController isKindOfClass:[contactViewController class]]) {
                
                if ([statusDAO needGetStatus:default_contact_list_status_id andType:status_type_contact_list])
                {
                    int maxConatctListGetStatusEmp = [UserDefaults getMaxGetStatusEmpNumberInContactList];

                    /** 停留在会话列表界面，并且需要获取状态，那么找到单聊联系人 */
                    contactViewController *_contact = (contactViewController *)self.curViewController;
                    for (Conversation *_conv in _contact.itemArray){
                        if (_conv.conv_type == singleType && empArray.count < maxConatctListGetStatusEmp) {
                            [empArray addObject:_conv.conv_id];
                        }
                    }
                }
            }
            else if([self.curViewController isKindOfClass:[talkSessionViewController class]])
            {
                talkSessionViewController *talkSession = (talkSessionViewController *)self.curViewController;
                if (talkSession.talkType == singleType) {
                    if ([statusDAO needGetStatus:talkSession.convId andType:status_type_single]) {

                        /** 停留在单人聊天界面，并且需要获取状态 */
                        [empArray addObject:talkSession.convId];
                    }
                }
                else if(talkSession.talkType == mutiableType)
                {
                    if ([statusDAO needGetStatus:talkSession.convId andType:status_type_group]) {

                        /** 停留在群聊界面，并且需要获取状态 */
                        for (Emp *_emp in talkSession.convEmps)
                        {
                            if (_emp.emp_id == _conn.userId.intValue) {
                                continue;
                            }
                            [empArray addObject:[StringUtil getStringValue:_emp.emp_id]];
                        }
                    }
                }
            }
            else if([self.curViewController isKindOfClass:[personInfoViewController class]])
            {
                personInfoViewController *personInfo = (personInfoViewController *)self.curViewController;
                
                NSString *empId = [StringUtil getStringValue:personInfo.emp.emp_id];
                
                if ([statusDAO needGetStatus:empId andType:status_type_single]) {

                    /** 打开了用户资料界面 */
                    [empArray addObject:empId];
                }
            }
            else if([self.curViewController isKindOfClass:[chatMessageViewController class]])
            {
                /** 查看聊天信息界面 */
                chatMessageViewController *chatMsg = (chatMessageViewController *)self.curViewController;
                if (chatMsg.talkType == singleType && chatMsg.convId) {
                    if ([statusDAO needGetStatus:chatMsg.convId andType:status_type_single]) {
                        [empArray addObject:chatMsg.convId];
                    }
                }
                else if(chatMsg.talkType == mutiableType)
                {
                    if ([statusDAO needGetStatus:chatMsg.convId andType:status_type_group]) {
                        for (Emp *_emp in chatMsg.dataArray) {
                            if (_emp.emp_id == _conn.userId.intValue) {
                                continue;
                            }
                            [empArray addObject:[StringUtil getStringValue:_emp.emp_id]];
                        }
                    }
                }
            }
            else if([self.curViewController isKindOfClass:[NewOrgViewController class]])
            {
                NewOrgViewController *newOrgViewController = (NewOrgViewController *)self.curViewController;
                if (newOrgViewController.deptArray.count >= 2)
                {
                    id temp= [newOrgViewController.deptArray lastObject];
                    if ([temp isKindOfClass:[Dept class]])
                    {
                        Dept *dept = (Dept *)temp;
                        if (dept.dept_type == type_dept_normal)
                        {
                            NSArray *tempEpArray=[[eCloudDAO getDatabase] getEmpsByDeptID:dept.dept_id andLevel:0];

                            /** add by shisp 如果本部门有员工，那么获取这个部门的人员状态 */
                            if (tempEpArray.count > 0)
                            {
                                if ([statusDAO needGetStatus:[StringUtil getStringValue:dept.dept_id] andType:status_type_dept])
                                {
                                    [self getDeptStatus:dept.dept_id];
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for (NSString *empId in empArray) {
            if ([self.commonEmpArray containsObject:empId]) {
                [empArray removeObject:empId];
            }
        }
        
        if (empArray.count > 0) {
            int maxGetStatusEmpNumber = [UserDefaults getMaxGetStatusEmpNumber];
            int count = empArray.count;
            if (count > maxGetStatusEmpNumber)
            {
                [LogUtil debug:@"需要获取状态的用户数超过了最大数"];
                while (empArray.count > maxGetStatusEmpNumber) {
                    [empArray removeLastObject];
                }
            }

            /** 开始获取状态 */
            [self getEmpStatus:empArray];
        }
    }
}

- (void)startGetStatusTimer
{    
    if (self.getStatusTimer && [self.getStatusTimer isValid]) {
        [self.getStatusTimer invalidate];
        self.getStatusTimer = nil;
    }
    
    self.getStatusTimer = [NSTimer scheduledTimerWithTimeInterval:[UserDefaults getStatusTimeInterval] target:self selector:@selector(getStatus) userInfo:nil repeats:YES];
    
    StatusDAO *statusDAO = [StatusDAO getDatabase];
    [statusDAO deleteInvalidStatusTime];
    
    [self getStatus];
}
@end
