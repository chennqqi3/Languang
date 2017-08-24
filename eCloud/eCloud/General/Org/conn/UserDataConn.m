//
//  UserDataConn.m
//  eCloud
//
//  Created by shisuping on 14-9-18.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "UserDataConn.h"

#import "RobotConn.h"
#import "eCloudDefine.h"

#import "conn.h"
#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "UserDataDAO.h"
#import "eCloudUser.h"
#import "eCloudDAO.h"
#import "OrgDAO.h"
#import "ASIFormDataRequest.h"
#import "NotificationUtil.h"
#ifdef _LANGUANG_FLAG_
#import "LGMettingUtilARC.h"
#endif

static UserDataConn *userDataConn;
@implementation UserDataConn

+ (UserDataConn *)getConn
{
    if (!userDataConn) {
        userDataConn = [[UserDataConn alloc]init];
    }
    return userDataConn;
}

- (void)sendUserDataSync:(int)userDataType
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    NSString *logStr = @"";
    BOOL needSyncData = NO;
    int oldUpdateTime;
    switch (userDataType) {
            
        case user_data_type_emp:
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,同步常用联系人 old time is %d,new time is %d",__FUNCTION__,_conn.oldCommonEmpUpdateTime,_conn.newCommonEmpUpdateTime]];

            if (_conn.newCommonEmpUpdateTime > _conn.oldCommonEmpUpdateTime) {
                needSyncData = YES;
                oldUpdateTime = _conn.oldCommonEmpUpdateTime;
                logStr = @"发出同步常用联系人指令";
            }
        }
            break;
        case user_data_type_dept:
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,同步常用部门 old time is %d,new time is %d",__FUNCTION__,_conn.oldCommonDeptUpdateTime,_conn.newCommonDeptUpdateTime]];

            if (_conn.newCommonDeptUpdateTime > _conn.oldCommonDeptUpdateTime) {
                needSyncData = YES;
                oldUpdateTime = _conn.oldCommonDeptUpdateTime;
                logStr = @"发出同步常用部门指令";
            }
        }
            break;
        case user_data_type_default_common_emp:
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,同步缺省常用联系人 old time is %d,new time is %d",__FUNCTION__,_conn.oldDefaultCommonEmpUpdateTime,_conn.newDefaultCommonEmpUpdateTime]];

            if (_conn.newDefaultCommonEmpUpdateTime > _conn.oldDefaultCommonEmpUpdateTime) {
                needSyncData = YES;
                oldUpdateTime = _conn.oldDefaultCommonEmpUpdateTime;
                logStr = @"发出同步缺省联系人请求";
            }
        }
            break;
        default:
            break;
    };
    
    if (needSyncData) {

        ROAMDATASYNC roamDataSync;
        memset(&roamDataSync, 0, sizeof(roamDataSync));
        roamDataSync.cRequestType = userDataType;
        roamDataSync.cTerminalType = TERMINAL_IOS;
        roamDataSync.dwUpdatetime = oldUpdateTime;
        roamDataSync.dwUserid = _conn.userId.intValue;
        roamDataSync.dwCompid = [_conn getCompId];
        
        int ret = CLIENT_RoamingDataSync(_conncb, &roamDataSync);
        if (ret == 0) {
            [LogUtil debug:logStr];
        }
    }
}

