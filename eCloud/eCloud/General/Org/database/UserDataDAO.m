

#import "UserDataDAO.h"
#import "ConvNotification.h"
#import "eCloudDAO.h"
#import "Emp.h"
#import "Dept.h"
#import "StringUtil.h"
#import "Conversation.h"
#import "eCloudDefine.h"
#import "client.h"
#import "conn.h"
#import "WXOrgUtil.h"
#import "NotificationUtil.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "HuaXiaOrgUtil.h"
#endif
static UserDataDAO *_userDataDAO;

//创建常用联系人表
#define table_common_emp @"common_emp"
//联系人id
//是否缺省联系人
#define create_table_common_emp @"create table if not exists common_emp(emp_id integer primary key,is_default integer default 0)"

//创建常用部门表
#define table_common_dept @"common_dept"
//常用部门id
#define create_table_common_dept @"create table if not exists common_dept(dept_id integer primary key)"

//创建固定群组表
#define table_system_group @"system_group"
//固定群组id
//固定群组名称
//创建人
//创建时间
#define create_table_system_group @"create table if not exists system_group(group_id text primary key,group_name text,create_emp_id integer,create_time integer)"

//创建固定群组成员表
//固定群组id
//成员id
//是否管理员
#define table_system_group_member @"system_group_member"
#define create_table_system_group_member @"create table if not exists system_group_member(group_id text,emp_id integer,is_admin integer default 0,primary key(group_id,emp_id))"

typedef enum
{
    only_common_emp = 0,
    only_default_common_emp,
    common_and_default_common_emp
}common_emp_info;

@implementation UserDataDAO

+ (UserDataDAO *)getDatabase
{
    if (!_userDataDAO) {
        _userDataDAO = [[UserDataDAO alloc]init];
    }
    return _userDataDAO;
}

- (void)createTable
{
    [self operateSql:create_table_common_emp Database:_handle toResult:nil];
    [self operateSql:create_table_common_dept Database:_handle toResult:nil];
//    固定群组也保存在会话表里
//    [self operateSql:create_table_system_group Database:_handle toResult:nil];
//    [self operateSql:create_table_system_group_member Database:_handle toResult:nil];
}
#pragma mark ===========常用联系人===============

//添加常用联系人
- (void)addCommonEmp:(NSArray *)empIdArray andIsDefault:(BOOL)isDefault
{
    if (!empIdArray || empIdArray.count == 0) {
        return;
    }
    int _default = 0;
    if (isDefault)
    {
        _default = 1;
    }
 
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:empIdArray.count];
    for (NSString *empId in empIdArray) {
        //        增加或替换
        NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,is_default) values(%@,%d)",table_common_emp,empId,_default];
        [sqlArray addObject:sql];
    }


    if ([self beginTransaction])
    {
        for (NSString *_sql in sqlArray) {
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [_sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
            pthread_mutex_unlock(&add_mutex);
        }
        [self commitTransaction];
    }
    else
    {
        for (NSString *_sql in sqlArray) {
            [self operateSql:_sql Database:_handle toResult:nil];
        }
    }
 
}

//删除多个常用联系人
- (void)removeCommonEmps:(NSArray *)empIdArray
{
    for (NSString *empId in empIdArray) {
        [self removeCommonEmp:empId.intValue];
    }
}

//删除常用联系人
- (void)removeCommonEmp:(int)empId
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where emp_id = %d",table_common_emp,empId];
    [self operateSql:sql Database:_handle toResult:nil];
}

