
#import "Emp.h"
#import "PermissionDAO.h"
#import "BlackListModel.h"
#import "LogUtil.h"
#import "PermissionModel.h"
#import "eCloudDAO.h"
#import "WhiteListModel.h"
#import "SpecialListModel.h"
#import "conn.h"

static PermissionDAO *permissionDAO;

@implementation PermissionDAO
@synthesize needReComputeDeptEmpCout;

+ (id)getDatabase
{
    if(permissionDAO == nil)
    {
        permissionDAO = [[PermissionDAO alloc]init];
    }
    return permissionDAO;
}

- (void)addSpeicalUser:(BlackListModel *)_model
{
    NSLog(@"%s",__FUNCTION__);
    conn *_conn = [conn getConn];
    if(_model.userType == type_emp && _model.userId == _conn.userId.intValue)
    {
        NSLog(@"增加的特殊用户是我自己，不用保存到特殊用户列表");
        return;
    }
    
//    查询下增加的特殊部门是不是自己的部门或者父部门
//    找到自己所在的部门
//    找到部门所在的父部门
//    检查特殊部门是否自己的部门或父部门
//    如果是则不做处理
    
    if(_model.userType == type_dept)
    {
        eCloudDAO *db = [eCloudDAO getDatabase];
        NSArray *deptsArray = [db getUserDeptsArray];
        for (NSString *deptId in deptsArray)
        {
            if(deptId.intValue == _model.userId)
            {
                NSLog(@"用户自己所在部门是特殊部门");
                return;
            }
            NSString *parentStr = [_conn getDeptParentStrByDeptId:deptId.intValue];
            if (parentStr)
            {
                NSLog(@"用户所在的部门id为%@,父部门id为%@",deptId,parentStr);
                NSArray *_deptArray = [parentStr componentsSeparatedByString:@","];
                for(NSString *_deptId in _deptArray)
                {
                    if(_model.userId == _deptId.intValue)
                    {
                        NSLog(@"当前用户所在的部门的父部门属于特殊部门，不用保存此特殊用户");
                        return;
                    }
                }
            }
        }
    }
    
    BOOL isBlack = [self isBlack:_model];
    
    if (isBlack)
    {
        NSLog(@"增加了一个特殊用户，并且用户自己没有在白名单里");
        _model.isBlack = 1;
        if(_model.permission.isHidden)
        {
            NSLog(@"黑名单，并且为隐藏");
            self.needReComputeDeptEmpCout = YES;
        }
    }
    else
    {
        NSLog(@"增加了一个特殊用户，并且用户自己在白名单里");
        _model.isBlack = 0;
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(user_id,user_type,hide_type,isblack) values(%d,%d,%d,%d)",table_black_list,_model.userId,_model.userType,_model.hideType,_model.isBlack];
    [self operateSql:sql Database:_handle toResult:nil];
    
    if(_model.isBlack == 0)
    {
        _model.hideType = 0;
    }
    
    [self updateOrgData:_model];
}

- (void)updateOrgData:(BlackListModel *)_model
{
    NSLog(@"%s",__FUNCTION__);
   conn *_conn = [conn getConn];
    if(_model.userType == type_emp)
    {
        NSString *sql = [NSString stringWithFormat:@"update %@ set permission = %d where emp_id = %d",table_emp_dept,_model.hideType,_model.userId];
        [self operateSql:sql Database:_handle toResult:nil];
        
//        如果是状态隐藏，那么把此用户的状态设置为离线，登录类型设置为pc
        
//        并且修改内存中的状态设置
 
        
//        修改内存数据，首先要找到内存里这个员工号的记录，然后设置其permission的值

        NSArray *emps = [_conn getEmpByEmpId:_model.userId];
        for(Emp *_emp in emps)
        {
            if(_model.hideType == 0)
            {
//                查询下对应的部门是否特殊部门，如果是那要设置成部门的permission
                int deptId = _emp.emp_dept;
                NSString *sql = [NSString stringWithFormat:@"select dept_permission from %@ where dept_id = %d",table_department,deptId];
                NSMutableArray *result = [self querySql:sql];
                
                int deptPermission = [[[result objectAtIndex:0]valueForKey:@"dept_permission"]intValue];
                
//                保存到数据库
                sql = [NSString stringWithFormat:@"update %@ set permission = %d where emp_id = %d and dept_id = %d",table_emp_dept,deptPermission,_model.userId,deptId];
                [self operateSql:sql Database:_handle toResult:nil];
                
//                保存到内存
                PermissionModel *permission = [[PermissionModel alloc]init];
                [permission setPermission:deptPermission];
                _emp.permission = permission;
                [permission release];
            }
            else
            {
                PermissionModel *permission = [[PermissionModel alloc]init];
                [permission setPermission:_model.hideType];
                _emp.permission = permission;
                [permission release];
                
//不在这里隐藏状态                
//                if (permission.hideState) {
//                    _emp.loginType = TERMINAL_PC;
//                    _emp.emp_status = status_offline;
//                    
//                    sql = [NSString stringWithFormat:@"update %@ set emp_status = %d and emp_login_type = %d where emp_id = %d",table_employee,status_offline,TERMINAL_PC,_emp.emp_id];
//                    [self operateSql:sql Database:_handle toResult:nil];
//                }
                
            }
        }

    }
    else if(_model.userType == type_dept)
    {
         //            查询部门
        NSString *sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id = %d",table_department,_model.userId];
        NSMutableArray *result = [self querySql:sql];
        if (result && result.count > 0) {
            NSString *subDept = [[result objectAtIndex:0]valueForKey:@"sub_dept"];
            NSMutableArray *tempArray = [subDept componentsSeparatedByString:@","];
            for(NSString *deptId in tempArray)
            {
                sql = [NSString stringWithFormat:@"update %@ set dept_permission = %d where dept_id = %@",table_department,_model.hideType,deptId];
                [self operateSql:sql Database:_handle toResult:nil];
                //            不是特殊用户才修改
                sql = [NSString stringWithFormat:@"update %@ set permission = %d where dept_id = %@ and is_special = 0",table_emp_dept,_model.hideType,deptId];
                [self operateSql:sql Database:_handle toResult:nil];
                
                NSArray *emps = [_conn getEmpsByDeptId:deptId.intValue];
                for(Emp *_emp in emps)
                {
                    
                    //                不是特殊用户才修改
                    if(_emp.isSpecial)
                    {
                        NSLog(@"%@是特殊用户，不用修改成和部门相同",_emp.emp_name);
                    }
                    else
                    {
                        PermissionModel *permission = [[PermissionModel alloc]init];
                        [permission setPermission:_model.hideType];
                        _emp.permission = permission;
                        [permission release];
                    }
                }
            }
        }
    }
}

- (BlackListModel *)getSpeicialUser:(int)userId andUserType:(int)userType
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_id = %d and user_type = %d",table_black_list,userId,userType];
    NSMutableArray *result = [self querySql:sql];
    if(result.count > 0)
    {
        NSDictionary *dic = [result objectAtIndex:0];
        BlackListModel *_model = [[[BlackListModel alloc]init]autorelease];
        _model.userId = userId;
        _model.userType = userType;
        _model.hideType = [[dic valueForKey:@"hide_type"]intValue];
        _model.isBlack = [[dic valueForKey:@"isblack"]intValue];
        return _model;
    }
    return nil;
}