/** 处理个人数据同步应答 */
- (void)processUserDataSyncAck:(ROAMDATASYNCACK *)info
{
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *userDataDAO = [UserDataDAO getDatabase];
    
    int userDataNum = info->wNum;
    NSMutableArray *mArray = [NSMutableArray array];
    
    for (int i = 0; i < userDataNum; i++)
    {
        int _dataId = info->dwUsersList[i];
        NSLog(@"%d",_dataId);
        [mArray addObject:[StringUtil getStringValue:_dataId]];
    }
    
    int userDataType = info->cResponseType;
    switch (userDataType) {
        case user_data_type_emp:
        {
            [LogUtil debug:[NSString stringWithFormat:@"收到常用联系人同步应答 %d 个",mArray.count]];
            [userDataDAO removeAllCommonEmps:NO];
            [userDataDAO addCommonEmp:mArray andIsDefault:NO];
            
            [userDb saveCommomEmpUpdateTime];
            
        }
            break;
        case user_data_type_dept:
        {
            [LogUtil debug:[NSString stringWithFormat:@"收到常用部门同步应答 %d 个",mArray.count]];
            [userDataDAO removeAllCommonDepts];
            [userDataDAO addCommonDept:mArray];
            
            [userDb saveCommomDeptUpdateTime];
        }
            break;
        case user_data_type_default_common_emp:
        {
            [LogUtil debug:[NSString stringWithFormat:@"收到缺省联系人同步应答 %d 个",mArray.count]];
            [userDataDAO removeAllDefaultCommonEmp];
            [userDataDAO addDefalutCommonEmp:mArray];
            
            [userDb saveDefaultCommomEmpUpdateTime];
        }
            break;
            
        default:
            break;
    }
}


- (BOOL)sendModiRequestWithDataType:(int)userDataType andUpdateType:(int)updateType andData:(NSArray *)dataArray
{
    conn *_conn = [conn getConn];
    CONNCB *_conncb = [_conn getConnCB];
    
    if (!_conncb || (_conn.userStatus != status_online)) {
        [UserTipsUtil showAlert:tips_no_connect];
        return NO;
    }
    
    ROAMDATAMODI _modi;
    memset(&_modi, 0, sizeof(_modi));
    
    _modi.cModifyType = updateType;
    _modi.cRequestType = userDataType;
    _modi.cTerminalType = TERMINAL_IOS;
    _modi.dwUserid = _conn.userId.intValue;
    _modi.wNum = dataArray.count;
    
    int index = 0;
    for (NSString *dataId in dataArray) {
        _modi.dwUsersList[index] = dataId.intValue;
        index++;
    }
    int ret = CLIENT_RoamingDataModi(_conncb,&_modi);
    if (ret == 0) {
        _conn.isUpdateUserDataCmd = true;
        [_conn startTimeoutTimer:15];
        return YES;
    }
    return NO;
}