//获取所有常用联系人
//如何排序
- (NSArray *)getAllCommonEmp
{
    /*
//    按照联系人拼音 进行排序
    NSString *sql = [NSString stringWithFormat:@"select distinct(a.emp_id),a.is_default,b.emp_name,b.emp_sex,b.emp_logo,b.emp_name_eng,b.emp_status,b.emp_login_type,b.emp_code,c.permission from %@ a,%@ b,%@ c where a.emp_id = b.emp_id and a.emp_id = c.emp_id order by b.emp_code",table_common_emp,table_employee,table_emp_dept];
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count == 0) {
        return [NSMutableArray array];
    }
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    NSMutableArray *emps = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *_dic in result)
    {
        Emp *_emp = [[Emp alloc]init];
        [_ecloud putDicData:_dic toEmp:_emp];
        int _default = [[_dic valueForKey:@"is_default"]intValue];
        _emp.isDefaultCommonEmp = NO;
        if (_default >= 1) {
            _emp.isDefaultCommonEmp = YES;
        }
        [emps addObject:_emp];
        [_emp release];
    }
    return emps;
     */
    
    NSMutableArray *emps = [NSMutableArray array];
    NSMutableArray *empsPCOnline = [NSMutableArray array];
    NSMutableArray *empsPCLeave = [NSMutableArray array];
    NSMutableArray *empsMobileOnline = [NSMutableArray array];
    NSMutableArray *empsOffline= [NSMutableArray array];
    
    // 按照联系人拼音 进行排序
    NSString *sql = [NSString stringWithFormat:@"select distinct(a.emp_id),a.is_default,b.emp_name,b.emp_sex,b.emp_logo,b.emp_pinyin,b.emp_name_eng,b.emp_status,b.emp_login_type,b.emp_code,c.permission from %@ a,%@ b,%@ c where a.emp_id = b.emp_id and a.emp_id = c.emp_id order by c.emp_sort desc,b.emp_code",table_common_emp,table_employee,table_emp_dept];
    NSArray *result = [self querySql:sql];
    
    if (result.count == 0) {
        return [NSMutableArray array];
    }
    
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    for (NSDictionary *_dic in result)
    {
        Emp *emp = [[Emp alloc]init];
        [_ecloud putDicData:_dic toEmp:emp];
        int _default = [[_dic valueForKey:@"is_default"]intValue];
//#ifdef _XIANGYUAN_FLAG_
#if defined(_XIANGYUAN_FLAG_) || defined(_LANGUANG_FLAG_)
        if ([emp.emp_name isEqualToString:@"文件助手"]) {
            
            continue;
        }
        if ([emp.emp_name rangeOfString:@"会议"].length) {
//            常用联系人里 不显示会议
            continue;
        }
        if ([emp.emp_name rangeOfString:@"秘书"].length) {
            //            常用联系人里 不显示秘书
            continue;
        }
        if ([emp.emp_name rangeOfString:@"广播"].length) {
            //            常用联系人里 不显示广播
            continue;
        }

        
#endif
        emp.isDefaultCommonEmp = NO;
        if (_default >= 1) {
            emp.isDefaultCommonEmp = YES;
        }
        
        if ([eCloudConfig getConfig].needDisplayUserStatus) {
            if (emp.emp_status == status_online)
            {
                if (emp.loginType == TERMINAL_PC)
                {
                    [empsPCOnline addObject:emp];
                }
                else
                {
                    [empsMobileOnline addObject:emp];
                }
            }
            else if (emp.emp_status == status_leave)
            {
                [empsPCLeave addObject:emp];
            }
            else
            {
                [empsOffline addObject:emp];
            }
        }else{
//            不需要显示人员状态时，也不用根据状态排序
            [empsPCOnline addObject:emp];
        }

        [emp release];
    }
    
    [emps addObjectsFromArray:empsPCOnline];
    [emps addObjectsFromArray:empsPCLeave];
    [emps addObjectsFromArray:empsMobileOnline];
    [emps addObjectsFromArray:empsOffline];

    return emps;
}