#pragma mark 如果某个特殊用户的白名单变了，那么只是修改下是否黑名单列
- (void)updateSpecialUserBlackFlag:(BlackListModel *)_model
{
    NSLog(@"%s",__FUNCTION__);
    int userId = _model.userId;
    int userType = _model.userType;
    
    NSString *sql = [NSString stringWithFormat:@"update %@ set isblack = %d where user_id = %d and user_type = %d",table_black_list,_model.isBlack,userId,userType];
    [self operateSql:sql Database:_handle toResult:nil];
    
    if(_model.isBlack == 0)
    {
        _model.hideType = 0;
    }
    [self updateOrgData:_model];
}


- (void)updateSpecialUser:(BlackListModel *)_model
{
    NSLog(@"%s",__FUNCTION__);

    int userId = _model.userId;
    int userType = _model.userType;
    
    BlackListModel *tempModel = [self getSpeicialUser:userId andUserType:userType];
    if(tempModel == nil)
    {
        NSLog(@"收到了特殊用户更新，但本地不存在，那么需要添加该特殊用户");
        [self addSpeicalUser:_model];
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"update %@ set hide_type = %d where user_id = %d and user_type = %d",table_black_list,_model.hideType,userId,userType];
        [self operateSql:sql Database:_handle toResult:nil];
        
        if(tempModel.isBlack == 1)
        {
            NSLog(@"修改的特殊用户是黑名单，所以需要特殊处理");
            NSLog(@"old hideType is %d,new hideType is %d",tempModel.hideType,_model.hideType);
            if(tempModel.hideType != _model.hideType)
            {
                NSLog(@"修改了隐藏类型");
                if(tempModel.permission.isHidden || _model.permission.isHidden)
                {
                    NSLog(@"原来隐藏或者现在隐藏，需要重新统计总人数");
                    self.needReComputeDeptEmpCout = YES;
                }
            }
            [self updateOrgData:_model];
        }
    }
}