- (void)processUserDataModiAck:(ROAMDATAMODIACK *)info
{
    eCloudUser *userDb = [eCloudUser getDatabase];
    
    UserDataDAO *_userDataDAO = [UserDataDAO getDatabase];
    conn *_conn = [conn getConn];
    [_conn stopTimeoutTimer];
    _conn.isUpdateUserDataCmd = false;
    
    int _result = info->cResult;
    if (_result == 0) {
        
        int newUpdateTIme = info->dwUpdatetime;

        int dataType = info->cResponseType;
        int dataUpdateType = info->cModifyType;
        
        if (dataType == user_data_type_emp) {
             switch (dataUpdateType) {
                case user_data_update_type_insert:
                {
                    TUserStatusList statusList;
                    CLIENT_user_status_Parse(false,&info->tUserStatus,&statusList);
                    
                    int empCount = statusList.dwUserStatusNum;
//                    for (int i = 0; i < empCount; i++) {
//                        USERSTATUSNOTICE _notice = statusList.szUserStatus[i];
//                        NSLog(@"%d,%d,%d",_notice.cLoginType,_notice.cStatus,_notice.dwUserID);
//                    }
                    [_conn saveEmpStatusOfWanda:&statusList];
                    
                    [LogUtil debug:[NSString stringWithFormat:@"成功增加%d个常用联系人",empCount]];

                }
                    
                    break;
                 case user_data_update_type_delete:
                 {
                     [LogUtil debug:@"删除常用联系人成功"];
                 }
                    break;
                    
                default:
                    break;
            }
            
            _conn.newCommonEmpUpdateTime = newUpdateTIme;
            [userDb saveCommomEmpUpdateTime];
        }
        else if (dataType == user_data_type_dept)
        {
           switch (dataUpdateType) {
                case user_data_update_type_insert:
               {
                   [LogUtil debug:[NSString stringWithFormat:@"成功增加%d常用部门",info->tDeptlist.wNum]];
                }
                    break;
                case user_data_update_type_delete:
                {
                    [LogUtil debug:@"删除常用部门成功"];
                }
                    break;
                    
                default:
                    break;
            }
            _conn.newCommonDeptUpdateTime = newUpdateTIme;
            [userDb saveCommomDeptUpdateTime];
        }
        
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = update_user_data_success;
        
        [[NotificationUtil getUtil]sendNotificationWithName:UPDATE_USER_DATA_NOTIFICATION andObject:_notificationObject andUserInfo:nil];

    }
    else
    {
        [LogUtil debug:@"修改个人漫游数据失败"];
        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
        _notificationObject.cmdId = update_user_data_fail;
        
        [[NotificationUtil getUtil]sendNotificationWithName:UPDATE_USER_DATA_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
    }
}

/** 接收漫游数据修改通知 */
- (void)processUserDataModiNotice:(ROAMDATAMODINOTICE *)info
{
    eCloudUser *userDb = [eCloudUser getDatabase];
    
    UserDataDAO *_userDataDAO = [UserDataDAO getDatabase];
    conn *_conn = [conn getConn];
    
    int newUpdateTIme = info->dwUpdatetime;
    
    int dataType = info->cResponseType;
    int dataUpdateType = info->cModifyType;
    
    
    if (dataType == user_data_type_emp) {
        
        TUserStatusList statusList;
        CLIENT_user_status_Parse(false,&info->tUserStatus,&statusList);
        
        int empCount = statusList.dwUserStatusNum;
        
        NSMutableArray *empIdArray = [NSMutableArray arrayWithCapacity:empCount];
        for (int i = 0; i < empCount; i++) {
            USERSTATUSNOTICE notice = statusList.szUserStatus[i];
            [empIdArray addObject:[StringUtil getStringValue:notice.dwUserID]];
        }

        switch (dataUpdateType) {
            case user_data_update_type_insert:
            {
                [_userDataDAO addCommonEmp:empIdArray andIsDefault:NO];
                
                [LogUtil debug:[NSString stringWithFormat:@"接收通知，增加了%d个常用联系人",empCount]];
 
                [_conn saveEmpStatusOfWanda:&statusList];
            }
                break;
            case user_data_update_type_delete:
            {
                [_userDataDAO removeCommonEmps:empIdArray];
                [LogUtil debug:@"接收通知，删除常用联系人成功"];
            }
                break;
                
            default:
                break;
        }
        
        _conn.newCommonEmpUpdateTime = newUpdateTIme;
        [userDb saveCommomEmpUpdateTime];
    }
    else if (dataType == user_data_type_dept)
    {
        int deptCount = info->tDeptlist.wNum;
        NSMutableArray *deptIdArray = [NSMutableArray arrayWithCapacity:deptCount];
        
        for (int i = 0; i < deptCount; i++) {
            [deptIdArray addObject:[StringUtil getStringValue:info->tDeptlist.dwDept[i]]] ;
        }
        
        switch (dataUpdateType) {
            case user_data_update_type_insert:
            {
                [_userDataDAO addCommonDept:deptIdArray];
                [LogUtil debug:[NSString stringWithFormat:@"接收通知，成功增加%d常用部门",info->tDeptlist.wNum]];
            }
                break;
            case user_data_update_type_delete:
            {
                [_userDataDAO removeCommonDepts:deptIdArray];
                [LogUtil debug:@"接收通知，删除常用部门成功"];
            }
                break;
                
            default:
                break;
        }
        _conn.newCommonDeptUpdateTime = newUpdateTIme;
        [userDb saveCommomDeptUpdateTime];
    }
    else
    {
        
    }
}

-(void)sendSystemGroupSync
{
    conn *_conn = [conn getConn];
    /** 万达需要第一次登录时，从服务器下载数据库文件，此数据库里应该已经包含下载好的组织架构，以及对应的时间戳,如果需要生成这样的数据库文件，就不再收取离线消息了 */
    if (CREATE_ORG_DATABASE_FILE) {
        [StringUtil zipDb];
        
        _conn.connStatus = normal_type;
        
        return;        
    }

    [LogUtil debug:[NSString stringWithFormat:@"%s,old time is %@, new time is %@",__FUNCTION__,_conn.oldVgroupTime,_conn.VgroupTime]];

    eCloudUser *userDb = [eCloudUser getDatabase];
    CONNCB *_conncb = [_conn getConnCB];
 
    _conn.needCountSystemGroup = NO;
    _conn.systemGroupSyncCount = 0;
    _conn.systemGroupCurCount = 0;
    _conn.bigSystemGroupDic = [NSMutableDictionary dictionary];
    
    if ([_conn.oldVgroupTime compare:_conn.VgroupTime ] == NSOrderedAscending)
    {
     
         int oldTime = [_conn.oldVgroupTime intValue];
        int ret = CLIENT_GetRegularGroupInfo(_conncb,oldTime);
        
        if (ret == 0)
        {
            _conn.needCountSystemGroup = YES;
//            NSLog(@"发送同步固定组请求");
        }
    }
    else
    {
        /** 先同步机器人，再获取离线消息 */
        [[RobotConn getConn]syncRobotInfo];
        
//        开始收取离线消息
//        [_conn getOfflineMsgNum];
    }
}

/** 接收固定组创建通知   depracated*/
- (void)processSystemGroupCreateNotice:(CREATEREGULARGROUPNOTICE *)info
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *_userDataDAO = [UserDataDAO getDatabase];
    
    NSString *sysGroupId = [StringUtil getStringByCString:info->aszGroupID];
    
    NSNumber *createEmpId = [NSNumber numberWithInt:info->dwCreaterID];
    NSString *sysGroupName = [StringUtil getStringByCString:info->aszGroupName];
    NSString *updateTime = [StringUtil getStringValue:info->dwTime];
    int sysGroupMemberNum = info->wUserNum;
    
    regulargroup_member member;
    NSMutableArray *memberArray = [NSMutableArray array];
    
    for (int i=0; i< sysGroupMemberNum; i++)
    {
        NSMutableDictionary *memberDic = [NSMutableDictionary dictionary];
        memcpy(&member, &info->aUserList[i], sizeof(regulargroup_member));
        [memberDic setValue:[NSNumber numberWithInt:member.dwUserID] forKey:@"emp_id"];
        [memberDic setValue:sysGroupId forKey:@"conv_id"];
        [memberDic setValue:[NSNumber numberWithInt:member.cAttribute &1] forKey:@"is_admin"];
        [memberArray addObject:memberDic];
    }
    
    NSDictionary *groupDic = [NSDictionary dictionaryWithObjectsAndKeys:createEmpId,@"create_emp_id",sysGroupId,@"conv_id",sysGroupName,@"conv_title",updateTime,@"create_time", nil];
    
    [_userDataDAO addSystemGroup:groupDic andValues:memberArray];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s,%@,%d",__FUNCTION__,[groupDic description],memberArray.count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYSTEM_GROUP_UPDATE_NOTIFICATION object:nil];
    
    [db updateConversationTime:sysGroupId andTime:info->dwTime];
    
//    _conn.VgroupTime = updateTime;
//    [userDb saveVGroupUpdateTime:nil];
//    
//    [_conn getOfflineMsgNum];
}