//获取所有联系人
- (NSArray *)getAllEmp
{
    NSMutableArray *mArr = [NSMutableArray array];
    
    // 按照联系人拼音 进行排序
    NSString *sql = [NSString stringWithFormat:@"select * from %@ order by emp_code desc",table_employee];
    NSMutableArray *result = [self querySql:sql];
    
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    for (NSDictionary *_dic in result)
    {
        Emp *emp = [[Emp alloc]init];
        [_ecloud putDicData:_dic toEmp:emp];
        emp.deptName = [_ecloud getEmpDeptNameByEmpId:[NSString stringWithFormat:@"%d",emp.emp_id]];
        [mArr addObject:emp];
    }
    
    return mArr;
}

//判断一个用户是否常用联系人
- (BOOL)isCommonEmp:(int)empId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where emp_id = %d",table_common_emp,empId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return NO;
    }
    return YES;
}

- (void)addOneCommonEmp:(int)empId andIsDefault:(BOOL)isDefault
{
    int _default = 0;
    if (isDefault) {
        _default = 1;
    }
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,is_default) values(%d,%d)",table_common_emp,empId,_default];
    [self operateSql:sql Database:_handle toResult:nil];
}

//删除所有的常用联系人，不包含缺省联系人
- (void)removeAllCommonEmps:(BOOL)isDefault
{
    int _default = 0;
    if (isDefault) {
        _default = 1;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where is_default = %d",table_common_emp,_default];
    [self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark ===========常用部门===============

//添加部门
- (void)addCommonDept:(NSArray *)deptIdArray
{
    if (!deptIdArray || deptIdArray.count == 0) {
        return;
    }
    NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:deptIdArray.count];
   
    for (NSString *deptId in deptIdArray){
        NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(dept_id) values(%@)",table_common_dept,deptId];
        [sqlArray addObject:sql];
    }
    if ([self beginTransaction]) {
        for (NSString *sql in sqlArray) {
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
            pthread_mutex_unlock(&add_mutex);
        }
        [self commitTransaction];
    }
    else
    {
        for (NSString *sql in sqlArray) {
            [self operateSql:sql Database:_handle toResult:nil];
        }
    }
}

//删除多个部门
- (void)removeCommonDepts:(NSArray *)deptIdArray
{
    for (NSString *deptId in deptIdArray) {
        [self removeCommonDept:deptId.intValue];
    }
}

//删除部门
- (void)removeCommonDept:(int)deptId
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where dept_id = %d",table_common_dept,deptId];
    [self operateSql:sql Database:_handle toResult:nil];
}

//获取所有常用部门
//如何排序
- (NSArray *)getAllCommonDept
{
//    附加的常用部门
    NSMutableArray *addCommonDepts = [NSMutableArray array];
    
//    南航版本要求把用户自己所在部门自动加到常用部门里去
    
    if ([UIAdapterUtil isCsairApp]) {
        
//     查找登录用户所在部门
        NSArray *curUserDeptArray = [[eCloudDAO getDatabase]getUserDeptsArray];
        
        //        判断登录用户所在部门是否是常用部门，如果不是那就需要取出来放到数组里区，如果是，那就不用特别处理

        for (NSNumber *deptId in curUserDeptArray) {
            BOOL isCommonDept = [self isCommonDept:[deptId integerValue]];
            if (isCommonDept) {
                //                    是常用部门
            }else{
                //                    不是常用部门
                NSString *sql = [NSString stringWithFormat:@"select dept_id,dept_name,dept_name_eng from %@ where dept_id = %d ",table_department,[deptId intValue]];
                NSMutableArray *result = [self querySql:sql];
                if (result.count) {
                    for (NSDictionary *_dic in result) {
                        Dept *_dept = [[[Dept alloc]init]autorelease];
                        _dept.dept_id = [[_dic valueForKey:@"dept_id"]intValue];
                        _dept.dept_name = [_dic valueForKey:@"dept_name"];
                        _dept.deptNameEng = [_dic valueForKey:@"dept_name_eng"];
                        [addCommonDepts addObject:_dept];
                    }
                }
            }
        }
    }
    
    NSMutableArray *deptArray = [NSMutableArray arrayWithArray:addCommonDepts];

    NSString *sql = [NSString stringWithFormat:@"select b.dept_id,b.dept_name,b.dept_name_eng from %@ a,%@ b where a.dept_id = b.dept_id order by dept_sort,dept_name",table_common_dept,table_department];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return deptArray;
    }
    for (NSDictionary *_dic in result) {
        Dept *_dept = [[Dept alloc]init];
        _dept.dept_id = [[_dic valueForKey:@"dept_id"]intValue];
        _dept.dept_name = [_dic valueForKey:@"dept_name"];
        _dept.deptNameEng = [_dic valueForKey:@"dept_name_eng"];
        [deptArray addObject:_dept];
        [_dept release];
    }
    return deptArray;
}
//获取所有常用部门
- (NSMutableDictionary *)getAllCommonDeptDic
{
     NSMutableDictionary *deptDic = [[NSMutableDictionary alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select b.dept_id,b.dept_name,b.dept_name_eng from %@ a,%@ b where a.dept_id = b.dept_id order by dept_sort,dept_name",table_common_dept,table_department];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return deptDic;
    }
   

    for (NSDictionary *_dic in result) {
        NSString *key_str=[NSString stringWithFormat:@"%@",[_dic valueForKey:@"dept_id"]];
        [deptDic setObject:@"YES" forKey:key_str];
           }
    return deptDic;
}
//删除所有的常用部门 因为假如常用部门有变化，服务器返回的是全量的常用部门数据
- (void)removeAllCommonDepts
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@",table_common_dept];
    [self operateSql:sql Database:_handle toResult:nil];
}