- (void)deleteSpecialUser:(BlackListModel *)_model
{
    NSLog(@"%s",__FUNCTION__);

    int userId = _model.userId;
    int userType = _model.userType;
    
    BlackListModel *tempModel = [self getSpeicialUser:userId andUserType:userType];
    if(tempModel == nil)
    {
        NSLog(@"收到了特殊用户删除，但本地不存在，直接返回");
        return;
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where user_id = %d and user_type = %d",table_black_list,userId,userType];
        [self operateSql:sql Database:_handle toResult:nil];
        
        if(tempModel.isBlack == 1)
        {
            if(tempModel.permission.isHidden)
            {
                NSLog(@"原来是黑名单，并且隐藏类型是隐藏，那么需要重新计算");
                self.needReComputeDeptEmpCout = YES;
            }
            NSLog(@"删除的特殊用户是黑名单，所以需要特殊处理");
            _model.hideType = 0;
            [self updateOrgData:_model];
        }
    }
}

//有必要就重新计算部门人数
- (void)reComputeDeptEmpCountIfNeed
{
    if(self.needReComputeDeptEmpCout)
    {
        eCloudDAO *db = [eCloudDAO getDatabase];
        [db updateDeptEmpCount];
    }
}

//增加一个白名单
- (void)addWhiteUser:(WhiteListModel *)_model
{
    NSString *sql = [NSString stringWithFormat:@"insert into %@(special_id,special_type,white_id) values(%d,%d,%d)",table_white_list,_model.userId,_model.userType,_model.whiteUserId];
    
    [self operateSql:sql Database:_handle toResult:nil];
}

//删除一个白名单
- (void)deleteWhiteUser:(WhiteListModel *)_model
{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where special_id = %d and special_type = %d and white_id = %d",table_white_list,_model.userId,_model.userType,_model.whiteUserId];
    [self operateSql:sql Database:_handle toResult:nil];
}

//判断一个特殊用户，是否是黑名单
- (BOOL)isBlack:(BlackListModel *)_model
{
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from %@ where special_id = %d and special_type = %d",table_white_list,_model.userId,_model.userType];
    NSMutableArray *result = [self querySql:sql];
    if([[[result objectAtIndex:0]valueForKey:@"_count"]intValue] == 0)
    {
        return YES;
    }
    return NO;
}

//如果是员工，那么是增加，那么就保存为是特殊用户，如果是删除，那么久保存为不是特殊用户，并且修改内存里的值
- (void)saveIfIsSpecial:(SpecialListModel *)model
{
    if(model.userType == type_emp)
    {
        BOOL bIsSpecial = NO;
        int isSpecial = 0;
        if(model.updateType == insertRecord || model.updateType == updateRecord)
        {
            isSpecial = 1;
            bIsSpecial = YES;
        }
        NSString *sql = [NSString stringWithFormat:@"update %@ set is_special = %d where emp_id = %d",table_emp_dept,isSpecial,model.userId];
        [self operateSql:sql Database:_handle toResult:nil];
        
        conn *_conn = [conn getConn];
        NSArray *empArray = [_conn getEmpByEmpId:model.userId];
        for (Emp *_emp in empArray)
        {
            _emp.isSpecial = bIsSpecial;
        }
    }
}

@end