/** 接收固定群组删除通知 */
- (void)processSystemGroupDeleteNotice:(DELETEREGULARGROUPNOTICE *)info
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *_userDataDAO = [UserDataDAO getDatabase];
    
    NSString *sysGroupId = [StringUtil getStringByCString:info->aszGroupID ];
    NSString *updateTime = [StringUtil getStringValue:info->dwTime];
    
    [_userDataDAO deleteSystemGroup:sysGroupId];
    
    [db updateConversationTime:sysGroupId andTime:updateTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:SYSTEM_GROUP_UPDATE_NOTIFICATION object:nil];
    
    _conn.VgroupTime = updateTime;
    [userDb saveVGroupUpdateTime:nil];
}

/** 接收固定群组名称变化通知  depracated*/
- (void)processSystemGroupNameChangeNotice:(GULARGROUPNAMECHANGENOTICE *)info
{
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *_userDataDao = [UserDataDAO getDatabase];
    
    NSString *sysGroupId = [StringUtil getStringByCString:info->aszGroupID];
    NSString *sysGroupName = [StringUtil getStringByCString:info->aszGroupName];
    NSString *updateTime = [StringUtil getStringValue:info->dwTime];
    int modifyEmpId = info->dwModifyID;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:sysGroupId,@"conv_id",sysGroupName,@"conv_name",updateTime,@"create_time",modifyEmpId,@"modify_id", nil];
    
    [_userDataDao updateSystemGroupName:dic];
    
    /** 发出群组名称修改通知 */
    [_conn sendGroupNameModifyNotification:sysGroupId andNewGroupName:sysGroupName];
    _conn.VgroupTime = updateTime;
    [userDb saveVGroupUpdateTime:nil];
    
    /*
    if([db searchConversationBy:sysGroupId])
	{
		[db updateConvInfo:sysGroupId andType:type andNewValue:sysGroupName];
        
		//	谁修改群名为"新群名"
        //操作人
		int operEmpId = info->dwModifyID;
		NSString *operEmpName;
		if(_conn.userId.intValue == operEmpId)
		{
			operEmpName = [StringUtil getLocalizableString:@"group_notify_big_you"];
		}
		else
		{
			operEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:operEmpId]];
        }
		
		//			发出群组名称修改通知
		[self sendGroupNameModifyNotification:sysGroupId andNewGroupName:sysGroupName];
		
		NSString *operTime = [StringUtil getStringValue:info->dwTime];
		NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_change_group_name_to_y"],operEmpName,sysGroupName];
		[self saveGroupNotifyMsg:sysGroupId andMsg:msgBody andMsgTime:operTime];
//		[db updateConversationTime:sysGroupId andTime:info->dwTime];
        _conn.VgroupTime = updateTime;
        [userDb saveVGroupUpdateTime:nil];
	}
     */
    
}