//是否是常用部门
-(BOOL)isCommonDept:(NSInteger) deptId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where dept_id = %ld",table_common_dept,(long)deptId];
    NSMutableArray *tempArray = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:tempArray];
    if (tempArray.count>0) {
        return YES;
    }
    return NO;
}

#pragma mark ===========固定群组===============

//保存固定群组 @"conv_id" @"conv_title" @"create_emp_id" @"create_time"

- (void)addSystemGroup:(NSDictionary *)dic andValues:(NSArray *)empArray
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    NSString *convId = [mDic valueForKey:@"conv_id"];
    
    if ([_ecloud searchConversationBy:convId] == nil)
    {
        NSString *convType = [StringUtil getStringValue:mutiableType];
        //				屏蔽
        NSString *recvFlag = [StringUtil getStringValue:open_msg];
        
        [mDic setObject:convType forKey:@"conv_type"];
        [mDic setObject:recvFlag forKey:@"recv_flag"];
        
//        增加保存 群组类型 因为龙湖要求普通群组 默认 为 关闭新消息提醒
        [mDic setValue:[NSNumber numberWithInt:system_group_type] forKey:@"group_type"];
        //    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
        //                         grpId,@"conv_id",
        //                         convType,@"conv_type",
        //                         grpName,@"conv_title",
        //                         recvFlag,@"recv_flag",
        //                         [StringUtil getStringValue:createId],@"create_emp_id",
        //                         groupTime,@"create_time",nil];
        
        [_ecloud addConversation:[NSArray arrayWithObject:mDic]];
        
        //    修改下群组类型为固定群组
        [_ecloud updateGroupTypeOfConv:convId andGroupType:system_group_type];
        
        [self addSystemGroupEmp:empArray];
        [LogUtil debug:[NSString stringWithFormat:@"%s 固定群组还不存在，保存固定群组 %@",__FUNCTION__,[mDic valueForKey:@"conv_title"]]];
    }
    else
    {
        [self updateSystemGroup:convId andValues:mDic];
        //先删除成员 再添加
        [_ecloud deleteConvEmpBy:convId];
        [self addSystemGroupEmp:empArray];
        
        //如果在同步到新的固定组之前 收到了离线消息 那么这里群组的类型就不是固定组且convId已存在 确定是固定群组 更新群组类型
        [_ecloud updateGroupTypeOfConv:convId andGroupType:system_group_type];
        [LogUtil debug:[NSString stringWithFormat:@"%s 固定群组已经存在，现在修改固定群组 %@",__FUNCTION__,[mDic valueForKey:@"conv_title"]]];
    }
    
    [[eCloudDAO getDatabase] sendNewConvNotification:mDic andCmdType:add_new_conversation];
    

}

//假设数组的每一个元素是一个Dic
- (void)addSystemGroupEmp:(NSArray *)empArray
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    [_ecloud addConvEmp:empArray];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    for (NSDictionary *_dic in empArray) {
        int empId = [[_dic valueForKey:@"emp_id"]intValue];

        /** 检查用户是否存在，如果不存在那么那么调用华夏的接口去获取 */
        NSString *sql = [NSString stringWithFormat:@"select emp_name from %@ where emp_id = %d",table_employee,empId];
        NSMutableArray *result = [self querySql:sql];
        if (result.count) {
            [LogUtil debug:[NSString stringWithFormat:@"%s %@保存已经存在",__FUNCTION__,[result[0] valueForKey:@"emp_name"]]];
            continue;
        }else{
            /** 调用华夏接口获取用户资料 */
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[_dic valueForKey:@"conv_id"],@"conv_id",[StringUtil getStringValue:mutiableType],@"conv_type", nil];
            
            NSDictionary *huaXiaEmpDic = [[HuaXiaOrgUtil getUtil]getHXEmpInfoByEmpId:empId withUserInfo:userInfo withCompleteHandler:^(NSDictionary *empInfoDic, NSDictionary *userInfo) {
                
                Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:empInfoDic];
                if (_emp) {
                    //                    发出通知给会话列表界面修改某个单聊会话的会话标题
                    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                    [mDic setObject:_emp forKey:@"EMP"];
                    
                    [[NotificationUtil getUtil]sendNotificationWithName:GET_USER_INFO_FROM_HX_NOTIFICATION andObject:nil andUserInfo:mDic];
                }
            }];
            if (huaXiaEmpDic){
                //马上获取到了Emp 保存此Emp
                Emp *_emp = [WXOrgUtil getEmpByHXEmpDic:huaXiaEmpDic];
            }
        }
    }
#endif
    
    for (NSDictionary *_dic in empArray) {
        
//        如果不是管理员用处理吗？
        int isAdmin = [[_dic valueForKey:@"is_admin"]intValue];
        NSString *convId = [_dic valueForKey:@"conv_id"];
        int empId = [[_dic valueForKey:@"emp_id"]intValue];
        [_ecloud setAdminFlagOfConv:convId andEmp:empId andFlag:isAdmin];
 
        NSLog(@"convid is %@ empid is %d isadmin is %d",convId,empId,isAdmin);
//        if (isAdmin == 1) {
//            NSString *convId = [_dic valueForKey:@"conv_id"];
//            int empId = [[_dic valueForKey:@"emp_id"]intValue];
//            [_ecloud setAdminFlagOfConv:convId andEmp:empId andFlag:isAdmin];
//        }
    }
    /*
    NSString *otherNames;
    for (int i =0;i<empArray.count;i++) {
        NSDictionary *dic = empArray[i];
        
        [otherNames appendString:[_ecloud getEmpNameByEmpId:[NSString stringWithFormat:@"%i,",[dic valueForKey:@"emp_id"]]]];
    }
    if(otherNames.length > 1)
    {
        [otherNames deleteCharactersInRange:NSMakeRange(otherNames.length-1, 1)];
        NSString *msgBody = [NSString stringWithFormat:@"%@加入了群聊",otherNames];
        //	保存到数据库中
        
        [_conn saveGroupNotifyMsg:convId andMsg:msgBody andMsgTime:updateTime];
        
        [_ecloud updateConversationTime:sysGroupId andTime:info->dwTime];
    }
    */
}