/** 接收固定群组成员变化通知  depracated*/
- (void)processSystemGroupMemberChangeNotice:(GULARGROUPMEMBERCHANGENOTICE *)info
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *_userDataDao = [UserDataDAO getDatabase];
    
    NSNumber *modifyId = [NSNumber numberWithInt:info->dwModifyID];
    NSString *sysGroupId = [StringUtil getStringByCString:info->aszGroupID];
    int modifyUserNum = info->wUserNum;
    int modifyType = info->cOperType;
    NSString *updateTime = [StringUtil getStringValue:info->dwTime];
    
    regulargroup_member member;
    NSMutableArray *memberArray = [NSMutableArray array];
    
    for (int i =0; i<modifyUserNum; i++)
    {
        NSMutableDictionary *memberDic = [NSMutableDictionary dictionary];
        memcpy(&member, 0, sizeof(info->aUserList[i]));
        [memberDic setValue:[NSNumber numberWithInt:member.dwUserID] forKey:@"emp_id"];
        [memberDic setValue:sysGroupId forKey:@"conv_id"];
        [memberDic setValue:[NSNumber numberWithInt:member.cAttribute &1] forKey:@"is_admin"];
        [memberArray addObject:memberDic];
    }
    
    switch (modifyType)
    {
        case 0:
            [_userDataDao addSystemGroupEmp:memberArray];
            
            NSString *otherNames;
            for (int i =0;i<modifyUserNum;i++) {
                NSDictionary *dic = memberArray[i];
                
                [otherNames appendString:[db getEmpNameByEmpId:[NSString stringWithFormat:@"%i,",[dic valueForKey:@"emp_id"]]]];
            }
            if(otherNames.length > 1)
            {
                [otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
                NSString *msgBody = [NSString stringWithFormat:@"%@加入了群聊",otherNames];
                /** 保存到数据库中 */
                [_conn saveGroupNotifyMsg:sysGroupId andMsg:msgBody andMsgTime:updateTime];
                
                [db updateConversationTime:sysGroupId andTime:info->dwTime];
                _conn.VgroupTime = updateTime;
                [userDb saveVGroupUpdateTime:nil];
            }
            
            break;
        case 1:
            
            [_userDataDao deleteSystemGroupEmp:memberArray];
            [db updateConversationTime:sysGroupId andTime:info->dwTime];
            
            _conn.VgroupTime = updateTime;
            [userDb saveVGroupUpdateTime:nil];
            break;
        case 2:
            
            [_userDataDao setAdminOfSystemGroupEmp:memberArray];
            [db updateConversationTime:sysGroupId andTime:info->dwTime];
            
            _conn.VgroupTime = updateTime;
            [userDb saveVGroupUpdateTime:nil];
            break;
    }
    
}