//更新固定组 "create_emp_id""create_time""conv_title"
-(void)updateSystemGroup:(NSString *)convId andValues:(NSDictionary *)dic
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    [_ecloud updateConversation:convId andValues:dic];
}

-(void)deleteSystemGroupEmp:(NSArray *)empArray
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    [_ecloud deleteConvEmp:empArray];
}

//获取所有的固定群组
- (NSArray *)getALlSystemGroup
{
    return [self getALlGroupByType:system_group_type];
}

- (NSArray *)getGroupsBytype:(int)groupType where:(NSString *)whereSql
{
//    NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type,group_type,conv_title,last_msg_id, 'Y' as display_merge_logo from %@ where conv_type = %d and group_type = %d and conv_title like '%%%@%%' order by conv_title",table_conversation,mutiableType,groupType,whereSql];
//    搜索时搜索所有 返回结果时才判断 如果要搜公司群，那么只返回公司群，如果要搜讨论组，那么返回所有讨论组，包括普通讨论组或者常用讨论组
    NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type,group_type,conv_title,last_msg_id, 'Y' as display_merge_logo from %@ where conv_type = %d and conv_title like '%%%@%%' order by conv_title",table_conversation,mutiableType,whereSql];

    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return result;
    }
    
    BOOL needSave = NO;
    
    NSMutableArray *groups = [NSMutableArray array];
    
    for (NSDictionary *dic in result) {
        Conversation *conv = [[Conversation alloc]init];
        [self putDicData:dic toConversation:conv];
        NSLog(@"%@",[dic description]);
        
        needSave = NO;
        if (groupType == system_group_type){
            if (conv.groupType == system_group_type) {
                needSave = YES;
            }
        }else{
            if (conv.groupType != system_group_type) {
                needSave = YES;
            }
        }
        if (needSave) {
            int totalNum = [[eCloudDAO getDatabase] getAllConvEmpNumByConvId:conv.conv_id];
            conv.totalEmpCount = totalNum;
            [groups addObject:conv];
        }
        [conv release];
    }
    return groups;
}

//判断一个群组是否固定群组
- (BOOL)isSystemGroup:(NSString *)convId
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    int groupType = [db getGroupTypeOfConv:convId];
    if (groupType == system_group_type) {
        return YES;
    }
    return NO;
}

//获取所有的固定群组
- (NSArray *)getALlGroupByType:(int)groupType
{
//    ,merged_logo_name
    NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type,group_type,conv_title,last_msg_id, 'Y' as display_merge_logo from %@ where conv_type = %d and group_type = %d order by conv_title",table_conversation,mutiableType,groupType];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        return result;
    }
    NSMutableArray *groups = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *dic in result) {
        Conversation *conv = [[Conversation alloc]init];
        [self putDicData:dic toConversation:conv];
        NSLog(@"%@",[dic description]);
        
        int totalNum = [[eCloudDAO getDatabase] getAllConvEmpNumByConvId:conv.conv_id];
//        NSString *convTitle = conv.conv_title;
//        conv.conv_title = [NSString stringWithFormat:@"%@(%d)",convTitle,totalNum];
        conv.totalEmpCount = totalNum;
        [groups addObject:conv];
        [conv release];
    }
    return groups;
}

//判断自己释放是固定组的管理员
- (BOOL)isAdminOfConv:(NSString *)convId
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    conn *_conn = [conn getConn];
    
    int isAdmin = [db getAdminFlagOfConv:convId andEmp:_conn.userId.intValue];
    if (isAdmin == 1) {
        return YES;
    }
    return NO;
}

//删除固定组
-(void)deleteSystemGroup:(NSString *)convId
{
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    [_ecloud deleteConvAndConvRecordsBy:convId];
    
}

//设置固定组管理员
-(void)setAdminOfSystemGroupEmp:(NSArray *)empArray
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    for (NSDictionary *_dic in empArray ) {
        int isAdmin = [[_dic valueForKey:@"is_admin"]intValue];
        NSString *convId = [_dic valueForKey:@"conv_id"];
        int empId = [[_dic valueForKey:@"emp_id"]intValue];
        [db setAdminFlagOfConv:convId andEmp:empId andFlag:isAdmin];
    }
}

//更新固定组名称 @"conv_id" @"conv_name" @"create_time" @"modify_id"
-(void)updateSystemGroupName:(NSDictionary *)dic
{
    conn *_conn = [conn getConn];
    eCloudDAO *db = [eCloudDAO getDatabase];
    
    NSDictionary *mDic = [NSDictionary dictionaryWithDictionary:dic];
    
    NSString *convId = [mDic valueForKey:@"conv_id"];
    NSString *newName = [mDic valueForKey:@"conv_name"];
    NSString *operTime = [mDic valueForKey:@"create_time"];
    int operEmpId = [mDic valueForKey:@"modify_id"];
    
    int type = 0;
    [db updateConvInfo:convId andType:type andNewValue:newName];
    
    //	谁修改群名为"新群名"
    //操作人
    NSString *operEmpName;
    if(_conn.userId.intValue == operEmpId)
    {
        operEmpName = [StringUtil getLocalizableString:@"group_notify_big_you"];
    }
    else
    {
        operEmpName = [db getEmpNameByEmpId:[StringUtil getStringValue:operEmpId]];
    }
    
    NSString *msgBody = [NSString stringWithFormat:[StringUtil getLocalizableString:@"group_notify_x_change_group_name_to_y"],operEmpName,newName];
    [_conn saveGroupNotifyMsg:convId andMsg:msgBody andMsgTime:operTime];
    [db updateConversationTime:convId andTime:operTime];
}
//如果是固定群组，那么打开群组资料的时候，有一些选项要屏蔽，那就要根据类型来判断
//4 如果固定组有变化怎么做？convId肯定不会变

//向固定群组，常用群组发送消息

#pragma mark ===========自定义群组===============
//设置为自定义组或取消设置为自定义组
//通过调用 setGroupTypeOfConv即可

//获取所有自定义组
- (NSArray *)getALlCommonGroup
{
    return [self getALlGroupByType:common_group_type];
}

//判断一个群组是否常用群组
- (BOOL)isCommonGroup:(NSString *)convId
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    int groupType = [db getGroupTypeOfConv:convId];
    if (groupType == common_group_type) {
        return YES;
    }
    return NO;
}

//添加一个自定义组
- (void)addOneCommonGroup:(NSString *)convId
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    [db updateGroupTypeOfConv:convId andGroupType:common_group_type];
}

//添加多个自定义组
- (void)addCommonGroups:(NSArray *)convIdArray
{
    for (NSString *convId in convIdArray) {
        [self addOneCommonGroup:convId];
    }
}

//删除一个自定义组
- (void)removeOneCommonGroup:(NSString *)convId
{
    eCloudDAO *db = [eCloudDAO getDatabase];
    [db updateGroupTypeOfConv:convId andGroupType:normal_group_type];
}

// 查询最近普通的讨论组，用户选择可以添加为常用讨论组
- (NSArray *)getRecentNormalGroups
{
    NSString *sql = [NSString stringWithFormat:@"select conv_id,conv_type,conv_title from %@ where conv_type = %d and group_type = %d and display_flag = 0 order by last_msg_time desc limit %d",table_conversation,mutiableType,normal_group_type,max_recent_conv_count];
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count == 0) {
        return result;
    }
    NSMutableArray *normalConvs = [NSMutableArray arrayWithCapacity:result.count];
    for (NSDictionary *dic in result) {
        Conversation *conv = [[Conversation alloc]init];
        [self putDicData:dic toConversation:conv];
        [normalConvs addObject:conv];
        [conv release];
    }
    return normalConvs;
}