/** 接收固定组创建通知 大群组 需要分包发送群组 */
- (void)processBigSystemGroupCreateNotice:(CREATEREGULARGROUPPROTOCOL2NOTICE *)info
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    eCloudUser *userDb = [eCloudUser getDatabase];
    UserDataDAO *_userDataDAO = [UserDataDAO getDatabase];
    
    NSString *sysGroupId = [StringUtil getStringByCString:info->aszGroupID];
    
    NSNumber *createEmpId = [NSNumber numberWithInt:info->dwCreaterID];
    NSString *sysGroupName = [StringUtil getStringByCString:info->aszGroupName];
    NSString *updateTime = [StringUtil getStringValue:info->dwTime];

    /** 因为是分包发送，每个包包含的成员已经保存了，现在直接使用 */
    NSMutableArray *memberArray = [_conn.bigSystemGroupDic valueForKey:sysGroupId];
    
//    NSLog(@"%s,memberArray is %@,current user id is %@",__FUNCTION__,[memberArray description],_conn.userId);
    
    int sysGroupMemberNum = info->wTotalNum;
    
    NSDictionary *groupDic = [NSDictionary dictionaryWithObjectsAndKeys:createEmpId,@"create_emp_id",sysGroupId,@"conv_id",sysGroupName,@"conv_title",updateTime,@"create_time", nil];
    
    [_userDataDAO addSystemGroup:groupDic andValues:memberArray];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SYSTEM_GROUP_UPDATE_NOTIFICATION object:nil];
    
    [db updateConversationTime:sysGroupId andTime:info->dwTime];
    
    /** 使用完毕后，删除缓存的数据 */
    [_conn.bigSystemGroupDic removeObjectForKey:sysGroupId];
    
    _conn.VgroupTime = updateTime;
    [userDb saveVGroupUpdateTime:nil];    
}


- (void)getLGCommonGroup:(NSDictionary *)dict
{
    //    http://222.209.223.92:8080/FilesService/usercommongroup?userid=6&timestamp=1499308968054&flag=1
    Emp *emp = [conn getConn].curUser;
    eCloudDAO *db = [eCloudDAO getDatabase];
    int userId = emp.emp_id;
    UInt64 time = [[NSDate date] timeIntervalSince1970]*1000;
#ifdef _LANGUANG_FLAG_
    
    NSString *urlString = [NSString stringWithFormat:@"%@/FilesService/usercommongroup",[LGMettingUtilARC getInterfaceUrl]];
    ASIFormDataRequest *requestForm = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [requestForm setPostValue:[NSString stringWithFormat:@"%d",userId] forKey:@"userid"];
    [requestForm setPostValue:[NSString stringWithFormat:@"%llu",time] forKey:@"timestamp"];
    
    if (dict != nil) {
        [requestForm setPostValue:[NSString stringWithFormat:@"%d",0] forKey:@"flag"];
        [requestForm setPostValue:dict forKey:@"data"];
    }else{
        [requestForm setPostValue:[NSString stringWithFormat:@"%d",1] forKey:@"flag"];
    }
    [requestForm startSynchronous];
    
    if(requestForm.error){
        
        [LogUtil debug:[NSString stringWithFormat:@"获取蓝光固定群组失败 %@",[requestForm.error localizedDescription]]];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"失败",XIANGYUAN_STATUS, nil];
        [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_COMMON_GROUP andObject:nil andUserInfo:dict];
    }
    
    NSString *responseString = requestForm.responseString;
    if (!responseString || responseString.length == 0 ) {
        return;
    }
    //接口有点问题，先把返回的数据写死
    //responseString = @"{\"data\":{\"data\":[{\"chatid\":\"1498635961000129604\",\"subject\":\"林慧,余翰林,吴彪\"},{\"chatid\":\"1498635720000129600\",\"subject\":\"林慧,eeee,余翰林\"}],\"userid\":6},\"flag\":\"1\",\"status\":\"0\",\"timestamp\":\"1499309248986\",\"msg\":\"请求成功\"}";
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    [LogUtil debug:[NSString stringWithFormat:@"获取蓝光固定群组成功 %@",responseDic]];
    [requestForm release];
    
    //    {
    //        data = "";
    //        flag = 0;
    //        msg = "\U8bf7\U6c42\U6210\U529f";
    //        status = 0;
    //        timestamp = 1499674617922;
    //    }
    
    NSNumber *status = responseDic[@"status"];
    if ([status intValue] == 0) {
        
        NSDictionary *dictData = responseDic[@"data"];
        
        if ([dictData isKindOfClass:[NSDictionary class]] && [dictData objectForKey:@"data"]) {
            
            NSArray *jsonArr = dictData[@"data"];
            for (NSDictionary *listDic in jsonArr) {
                
                NSString *chatid = listDic[@"chatid"];
                NSString *subject = listDic[@"subject"];
                BOOL _flag1 = [[UserDataDAO getDatabase] isCommonGroup:chatid];
                if (!_flag1) {
                    
                    if(![db userExistInConvEmp:chatid] )
                    {
                        //	收到群组消息，如果自己不在群中，那么把自己加到群组成员中
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:chatid,@"conv_id",[NSString stringWithFormat:@"%d",userId],@"emp_id",nil];
                        
                        [db addConvEmp:[NSArray arrayWithObject:dic]];
                        
                    }
                    
                    NSDictionary *dic = [db searchConversationBy:chatid];
                    if(dic == nil )
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"固定群组还没有创建，还没有收到创建群组通知，首先在本地先创建一个会话"]];
                        //				多人会话
                        NSString *convType = [StringUtil getStringValue:mutiableType];
                        //				不屏蔽
                        NSString *recvFlag = [StringUtil getStringValue:open_msg];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                             chatid,@"conv_id",
                                             convType,@"conv_type",
                                             subject,@"conv_title",
                                             recvFlag,@"recv_flag",
                                             @"0",@"create_emp_id",
                                             @"",@"create_time",nil];
                        
                        [db addConversation:[NSArray arrayWithObject:dic]];
                        [LogUtil debug:[NSString stringWithFormat:@"从服务器端取群组信息数据"]];
                        [[conn getConn] getGroupInfo:chatid];
                        
                    }
                    [[UserDataDAO getDatabase]addOneCommonGroup:chatid];
                    
                }
            }
        }
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"成功",XIANGYUAN_STATUS, nil];
        [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_COMMON_GROUP andObject:nil andUserInfo:dict];
    }else{
        
        [LogUtil debug:[NSString stringWithFormat:@"获取蓝光固定群组失败 %@",responseDic]];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"失败",XIANGYUAN_STATUS, nil];
        [[NotificationUtil getUtil]sendNotificationWithName:XIANGYUAN_COMMON_GROUP andObject:nil andUserInfo:dict];
    }
#endif
}


@end