- (void)putDicData:(NSDictionary *)dic toConversation:(Conversation *)conv
{
    conv.conv_id = [dic objectForKey:@"conv_id"];
	conv.conv_title = [dic objectForKey:@"conv_title"];
    conv.conv_type = [[dic objectForKey:@"conv_type"]intValue];
    conv.groupType = [[dic objectForKey:@"group_type"]intValue];
    conv.last_msg_id=[[dic objectForKey:@"last_msg_id"]intValue];
    
    [[eCloudDAO getDatabase]processAboutGroupMergedLogoWithConversation:conv andDicData:dic];
}

//什么情况会引起会话删除
//清空聊天记录的时候
//删除会话的
//这里可以增加一个判断，如果是常用群组和固定群组，则要特别处理的

#pragma mark ===========缺省常联系人===============

//添加缺省联系人
-(void)addDefalutCommonEmp:(NSArray*)defalutCommonEmpArray
{
    for (NSString *empId in defalutCommonEmpArray) {
        NSMutableArray *array = [NSMutableArray array];
        
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where emp_id = %@",table_common_emp,empId];
        [self operateSql:sql Database:_handle toResult:array];
        if (array.count>0) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set is_default = %d where emp_id = %@",table_common_emp,common_and_default_common_emp,empId];
            [self operateSql:sql Database:_handle toResult:nil];
        }
        else
        {
            NSString *sql = [NSString stringWithFormat:@"insert into %@ values(%@,%d)",table_common_emp,empId,only_default_common_emp];
            [self operateSql:sql Database:_handle toResult:nil];
        }
    }
   
}

//删除所有缺省联系人
-(void)removeAllDefaultCommonEmp
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSString *sqlQuery = [NSString stringWithFormat:@"select (select count(*) from %@ where is_default = %d) as count1,(select count(*) from %@ where is_default = %d) as count2",table_common_emp,only_default_common_emp,table_common_emp,common_and_default_common_emp];
    [self operateSql:sqlQuery Database:_handle toResult:tempArray];
    
    if (tempArray.count) {
        NSDictionary *dic = [tempArray objectAtIndex:0];
        if ([[dic valueForKey:@"count1"] intValue]>0) {
            NSString *sqlDelete = [NSString stringWithFormat:@"delete from %@ where is_default = %d",table_common_emp,only_default_common_emp];
            [self operateSql:sqlDelete Database:_handle toResult:nil];
        }
        
        if ([[dic valueForKey:@"count2"] intValue]>0) {
            NSString *sqlUpdate = [NSString stringWithFormat:@"update %@ set is_default = %d where is_default = %d",table_common_emp,only_common_emp,common_and_default_common_emp];
            [self operateSql:sqlUpdate Database:_handle toResult:nil];
        }
    }
 
}

//判断是否是缺省联系人
-(BOOL)isDefaultCommonEmp:(int)empId
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where is_default > %d and emp_id = %d",table_common_emp,only_common_emp,empId];
    
    [self operateSql:sql Database:_handle toResult:array];
    if (array.count>0) {
        return YES;
    }else
    {
        return NO;
    }
}

//根据群组id，得到groupTypeValue
- (int)getGroupTypeValueByConvId:(NSString *)convId
{
    int nGroupType = 1;
    if ([self isSystemGroup:convId])
    {
        nGroupType = 2;
    }
    return nGroupType;
}

//查询一个固定群所有的管理员
- (NSDictionary *)getAllAdminOfSystemGroup:(NSString *)convId
{
    NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where conv_id = '%@' and is_admin = 1",table_conv_emp,convId];
    NSMutableArray *result = [self querySql:sql];
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dic in result) {
        [mDic setValue:@"1" forKey:dic[@"emp_id"]];
    }
    return mDic;
}
@end
