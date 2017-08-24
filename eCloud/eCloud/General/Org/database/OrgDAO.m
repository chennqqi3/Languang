
//create by shisp 和组织架构相关操作数据库的方法

#define SEARCHLIMIT  100      //通讯录搜索人数限制

//蓝光的部门分隔符是- 默认是/
#ifdef _LANGUANG_FLAG_
#define dept_seperator @"-"
#else
#define dept_seperator @"/"
#endif

#import "OrgDAO.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "WXOrgUtil.h"

#import "Conversation.h"

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
#import "CreateGroupDefine.h"
#import "HuaXiaOrgUtil.h"
#endif


#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"

#import "RecentMember.h"
#import "RecentGroup.h"

#import "RobotDAO.h"
#import "eCloudUser.h"

#import "BlackListModel.h"
#import "PermissionModel.h"
#import "PermissionDAO.h"
#import "DeptInMemory.h"
#import "ChineseToPinyin.h"
#import "LanUtil.h"

#import "eCloudConfig.h"
#import "EmpDeptDL.h"
#import "TalkSessionDefine.h"

#define DEF_IGNOR_DEPT @[@"我的电脑",@"测试"]

@implementation OrgDAO
{
//    是否需要限制 搜索出来的人数，通讯录界面需要限制，但是搜索会话时不限制
    BOOL limitWhenSearchUser;
}

#pragma mark 增加公司
-(void)addCompany:(NSString *)compId andName:(NSString*)compName
{
	NSString *sql = [NSString stringWithFormat:@"insert into %@(comp_id,comp_name) values('%@','%@')",table_company,compId,compName];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark 根据公司id，查询公司的名称
-(NSString *)getCompanyNameBy:(NSString *) compId
{
	NSString * sql = [NSString stringWithFormat:@"select * from %@ where comp_id = '%@'",table_company,compId];
	NSMutableArray *result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] == 1)
	{
		return [[result objectAtIndex:0] objectForKey:@"comp_name"];
	}
	return nil;
}

#pragma mark ---部门----

//把删除的和增加修改的分开，先处理删除的
- (NSArray *)seperateAndDeleteDepts:(NSArray *)info
{
    NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
    NSMutableArray *deleteRecords = [NSMutableArray array];
    for (NSDictionary *dic in info)
    {
        NSNumber *updateType = [dic valueForKey:@"update_type"];
        if (updateType.intValue == deleteRecord)
        {
            [deleteRecords addObject:dic];
        }
        else
        {
            [addOrUpdateRecords addObject:dic];
        }
   }
    
    if (deleteRecords.count > 0)
    {
        [self delDeptsWithTransaction:deleteRecords];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s,addorupdate %d ,delete %d",__FUNCTION__,addOrUpdateRecords.count,deleteRecords.count]];

    return addOrUpdateRecords;

}

#pragma mark 保存部门
-(bool)addDept:(NSArray *)info
{
    int start = [[StringUtil currentTime]intValue];
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
    NSArray *addOrUpdateRecords = [self seperateAndDeleteDepts:info];
    
	bool ret = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
//    add by shisp 保存部门数据的时候，如果是根部门，默认dept_name_contain_parent列默认保存部门名称
    
    //万达版本不需要搜索部门拼音
//    NSArray *keys           =   [NSArray arrayWithObjects:@"dept_id",@"dept_name",@"dept_name_eng",@"dept_parent",@"dept_sort",@"dept_tel",@"dept_pinyin",@"sub_dept",@"dept_name_contain_parent",@"dept_name_contain_parent_eng",@"dept_pinyin_all",@"dept_pinyin_simple",nil];
	 NSArray *keys           =   [NSArray arrayWithObjects:@"dept_id",@"dept_name",@"dept_name_eng",@"dept_parent",@"dept_sort",@"dept_tel",@"sub_dept",@"dept_name_contain_parent",@"dept_name_contain_parent_eng",nil];
    
	if([self beginTransaction])
	{
		NSString *sql;
		
		for (NSDictionary *dic in addOrUpdateRecords)
		{
            
//
			NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//
            NSDictionary *pinyinDic = nil;
            NSString *pinyinAllWithSpace = @"";
            NSString *pinyinAll = @"";
            NSString *pinyinSimple = @"";

            if ([eCloudConfig getConfig].needCreateDeptPinyinByDeptName) {
                pinyinDic = [ChineseToPinyin getPinyinFromString:[dic valueForKey:@"dept_name"]];
                pinyinAllWithSpace = [pinyinDic valueForKey:pinyin_all_with_space];
                pinyinAll = [pinyinDic valueForKey:pinyin_all];
                pinyinSimple = [pinyinDic valueForKey:pinyin_simple];
            }

            [mDic setValue:pinyinAllWithSpace forKey:@"dept_pinyin"];
            [mDic setValue:pinyinAll forKey:@"dept_pinyin_all"];
            [mDic setValue:pinyinSimple forKey:@"dept_pinyin_simple"];
			
            //            add by shisp
            int deptParent = [[dic valueForKey:@"dept_parent"]intValue];
            if(deptParent == 0)
            {
                NSString *deptName = [dic valueForKey:@"dept_name"];
                [mDic setValue:deptName forKey:@"dept_name_contain_parent"];
                
                NSString *deptNameShortCut = [self getDeptNameShortCut:deptName];
                [mDic setValue:deptNameShortCut forKey:@"dept_name"];
                
                NSString *deptNameEng = [dic valueForKey:@"dept_name_eng"];
                [mDic setValue:deptNameEng forKey:@"dept_name_contain_parent_eng"];
            }
            else
            {
                [mDic setValue:@"" forKey:@"dept_name_contain_parent"];
                [mDic setValue:@"" forKey:@"dept_name_contain_parent_eng"];
            }
            
			dic = [NSDictionary dictionaryWithDictionary:mDic];
			sql =   [self replaceIntoTable:table_department newInfo:dic keys:keys];
			
			char *errorMessage;
			
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
			
			if(errorMessage)
                [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];

		}
		[self commitTransaction];
		ret = true;
	}
	
	[pool release];
    
    [LogUtil debug:[NSString stringWithFormat:@"保存部门耗时:%ds",([[StringUtil currentTime]intValue] - start)]];

	return ret;
}

#pragma mark - 获取一级部门简称
- (NSString *)getDeptNameShortCut:(NSString *)deptName{
    NSString *shotcutStr;
    
    if ([deptName rangeOfString:@"集团股份"].length) {
        shotcutStr = @"集团";
    }
    else if ([deptName rangeOfString:@"商业地产"].length){
        shotcutStr = @"商业地产";
    }
    else if ([deptName rangeOfString:@"文化产业"].length){
        shotcutStr = @"文化集团";
    }
    else{
        shotcutStr = deptName;
    }
    
    return shotcutStr;
}

#pragma mark 查询一个部门
-(NSDictionary *)searchDept:(NSString*)deptId
{
	if(deptId && [deptId length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select * from %@ where dept_id = '%@'", table_department,deptId];
        if([self operateSql:sql Database:_handle toResult:result] && 1 == [result count])
        {
            return [result objectAtIndex:0];
        }
    }
    
    return nil;
}

#pragma mark 删除部门
-(void)delDepts:(NSArray *)info
{
	NSString *deptId;
	NSString *sql;
	for(NSDictionary *dic in info)
	{
		deptId = [dic objectForKey:@"dept_id"];
		if([self searchDept:deptId])
		{
			//			删除部门表里的数据
			sql = [NSString stringWithFormat:@"delete from %@ where dept_id = '%@' ",table_department,deptId];
			[self operateSql:sql Database:_handle toResult:nil];
			
			//			删除部门员工表里的数据
			sql = [NSString stringWithFormat:@"delete from %@ where dept_id='%@'",table_emp_dept,deptId];
			[self operateSql:sql Database:_handle toResult:nil];
		}
	}
}

//使用事务提交部门的修改
-(void)delDeptsWithTransaction:(NSArray *)info
{
	NSString *deptId;
	NSString *sql;
    if ([self beginTransaction])
    {
        for(NSDictionary *dic in info)
        {
            deptId = [dic objectForKey:@"dept_id"];
                //			删除部门表里的数据
            sql = [NSString stringWithFormat:@"delete from %@ where dept_id = '%@' ",table_department,deptId];
            
            char *errorMessage;
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
            pthread_mutex_unlock(&add_mutex);
            
            if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        }
        [self commitTransaction];
    }
	
}

#pragma mark 取出某一部门下的所有子部门，通讯录展开部门的时候用到
-(NSArray *)getChildDepts:(NSString*)deptParent
{
//    修改为从内存中获取子部门
	NSMutableArray *childs = [NSMutableArray array];
    conn *_conn = [conn getConn];
    DeptInMemory *_dept = [_conn getDeptInMemoryByDeptId:deptParent.intValue];
    if (_dept) {
        NSString *subDept = _dept.subDept;
        [childs addObjectsFromArray:[subDept componentsSeparatedByString:@","] ];
    }
    return childs;
    
//    
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//	NSString * sql = [NSString stringWithFormat:@"select sub_dept from %@ where dept_id = %@",table_department,deptParent];
//	NSMutableArray *result = [NSMutableArray array];
//	[self operateSql:sql Database:_handle toResult:result];
//	if(result.count > 0)
//	{
//		NSString *subDept = [[result  objectAtIndex:0]valueForKey:@"sub_dept"];
//		[childs addObjectsFromArray:[subDept componentsSeparatedByString:@","] ];
//	}
//	//	[self getChildDepts:deptParent andArray:childs];
//	[pool release];
//	//	[LogUtil debug:[NSString stringWithFormat:@"dept 's childs is %@",childs]];
//	return childs;
}
#pragma mark 取出某一部门所有父部门
-(NSArray *)getParentDepts:(NSString*)deptParent
{
	NSMutableArray *parents = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select dept_parent_dept from %@ where dept_id = %@",table_department,deptParent];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result.count > 0)
	{
		NSString *subDept = [[result  objectAtIndex:0]valueForKey:@"dept_parent_dept"];
		[parents addObjectsFromArray:[subDept componentsSeparatedByString:@","] ];
	}
	//	[self getChildDepts:deptParent andArray:childs];
	[pool release];
	//	[LogUtil debug:[NSString stringWithFormat:@"dept 's childs is %@",childs]];
	return parents;
}

#pragma mark add by shisp 检测下dept_name_contain_parent 字段，如果还没有计算，那么先计算，否则返回
- (void)calculateDeptNameContainParentOfDept
{
//   万达需求 不检查部门的父部门
    return;
    NSString *sql = [NSString stringWithFormat:@"select dept_name_contain_parent from %@ where dept_parent <> 0 limit 1",table_department];
    NSMutableArray *result = [self querySql:sql];
    if(result.count > 0)
    {
        NSDictionary *dic = [result objectAtIndex:0];
        NSString *deptName = [dic valueForKey:@"dept_name_contain_parent"];
        if(!deptName || deptName.length == 0)
        {
            [self saveDeptParentDept];
        }
    }
    
//    检查下根部门是否给新增列dept_name_contain_parent赋值
    sql = [NSString stringWithFormat:@"select dept_name_contain_parent from %@ where dept_parent = 0 limit 1",table_department];
    result = [self querySql:sql];
    if(result.count > 0)
    {
        NSDictionary *dic = [result objectAtIndex:0];
        NSString *deptName = [dic valueForKey:@"dept_name_contain_parent"];
        if(!deptName || deptName.length == 0)
        {
            sql = [NSString stringWithFormat:@"update %@ set dept_name_contain_parent = dept_name where dept_parent = 0",table_department];
            [self operateSql:sql Database:_handle toResult:nil];
        }
       
    }
}

#pragma mark 查询所有的部门id，返回所有的deptid，每个deptid对应的在线人数为0，增加获取部门的所有父部门，统计部门在线人数的时候用到
-(NSArray*)getAllDeptId
{
//    return nil;
    int startTime = [[StringUtil currentTime]intValue];
    [StringUtil usedMemory];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
	NSMutableArray *deptArray = [NSMutableArray array];
    NSMutableDictionary *allDeptsDic = [NSMutableDictionary dictionary];
    
    NSMutableString *colNames = [NSMutableString stringWithString:@"dept_id,dept_name,dept_name_eng"];
    if ([eCloudConfig getConfig].needGetDeptSubDeptToMemory) {
        [colNames appendString:@",sub_dept"];
    }
    if ([eCloudConfig getConfig].needGetDeptParentDeptToMemory) {
        [colNames appendString:@",dept_parent_dept"];
    }
//    泰和版本 客户要求在搜索联系人时 显示 人员部门及父部门
#if defined(_TAIHE_FLAG_) || defined(_LANGUANG_FLAG_)
    colNames = [NSMutableString stringWithString:@"dept_id,dept_name_contain_parent"];
#endif

    
    //    增加获取英文部门名称到内存
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@",colNames,table_department];
    
//    if ([LanUtil isChinese])
//    {
//        sql = [NSString stringWithFormat:@"select dept_id,dept_name_contain_parent,dept_name_contain_parent_eng from %@",table_department];//,sub_dept,dept_parent_dept,dept_name_contain_parent
//    }
//    else
//    {
//        sql = [NSString stringWithFormat:@"select dept_id from %@",table_department];//,sub_dept,dept_parent_dept,dept_name_contain_parent_eng
//    }
    
//    sql = [NSString stringWithFormat:@"select dept_id from %@",table_department];
    
    sqlite3_stmt    *statement	=   nil;
    pthread_mutex_lock(&add_mutex);
    int state  =   sqlite3_prepare(_handle,[sql UTF8String],-1,&statement,nil);
    pthread_mutex_unlock(&add_mutex);
    
    NSString *col_name	=   nil;
    int      col_count			=   0;
    
    while (SQLITE_ROW == sqlite3_step(statement))
    {
        DeptInMemory *_dept = [[DeptInMemory alloc]init];

        col_count   =   sqlite3_column_count(statement);
        
        for (int i = 0; i < col_count; i++)
        {
            col_name    =   [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
            
            if ([col_name isEqualToString:@"dept_id"])
            {
                _dept.deptId = sqlite3_column_int(statement, i);
            }
//            update by shisp 我观察了下这个字段，发现只在特殊用户时使用到了，-(NSString *)getDeptParentStrByDeptId:(int)deptId，万达版本不用
            else if ([eCloudConfig getConfig].needGetDeptParentDeptToMemory && [col_name isEqualToString:@"dept_parent_dept"])
            {
                _dept.deptParentDept = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"dept_name_contain_parent"])
            {
                NSString *tempStr = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
//                泰和 蓝光 客户要求在搜索人员时显示人员部门及父部门
#if defined(_TAIHE_FLAG_) || defined(_LANGUANG_FLAG_)
                NSArray *tempArray = [tempStr componentsSeparatedByString:@"/"];
                int _count = (int)tempArray.count;
                if (_count >= 2) {
                    _dept.deptNameContainParent = [NSString stringWithFormat:@"%@%@%@",tempArray[_count - 2],dept_seperator,tempArray[_count - 1]];
                }else{
                    _dept.deptNameContainParent = tempStr;
                }
                
//                NSLog(@"%s deptid is %d deptname is %@,deptNameContainParent is %@",__FUNCTION__,_dept.deptId,tempStr,_dept.deptNameContainParent);
                
#else
                _dept.deptNameContainParent = tempStr;
                
#endif

            }
//            else if ([col_name isEqualToString:@"dept_name_contain_parent_eng"])
//            {
//                _dept.deptNameContainParentEng = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
//            }
            else if ([eCloudConfig getConfig].needGetDeptSubDeptToMemory && [col_name isEqualToString:@"sub_dept"])
            {
                _dept.subDept = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"dept_name"])
            {
                _dept.deptName = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"dept_name_eng"])
            {
                _dept.deptNameEng = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
                if (_dept.deptNameEng && _dept.deptNameEng.length > 0)
                {
//                    NSLog(@"有英语部门 %@",_dept.deptNameEng);
                }
                else
                {
                    _dept.deptNameEng = nil;
                }
            }
            
        }
        _dept.onlineEmpCount = 0;
        _dept.isChecked = false;
        
        [deptArray addObject:_dept];
        [allDeptsDic setValue:_dept forKey:[StringUtil getStringValue:_dept.deptId]];
        
        [_dept release];
    }
    
    conn *_conn = [conn getConn];
    _conn.allDeptsDic = allDeptsDic;
    _conn.onlineEmpCountArray = deptArray;

    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(statement);
    pthread_mutex_unlock(&add_mutex);
    

	[LogUtil debug:[NSString stringWithFormat:@"%s,部门个数：%d 需要时间:%d",__FUNCTION__,deptArray.count,[[StringUtil currentTime]intValue] - startTime]];
    
    [pool release];
    [StringUtil usedMemory];

	return nil;
}

#pragma mark 查询部门表，查询每一个部门，并且找到其所有直接或间接的子部门，并保存到相应数据库
-(bool)saveDeptSubDept
{
    if (![[eCloudConfig getConfig]needCalculateDeptSubDept]) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 不需要计算部门的子部门",__FUNCTION__]];
        return true;
    }
    
    int start = [[StringUtil currentTime]intValue];
    
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	bool ret = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select distinct(dept_parent) from %@ where dept_parent<>0",table_department];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result)
	{
		NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:result.count];
		
        NSString *deptParent;
        NSMutableArray *childDepts;
        NSString *childDeptStr;
        
		for(NSDictionary *dic in result)
		{
			deptParent = [StringUtil getStringValue:[[dic valueForKey:@"dept_parent"]intValue]] ;
			childDepts = [NSMutableArray array];
			[self getAllDeptsUnderDeptID:deptParent andChildDepts:childDepts];
			
		    childDeptStr = [self getSubDeptsStr:deptParent :childDepts];
			sql = [NSString stringWithFormat:@"update %@ set sub_dept = '%@' where dept_id = %@",table_department,childDeptStr,deptParent];
			[sqlArray addObject:sql];
		}
		
		if([self beginTransaction])
		{
			char *errorMessage;
			
			for(NSString *_sql in sqlArray)
			{
				pthread_mutex_lock(&add_mutex);
				sqlite3_exec(_handle, [_sql UTF8String], NULL, NULL, &errorMessage);
				pthread_mutex_unlock(&add_mutex);
				
				if(errorMessage)
					[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
			}
			[self commitTransaction];
			ret = true;
		}
	}
	[pool release];
    
    [LogUtil debug:[NSString stringWithFormat:@"保存部门的子部门耗时:%ds",([[StringUtil currentTime]intValue] - start)]];
    
	return ret;
}
//获取父部分的所有子部门
-(void)getAllDeptsUnderDeptID:(NSString*)deptParent andChildDepts:(NSMutableArray*)childDepts
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
    NSString *sql = [NSString stringWithFormat:@"select dept_id from %@ where dept_parent=%@",table_department,deptParent];
	//查询父部门的所有子部门
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	if([result count]>0)
	{
		NSString *dept_id_str;
		for(NSDictionary *dic in result)
		{
			dept_id_str=[dic objectForKey:@"dept_id"];
            [childDepts addObject:dept_id_str];
			[self getAllDeptsUnderDeptID:dept_id_str andChildDepts:childDepts];
		}
	}
	[pool release];
}
-(NSString *)getSubDeptsStr:(NSString*)deptId :(NSArray *)subDepts
{
    NSMutableString *inStr = [NSMutableString stringWithString:deptId];
    
    for (int i=0; i<[subDepts count]; i++) {
        [inStr appendString:[NSString stringWithFormat:@",%@",[subDepts objectAtIndex:i]]];
    }
    return inStr;
}

#pragma mark 保存每个部门的所有的父亲部门 包括中文和英文
-(bool)saveDeptParentDept
{
//    万达需求，不计算部门的父部门
    if (![eCloudConfig getConfig].needCalculateDeptParentDept) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 不需要计算部门的父部门",__FUNCTION__]];
        return true;
    }
    
    int start = [[StringUtil currentTime]intValue];
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

	bool ret = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	//	查询所有的非一级部门，查找其父亲部门
//    update by shisp 增加获取部门名称
	NSString *sql = [NSString stringWithFormat:@"select dept_id,dept_parent,dept_name,dept_name_eng from %@ where dept_parent<>0",table_department];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result)
	{
		NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:result.count];
		
		for(NSDictionary *dic in result)
		{
			//			部门id，父部门id，
			NSString *deptId = [dic valueForKey:@"dept_id"];
			NSString *deptParent = [dic valueForKey:@"dept_parent"];
            NSString *deptName = [dic valueForKey:@"dept_name"];
//            增加保存英文名称
            NSString *deptNameEng = [dic valueForKey:@"dept_name_eng"];
			
			//			先保存此父部门
			NSMutableArray *parentDeptArray = [NSMutableArray arrayWithObject:deptParent];

            NSMutableArray *parentDeptNameArray = [NSMutableArray arrayWithObject:deptName];

//            部门英文名称数组
            NSMutableArray *parentDeptNameEngArray = [NSMutableArray arrayWithObject:deptNameEng];

			//			再找到父部门的父部门，直到父部门为0为止
			[self getDeptParentByDeptId:deptParent andParentDeptArray:parentDeptArray andParentDeptNameArray:parentDeptNameArray andParentDeptNameEngArray:parentDeptNameEngArray];
			
			NSMutableString *parentStr = [NSMutableString stringWithString:@""];
//			for (int i = 0; i<[parentDeptArray count]; i++)
			for (int i = parentDeptArray.count - 1; i >= 0; i--)
			{
				[parentStr appendString:[NSString stringWithFormat:@"%@",[parentDeptArray objectAtIndex:i]]];
				[parentStr appendString:@","];
			}
			[parentStr deleteCharactersInRange:NSMakeRange(parentStr.length-1, 1)];
			
			//			[LogUtil debug:[NSString stringWithFormat:@"deptId is %@,parentStr is %@",deptId,parentStr]];
 			
            NSMutableString *deptNameStr = [NSMutableString stringWithString:@""];
            for(int i = parentDeptNameArray.count - 1;i>=0;i--)
            {
                NSString *_deptName = [parentDeptNameArray objectAtIndex:i];
                [deptNameStr appendFormat:@"%@/",_deptName];
            }
            [deptNameStr deleteCharactersInRange:NSMakeRange(deptNameStr.length - 1,1)];

//            部门英文名称
            NSMutableString *deptNameEngStr = [NSMutableString stringWithString:@""];
            for(int i = parentDeptNameEngArray.count - 1;i>=0;i--)
            {
                NSString *_deptNameEng = [parentDeptNameEngArray objectAtIndex:i];
                [deptNameEngStr appendFormat:@"%@/",_deptNameEng];
            }
            [deptNameEngStr deleteCharactersInRange:NSMakeRange(deptNameEngStr.length - 1,1)];

            
			sql = [NSString stringWithFormat:@"update %@ set dept_parent_dept = '%@',dept_name_contain_parent = '%@',dept_name_contain_parent_eng = '%@' where dept_id = %@",table_department,parentStr,deptNameStr,deptNameEngStr,deptId];
			[sqlArray addObject:sql];
		}
		
		if([self beginTransaction])
		{
			char *errorMessage;
			
			for(NSString *_sql in sqlArray)
			{
				pthread_mutex_lock(&add_mutex);
				sqlite3_exec(_handle, [_sql UTF8String], NULL, NULL, &errorMessage);
				pthread_mutex_unlock(&add_mutex);
				
				if(errorMessage)
					[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
			}
			[self commitTransaction];
			ret = true;
		}
	}
	[pool release];
    
    [LogUtil debug:[NSString stringWithFormat:@"保存部门的父部门耗时:%ds",([[StringUtil currentTime]intValue] - start)]];

	return ret;
}
#pragma mark 查找根据部门id查找其父亲部门，如果父亲部门为0则停止查找，否则递归调用
-(void)getDeptParentByDeptId:(NSString*)deptId andParentDeptArray:(NSMutableArray*)parentArray andParentDeptNameArray:(NSMutableArray*)deptNameArray andParentDeptNameEngArray:(NSMutableArray*)deptNameEngArray
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = [NSString stringWithFormat:@"select dept_parent,dept_name,dept_name_eng from %@ where dept_id = %@",table_department,deptId];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result.count == 1)
	{
		NSString *deptParent = [[result objectAtIndex:0]valueForKey:@"dept_parent"];
        NSString *deptName = [[result objectAtIndex:0]valueForKey:@"dept_name"];
//        部门英文名称
        NSString *deptNameEng = [[result objectAtIndex:0]valueForKey:@"dept_name_eng"];
		
		if(deptParent.intValue == 0)
		{
            [deptNameArray addObject:deptName];
            if (deptNameEng == nil) {
                [deptNameEngArray addObject:deptName];
            }else{
                [deptNameEngArray addObject:deptNameEng];
            }
			return;
		}
		else
		{
			[parentArray addObject:deptParent];
            [deptNameArray addObject:deptName];
            [deptNameEngArray addObject:deptNameEng];
            
			[self getDeptParentByDeptId:deptParent  andParentDeptArray:parentArray andParentDeptNameArray:deptNameArray andParentDeptNameEngArray:deptNameEngArray];
		}
	}
	[pool release];
}


#pragma mark 修改用户状态
-(void)updateEmpStatus:(NSArray *)info
{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	if(info.count == 1)
    {
        NSDictionary *dic = [info objectAtIndex:0];
        NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %@,emp_login_type = %@ where emp_id = %@ ",table_employee,[dic valueForKey:@"emp_status"],[dic valueForKey:@"emp_login_type"],[dic valueForKey:@"emp_id"]];
        [self operateSql:sql Database:_handle toResult:nil];
    }
    else
    {
//        if([self beginTransaction])
//        {
            for(NSDictionary *dic in info)
            {
                NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %@,emp_login_type = %@ where emp_id = %@ ",table_employee,[dic valueForKey:@"emp_status"],[dic valueForKey:@"emp_login_type"],[dic valueForKey:@"emp_id"]];
                pthread_mutex_lock(&add_mutex);
                sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, NULL);
                pthread_mutex_unlock(&add_mutex);
            }
//            [self commitTransaction];
//        }
    }
}
#pragma mark 设置所有人员的状态为离线
-(void)setAllEmpsToOffline
{
//	NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %d,emp_login_type = %d",table_employee,status_offline,TERMINAL_PC];
	NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %d,emp_login_type = %d where emp_status == %d or emp_status == %d",table_employee,status_offline,TERMINAL_PC,status_online,status_leave];
	[self operateSql:sql Database:_handle toResult:nil];
}

#pragma mark 修改用户自己的状态，包括修改用户表及员工表里的用户状态的值
-(void)updateUserStatus:(NSString*)userId andStatus:(int)status
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set emp_status = %d where emp_id=%@ ",table_employee,status,userId];
	[self operateSql:sql Database:_handle toResult:nil];
	
	[[eCloudUser getDatabase]updateUserStatus:userId andStatus:status];
}


//查询联系人部门
-(NSDictionary *)searchEmpDept:(NSString *)empId andDept:(NSString*)deptId
{
	if(empId && [empId length] > 0 && deptId && [empId length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select * from %@ where emp_id = '%@' and dept_id='%@'", table_emp_dept,empId,deptId];
        if([self operateSql:sql Database:_handle toResult:result] && 1 == [result count])
        {
            return [result objectAtIndex:0];
        }
    }
	return nil;
}

#pragma mark 删除联系人和部门的对应关系
-(void)delEmpDepts:(NSArray *)info
{
	NSString *sql ,*empId,*deptId;
	for(NSDictionary *dic in info)
	{
		empId = [dic objectForKey:@"emp_id"];
		deptId = [dic objectForKey:@"dept_id"];
		if([self searchEmpDept:empId andDept:deptId])
		{
			sql = [NSString stringWithFormat:@"delete from %@ where emp_id = '%@' and dept_id = '%@' ",table_emp_dept,empId,deptId];
			[self operateSql:sql Database:_handle toResult:nil];
		}
	}
}
//优化代码 使用事务方式，删除员工与部门关系数据
-(void)delEmpDeptsWithTransaction:(NSArray *)deleteRecords
{
	NSString *sql;
    int empId;
    int deptId;
    
    if ([self beginTransaction])
    {
        for(EmpDeptDL *empDept in deleteRecords)
        {
            empId = empDept.empId;
            deptId = empDept.deptId;
            sql = [NSString stringWithFormat:@"delete from %@ where emp_id = %d and dept_id = %d ",table_emp_dept,empId,deptId];
            
            char *errorMessage;
            pthread_mutex_lock(&add_mutex);
            sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
            pthread_mutex_unlock(&add_mutex);
            
            if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        }
        [self commitTransaction];
    }
}

//把删除的记录和增加及修改的记录分离，并且 删除
- (NSMutableArray *)seperateAndDeleteEmpDepts:(NSArray *)empDepts
{
    int curUserId = [conn getConn].userId.intValue;

    NSMutableArray *addOrUpdateRecords = [NSMutableArray array];
    NSMutableArray *deleteRecords = [NSMutableArray array];
    for (EmpDeptDL *empDept in empDepts)
    {
        if (empDept.updateType == deleteRecord)
        {
            [deleteRecords addObject:empDept];
            //            如果 删除的部门 对应用户 有当前用户，那么需要重新获取 部门显示配置
            if (empDept.empId == curUserId) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 当前登录用户 部门有变化 下次登录时 重新获取部门显示配置",__FUNCTION__]];
                [[eCloudUser getDatabase]saveDeptShowConfigUpdateTime:0];
            }
        }
        else
        {
            [addOrUpdateRecords addObject:empDept];
        }
    }
    
    if (deleteRecords.count > 0)
    {
        [self delEmpDeptsWithTransaction:deleteRecords];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s,addorupdate %d ,delete %d",__FUNCTION__,addOrUpdateRecords.count,deleteRecords.count]];
    return addOrUpdateRecords;
}

#pragma mark---组织架构---保存员工数据，部门与员工关系数据
-(bool)saveEmpDepts:(NSArray*)empDepts
{
    int start = [[StringUtil currentTime]intValue];
    
    NSMutableArray *addOrUpdateRecords = [self seperateAndDeleteEmpDepts:empDepts];
    
    NSLog(@"addOrUpdateRecords time is %d",[[StringUtil currentTime]intValue] - start);
    if (addOrUpdateRecords.count <= 0)
        return true;
    
	bool ret = false;
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	char* errorMessage;
	conn *_conn = [conn getConn];
	if([self beginTransaction])
	{
		NSString *sql;
        
        NSString *tempStr;
        NSArray *tempArray;
        NSString *phoneStr;
        NSString *titleStr;
		
		for (EmpDeptDL *empDept in addOrUpdateRecords)
		{
			if(empDept.empId == _conn.userId.intValue)
			{
				sql = [NSString stringWithFormat:@"update %@ set emp_dept_id = %d where emp_id = %d",table_employee,empDept.deptId,empDept.empId];
			}
			else
			{
                if ([eCloudConfig getConfig].needCreateEmpPinyinByEmpName) {
                    
                    NSString *pinyinAllWithSpace = @"";
                    NSString *pinyinAll = @"";
                    NSString *pinyinSimple = @"";

                    if ([UIAdapterUtil isCsairApp] && (empDept.rankId == 0) && START_CSAIR_HIDE_ORG) {
//                        因为用户不用显示，所以 也不用保存拼音了
//                        [LogUtil debug:[NSString stringWithFormat:@"%s 用户%@不用生成拼音",__FUNCTION__,empDept.empName]];
                    }else{
                        NSDictionary *pinyinDic = [ChineseToPinyin getPinyinFromString:empDept.empName];
                        pinyinAllWithSpace = [pinyinDic valueForKey:pinyin_all_with_space];
                        pinyinAll = [pinyinDic valueForKey:pinyin_all];
                        pinyinSimple = [pinyinDic valueForKey:pinyin_simple];
                    }
                    
                    sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,emp_code,emp_dept_id,emp_status,emp_info_flag,emp_name,emp_name_eng,emp_pinyin,emp_logo,emp_sex,emp_pinyin_all,emp_pinyin_simple) values(%d,'%@',%d,%d,'%@','%@','%@','%@','%@',%d,'%@','%@')",table_employee,empDept.empId,empDept.empCode,empDept.deptId,status_offline,@"N",empDept.empName,empDept.empNameEng,pinyinAllWithSpace,empDept.empLogo,empDept.empSex,pinyinAll,pinyinSimple];

                    if ([eCloudConfig getConfig].supportSearchByPhone) {
                        if ([eCloudConfig getConfig].supportSearchByTitle) {
                            /** 同步通讯录时 英文名里保存了手机号和title，方便根据手机号 和 职位搜索 */
                            tempStr = empDept.empNameEng;
                            tempArray = [tempStr componentsSeparatedByString:@","];
                            
                            if (tempArray.count >= 2) {
                                phoneStr = tempArray[0];//手机号保存为第一个元素
                                
                                titleStr = [tempStr substringFromIndex:(phoneStr.length + 1)];
                            }else{
                                phoneStr = tempStr;
                                titleStr = @"";
                            }
                            
                            NSLog(@"%s %@",__FUNCTION__,tempStr);
                            
                            sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,emp_code,emp_dept_id,emp_status,emp_info_flag,emp_name,emp_mobile,emp_title,emp_pinyin,emp_logo,emp_sex,emp_pinyin_all,emp_pinyin_simple) values(%d,'%@',%d,%d,'%@','%@','%@','%@','%@','%@',%d,'%@','%@')",table_employee,empDept.empId,empDept.empCode,empDept.deptId,status_offline,@"N",empDept.empName,phoneStr,titleStr,pinyinAllWithSpace,empDept.empLogo,empDept.empSex,pinyinAll,pinyinSimple];
                            
                        }else{
                            /** 同步通讯录时 英文名里保存了手机号，方便根据手机号搜索 */
                            sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,emp_code,emp_dept_id,emp_status,emp_info_flag,emp_name,emp_mobile,emp_pinyin,emp_logo,emp_sex,emp_pinyin_all,emp_pinyin_simple) values(%d,'%@',%d,%d,'%@','%@','%@','%@','%@',%d,'%@','%@')",table_employee,empDept.empId,empDept.empCode,empDept.deptId,status_offline,@"N",empDept.empName,empDept.empNameEng,pinyinAllWithSpace,empDept.empLogo,empDept.empSex,pinyinAll,pinyinSimple];
                        }
                    }
                }
                else
                {
                    sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,emp_code,emp_dept_id,emp_status,emp_info_flag,emp_name,emp_name_eng,emp_logo,emp_sex) values(%d,'%@',%d,%d,'%@','%@','%@','%@',%d)",table_employee,empDept.empId,empDept.empCode,empDept.deptId,status_offline,@"N",empDept.empName,empDept.empNameEng,empDept.empLogo,empDept.empSex];

                }
			}
			if(_handle == nil)
			{
				[LogUtil debug:[NSString stringWithFormat:@"_handle is null"]];
			}
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
			
			if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
			
//            如果是南航版本 每个人能看到的员工是不一样的，级别越高的人，看到的人越多。是否能显示某个人，放在了rank_id里 rank_id为0 不显示 rank_id为1则为显示
            if ([UIAdapterUtil isCsairApp] && (empDept.rankId == 0) && START_CSAIR_HIDE_ORG) {
                //                    设置为特殊用户，并且是隐藏类型 is_special = 1 permission = 1
                sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id,rank_id,prof_id,area_id,emp_sort,is_special,permission) values(%d,%d,%d,%d,%d,%d,%d,%d)",table_emp_dept, empDept.empId,empDept.deptId,empDept.rankId,empDept.profId,empDept.areaId,empDept.empSort,1,1];
//                [LogUtil debug:[NSString stringWithFormat:@"%s 用户%@不能显示",__FUNCTION__,empDept.empName]];
            }else{
                sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id,rank_id,prof_id,area_id,emp_sort) values(%d,%d,%d,%d,%d,%d)",table_emp_dept, empDept.empId,empDept.deptId,empDept.rankId,empDept.profId,empDept.areaId,empDept.empSort];
            }
            
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
			
			if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
			
		}
		[self commitTransaction];
		ret = true;
	}
	[pool release];
	
    [LogUtil debug:[NSString stringWithFormat:@"保存员工与部门关系耗时:%ds",([[StringUtil currentTime]intValue] - start)]];
#ifdef _XINHUA_FLAG_
    [self addSystemUser];
#endif
    
	return ret;
}

#pragma mark 同步完员工部门数据后，更新部门总人数信息
//-(bool)updateDeptEmpCount
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//	bool ret = false;
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//	//	查询每个部门的总人数
//	NSString *_sql = [NSString stringWithFormat:@"select count(emp_id) as emp_count,dept_id from %@ where permission <> 1 group by dept_id",table_emp_dept];
//	NSMutableArray *_result = [NSMutableArray array];
//	[self operateSql:_sql Database:_handle toResult:_result];
//	//	[LogUtil debug:[NSString stringWithFormat:@"dept emp count is %@",_result]];
//	
//	//	根据部门，查询员工部门表，得到部门总人数，如果部门还有子部门，那么子部门的人数也包括在内，放在一个数组中，批量执行，修改部门总人数列的值
//	//	暂时不批量执行
//	NSMutableArray *sqlArray = [NSMutableArray array];
//    
//	int deptId;
//	int empCount;
//    NSString *sql;
//	
//    conn *_conn = [conn getConn];
//	for(NSDictionary *dic in _result)
//	{
//		deptId = [[dic valueForKey:@"dept_id"]intValue];
//		empCount = [[dic valueForKey:@"emp_count"]intValue];
//        
////        修改内存中部门id对应的empCount的值
//        [_conn updateEmpCountOfDeptId:deptId andEmpCount:empCount];
//		//		[LogUtil debug:[NSString stringWithFormat:@"empCount is %d",empCount]];
//		sql = [NSString stringWithFormat:@"update %@ set emp_count = %d where dept_id = %d",table_department,empCount,deptId];
//		//		[LogUtil debug:[NSString stringWithFormat:@"%s,sql is %@",__FUNCTION__,sql]];
//		//		[self operateSql:sql Database:_handle toResult:nil];
//		[sqlArray addObject:sql];
//	}
//	
//	//	更新部门表的部门人数字段
//	//
//	if([self beginTransaction])
//	{
//		char *errorMessage;
//		
//		for(NSString *_sql in sqlArray)
//		{
//			pthread_mutex_lock(&add_mutex);
//			sqlite3_exec(_handle, [_sql UTF8String], NULL, NULL, &errorMessage);
//			pthread_mutex_unlock(&add_mutex);
//			
//			if(errorMessage)
//				[LogUtil debug:[NSString stringWithFormat:@"%@",[NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]]];
//			
//		}
//		[self commitTransaction];
//		ret = true;
//	}
//	
//	[pool release];
//	return ret;
//}
-(bool)updateDeptEmpCount
{
    if (![eCloudConfig getConfig].needCalculateDeptEmpCount) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 不需要计算部门人数",__FUNCTION__]];
        return true;
    }
    
    int start = [[StringUtil currentTime]intValue];
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	bool ret = false;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	//	查询每个部门的总人数
	NSString *_sql = [NSString stringWithFormat:@"select count(emp_id) as emp_count,dept_id from %@ where permission <> 1 group by dept_id",table_emp_dept];
	NSMutableArray *_result = [NSMutableArray array];
	[self operateSql:_sql Database:_handle toResult:_result];
    
    NSMutableDictionary *allDeptsDic = [NSMutableDictionary dictionaryWithCapacity:_result.count];
    
    for (NSDictionary *dic in _result)
    {
        [allDeptsDic setValue:[StringUtil getStringValue:[[dic valueForKey:@"emp_count"]intValue]] forKey:[StringUtil getStringValue:[[dic valueForKey:@"dept_id"]intValue]]];
    }
	//	[LogUtil debug:[NSString stringWithFormat:@"dept emp count is %@",_result]];
	
	//	查询部门表，得到所有部门
	NSString *sql = [NSString stringWithFormat:@"select dept_id,sub_dept from %@",table_department];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	
	//	根据部门，查询员工部门表，得到部门总人数，如果部门还有子部门，那么子部门的人数也包括在内，放在一个数组中，批量执行，修改部门总人数列的值
	//	暂时不批量执行
	NSMutableArray *sqlArray = [NSMutableArray array];
	
	int deptId;
	NSString *subDept;
	int empCount;
	
	for(NSDictionary *dic in result)
	{
		deptId = [[dic valueForKey:@"dept_id"]intValue];
		subDept = [dic valueForKey:@"sub_dept"];
		empCount = [self getDeptEmpNumBy:allDeptsDic andSubDept:subDept];
		//		[LogUtil debug:[NSString stringWithFormat:@"empCount is %d",empCount]];
		sql = [NSString stringWithFormat:@"update %@ set emp_count = %d where dept_id = %d",table_department,empCount,deptId];
		//		[LogUtil debug:[NSString stringWithFormat:@"%s,sql is %@",__FUNCTION__,sql]];
		//		[self operateSql:sql Database:_handle toResult:nil];
		[sqlArray addObject:sql];
	}
	
	//	更新部门表的部门人数字段
	//
	if([self beginTransaction])
	{
		char *errorMessage;
		
		for(NSString *_sql in sqlArray)
		{
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [_sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
			
			if(errorMessage)
				[LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
			
		}
		[self commitTransaction];
		ret = true;
	}
	
	[pool release];
    [LogUtil debug:[NSString stringWithFormat:@"计算部门人数耗时:%ds",([[StringUtil currentTime]intValue] - start)]];
	return ret;
}

#pragma mark 先查询出每个部门直属的人员的个数放在数组里，然后再根据部门包含的子部门数，进行累加，得到一个部门的所有员工数
-(int)getDeptEmpNumBy:(NSMutableDictionary*)allDeptsDic andSubDept:(NSString*)subDeptStr
{
	int count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSArray *deptArray = [subDeptStr componentsSeparatedByString:@","];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"dept sub dept is %@",deptArray]];
	
	NSString *_deptId;
//	int _empCount;
	for(NSString *deptId in deptArray)
	{
        count += [[allDeptsDic valueForKey:deptId]intValue];
	}
	[pool release];
	return count;
}
// update by shisp 修改为使用Dictionary方式，检索快
//-(int)getDeptEmpNumBy:(NSArray*)deptEmpNumArray andSubDept:(NSString*)subDeptStr
//{
//	int count = 0;
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//	NSArray *deptArray = [subDeptStr componentsSeparatedByString:@","];
//	
//	//	[LogUtil debug:[NSString stringWithFormat:@"dept sub dept is %@",deptArray]];
//	
//	NSString *_deptId;
//	int _empCount;
//	for(NSString *deptId in deptArray)
//	{
//		for(NSDictionary *dic in deptEmpNumArray)
//		{
//			_deptId = [dic valueForKey:@"dept_id"];
//			if(deptId.intValue == _deptId.intValue)
//			{
//				_empCount = [[dic valueForKey:@"emp_count"]intValue];
//				count += _empCount;
//				break;
//			}
//		}
//	}
//	[pool release];
//	return count;
//}


#pragma mark 根据部门id，获取部门的所有员工信息,并定位级别 废弃代码 by shisp
-(NSArray *)getDeptEmpInfoWithLevel:(NSString *)deptId andLevel:(int)level
{
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *empCols = @"b.emp_id,emp_name,emp_sex,emp_status,emp_logo,emp_info_flag,emp_code,emp_signature,emp_login_type";
	//	先查询在线和离开的
	NSString *sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b where a.dept_id = '%@' and a.emp_id = b.emp_id and (b.emp_status = %d or b.emp_status = %d) order by emp_code",empCols,table_emp_dept,table_employee,deptId,status_online,status_leave];
	
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
		emp.emp_dept=[deptId intValue];
		emp.emp_level=level;
		[emps addObject:emp];
		[emp release];
	}
	//	再查询离线的
	sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b where a.dept_id = '%@' and a.emp_id = b.emp_id and (b.emp_status = %d or b.emp_status = %d) order by emp_code",empCols,table_emp_dept,table_employee,deptId,status_exit,status_offline];
	
	[result removeAllObjects];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
		emp.emp_dept=[deptId intValue];
		emp.emp_level=level;
		[emps addObject:emp];
		[emp release];
	}
	
	[pool release];
	return emps;
}

#pragma mark 根据上级部门id，获取直接子部门，并定位级别 在通讯录展开部门，获取子部门时使用 部门是按照dept_sort升序排序
-(NSArray *)getLocalNextDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level
{
    conn *_conn = [conn getConn];
	NSMutableArray *depts = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat: @"select dept_id,dept_name,emp_count,dept_name_eng from %@ where dept_parent = '%@' and dept_permission <> 1 and display_flag <> %d order by dept_sort",table_department,deptParent,dept_display_type_hide];
	NSMutableArray * result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
		//		[LogUtil debug:[NSString stringWithFormat:@"deptid is %@ child_dept is %@",deptParent , result]];
		for(int i = 0;i<[result count];i++)
		{
			Dept *dept = [[Dept alloc]init];
			NSDictionary *dic = [result objectAtIndex:i];
            
            NSString *deptName = [dic objectForKey:@"dept_name"];
            
            if (deptName && ([deptName isEqualToString:@"我的电脑"] || [deptName isEqualToString:@"测试"])) {
                continue;
            }
            
			NSString *dept_id = [dic objectForKey:@"dept_id"];
			dept.dept_id = [dept_id intValue];
			dept.dept_name = [dic objectForKey:@"dept_name"];
            dept.deptNameEng = [dic objectForKey:@"dept_name_eng"];
			dept.dept_parent = [deptParent intValue];
			dept.dept_level=level;
			dept.dept_emps = nil;
			
			//			在线人数需要计算
            dept.totalNum=[[dic valueForKey:@"emp_count"]intValue];//--部门所有人员人数
//            dept.onlineNum = [_conn getOnlineEmpCountByDeptId:dept.dept_id];
			[depts addObject:dept];
			[dept release];            
		}
	}
	[pool release];
	return depts;
}

#pragma mark 选择部门下所有员工，并设置选择状态
-(NSArray *)getDeptEmpInfoWithSelected:(NSString *)deptId andLevel:(int)level andSelected:(bool)isSelected
{
	NSArray *emps = [self getDeptEmpInfoWithLevel:deptId andLevel:level];
	for(Emp *_emp in emps)
	{
		_emp.isSelected = isSelected;
	}
	return emps;
}
#pragma mark 选择最近联系人下所有员工，并设置选择状态 废弃代码 by shisp
-(NSArray *)getRecentEmpInfoWithSelected:(NSString *)typeId andLevel:(int)level andSelected:(bool)isSelected
{
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];

   NSString *sql= [NSString stringWithFormat:@"select * from (select * from %@ where emp_id in (select emp_id from %@ where conv_id in (select conv_id from %@ where conv_type=0)) order by emp_code) order by emp_status",table_employee,table_conv_emp,table_conversation];
    
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
		emp.emp_dept=[typeId intValue];
		emp.emp_level=level;
        emp.isSelected=isSelected;
		[emps addObject:emp];
		[emp release];
	}
	
	[pool release];
	return emps;
}
#pragma mark 选择最近讨论组下所有员工，并设置选择状态 废弃代码 by shisp
-(NSArray *)getRecentGroupMemberWithSelected:(NSString *)typeId andLevel:(int)level andSelected:(bool)isSelected andConvId:(NSString *)conv_id
{
	NSMutableArray *emps = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *sql= [NSString stringWithFormat:@"select * from (select * from %@ where emp_id in (select emp_id from %@ where conv_id =%@ and is_valid = 0) order by  emp_code) order by emp_status",table_employee,table_conv_emp,conv_id];
    
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
		emp.emp_dept=[typeId intValue];
		emp.emp_level=level;
        emp.isSelected=isSelected;
		[emps addObject:emp];
		[emp release];
	}
	
	[pool release];
	return emps;
}
#pragma mark 并是否选中 根据上级部门id，获取直接子部门，并定位级别
-(NSArray *)getLocalNextDeptInfoWithSelected:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected
{
	NSArray *depts = [self getLocalNextDeptInfoWithLevel:deptParent andLevel:level];
	for(Dept *_dept in depts)
	{
		_dept.isChecked = isSelected;
	}
	return depts;
}
#pragma mark 最近讨论组，最近联系人
-(NSArray *)getTypeArray
{
	NSMutableArray *types = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
    RecentMember *typeObject = [[RecentMember alloc]init];
    typeObject.type_name=@"最近讨论组";
    typeObject.type_level=0;
    typeObject.type_parent=0;
    typeObject.type_id=1;
    typeObject.isExtended=false;
    typeObject.isChecked=false;
    [types addObject:typeObject];
    [typeObject release];
    
    RecentMember *typeObject1 = [[RecentMember alloc]init];
    typeObject1.type_name=@"最近联系人";
    typeObject1.type_level=0;
    typeObject1.type_parent=0;
    typeObject1.type_id=2;
    typeObject1.isExtended=false;
    typeObject1.isChecked=false;
    [types addObject:typeObject1];
    [typeObject1 release];
    
    [pool release];
	return types;
}

#pragma mark 筛选结果
-(NSArray *)getChooseArray
{
	NSMutableArray *types = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RecentMember *typeObject = [[RecentMember alloc]init];
    typeObject.type_name=@"筛选结果";
    typeObject.type_level=0;
    typeObject.type_parent=0;
    typeObject.type_id=1;
    typeObject.isExtended=true;
    typeObject.isChecked=false;
   
    NSArray *temp=[self getRecentEmpInfoWithSelected:@"1" andLevel:1 andSelected:false];
    if ([temp count]>0) {
        [types addObject:typeObject];
        [typeObject release];
    }
    [types addObjectsFromArray:temp];
    [pool release];
   
	return types;
}

#pragma mark 最近讨论组
-(NSArray *)getGroupArray
{
    NSMutableArray *groups = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *sql= [NSString stringWithFormat:@"select * from %@ where conv_type=1 order by last_msg_time desc",table_conversation];
    
	NSMutableArray * result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	for(NSDictionary *dic in result)
	{
		RecentGroup *rgroup = [[RecentGroup alloc]init];
	    rgroup.type_id=11;
        rgroup.type_level=1;
        rgroup.isExtended=false;
        rgroup.isChecked=false;
        rgroup.type_name=[dic objectForKey:@"conv_title"];
        rgroup.type_parent=1;
        rgroup.conv_id=[dic objectForKey:@"conv_id"];
		[groups addObject:rgroup];
		[rgroup release];
	}
	
	[pool release];
	return groups;
}

#pragma mark 获取所有讨论组
-(NSArray *)getAllGroupArray
{
    NSMutableArray *groups = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSString *sql= [NSString stringWithFormat:@"select * from %@ where conv_type=1 order by last_msg_time desc",table_conversation];
    
    NSMutableArray * result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    for(NSDictionary *dic in result)
    {
        Conversation *rgroup = [[Conversation alloc]init];
        rgroup.conv_title=[dic objectForKey:@"conv_title"];
        rgroup.conv_id=[dic objectForKey:@"conv_id"];
        rgroup.conv_type = mutiableType;
        [groups addObject:rgroup];
        [rgroup release];
    }
    
    [pool release];
    return groups;
}

#pragma mark 增加一个方法，获取员工总人数，是员工部门表和员工表通过emp_id链接后的记录的总数
- (int)getDeptEmpCount
{
   NSString *sql = [NSString stringWithFormat: @"select count(*) as _count from %@ a , %@ b where a.emp_id = b.emp_id", table_emp_dept,table_employee];
    NSMutableArray *result = [self querySql:sql];
    if (result && result.count > 0) {
        return [[[result objectAtIndex:0]valueForKey:@"_count"]intValue];
    }
    return 0;
}

#pragma mark 获取所有人员放在内存中 获取人员到内存，先按照emp_sort降序排列，再按照empcode升序排列，搜索人员时，展开某个部门的人员时用到的排序方式 by shisp
-(NSArray *)getEmployeeList
{
    //    return nil;
    //    [StringUtil usedMemory];
    
    int startTime = [[StringUtil currentTime]intValue];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSMutableArray *emps = [NSMutableArray array];
    NSMutableDictionary *allEmpsDic = [NSMutableDictionary dictionary];
    
    //    增加empCode和emp的对应字典
    NSMutableDictionary *empCodeAndEmpDic = [NSMutableDictionary dictionary];
    
    
    //	NSString *empCols = @"b.emp_id,b.emp_title,emp_name,emp_sex,emp_status,emp_logo,emp_info_flag,emp_code,emp_signature,emp_pinyin,a.dept_id,emp_login_type,a.permission,a.is_special,emp_pinyin_all,emp_pinyin_simple";
    
    //    NSString *empCols = @"b.emp_id,emp_name,emp_status,emp_name_eng,emp_sex,a.dept_id,emp_code,emp_pinyin_simple,emp_logo";
    
    //    update by shisp 如果是中文环境，则获取中文姓名，如果是英文环境则获取英文姓名，这样可以减少内存占用
    NSMutableString *empCols = [NSMutableString stringWithString:@"b.emp_id,emp_status,emp_name,emp_name_eng,emp_sex,a.dept_id,emp_code,emp_login_type,emp_sort,c.display_flag"];
    
    if ([eCloudConfig getConfig].supportSearchByPhone) {
        [empCols appendString:@",emp_mobile"];
    }
    if ([eCloudConfig getConfig].supportSearchByTitle) {
        [empCols appendString:@",b.emp_title"];
    }
    
    if ([eCloudConfig getConfig].needGetEmpSimplePinyinToMemory) {
        [empCols appendString:@",emp_pinyin_simple"];
    }
    if ([eCloudConfig getConfig].needGetEmpAllPinyinToMemory) {
        [empCols appendString:@",emp_pinyin_all"];
    }
    
    //	NSString *sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b where a.emp_id = b.emp_id and a.dept_id > 0 order by emp_sort desc,emp_code asc",empCols,table_emp_dept,table_employee];
    
    NSString *sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b ,%@ c where a.emp_id = b.emp_id and a.dept_id = c.dept_id order by emp_sort desc,emp_code",empCols,table_emp_dept,table_employee,table_department];
    
    sqlite3_stmt    *statement	=   nil;
    pthread_mutex_lock(&add_mutex);
    
    int state  =   sqlite3_prepare(_handle,[sql UTF8String],-1,&statement,nil);
    
    pthread_mutex_unlock(&add_mutex);
    
    
    NSString *col_name	=   nil;
    int      col_count			=   0;
    while (SQLITE_ROW == sqlite3_step(statement))
    {
        Emp *_emp = [[Emp alloc]init];
        
        col_count   =   sqlite3_column_count(statement);
        
        for (int i = 0; i < col_count; i++)
        {
            col_name    =   [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
            
            if ([col_name isEqualToString:@"emp_id"])
            {
                [_emp setEmpId:sqlite3_column_int(statement, i)];
                //                _emp.emp_id = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"emp_name"])
            {
                _emp.emp_name = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"emp_name_eng"])
            {
                _emp.empNameEng = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"emp_sex"])
            {
                _emp.emp_sex = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"dept_id"])
            {
                _emp.emp_dept = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"emp_code"])
            {
                _emp.empCode = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([eCloudConfig getConfig].needGetEmpSimplePinyinToMemory && [col_name isEqualToString:@"emp_pinyin_simple"])
            {
                _emp.empPinyinSimple = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([eCloudConfig getConfig].needGetEmpAllPinyinToMemory && [col_name isEqualToString:@"emp_pinyin_all"])
            {
                _emp.empPinyin = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            }
            else if ([col_name isEqualToString:@"emp_status"])
            {
                _emp.emp_status = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"emp_login_type"])
            {
                _emp.loginType = sqlite3_column_int(statement, i);
            }
            //            else if([col_name isEqualToString:@"emp_logo"])
            //            {
            //                _emp.emp_logo = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
            //            }
            else if([col_name isEqualToString:@"emp_sort"])
            {
                int empSort = sqlite3_column_int(statement, i);
                _emp.empSort = empSort;
                if (empSort > 0) {
                    //                    NSLog(@"%s,%@,%d",__FUNCTION__,_emp.emp_name,empSort);
                }
            }
            else if([col_name isEqualToString:@"emp_mobile"])
            {
                NSString *empMobile = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
                _emp.emp_mobile = empMobile;
            }
            else if([col_name isEqualToString:@"emp_title"])
            {
                NSString *empTitle = [StringUtil getStringByCString:(char *)sqlite3_column_text(statement, i)];
                NSLog(@"%s empname is %@ empTitle is %@",__FUNCTION__,_emp.emp_name,empTitle);
                _emp.titleName = empTitle;
            }
            else if ([col_name isEqualToString:@"display_flag"]){
                int deptDisplayFlag = sqlite3_column_int(statement, i);
                if (deptDisplayFlag ==  dept_display_type_hide || deptDisplayFlag == dept_display_type_display_sub_dept) {
                    //部门的设置是隐藏或不显示员工
                    _emp.isSpecial = YES;
                    PermissionModel *_permission = [[PermissionModel alloc]init];
                    //                    1 代表用户是隐藏的
                    [_permission setPermission:1];
                    _emp.permission = _permission;
                    [_permission release];
                }else{
                    _emp.isSpecial = NO;
                }
            }
            
        }
        
        _emp.isSpecial = NO;
        //        PermissionModel *_model = [[PermissionModel alloc]init];
        //        [_model setPermission:0];
        //        _emp.permission = _model;
        //        [_model release];
        
        [emps addObject:_emp];
        
        //        [LogUtil debug:[NSString stringWithFormat:@"%s , emp_name is %@ empcode is %@ empsort is %d",__FUNCTION__,_emp.emp_name,_emp.empCode,(int)_emp.empSort]];
        
        [allEmpsDic setValue:_emp forKey:[NSString stringWithFormat:@"%d_%d",_emp.emp_id,_emp.emp_dept]];
        
        //        账号使用小写
        [empCodeAndEmpDic setValue:_emp forKey:[_emp.empCode lowercaseString]];
        
        [_emp release];
    }
    
    conn *_conn = [conn getConn];
    _conn.allEmpsDic = allEmpsDic;
    _conn.allEmpArray = emps;
    _conn.empCodeAndEmpDic = empCodeAndEmpDic;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s , 职员总数为 %lu 个 需要时间:%d",__FUNCTION__,(unsigned long)[emps count],[[StringUtil currentTime]intValue] - startTime]];
    
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(statement);
    pthread_mutex_unlock(&add_mutex);
    
    [self getSpecialEmps];
    
    [[RobotDAO getDatabase]initRobots];
    
    [pool release];
    
    [StringUtil usedMemory];
    
    return nil;
}

- (void)getSpecialEmps
{
    conn *_conn = [conn getConn];
    
    //        查询到特殊用户，给内存中的emp赋值
    NSString *sql = [NSString stringWithFormat:@"select emp_id,dept_id,permission from %@ where is_special = 1",table_emp_dept];

    sqlite3_stmt    *statement	=   nil;
    pthread_mutex_lock(&add_mutex);
    int state  =   sqlite3_prepare(_handle,[sql UTF8String],-1,&statement,nil);
    pthread_mutex_unlock(&add_mutex);
    
    NSString *col_name	=   nil;
    int      col_count =   0;
    while (SQLITE_ROW == sqlite3_step(statement))
    {
        Emp *_emp = [[Emp alloc]init];
        
        col_count   =   sqlite3_column_count(statement);
        
        for (int i = 0; i < col_count; i++)
        {
            col_name    =   [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
            
            if ([col_name isEqualToString:@"emp_id"])
            {
                _emp.emp_id = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"dept_id"])
            {
                _emp.emp_dept = sqlite3_column_int(statement, i);
            }
            else if ([col_name isEqualToString:@"permission"])
            {
                PermissionModel *_permission = [[PermissionModel alloc]init];
                [_permission setPermission:sqlite3_column_int(statement, i)];
                _emp.permission = _permission;
                [_permission release];
            }
        }
        
        int empId = _emp.emp_id;
        int deptId = _emp.emp_dept;
        
        NSString *empKey = [NSString stringWithFormat:@"%d_%d",empId,deptId];
        Emp *emp = [_conn.allEmpsDic valueForKey:empKey];
        if (emp) {
            emp.isSpecial = YES;
            emp.permission = _emp.permission;
//            [LogUtil debug:[NSString stringWithFormat:@"%s %@用户属于特殊用户",__FUNCTION__,emp.emp_name]];
        }
        [_emp release];
    }

    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(statement);
    pthread_mutex_unlock(&add_mutex);
}

-(NSString *)getDeptNameByID:(int)dept_id
{
    NSString *dept_name=nil;
    int dept_parent=0;
    NSMutableArray * result = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat: @"select dept_parent,dept_name from %@ where dept_id=%d",table_department,dept_id];
    if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
        NSDictionary *dic = [result objectAtIndex:0];
        dept_parent = [[dic objectForKey:@"dept_parent"]intValue];
        dept_name=[dic objectForKey:@"dept_name"];
	}
    if (dept_parent==0) {
        
        return dept_name;
    }
    
    NSString *dept_name_other=[self getDeptNameByID:dept_parent];
    
    if (dept_name==nil) {
            dept_name=dept_name_other;
        }else
        {
            dept_name=[NSString stringWithFormat:@"%@/%@",dept_name_other,dept_name];
        }
    return dept_name;
    
    
}
#pragma mark 根据deptid从内存中获取包含了父部门的部门名称
-(NSString *)getParentDeptListName:(int)dept_id
{
 //    return nil;
    conn *_conn = [conn getConn];
	[_conn getAllDeptId];
    
    //    update by shisp 原来是从数组中获取，现在从Dictionary中获取，可以根据deptId快速定位
    DeptInMemory *_dept = [_conn.allDeptsDic objectForKey:[StringUtil getStringValue:dept_id]];
    
    if (_dept) {
//        需要加上语言逻辑，返回不同的父部门数据
        return _dept.deptNameContainParent;
    }
    return @"";
}

#pragma mark 获取部门，选择聊天成员时使用
-(NSArray *)getDeptList
{
	NSMutableArray *depts = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat: @"select dept_id,emp_count,sub_dept,dept_name from %@ where dept_permission <> 1",table_department];
	NSMutableArray * result = [NSMutableArray array];
	
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
            Dept *dept = [[Dept alloc]init];
			NSDictionary *dic = [result objectAtIndex:i];
			NSString *dept_id = [dic objectForKey:@"dept_id"];
			dept.dept_id = [dept_id intValue];
			dept.isChecked=false;
            dept.totalNum=[[dic valueForKey:@"emp_count"]intValue];//--部门所有人员人数
            dept.subDeptsStr=[dic objectForKey:@"sub_dept"];
            dept.dept_name=[dic objectForKey:@"dept_name"];
			[depts addObject:dept];
			[dept release];
		}
	}
	
	[pool release];
	return depts;
}

#pragma mark 获取某部门人员数量
-(int)getDeptNumBy:(int)dept_id
{
    int num=0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat: @"select dept_id,emp_count from %@ where dept_id=%d",table_department,dept_id];
	NSMutableArray * result = [NSMutableArray array];
	
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
		for(int i=0;i<[result count];i++)
		{
			NSDictionary *dic = [result objectAtIndex:i];
            num=[[dic valueForKey:@"emp_count"]intValue];//--部门所有人员人数

		}
	}
	
	[pool release];
	return num;
}

#pragma mark 修改某用户的empinfoflag为N
-(void)updateEmpInfoFlag:(NSString*)empId
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where emp_id = %@ and emp_info_flag = 'Y'",table_employee,empId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0)
    {
        //    增加修改内存里的数据
        conn *_conn = [conn getConn];
        NSArray *emps = [_conn getEmpByEmpId:empId.intValue];
        for (Emp *_emp in emps)
        {
            _emp.info_flag = false;
        }
        NSString *sql = [NSString stringWithFormat:@"update %@ set emp_info_flag = 'N' where emp_id = %@",table_employee,empId];
        [self operateSql:sql Database:_handle toResult:nil];
    }
//    NSLog(@"%s,empId is %@",__FUNCTION__,empId);
}

#pragma mark 保存员工资料
-(void)addEmp:(NSArray *)info
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	if(info.count == 1)
	{
		[self addOneEmp:[info objectAtIndex:0]];
	}
	else
	{
		if([self beginTransaction])
		{
			for (NSDictionary *dic in info)
			{
				[self addOneEmp:dic];
			}
			[self commitTransaction];
		}
	}
}

//增加一个联系人
-(void)addOneEmp:(NSDictionary *)dic
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *sql = [NSString stringWithFormat:@"insert into  %@(emp_id,emp_name,emp_sex,emp_mail,emp_mobile,emp_tel,emp_title,emp_pinyin,emp_status,emp_logo,emp_info_flag,emp_signature,emp_login_type,emp_hometel,emp_emergencytel,emp_code,emp_pinyin_all,emp_pinyin_simple,emp_birthday,emp_fax,emp_address,emp_postcode,emp_name_eng) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",table_employee];
	
	sqlite3_stmt *stmt = nil;
	
	//		编译
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		//			编译错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
		//			释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	
	sqlite3_bind_int(stmt, 1, [[dic valueForKey:@"emp_id"] intValue]);//emp_id
	sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"emp_name"]UTF8String],-1,NULL);//emp_name
	sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"emp_sex"]intValue]);//emp_sex
	sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"emp_mail"]UTF8String],-1,NULL);//emp_mail
	sqlite3_bind_text(stmt, 5, [[dic valueForKey:@"emp_mobile"]UTF8String],-1,NULL);//emp_mobile
	sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"emp_tel"]UTF8String],-1,NULL);//emp_tel
	sqlite3_bind_text(stmt, 7, [[dic valueForKey:@"emp_title"]UTF8String],-1,NULL);//emp_title
	
    NSString *pinyinAllWithSpace = @"";
    NSString *pinyinAll = @"";
    NSString *pinyinSimple = @"";

    if ([eCloudConfig getConfig].needCreateEmpPinyinByEmpName) {
        NSDictionary *pinyinDic = [ChineseToPinyin getPinyinFromString:[dic valueForKey:@"emp_name"]];
        pinyinAllWithSpace = [pinyinDic valueForKey:pinyin_all_with_space];
        pinyinAll = [pinyinDic valueForKey:pinyin_all];
        pinyinSimple = [pinyinDic valueForKey:pinyin_simple];
    }

	sqlite3_bind_text(stmt, 8, [pinyinAllWithSpace UTF8String],-1,NULL);//emp_pinyin
	
	sqlite3_bind_int(stmt, 9, [[dic valueForKey:@"emp_status"]intValue]);//emp_status
	sqlite3_bind_text(stmt, 10, [[dic valueForKey:@"emp_logo"]UTF8String],-1,NULL);//emp_logo
	sqlite3_bind_text(stmt,11, [[dic valueForKey:@"emp_info_flag"]UTF8String],-1,NULL);//emp_info_flag
	sqlite3_bind_text(stmt, 12, [[dic valueForKey:@"emp_signature"]UTF8String],-1,NULL);//emp_signature
	sqlite3_bind_int(stmt, 13, [[dic valueForKey:@"emp_login_type"]intValue]);//emp_login_type
	sqlite3_bind_text(stmt, 14, [[dic valueForKey:@"emp_hometel"]UTF8String],-1,NULL);//emp_hometel
	sqlite3_bind_text(stmt, 15, [[dic valueForKey:@"emp_emergencytel"]UTF8String],-1,NULL);//emp_emergencytel
	sqlite3_bind_text(stmt, 16, [[dic valueForKey:@"emp_code"]UTF8String],-1,NULL);//emp_emergencytel
	
    sqlite3_bind_text(stmt, 17, [pinyinAll UTF8String],-1,NULL);//emp_pinyin_all
	sqlite3_bind_text(stmt, 18, [pinyinSimple UTF8String],-1,NULL);//emp_pinyin_simple

//    emp_birthday,emp_fax,emp_address,emp_postcode,emp_name_eng
    sqlite3_bind_int(stmt, 19, [[dic valueForKey:@"emp_birthday"]intValue]);//emp_birthday
    sqlite3_bind_text(stmt, 20, [[dic valueForKey:@"emp_fax"] UTF8String],-1,NULL);//emp_fax
	sqlite3_bind_text(stmt, 21, [[dic valueForKey:@"emp_address"] UTF8String],-1,NULL);//emp_address
    sqlite3_bind_text(stmt, 22, [[dic valueForKey:@"emp_postcode"] UTF8String],-1,NULL);//emp_postcode
	sqlite3_bind_text(stmt, 23, [[dic valueForKey:@"emp_name_eng"] UTF8String],-1,NULL);//emp_name_eng
	
	//	执行
	state = sqlite3_step(stmt);
	
	pthread_mutex_unlock(&add_mutex);
	//	执行结果
	if(state != SQLITE_DONE &&  state != SQLITE_OK)
	{
		//			执行错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
	}
	//释放资源
	pthread_mutex_lock(&add_mutex);
	sqlite3_finalize(stmt);
	pthread_mutex_unlock(&add_mutex);
	[pool release];
}
#pragma mark 修改多个员工的信息
-(void)updateEmp:(NSArray *)info
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(info.count == 1)
	{
		[self updateOneEmp:[info objectAtIndex:0]];
	}
	else
	{
		if([self beginTransaction])
		{
			for (NSDictionary *dic in info)
			{
				[self updateOneEmp:dic];
			}
			[self commitTransaction];
		}
	}
	[pool release];
}

#pragma mark 修改一个员工的信息
-(void)updateOneEmp:(NSDictionary *)dic
{
    
	NSString *sql = [NSString stringWithFormat:@"update %@ set emp_id = ?,emp_name = ?,emp_sex = ?,emp_mail = ?,emp_mobile = ?,emp_tel = ?,emp_title = ?,emp_pinyin = ?,emp_logo = ?,emp_info_flag=?,emp_signature=?,emp_hometel=?,emp_emergencytel=?,emp_code = ?,emp_pinyin_all = ?,emp_pinyin_simple = ?,emp_birthday = ?,emp_fax = ?,emp_address = ?,emp_postcode = ?,emp_name_eng = ?  where emp_id = ?",table_employee];
	
	sqlite3_stmt *stmt = nil;
	
	//		编译
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		//			编译错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
		//			释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	
	sqlite3_bind_int(stmt, 1, [[dic valueForKey:@"emp_id"] intValue]);//emp_id
	sqlite3_bind_text(stmt, 2, [[dic valueForKey:@"emp_name"]UTF8String],-1,NULL);//emp_name
	sqlite3_bind_int(stmt, 3, [[dic valueForKey:@"emp_sex"]intValue]);//emp_sex
	sqlite3_bind_text(stmt, 4, [[dic valueForKey:@"emp_mail"]UTF8String],-1,NULL);//emp_mail
	sqlite3_bind_text(stmt, 5, [[dic valueForKey:@"emp_mobile"]UTF8String],-1,NULL);//emp_mobile
	sqlite3_bind_text(stmt, 6, [[dic valueForKey:@"emp_tel"]UTF8String],-1,NULL);//emp_tel
	sqlite3_bind_text(stmt, 7, [[dic valueForKey:@"emp_title"]UTF8String],-1,NULL);//emp_title
	
    NSString *pinyinAllWithSpace = @"";
    NSString *pinyinAll = @"";
    NSString *pinyinSimple = @"";
    
    if ([eCloudConfig getConfig].needCreateEmpPinyinByEmpName) {
        NSDictionary *pinyinDic = [ChineseToPinyin getPinyinFromString:[dic valueForKey:@"emp_name"]];
        pinyinAllWithSpace = [pinyinDic valueForKey:pinyin_all_with_space];
        pinyinAll = [pinyinDic valueForKey:pinyin_all];
        pinyinSimple = [pinyinDic valueForKey:pinyin_simple];
    }
	sqlite3_bind_text(stmt, 8, [pinyinAllWithSpace UTF8String],-1,NULL);//emp_pinyin
	sqlite3_bind_text(stmt, 9, [[dic valueForKey:@"emp_logo"]UTF8String],-1,NULL);//emp_logo
	sqlite3_bind_text(stmt,10, [[dic valueForKey:@"emp_info_flag"]UTF8String],-1,NULL);//emp_info_flag
	sqlite3_bind_text(stmt, 11, [[dic valueForKey:@"emp_signature"]UTF8String],-1,NULL);//emp_signature
	sqlite3_bind_text(stmt, 12, [[dic valueForKey:@"emp_hometel"]UTF8String],-1,NULL);//emp_hometel
	sqlite3_bind_text(stmt, 13, [[dic valueForKey:@"emp_emergencytel"]UTF8String],-1,NULL);//emp_emergencytel
	sqlite3_bind_text(stmt, 14, [[dic valueForKey:@"emp_code"]UTF8String],-1,NULL);//emp_emergencytel
	
    sqlite3_bind_text(stmt, 15, [pinyinAll UTF8String],-1,NULL);//emp_pinyin_all
	sqlite3_bind_text(stmt, 16, [pinyinSimple UTF8String],-1,NULL);//emp_pinyin_simple

    //    emp_birthday,emp_fax,emp_address,emp_postcode,emp_name_eng
    sqlite3_bind_int(stmt, 17, [[dic valueForKey:@"emp_birthday"]intValue]);//emp_birthday
    sqlite3_bind_text(stmt, 18, [[dic valueForKey:@"emp_fax"] UTF8String],-1,NULL);//emp_fax
	sqlite3_bind_text(stmt, 19, [[dic valueForKey:@"emp_address"] UTF8String],-1,NULL);//emp_address
    sqlite3_bind_text(stmt, 20, [[dic valueForKey:@"emp_postcode"] UTF8String],-1,NULL);//emp_postcode
	sqlite3_bind_text(stmt, 21, [[dic valueForKey:@"emp_name_eng"] UTF8String],-1,NULL);//emp_name_eng

	sqlite3_bind_int(stmt, 22, [[dic valueForKey:@"emp_id"] intValue]);//emp_id    

	//	执行
	state = sqlite3_step(stmt);
	
	pthread_mutex_unlock(&add_mutex);
	
	//	执行结果
	if(state != SQLITE_DONE &&  state != SQLITE_OK)
	{
		//			执行错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
	}
	//释放资源
	pthread_mutex_lock(&add_mutex);
	sqlite3_finalize(stmt);
	pthread_mutex_unlock(&add_mutex);
}

#pragma mark 查询员工
-(NSDictionary *)searchEmp:(NSString*)empId
{
	if(empId && [empId length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select a.*,b.permission,b.is_special from %@ a,%@ b where a.emp_id = %@ and a.emp_id = b.emp_id ", table_employee,table_emp_dept,empId];
        [self operateSql:sql Database:_handle toResult:result];
        
        if(result.count >= 1 )
        {
//            如果有多个部门，那么就需要查询下是否有permission大于0的数据，如果有则返回
            if (result.count > 1)
            {
                 for (NSDictionary *dic in result) {
//                    NSLog(@"%d",[[dic valueForKey:@"permission"]intValue]);
                    int permissionTmp = [[dic valueForKey:@"permission"]intValue];
                    if (permissionTmp > 0) {
                        return dic;
                    }
                }
            }

			return [result objectAtIndex:0];
        }
        else
        {
//            如果根据部门没有查询出来，那么直接查询员工表
            sql  =   [NSString stringWithFormat:@"select * from %@ a where emp_id = %@ ", table_employee,empId];
            [self operateSql:sql Database:_handle toResult:result];
            
            if (result.count >= 1) {
                return [result objectAtIndex:0];
            }
            else
            {
                return nil;
            }
        }
    }
	return nil;
}

#pragma mark - 根据工号查询用户资料
-(NSDictionary *)searchEmpInfoByUsercode:(NSString*)usercode{
    if(usercode && [usercode length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select * from %@ a where emp_code = '%@' COLLATE NOCASE ", table_employee,usercode];
        [self operateSql:sql Database:_handle toResult:result];
        
        if (result.count >= 1) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[result objectAtIndex:0]];
            Emp *_emp = [self getEmpInfo:[StringUtil getStringValue:[[dic objectForKey:@"emp_id"]intValue]]];
            [dic setObject:_emp.deptName forKey:@"emp_dept"];
            return dic;
        }
        else
        {
            return nil;
        }
    }
	return nil;
}

#pragma mark - 根据姓名查询用户资料
-(NSDictionary *)searchEmpByEmpName:(NSString *)empName
{
    if(empName && [empName length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select a.*,b.permission,b.is_special from %@ a,%@ b where a.emp_name = '%@' and a.emp_id = b.emp_id ", table_employee,table_emp_dept,empName];
        [self operateSql:sql Database:_handle toResult:result];
        
        if(result.count >= 1 )
        {
            //            如果有多个部门，那么就需要查询下是否有permission大于0的数据，如果有则返回
            if (result.count > 1)
            {
                for (NSDictionary *dic in result) {
                    int permissionTmp = [[dic valueForKey:@"permission"]intValue];
                    if (permissionTmp > 0) {
                        return dic;
                    }
                }
            }
            
            return [result objectAtIndex:0];
        }
        else
        {
            //            如果根据部门没有查询出来，那么直接查询员工表
            sql  =   [NSString stringWithFormat:@"select * from %@ a where emp_name = '%@' ", table_employee,empName];
            [self operateSql:sql Database:_handle toResult:result];
            
            if (result.count >= 1) {
                return [result objectAtIndex:0];
            }
            else
            {
                return nil;
            }
        }
    }
    return nil;
}


#pragma mark 根据员工id查找员工名字，如果名字为空，返回员工工号，如果工号为空，则返回用户id
-(NSString *)getEmpNameByEmpId:(NSString *)emp_id
{
    NSString *sql;
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    sql = [NSString stringWithFormat:@"select emp_name from %@ where emp_id= %@ ",table_employee,emp_id];
    NSArray *result = [self querySql:sql];
    if (result.count) {
        NSDictionary *dic = result[0];
        return dic[@"emp_name"];
    }
#else
    if ([LanUtil isChinese])
    {
        sql = [NSString stringWithFormat:@"select emp_name,emp_code from %@ where emp_id= %@ ",table_employee,emp_id];
    }
    else
    {
        sql = [NSString stringWithFormat:@"select emp_name_eng,emp_code from %@ where emp_id= %@ ",table_employee,emp_id];
    }
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    if (result!=nil&&[result count]==1) {
        NSDictionary *dic = [result objectAtIndex:0];
        NSString *empName;
        if ([LanUtil isChinese])
        {
            empName = [dic valueForKey:@"emp_name"];
        }
        else
        {
            empName = [dic valueForKey:@"emp_name_eng"];
        }
        
        if(empName && empName.length > 0)
            return empName;
        
        NSString *empCode = [dic valueForKey:@"emp_code"];
        if(empCode && empCode.length > 0)
            return empCode;
    }
    
#endif

	return emp_id;
}

/** 根据员工id获取该员工所在部门 */
- (NSString *)getEmpDeptNameByEmpId:(NSString *)empId{
    
    NSString *sql = [NSString stringWithFormat:@"select b.* from %@ a,%@ b where a.emp_id = '%@'  and a.dept_id = b.dept_id order by a.dept_id",table_emp_dept,table_department,empId];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    
    //    int permission = 0;
    NSMutableString *deptName = [NSMutableString string];
    //	NSMutableString *titleName = [NSMutableString string];
    NSString *temp = @"";
    for(NSDictionary *dic in result)
    {
        
        temp = [self getDeptNameWithParentByDeptInfo:dic];
        //        因为在保存组织架构时 已经不计算 部门的父部门，所以要修改方式
        //		temp = [dic objectForKey:@"dept_name_contain_parent"];
        
        temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if([temp length] > 0){
            if([deptName length] > 0)
            {
                [deptName appendString:@"\n"];
                [deptName appendString:temp];
            }
            else
            {
                [deptName appendString:temp];
            }
        }
        
        //        人员title是保存在员工表里的
        //		temp = [dic objectForKey:@"emp_title"];
        //		temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //
        //		if([temp length] > 0)
        //		{
        //			if([titleName length] > 0)
        //			{
        //				[titleName appendString:@";"];
        //				[titleName appendString:temp];
        //			}
        //			else
        //			{
        //				[titleName appendString:temp];
        //			}
        //		}
        //        permission = [[dic objectForKey:@"permission"]intValue];
    }
    return deptName;
}

#pragma mark 查询本地用户资料，除包括基本信息如果id，名称，性别外，还包括部门名称，职务名称，email，手机号等信息 一个人存在于多个部门
-(Emp *)getEmpInfo:(NSString*)empId
{
	NSMutableString *deptName = [self getEmpDeptNameByEmpId:empId];
	
	NSDictionary *dic = [self searchEmp:empId];
	
	if(dic)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
        if (!emp.emp_mobile) {
            emp.emp_mobile = @"";
        }
        if (!emp.emp_tel) {
            emp.emp_tel = @"";
        }
        if (!emp.emp_mail) {
            emp.emp_mail = @"";
        }
		emp.deptName = deptName;
        
//        NSLog(@"%@",emp.deptName);
//
//        PermissionModel *_model = [[PermissionModel alloc]init];
//        [_model setPermission:permission];
//        emp.permission = _model;
//        [_model release];
//				emp.titleName = titleName;
		return [emp autorelease];
	}
	
	return nil;
}

#pragma mark - 根据empName,获取Emp信息
-(Emp *)getEmpInfoByEmpName:(NSString *)empName
{
    NSDictionary *dic = [self searchEmpByEmpName:empName];
    if(dic)
    {
        Emp *emp = [[Emp alloc]init];
        [self putDicData:dic toEmp:emp];
        return [emp autorelease];
    }
    return nil;
}

#pragma mark 根据empCode，在内存里找到对应的emp
-(Emp*)getEmpFromMemoryByEmpCode:(NSString *)empCode
{
    conn *_conn = [conn getConn];
    Emp *_emp;
//    先根据empcode，查询出员工和员工部门
    NSString *sql = [NSString stringWithFormat:@"select a.emp_id,b.dept_id from %@ a,%@ b where a.emp_code = '%@' and a.emp_id = b.emp_id  COLLATE NOCASE ",table_employee,table_emp_dept,empCode];
    NSMutableArray *result = [self querySql:sql];
//    再修改内存里该用户的状态，设置为选中
//    如果这个用户属于多个部门，那么只返回一个
    for (int i = 0; i < result.count; i++) {
        NSString *keyStr = [NSString stringWithFormat:@"%@_%@",[[result objectAtIndex:i]valueForKey:@"emp_id"],[[result objectAtIndex:i]valueForKey:@"dept_id"]];
        _emp = [_conn.allEmpsDic objectForKey:keyStr];
        if (_emp) {
            _emp.isSelected = YES;
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,@"内存中还没有员工数据"]];
        }
    }
    return _emp;
}

#pragma mark - 根据工号查询本地用户资料
-(Emp *)getEmpInfoByUsercode:(NSString*)usercode{
    if(usercode && [usercode length] > 0)
    {
        NSMutableArray *result  =   [NSMutableArray array];
        
        NSString *sql  =   [NSString stringWithFormat:@"select * from %@ a where emp_code = '%@'  COLLATE NOCASE ", table_employee,usercode];
        [self operateSql:sql Database:_handle toResult:result];
        
        if (result.count >= 1) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[result objectAtIndex:0]];
            Emp *_emp = [self getEmpInfo:[StringUtil getStringValue:[[dic objectForKey:@"emp_id"]intValue]]];
            return _emp;
        }
        else
        {
            return nil;
        }
    }
	return nil;
}


#pragma mark - 按emp_id 获取 人员信息 ,和getEmpInfo的区别是没有获取部门
-(Emp *)getEmployeeById:(NSString *)emp_id
{
	NSDictionary *dic = [self searchEmp:emp_id];
	if(dic)
	{
		Emp *emp = [[Emp alloc]init];
		[self putDicData:dic toEmp:emp];
		return [emp autorelease];
	}
	return nil;
}

//增加一个是否最近联系人的判断
- (BOOL)isRecentContact:(NSString *)empId
{
    return YES;
}

#pragma mark 删除人员
-(void)delEmps:(NSArray *)info
{
    NSDictionary *allChatEmps = nil;
    if (info.count) {
        allChatEmps = [[eCloudDAO getDatabase]getAllChatEmps];
    }
    NSString *sql;
    NSString *empId;
    NSMutableArray *result;
    for(NSDictionary *dic in info)
    {
        empId = [dic objectForKey:@"emp_id"];
        
        if (allChatEmps[empId])    {
            //首先删除所有的员工与部门关系
            sql = [NSString stringWithFormat:@"delete from %@ where emp_id = %@",table_emp_dept,empId];
            [self operateSql:sql Database:_handle toResult:nil];
            
            //                是最近联系人，在部门表里增加一条部门id为0的记录
            sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id,emp_sort) values(%@,0,0)",table_emp_dept,empId];
            [self operateSql:sql Database:_handle toResult:nil];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 收到过%@的消息不删除",__FUNCTION__,empId]];
            
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s delete empid is %@",__FUNCTION__,empId]];
            
            sql = [NSString stringWithFormat:@"delete from %@ where emp_id = '%@'",table_employee,empId];
            [self operateSql:sql Database:_handle toResult:nil];
        }
    }
}
//{
//	NSString *sql;
//	NSString *empId;
//    NSMutableArray *result;
//	for(NSDictionary *dic in info)
//	{
//		empId = [dic objectForKey:@"emp_id"];
//        
//        [LogUtil debug:[NSString stringWithFormat:@"%s delete empid is %@",__FUNCTION__,empId]];
//        
//        
//        sql = [NSString stringWithFormat:@"select emp_name from %@ where emp_id = %@",table_employee,empId];
//        result = [self querySql:sql];
//        if (result.count > 0)
//        {
//            [LogUtil debug:[NSString stringWithFormat:@"人员%@存在",[[result objectAtIndex:0]valueForKey:@"emp_name"]]];
//            
//            if ([self isRecentContact:empId])
//            {
////首先删除所有的员工与部门关系
//                sql = [NSString stringWithFormat:@"delete from %@ where emp_id = %@",table_emp_dept,empId];
//                pthread_mutex_lock(&add_mutex);
//                sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, NULL);
//                pthread_mutex_unlock(&add_mutex);
//                
////                是最近联系人，在部门表里增加一条部门id为0的记录
//                sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id,emp_sort) values(%@,0,0)",table_emp_dept,empId];
//             }
//            else
//            {
//                sql = [NSString stringWithFormat:@"delete from %@ where emp_id = '%@'",table_employee,empId];
//            }
//
//            char *errorMessage;
//            
//            pthread_mutex_lock(&add_mutex);
//            sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
//            pthread_mutex_unlock(&add_mutex);
//            
//            if(errorMessage)
//                [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
//        }
////        
////        
////		if([self searchEmp:empId])
////		{
////			//			删除员工表里的数据
////			sql = [NSString stringWithFormat:@"delete from %@ where emp_id = '%@'",table_employee,empId];
////			[self operateSql:sql Database:_handle toResult:nil];
////			
////			//			删除部门员工表里的数据
////			sql = [NSString stringWithFormat:@"delete from %@ where emp_id='%@'",table_emp_dept,empId];
////			[self operateSql:sql Database:_handle toResult:nil];
////			
////		}
//	}
//}

//使用事务方式删除多个人员
-(void)delEmpsWithTransaction:(NSArray *)info
{
	NSString *sql;
	NSString *empId;
	for(NSDictionary *dic in info)
	{
		empId = [dic objectForKey:@"emp_id"];
		if([self searchEmp:empId])
		{
			//			删除员工表里的数据
			sql = [NSString stringWithFormat:@"delete from %@ where emp_id = '%@'",table_employee,empId];
			[self operateSql:sql Database:_handle toResult:nil];
			
			//			删除部门员工表里的数据
			sql = [NSString stringWithFormat:@"delete from %@ where emp_id='%@'",table_emp_dept,empId];
			[self operateSql:sql Database:_handle toResult:nil];
			
		}
	}
}
#pragma mark 如果用户详细资料不是最新的，那么获取最新的用户资料并下载头像，如果是最新的，则检查头像是否存在，如果不存在则下载头像
//如果第一次和某个人单聊，或者是收到一条消息，并且是发送人第一次向这个群组发消息
-(void)getUserInfoAndDownloadLogo:(NSString*)empId
{
//    return;
	NSDictionary *empInfo = [self searchEmp:empId];
	NSString *empInfoFlag = [empInfo valueForKey:@"emp_info_flag"];
	if([empInfoFlag isEqualToString:@"Y"])
	{
		//					下载头像
		[StringUtil downloadUserLogo:[StringUtil getStringValue:[[empInfo valueForKey:@"emp_id"]intValue]] andLogo:[empInfo valueForKey:@"emp_logo"] andNeedSaveUrl:false];
	}
	else
	{
		//					下载用户资料
		conn *_conn = [conn getConn];
		[_conn getUserInfoAuto:empId.intValue];
	}
}



#pragma mark 根据拼音或者名称查询部门 废弃代码 by shisp
-(NSArray *)getDeptByNameOrPinyin:(NSString*)searchText andType:(int)_type
{
	NSMutableArray *depts = [NSMutableArray array];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString *sql = nil;
	
    NSString *firstChar = [searchText substringToIndex:1];
    
	switch (_type)
	{
		case letter_type:
			sql = [NSString stringWithFormat:@"select * from %@ where (dept_permission <> 1) and ((dept_pinyin_simple like '%%%@%%') or (dept_pinyin_all like '%%%@%%') or (dept_name_eng like '%%%@%%'))  ORDER BY dept_id",table_department,searchText,searchText,searchText];
			break;
		case hanzi_type:
			sql = [NSString stringWithFormat:@"select * from %@ where (dept_permission <> 1) and (dept_name like '%%%@%%')   ORDER BY dept_id",table_department,searchText];
			break;
		default:
			break;
	}
	
	if(sql)
	{
		//		[LogUtil debug:[NSString stringWithFormat:@"根据拼音或者名称查询部门 sql is %@",sql]];
		NSMutableArray *result = [NSMutableArray array];
		[self operateSql:sql Database:_handle toResult:result];
		if([result count]>0)
		{
			for(int i = 0;i<[result count];i++)
			{
				Dept *dept = [[Dept alloc]init];
				NSDictionary *dic = [result objectAtIndex:i];
				NSString *dept_id = [dic objectForKey:@"dept_id"];
				dept.dept_id = [dept_id intValue];
				dept.dept_name = [dic objectForKey:@"dept_name"];
				dept.dept_tel = [dic objectForKey:@"dept_tel"];
				dept.dept_parent = [[dic objectForKey:@"dept_parent"] intValue];
                dept.dept_level=0;
                dept.dept_emps = nil;
                dept.isChecked = false;
                
                //			在线人数需要计算
//                dept.totalNum=[[dic valueForKey:@"emp_count"]intValue];//--部门所有人员人数
//                conn *_conn = [conn getConn];
//                dept.onlineNum=[_conn getOnlineEmpCountByDeptId:dept.dept_id];
				[depts addObject:dept];
				[dept release];
			}
		}
	}
	[pool release];
	return depts;
}

#pragma mark 在会话列表界面增加了搜索功能，可以根据群组人员名称进行搜索，因为群组成员表里只保持了userid，因此查询要分两步，第一步是根据用户输入查询userid，第二步是根据userid，查询群组成员表，得到符合条件的群组
-(NSArray *)searchUserBy:(NSString*)searchText
{
	int _type = [StringUtil getStringType:searchText];
	if(_type == other_type)
		return nil;
    
    [self setLimitWhenSearchUser:NO];
    
    return [self getEmpsByNameOrPinyin:searchText andType:_type];
}

//在内存中查询用户，可以根据简拼，全屏，工号，姓名查询
//万达版本 如果是字母，那么看是否和简拼及账号匹配(账号保存在empcode中，默认的是中文姓名的拼音在加一个数字) 如果是中文那么匹配中文姓名
- (void)searchUserFromMemoryWithExactEmps:(NSMutableArray *)exactEmps withEmpsFromIndex0:(NSMutableArray*)empsFromIndex0 withEmpsOther:(NSMutableArray *)emps andCondition:(NSString *)searchText andConditionType:(int)conditionType
{
    //		先去内存根据简拼查询
    conn *_conn = [conn getConn];
    [_conn getAllEmpArray];
    
    BOOL isMatch;
    NSRange range;
    
    NSString *firstChar = [searchText substringToIndex:1];
    
//    NSLog(@"%s,%@,%@",__FUNCTION__,searchText,firstChar);
    
    int searchLimit = 0;
    
    for(Emp *emp in [_conn getAllEmpInfoArray])
    {
        range = NSMakeRange(0, 0);
        
        isMatch = NO;
        if(conditionType == 0)
        {
            //        按照简拼和账号查询
            
            if(emp.empPinyinSimple && emp.empPinyinSimple.length > 0)
            {
                if ([emp.empPinyinSimple isEqualToString:searchText])
                {
//                    完全匹配简拼
                    isMatch = YES;
                }
                else
                {
                    range = [emp.empPinyinSimple rangeOfString:searchText];
                    
//                    if (range.length == 0)
//                    {
////                        和简拼不匹配，检查是否和账号匹配
////                        账号肯定不为空，所以这里不用判断
//                        if ([emp.empCode isEqualToString:searchText])
//                        {
//                            isMatch = YES;
//                        }
//                        else
//                        {
//                            range = [emp.empCode rangeOfString:searchText];
//                        }
//                    }
                }
            }
//            else
//            {
////                NSLog(@"%@,%@",emp.emp_name,emp.empCode);
////                简拼为空，匹配账号
//                if ([emp.empCode isEqualToString:searchText])
//                {
//                    isMatch = YES;
//                }
//                else
//                {
//                    range = [emp.empCode rangeOfString:searchText];
//                }
//            }
        }
//        update by shisp 不匹配全拼，只匹配简拼和账号
//        按照全拼查询
        else if(conditionType == 1)
        {
            if (emp.empPinyin)
            {
                if ([emp.empPinyin isEqualToString:searchText])
                {
                    isMatch = YES;
                }
                else
                {
                    range = [emp.empPinyin rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
            }
            else
            {
                continue;
            }
        }
//        按照工号查询
        else if(conditionType == 2)
        {
            if (emp.empCode)
            {
                if ([emp.empCode isEqualToString:searchText])
                {
                    isMatch = YES;
                }
                else
                {
                    range = [emp.empCode rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
            }
            else
            {
                continue;
            }
        }
//        根据姓名去查询
        else if(conditionType == 3)
        {
            if (emp.emp_name)
            {
                if ([emp.emp_name isEqualToString:searchText])
                {
                    isMatch = YES;
                }
                else
                {
                    range = [emp.emp_name rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
            }
            else
            {
                continue;
            }
        }
        //        根据手机号去查询
        else if(conditionType == 4)
        {
            if (emp.emp_mobile)
            {
                if ([emp.emp_mobile isEqualToString:searchText])
                {
                    isMatch = YES;
                }
                else
                {
                    range = [emp.emp_mobile rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
            }
            else
            {
                continue;
            }
        }
//根据title查询
        else if(conditionType == 5)
        {
            if (emp.titleName)
            {
                if ([emp.titleName isEqualToString:searchText])
                {
                    isMatch = YES;
                }
                else
                {
                    range = [emp.titleName rangeOfString:searchText options:NSCaseInsensitiveSearch];
                }
            }
            else
            {
                continue;
            }
        }
        
        
        if (isMatch || range.length > 0) {
            //            如果是隐藏的则不用加
            if(emp.permission.isHidden && START_CSAIR_HIDE_ORG)
            {
                NSLog(@"因为是黑名单，并且是隐藏，所以不处理 %@",emp.emp_name);
                continue;
            }
            if (emp.emp_id == [BACK_LOG_ID intValue] || emp.emp_id == [MEETING_ID_TEST intValue] ||emp.emp_id == [MEETING_ID intValue] ||emp.emp_id == [SECRETARY_ID intValue] ||emp.emp_id == [File_ID intValue]) {
                
                continue;
            }
        }
        
        BOOL isAdd = NO;
        if (isMatch)
        {
//            add by shisp 如果还没有加到搜索结果，那么就增加，否则不增加
            if (!emp.isAddToSearchResult) {
                emp.isAddToSearchResult = YES;
                [exactEmps addObject:emp];
                isAdd = YES;
            }
        }
        else
        {
//            add by shisp 如果还没有加到搜索结果，那么就增加，否则不增加
           if (range.length > 0 && !emp.isAddToSearchResult)
            {
                emp.isAddToSearchResult = YES;
                isAdd = YES;
                if (range.location == 0)
                {
                    [empsFromIndex0 addObject:emp];
                }
                else{
                    [emps addObject:emp];
                }
            }
        }
        if (isAdd)
        {
            //            update by shisp 不保存查询到的父部门数据，每次都去查询，可以根据语言显示不同的父部门
//            if (emp.parent_dept_list == nil)
//            {
            //            }

#if defined(_TAIHE_FLAG_) || defined(_LANGUANG_FLAG_)
//            查询这个人员所有的部门
            [self setTaiheEmpDept:emp];
//            如果没有取到父部门，那么就从结果中删除
            if (emp.parent_dept_list.length == 0) {
                 if (isMatch) {
                    [exactEmps removeObject:emp];
                }else{
                    if (range.location == 0) {
                        [empsFromIndex0 removeObject:emp];
                    }else{
                        [emps removeObject:emp];
                    }
                }
            }
#else
            emp.parent_dept_list = [self getParentDeptListName:emp.emp_dept];
#endif
            emp.emp_level=0;
        }
    }
}

//获取泰和某个人所在部门
- (void)setTaiheEmpDept:(Emp *)emp
{
//    emp.parent_dept_list = @"集团总部/信息流程部集团总部/信息流程部集团总部/信息流程部集团总部/信息流程部集团总部/信息流程部集团总部/信息流程部集团总部/信息流程部";
//    return;
    NSArray *emps = [[conn getConn] getEmpByEmpId:emp.emp_id];
    if (emps.count) {
        if (emps.count == 1) {
            emp.parent_dept_list = [self getParentDeptListName:emp.emp_dept];
        }else{
            NSMutableString *mTempStr = [NSMutableString stringWithString:@""];
            for (Emp *tempEmp  in emps) {
                NSString *tempEmpDept = [self getParentDeptListName:tempEmp.emp_dept];
                
                if (!tempEmp.isAddToSearchResult) {
                    tempEmp.isAddToSearchResult = YES;
                }
                
                [LogUtil debug:[NSString stringWithFormat:@"%s %@ %@",__FUNCTION__,tempEmp.emp_name,tempEmpDept]];

                NSArray *tempArray = [tempEmpDept componentsSeparatedByString:@"/"];
                if (tempArray.count) {
                    NSString *rootDeptName = tempArray.lastObject;
                    if (mTempStr.length) {
                        [mTempStr appendFormat:@",%@",rootDeptName];
                    }else{
                        [mTempStr appendFormat:@"%@",rootDeptName];
                    }
                }
            }
            emp.parent_dept_list = mTempStr;
        }
#ifdef _LANGUANG_FLAG_
        if (emp.parent_dept_list.length && emp.titleName.length) {
            
            NSString *tempStr = emp.parent_dept_list;
            emp.parent_dept_list = [NSString stringWithFormat:@"%@%@%@",tempStr,dept_seperator,emp.titleName];
        }
#endif
    }
}

#pragma mark 根据拼音或者姓名查询联系人
-(NSArray *)getEmpsByNameOrPinyin:(NSString*)searchText andType:(int)_type
{
//    保存精确匹配的结果的数组
    NSMutableArray *exactEmps = [NSMutableArray array];
//    保存从头开始匹配的结果的数组
    NSMutableArray *empsFromIndex0 = [NSMutableArray array];
//    保存其它种类匹配的数组
	NSMutableArray *emps = [NSMutableArray array];
	
        switch (_type) {
//                如果是字母类型，那么只能是简拼，全拼，账号
            case letter_type:
            {
                searchText = [searchText lowercaseString];
                if (([eCloudConfig getConfig].searchEmpByLetter.intValue & emp_match_simple_pinyin)) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:0];
                }
                
                if ([eCloudConfig getConfig].searchEmpByLetter.intValue & emp_match_pinyin_withoutspace) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:1];
                }
                
                if ([eCloudConfig getConfig].searchEmpByLetter.intValue & emp_match_empcode) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:2];
                }
            }
                break;
//                如果是数字类型，那么只能是账号
            case number_type:
            {
                /** 如果是泰禾，用户输入了数字，那么匹配手机号 */
                if ([eCloudConfig getConfig].supportSearchByPhone) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:4];
                }
                if ([eCloudConfig getConfig].searchEmpByNumber.intValue & emp_match_empcode) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:2];
                }
            }
                break;
//                如果是汉字类型，只能是名字
            case hanzi_type:
            {
                [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:3];
                if ([eCloudConfig getConfig].supportSearchByTitle) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:5];
                }
            }
                break;
//                如果是特殊字符，那么可能是名字，也可能是账号
            case special_char_type:
            {
                if ([eCloudConfig getConfig].searchEmpBySpecialChar.intValue & emp_match_empcode) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:2];
                }
                if ([eCloudConfig getConfig].searchEmpBySpecialChar.intValue & emp_match_empname) {
                    [self searchUserFromMemoryWithExactEmps:exactEmps withEmpsFromIndex0:empsFromIndex0 withEmpsOther:emps andCondition:searchText andConditionType:3];
                }
            }
                
                break;
            default:
                break;
        }
    
    NSMutableArray *_emps = [NSMutableArray array];
    [_emps addObjectsFromArray:exactEmps];
    [_emps addObjectsFromArray:empsFromIndex0];
    [_emps addObjectsFromArray:emps];
    
    //    恢复为原来的状态
    for (Emp *_emp in _emps) {
        _emp.isAddToSearchResult = NO;
    }

    if (limitWhenSearchUser && _emps.count > SEARCHLIMIT)
    {
        NSMutableArray *mArray = [NSMutableArray arrayWithCapacity:SEARCHLIMIT];
        for (int i = 0; i < SEARCHLIMIT; i++) {
            [mArray addObject:[_emps objectAtIndex:i]];
        }
        return mArray;
    }
    
	return _emps;
}

#pragma mark 根据部门查询人员 当内存里还没有获取到员工资料时，使用这个方法，获取部门直属员工，也是emp_sort降序，emp_code升序，和获取到内存的顺序一致，如果内存里已经有员工资料了，则按照pc在线，pc离开，移动在线，离线的顺序来展示
-(NSArray *)getEmpsByDeptID:(int)dept_id andLevel:(int)level
{
	NSMutableArray *emps = [NSMutableArray array];
    
	NSMutableArray *empsPCOnline = [NSMutableArray array];
    
    NSMutableArray *empsPCLeave = [NSMutableArray array];
    
    NSMutableArray *empsMobileOnline = [NSMutableArray array];
    
    NSMutableArray *empsOffline= [NSMutableArray array];
    
    conn *_conn = [conn getConn];
    [_conn getAllEmpArray];
    
    if(_conn.allEmpArray.count <= 1)
    {
        NSString *empCols = @"b.emp_id,emp_status,emp_name,emp_name_eng,emp_sex,a.dept_id,emp_code,emp_login_type";
        
//        NSString *sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b where a.dept_id = %d and a.emp_id = b.emp_id order by emp_sort desc,emp_code",empCols,table_emp_dept,table_employee,dept_id];

        //        需要增加判断条件 对应的部门 要能够显示员工才行
        NSString *sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b ,%@ c where a.dept_id = %d and a.dept_id = c.dept_id and c.display_flag = %d and a.emp_id = b.emp_id order by emp_sort desc,emp_code ",empCols,table_emp_dept,table_employee,table_department,dept_id,dept_display_type_display_emp_and_subdept];

//        如果是南航，那么rank_id等于0时不能显示 只有大于0才显示,因此增加一个rank_id > 0的查询条件
        if ([UIAdapterUtil isCsairApp] && START_CSAIR_HIDE_ORG) {
            sql = [NSString stringWithFormat: @"select %@ from %@ a , %@ b where a.dept_id = %d and a.emp_id = b.emp_id and a.rank_id > 0 order by emp_sort desc,emp_code",empCols,table_emp_dept,table_employee,dept_id];
        }
        
        NSMutableArray *result = [self querySql:sql];
        
        for (NSDictionary *dic in result)
        {
            Emp *emp = [[Emp alloc]init];
            emp.emp_id = [[dic valueForKey:@"emp_id"]intValue];
            
            emp.emp_name = [dic valueForKey:@"emp_name"];
            emp.empNameEng = [dic valueForKey:@"emp_name_eng"];
            emp.empCode = [dic valueForKey:@"emp_code"];

            emp.emp_status = [[dic valueForKey:@"emp_status"]intValue];
            emp.emp_sex = [[dic valueForKey:@"emp_sex"]intValue];
            emp.emp_dept = [[dic valueForKey:@"dept_id"]intValue];
            
            emp.loginType = [[dic valueForKey:@"emp_login_type"]intValue];
            
            emp.isSpecial = NO;
//            如果不需要显示用户状态，那么就不用按照状态排序
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
                [empsOffline addObject:emp];
            }
            
            [emp release];
        }
    }
    else
    {
        for(Emp *emp in [_conn getAllEmpInfoArray])
        {
            if (emp.emp_dept==dept_id)
            {
                if(emp.permission.isHidden && START_CSAIR_HIDE_ORG)
                {
                    NSLog(@"%s,隐藏成员，不显示 %@",__FUNCTION__,emp.emp_name);
                    continue;
                }
                
                emp.emp_level=level;
                
                //            如果不需要显示用户状态，那么就不用按照状态排序
                if ([eCloudConfig getConfig].needDisplayUserStatus) {
                    //            如果是状态隐藏，那么加到离线的数组中
                    if (emp.permission.hideState)
                    {
                        NSLog(@"%s，状态隐藏 %@",__FUNCTION__,emp.emp_name);
                        [empsOffline addObject:emp];
                        continue;
                    }

                    if (emp.emp_status==status_online)
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
                    else if (emp.emp_status==status_leave)
                    {
                        [empsPCLeave addObject:emp];
                    }
                    else
                    {
                        [empsOffline addObject:emp];
                    }
                }else{
                    [empsOffline addObject:emp];
                }
            }
        }
    }
    

    [emps addObjectsFromArray:empsPCOnline];
    [emps addObjectsFromArray:empsPCLeave];
    [emps addObjectsFromArray:empsMobileOnline];
    [emps addObjectsFromArray:empsOffline];
    
//    NSLog(@"%s,pc online:%d ,pc leave:%d , mobile online: %d ,offline: %d ",__FUNCTION__,empsPCOnline.count,empsPCLeave.count,empsMobileOnline.count,empsOffline.count);
    
	return emps;
}

//用户职务
-(void)updateUserPosition:(NSString *)position :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_title =? where emp_id=%d ",table_employee,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	sqlite3_stmt *stmt = nil;
	
	//		编译
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		//			编译错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
		//			释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	sqlite3_bind_text(stmt, 1, [position UTF8String],-1,NULL);
	//	执行
	state = sqlite3_step(stmt);
	
	pthread_mutex_unlock(&add_mutex);
	//	执行结果
	if(state != SQLITE_DONE &&  state != SQLITE_OK)
	{
		//			执行错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
	}
	//释放资源
	pthread_mutex_lock(&add_mutex);
	sqlite3_finalize(stmt);
	pthread_mutex_unlock(&add_mutex);
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.titleName = position;
    }
}
//用户邮件
-(void)updateUserMail:(NSString *)mail :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_mail ='%@' where emp_id=%d ",table_employee,mail,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_mail = mail;
    }
    
}
//用户地址
-(void)updateUserAddress:(NSString *)address :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_address ='%@' where emp_id=%d ",table_employee,address,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
    
    [self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.empAddress = address;
    }
}

//用户宅电
-(void)updateUserHomeTel:(NSString *)telephone :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_hometel ='%@' where emp_id=%d ",table_employee,telephone,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_hometel = telephone;
    }
}

//用户紧急
-(void)updateUserEmergencyTel:(NSString *)telephone :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_emergencytel ='%@' where emp_id=%d ",table_employee,telephone,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_emergencytel = telephone;
    }
    
}

//用户电话
-(void)updateUserTelephone:(NSString *)telephone :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_tel ='%@' where emp_id=%d ",table_employee,telephone,userid];
    
	//	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_tel = telephone;
    }
}

//用户手机
-(void)updateUserMobile:(NSString *)mobileStr :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_mobile ='%@' where emp_id=%d ",table_employee,mobileStr,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_mobile = mobileStr;
    }
    
}

//用户签名
-(void)updateUserSignature:(NSString *)signature :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_signature =? where emp_id=%d ",table_employee,userid];
    
    //	[LogUtil debug:[NSString stringWithFormat:@"sql is %@",sql]];
	sqlite3_stmt *stmt = nil;
	
	//		编译
	pthread_mutex_lock(&add_mutex);
	int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
	pthread_mutex_unlock(&add_mutex);
	
	if(state != SQLITE_OK)
	{
		//			编译错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
		//			释放资源
		pthread_mutex_lock(&add_mutex);
		sqlite3_finalize(stmt);
		pthread_mutex_unlock(&add_mutex);
		return;
	}
	
	//		绑定值
	pthread_mutex_lock(&add_mutex);
	sqlite3_bind_text(stmt, 1, [signature UTF8String],-1,NULL);
	//	执行
	state = sqlite3_step(stmt);
	
	pthread_mutex_unlock(&add_mutex);
	//	执行结果
	if(state != SQLITE_DONE &&  state != SQLITE_OK)
	{
		//			执行错误
		[LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
	}
	//释放资源
	pthread_mutex_lock(&add_mutex);
	sqlite3_finalize(stmt);
	pthread_mutex_unlock(&add_mutex);
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.signature = signature;
    }
}

//用户性别
-(void)updateUserSex:(int)sex :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_sex =%d where emp_id=%d ",table_employee,sex,userid];
    
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_sex = sex;
    }
    
}

//用户头像id
-(void)updateUserAvatar:(NSString *)Avatar :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set emp_logo ='%@' where emp_id=%d ",table_employee,Avatar,userid];
    
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:userid];
    for (Emp *emp in emps)
    {
        emp.emp_logo = Avatar;
    }
}

#pragma mark 收到用户头像修改通知后，保存新的头像url
-(void)updateEmpLogo:(NSString*)empId andLogo:(NSString*)logo
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set emp_logo = '%@' where emp_id = %@ ",table_employee,logo,empId];
	[self operateSql:sql Database:_handle toResult:nil];
    
    conn *_conn = [conn getConn];
    NSArray *emps = [_conn getEmpByEmpId:empId];
    for (Emp *emp in emps)
    {
        emp.emp_logo = logo;
    }
}

-(void)putDicData:(NSDictionary*)dic toEmp:(Emp*)emp
{
	emp.emp_id = [[dic objectForKey:@"emp_id"] intValue];
	emp.emp_name = [dic objectForKey:@"emp_name"];
	emp.emp_sex = [[dic objectForKey:@"emp_sex"] intValue];
	emp.emp_status = [[dic objectForKey:@"emp_status"] intValue];
	emp.emp_mail = [dic objectForKey:@"emp_mail"];
	emp.emp_tel = [dic objectForKey:@"emp_tel"];
	emp.emp_mobile = [dic objectForKey:@"emp_mobile"];
	emp.emp_logo = [dic objectForKey:@"emp_logo"];
    emp.emp_hometel=[dic objectForKey:@"emp_hometel"];
    emp.emp_emergencytel=[dic objectForKey:@"emp_emergencytel"];
    emp.empPinyin = [dic objectForKey:@"emp_pinyin"];
    emp.emp_dept = [[dic objectForKey:@"emp_dept_id"] intValue];
  	NSString * sInfoFlag = [dic objectForKey:@"emp_info_flag"];
	if([sInfoFlag compare:@"Y"] == NSOrderedSame)
	{
		emp.info_flag = true;
	}
	else
	{
		emp.info_flag = false;
	}
	emp.comp_id = [[dic objectForKey:@"emp_comp_id"] intValue];
	
	emp.titleName = [dic objectForKey:@"emp_title"];
	emp.empCode = [dic objectForKey:@"emp_code"];
	emp.signature = [dic objectForKey:@"emp_signature"];
	emp.loginType = [[dic objectForKey:@"emp_login_type"] intValue];
    
	
	//	如果员工name没有，那么显示员工工号
	if(emp.emp_name == nil || emp.emp_name.length == 0)
		emp.emp_name = emp.empCode;
    
    int permission = [[dic objectForKey:@"permission"]intValue];
//    if(permission > 0)
//    {
//        NSLog(@"%@,permission is %d",emp.emp_name,permission);
//    }
    
    PermissionModel *_model = [[PermissionModel alloc]init];
    [_model setPermission:permission];
    emp.permission = _model;
    [_model release];
    
    int isSpecial = [[dic valueForKey:@"is_special"]intValue];
    if(isSpecial == 0)
    {
        emp.isSpecial = NO;
    }
    else
    {
        emp.isSpecial = YES;
    }
    
    emp.birthday = [[dic valueForKey:@"emp_birthday"]intValue];
    emp.empNameEng = [dic valueForKey:@"emp_name_eng"];
    emp.empFax = [dic valueForKey:@"emp_fax"];
    emp.empAddress = [dic valueForKey:@"emp_address"];
    emp.empPostCode = [dic valueForKey:@"emp_postcode"];
}

-(Emp *)getEmpByDicData:(NSDictionary *)dic
{
	Emp *emp = [[Emp alloc]init];
	emp.emp_id = [[dic objectForKey:@"emp_id"] intValue];
	emp.emp_name = [dic objectForKey:@"emp_name"];
	emp.emp_sex = [[dic objectForKey:@"emp_sex"] intValue];
	emp.emp_status = [[dic objectForKey:@"emp_status"] intValue];
	emp.emp_mail = [dic objectForKey:@"emp_mail"];
	emp.emp_tel = [dic objectForKey:@"emp_tel"];
	emp.emp_mobile = [dic objectForKey:@"emp_mobile"];
	emp.emp_logo = [dic objectForKey:@"emp_logo"];
    emp.emp_hometel=[dic objectForKey:@"emp_hometel"];
    emp.emp_emergencytel=[dic objectForKey:@"emp_emergencytel"];
  	NSString * sInfoFlag = [dic objectForKey:@"emp_info_flag"];
	if([sInfoFlag compare:@"Y"] == NSOrderedSame)
	{
		emp.info_flag = true;
	}
	else
	{
		emp.info_flag = false;
	}
	emp.comp_id = [[dic objectForKey:@"emp_comp_id"] intValue];
	
	emp.titleName = [dic objectForKey:@"emp_title"];
	emp.empCode = [dic objectForKey:@"emp_code"];
	emp.signature = [dic objectForKey:@"emp_signature"];
	emp.loginType = [[dic objectForKey:@"emp_login_type"] intValue];
	
	//	如果员工name没有，那么显示员工工号
	if(emp.emp_name == nil || emp.emp_name.length == 0)
		emp.emp_name = emp.empCode;
	
  	return emp ;
}
//查询第一个还未获取员工资料的员工id
-(int)selectFirstNoDetailEmpId
{
	//	NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where emp_id not in (select emp_id from %@ where emp_name <> '' ) limit 1",table_emp_dept,table_employee];
	//update by shisp
	NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where emp_info_flag = 'N' limit 1",table_employee];
	
	//	[LogUtil debug:[NSString stringWithFormat:@"%@",sql]];
	NSMutableArray *result = [[NSMutableArray alloc]init];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 0) {
        [result release];
        return -1;}
	int empId = [[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue];
    [result release];
	return empId;
}

#pragma mark 获取特殊用户列表的时候，需要发送用户自己所在部门数组
- (NSArray *)getUserDeptsArray
{
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"select dept_id from %@ where emp_id = %@",table_emp_dept,_conn.userId];
    NSMutableArray *result = [self querySql:sql];
    
    if(result.count == 0)
        return nil;
    NSMutableArray *deptsArray = [NSMutableArray arrayWithCapacity:result.count];
    for(NSDictionary *dic in result)
    {
        [deptsArray addObject:[dic valueForKey:@"dept_id"]];
    }
    return deptsArray;
}

#pragma mark 根据empId返回所在部门的id
- (NSArray *)getDeptCountByEmpId:(int)empId
{
    int deptCount = 0;
    NSString *sql = [NSString stringWithFormat:@"select dept_id from %@ where emp_id = %d",table_emp_dept,empId];
    NSMutableArray *result = [self querySql:sql];
    return result;
}

//保存用户的简要信息 id name sex
//???如果用户已经存在了，还有必要修改吗
- (void)saveCurUserBriefInfo:(Emp *)emp
{
    int empId = emp.emp_id;
    int sex = emp.emp_sex;
    NSString *empName = emp.emp_name;
    NSString *empNameEng = emp.empNameEng;
    int empStatus = emp.emp_status;
    
    NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where emp_id = %d",table_employee,empId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count == 0) {
        sql = [NSString stringWithFormat:@"insert into %@(emp_id,emp_sex,emp_name,emp_name_eng,emp_status) values(%d,%d,'%@','%@',%d)",table_employee,empId,sex,empName,empNameEng,empStatus];
    }
    else
    {
        sql = [NSString stringWithFormat:@"update %@ set emp_sex = %d,emp_name = '%@',emp_name_eng = '%@',emp_status = %d where emp_id = %d",table_employee,sex,empName,empNameEng,empStatus,empId];
    }
    [self operateSql:sql Database:_handle toResult:nil];

#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    /** 同时保存一条员工与部门关系数据 */
    sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id) values(%d,%d)",table_emp_dept,emp.emp_id,DEFAULT_DEPT_ID];
    [self operateSql:sql Database:_handle toResult:nil];
#endif

}

// 设置是否需要限制查询人数 add by shisp
- (void)setLimitWhenSearchUser:(BOOL)needLimit
{
    limitWhenSearchUser = needLimit;
}


//根据员工id，找到员工的部门资料，然后根据这个部门资料找到 包含父部门的部门名称
- (NSString *)getDeptNameWithParentByDeptInfo:(NSDictionary *)dic
{
    //			部门id，父部门id，
    NSString *deptId = [dic valueForKey:@"dept_id"];
    NSString *deptParent = [dic valueForKey:@"dept_parent"];
    NSString *deptName = [dic valueForKey:@"dept_name"];
    //            增加保存英文名称
    NSString *deptNameEng = [dic valueForKey:@"dept_name_eng"];
    if (deptNameEng == nil || deptNameEng.length == 0) {
        //            如果英文名称不存在，那么要显示中文名称
       deptNameEng = deptName;
    }
    
    if (deptParent == 0) {
        if ([LanUtil isChinese]) {
            return deptName;
        }
        else
        {
            return deptNameEng;
        }
    }
    else
    {
        //			先保存此父部门
        NSMutableArray *parentDeptArray = [NSMutableArray arrayWithObject:deptParent];
        
        NSMutableArray *parentDeptNameArray = [NSMutableArray arrayWithObject:deptName];
        
        //            部门英文名称数组
        NSMutableArray *parentDeptNameEngArray = [NSMutableArray arrayWithObject:deptNameEng];
        
        //			再找到父部门的父部门，直到父部门为0为止
        [self getDeptParentByDeptId:deptParent andParentDeptArray:parentDeptArray andParentDeptNameArray:parentDeptNameArray andParentDeptNameEngArray:parentDeptNameEngArray];
        
        if ([LanUtil isChinese])
        {
            NSMutableString *deptNameStr = [NSMutableString stringWithString:@""];
            for(int i = parentDeptNameArray.count - 1;i>=0;i--)
            {
                NSString *_deptName = [parentDeptNameArray objectAtIndex:i];
                [deptNameStr appendFormat:@"%@/",_deptName];
            }
            [deptNameStr deleteCharactersInRange:NSMakeRange(deptNameStr.length - 1,1)];
            return deptNameStr;
        }
        else
        {
            //            部门英文名称
            NSMutableString *deptNameEngStr = [NSMutableString stringWithString:@""];
            for(int i = parentDeptNameEngArray.count - 1;i>=0;i--)
            {
                NSString *_deptNameEng = [parentDeptNameEngArray objectAtIndex:i];
                if (_deptNameEng.length == 0)
                {
                    //            如果英文名称不存在，那么要显示中文名称
                    _deptNameEng = [parentDeptNameArray objectAtIndex:i];
                }
                [deptNameEngStr appendFormat:@"%@/",_deptNameEng];
            }
            [deptNameEngStr deleteCharactersInRange:NSMakeRange(deptNameEngStr.length - 1,1)];
            
            return deptNameEngStr;
        }
    }
}

#pragma mark  =====手动刷新组织架构======

- (void)refreshOrgByHand
{
    //    初始化组织架构时间戳
    [[eCloudUser getDatabase]initOrgUpdateTime];

//删除本地保存的部门数据，员工与部门关系数据，员工数据
    [LogUtil debug:[NSString stringWithFormat:@"%s:删除旧的组织架构数据...",__FUNCTION__]];
    conn *_conn = [conn getConn];

    if ([self beginTransaction]) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@",table_department];
        
        char *errorMessage;
        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        
        if(errorMessage)
            [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        
        sql = [NSString stringWithFormat:@"delete from %@",table_emp_dept];
        
        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        
        if(errorMessage)
            [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        
        sql = [NSString stringWithFormat:@"delete from %@ where emp_id <> %@",table_employee,_conn.userId];

        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        
        if(errorMessage)
            [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        
        [self commitTransaction];
    }
    
    [LogUtil debug:@"开始手动刷新组织架构..."];
//    修改内存里部门时间戳，员工与部门关系时间戳时间戳为0
    _conn.oldDeptUpdateTime = @"0";
    _conn.oldEmpDeptUpdateTime = @"0";
    _conn.oldDeptShowConfigUpdateTime = 0;

    
    _conn.isRefreshOrgByHand = YES;
    [_conn setCurConnStatus];

//    发起同步通讯录的请求
    [_conn getDeptInfo:nil];
}

//根据用户账号得到对应的Emp对象
- (Emp *)getEmpByUserAccount:(NSString *)userAccount
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where emp_code = '%@'  COLLATE NOCASE ",table_employee,userAccount];
    NSMutableArray *result = [self querySql:sql];
    if (result.count > 0) {
        return [self getEmpByDicData:[result objectAtIndex:0]];
    }
    return nil;
}

//根据用户账号得到id，如果没有找到，则返回-1
- (int)getEmpIdByUserAccount:(NSString *)userAccount
{
    //    long long start = [[NSDate date]timeIntervalSince1970] * 1000;
//    return -1;
    conn *_conn = [conn getConn];
    if (_conn.allEmpArray.count <= 1) {
        NSString *sql = [NSString stringWithFormat:@"select emp_id from %@ where emp_code = '%@'  COLLATE NOCASE ",table_employee,userAccount];
        NSMutableArray *result = [self querySql:sql];
        //        long long end = [[NSDate date]timeIntervalSince1970] * 1000;
        //        NSLog(@"%s 111 %d",__FUNCTION__ ,(end - start));
        
        if (result.count > 0) {
            return [[[result objectAtIndex:0]valueForKey:@"emp_id"]intValue];
        }
    }else{
        Emp *_emp = [_conn getEmpByEmpCode:userAccount];
        
        //        long long end = [[NSDate date]timeIntervalSince1970] * 1000;
        //        NSLog(@"%s 222 %d",__FUNCTION__ ,(end - start));
        if (_emp) {
            return _emp.emp_id;
        }
    }
    return -1;
}

//获取我的电脑这个一级部门的部门id
- (int)getDeptIdOfMyComputerDept
{
    NSString *sql = [NSString stringWithFormat:@"select dept_id from %@ where dept_parent = 0 and dept_name = '%@' ",table_department,MY_COMPUTER_DEPT_NAME];
    NSMutableArray *result = [self querySql:sql];
    
    if (result.count) {
        return [[result[0] valueForKey:@"dept_id"]intValue];
    }
    return -1;
}

//根据用户id获取其rank_id
- (int)getRankIdWithUserId:(int)userId
{
    NSString *sql = [NSString stringWithFormat:@"select rank_id from %@ where emp_id = %d",table_emp_dept,userId];
    NSMutableArray *result = [self querySql:sql];
    if (result.count) {
        return [[result[0] valueForKey:@"rank_id"]intValue];
    }
    return -1;
}

//删除员工与部门关系数据 删除员工数据 启动重新同步 南航需求 用户级别更换后，需要重新获取 哪些用户隐藏 哪些用户显示
- (void)clearEmpDeptData
{
    //    把数据库里保存的 empdept的时间戳 初始化为0
    [[eCloudUser getDatabase]initEmpDeptUpdateTime];
    
    //删除本地保存的部门数据，员工与部门关系数据，员工数据
    [LogUtil debug:[NSString stringWithFormat:@"%s:删除员工与部门关系数据和员工资料数据...",__FUNCTION__]];
    conn *_conn = [conn getConn];
    
    if ([self beginTransaction]) {
        char *errorMessage;
        
        NSString *sql = [NSString stringWithFormat:@"delete from %@",table_emp_dept];
        
        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        
        if(errorMessage)
            [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        
        sql = [NSString stringWithFormat:@"delete from %@ where emp_id <> %@",table_employee,_conn.userId];
        
        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        
        if(errorMessage)
            [LogUtil debug:[NSString stringWithFormat:@"%s sql 操作失败",__FUNCTION__]];
        
        [self commitTransaction];
    }
    
    [LogUtil debug:@"员工与部门关系数据已经删除，本地时间戳也设置为0，接下来正常同步即可..."];
    //    修改内存里部门时间戳，员工与部门关系时间戳时间戳为0
    _conn.oldEmpDeptUpdateTime = @"0";
    
//    [_conn setCurConnStatus];
//    
//    //    发起同步通讯录的请求
//    [_conn getDeptInfo:nil];
}

/** 华夏不同步通讯录 保存一个默认的部门 */
- (void)saveHXDefaultDept
{
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(dept_id) values(%d) ",table_department,DEFAULT_DEPT_ID];
    [self operateSql:sql Database:_handle toResult:nil];
}

/** 从华夏取到人员后保存在本地 */
- (BOOL)saveHXEmpToDB:(Emp *)_emp{
    NSString *sql = [NSString stringWithFormat:@"select emp_name from %@ where emp_id = %d",table_employee,_emp.emp_id];
    NSMutableArray *result = [self querySql:sql];
    if (result.count) {
        [LogUtil debug:[NSString stringWithFormat:@"%s %@保存已经存在",__FUNCTION__,[result[0] valueForKey:@"emp_name"]]];
        return NO;
    }
    
    sql = [NSString stringWithFormat:@"insert into %@(emp_id,emp_name,emp_sex,emp_code) values(%d,?,%d,?)",table_employee,_emp.emp_id,_emp.emp_sex];
    
    sqlite3_stmt *stmt = nil;
    
    //		编译
    pthread_mutex_lock(&add_mutex);
    int state = sqlite3_prepare_v2(_handle, [sql UTF8String], -1, &stmt, nil);
    pthread_mutex_unlock(&add_mutex);
    
    if(state != SQLITE_OK)
    {
        //			编译错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,prepare state is %d",__FUNCTION__,state]];
        //			释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        return NO;
    }
    //		绑定值
    pthread_mutex_lock(&add_mutex);
    sqlite3_bind_text(stmt, 1, [_emp.emp_name UTF8String],-1,NULL);
    sqlite3_bind_text(stmt, 2, [_emp.empCode UTF8String],-1,NULL);
    //	执行
    state = sqlite3_step(stmt);
    
    pthread_mutex_unlock(&add_mutex);
    //	执行结果
    if(state != SQLITE_DONE &&  state != SQLITE_OK)
    {
        //			执行错误
        [LogUtil debug:[NSString stringWithFormat:@"%s,exe state is %d",__FUNCTION__,state]];
        //释放资源
        pthread_mutex_lock(&add_mutex);
        sqlite3_finalize(stmt);
        pthread_mutex_unlock(&add_mutex);
        return NO;
    }
    //释放资源
    pthread_mutex_lock(&add_mutex);
    sqlite3_finalize(stmt);
    pthread_mutex_unlock(&add_mutex);
    
    NSString *empName = [self getEmpNameByEmpId:[StringUtil getStringValue:_emp.emp_id]];
    [LogUtil debug:[NSString stringWithFormat:@"%s 保存用户成功后获取到的empname is %@",__FUNCTION__,empName]];

    sql = [NSString stringWithFormat:@"insert or replace into %@(emp_id,dept_id) values(%d,%d)",table_emp_dept,_emp.emp_id,DEFAULT_DEPT_ID];
    [self operateSql:sql Database:_handle toResult:nil];
    return YES;
}


//修改所有部门的display_flag
- (BOOL)updateAllDeptWithDisplayFlag:(int)displayFlag
{
    NSString *sql = [NSString stringWithFormat:@"update %@ set display_flag = %d",table_department,displayFlag];
    BOOL result = [self operateSql:sql Database:_handle toResult:nil];
    return result;
}

//保存特殊的部门显示标志
- (BOOL)updatePartDeptDisplayFlags:(NSArray *)array
{
    BOOL result = YES;
    if (array.count) {
        NSMutableArray *sqlArray = [NSMutableArray arrayWithCapacity:array.count];
        
        for (NSDictionary *dic in array) {
            NSString *sql = [NSString stringWithFormat:@"update %@ set display_flag = %d where dept_id = %d ",table_department,[(dic[@"show_level"])intValue], [dic[@"dept_id"] intValue]];
            [sqlArray addObject:sql];
        }
        
        if ([self beginTransaction]) {
            for (NSString *sql in sqlArray) {
                char *errorMessage;
                
                pthread_mutex_lock(&add_mutex);
                sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
                pthread_mutex_unlock(&add_mutex);
                
                if(errorMessage){
                    [LogUtil debug:[NSString stringWithFormat:@"%s 出错了",__FUNCTION__]];
                    result = NO;
                }
            }
            [self commitTransaction];
        }else{
            for (NSString *sql in sqlArray) {
                if (![self operateSql:sql Database:_handle toResult:nil]) {
                    result = NO;
                }
            }
        }
    }
    return result;
}

/** 显示一个部门的父节点和子节点 */
- (void)displayParentDeptAndSubDept:(int)deptId{
//    找到部门的资料
    NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:[StringUtil getStringValue:deptId]];
    if (tempDic) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        
        //                                查找此部门的父部门
        NSString *parentDeptIds = tempDic[@"dept_parent_dept"];
        
        if (parentDeptIds.length) {
            NSArray *tempArray = [parentDeptIds componentsSeparatedByString:@","];
            NSMutableString *mStr = [NSMutableString string];
            for (NSString *parentDeptId in tempArray) {
                NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:parentDeptId];
                
                [mStr appendString:[NSString stringWithFormat:@"%@,",tempDic[@"dept_name"]]];
                
                [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:parentDeptId.intValue],@"dept_id",[NSNumber numberWithInt:dept_display_type_display_emp_and_subdept],@"show_level", nil]];
            }
            [LogUtil debug:[NSString stringWithFormat:@"%s 显示父部门 %@ ",__FUNCTION__,mStr]];
        }
        
        NSString *subDeptIds = tempDic[@"sub_dept"];
        
        if (subDeptIds.length) {
            NSArray *tempArray = [subDeptIds componentsSeparatedByString:@","];
            NSMutableString *mStr = [NSMutableString string];
            
            for (NSString *subDeptId in tempArray) {
                NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:subDeptId];
                [mStr appendString:[NSString stringWithFormat:@"%@,",tempDic[@"dept_name"]]];
                
                [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:subDeptId.intValue],@"dept_id",[NSNumber numberWithInt:dept_display_type_display_emp_and_subdept],@"show_level", nil]];
            }
            [LogUtil debug:[NSString stringWithFormat:@"%s 显示自己以及子部门 %@ ",__FUNCTION__,mStr]];
        }
        
        [self updatePartDeptDisplayFlags:mArray];
    }
}

/** 隐藏一个部门的父节点和子节点，只有父部门没有可显示的部门时，隐藏父部门 */
- (void)hideDeptAndSubDept:(int)deptId
{
    //    找到部门的资料
    NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:[StringUtil getStringValue:deptId]];
    if (tempDic) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        
//        查找部门的子部门，隐藏自己及子部门
        NSString *subDeptIds = tempDic[@"sub_dept"];
        
        if (subDeptIds.length) {
            NSArray *tempArray = [subDeptIds componentsSeparatedByString:@","];
            NSMutableString *mStr = [NSMutableString string];
            for (NSString *subDeptId in tempArray) {
                NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:subDeptId];
                [mStr appendString:[NSString stringWithFormat:@"%@,",tempDic[@"dept_name"]]];
                
                [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:subDeptId.intValue],@"dept_id",[NSNumber numberWithInt:dept_display_type_hide],@"show_level", nil]];
            }
            [LogUtil debug:[NSString stringWithFormat:@"%s 隐藏以下部门%@ ",__FUNCTION__,mStr]];
        }
        
        [self updatePartDeptDisplayFlags:mArray];
        
        //                                查找此部门的父部门
        NSString *parentDeptIds = tempDic[@"dept_parent_dept"];
        
        if (parentDeptIds.length) {
            NSArray *tempArray = [parentDeptIds componentsSeparatedByString:@","];
            if (tempArray.count) {
                NSString *tempDeptId = tempArray.lastObject;
                [self hideOrDspDept:tempDeptId.intValue];
            }
        }
    }
}

/** 看一个部门是否有可见的子部门，如果没有那么隐藏，同时查看其父部门是否需要隐藏，如果有则继续判断 */

- (void)hideOrDspDept:(int)deptId{
    
//    查找部门的直接子部门，如果没有要显示的，则隐藏部门本身
    NSArray *subDeptArray = [self getLocalNextDeptInfoWithLevel:[StringUtil getStringValue:deptId] andLevel:0];
    if (subDeptArray.count == 0) {
        //        查看部门的父部门是否需要隐藏
        NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:[StringUtil getStringValue:deptId]];
        if (tempDic) {
            NSMutableArray *mArray = [NSMutableArray array];
            [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:deptId],@"dept_id",[NSNumber numberWithInt:dept_display_type_hide],@"show_level", nil]];
            [LogUtil debug:[NSString stringWithFormat:@"%s 隐藏部门%@",__FUNCTION__,tempDic[@"dept_name"]]];
            [self updatePartDeptDisplayFlags:mArray];

            NSString *parentDept = tempDic[@"dept_parent_dept"];
            NSArray *parentDeptArray = [parentDept componentsSeparatedByString:@","];
            if (parentDeptArray.count) {
                NSString *tempDeptId = parentDeptArray.lastObject;
                [self hideOrDspDept:tempDeptId.intValue];
            }
        }
    }
}

/** 显示默认部门 找到用户自己所在部门的二级部门，显示此部门 */
- (void)dspDefaultDept{
    //                        找到自己的部门
    NSArray *curUserDeptArray = [[eCloudDAO getDatabase]getDeptCountByEmpId:[conn getConn].userId.intValue];
    for (NSDictionary *dic in curUserDeptArray) {
        int deptId = [dic[@"dept_id"]intValue];
        
        NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:[StringUtil getStringValue:deptId]];
        
        if (tempDic) {
            [LogUtil debug:[NSString stringWithFormat:@"%s 当前登录用户所在部门为 %d %@",__FUNCTION__,deptId,tempDic[@"dept_name"]]];
            
            //                                查找此部门的父部门
            NSString *parentDeptIds = tempDic[@"dept_parent_dept"];
            
            NSArray *tempArray = [parentDeptIds componentsSeparatedByString:@","];
            NSMutableString *mStr = [NSMutableString string];
            
            for (NSString *parentDeptId in tempArray) {
                NSDictionary *tempDic = [[eCloudDAO getDatabase]searchDept:parentDeptId];
                [mStr appendString:[NSString stringWithFormat:@"%@,",tempDic[@"dept_name"]]];
            }
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 当前登录用户父部门%@",__FUNCTION__,mStr]];
            
            //                都显示
            if (tempArray.count == 0) {
//                用户属于根部门，那么显示所有
                [LogUtil debug:[NSString stringWithFormat:@"%s 登录用户的部门是根部门，显示所有",__FUNCTION__]];
                [self updateAllDeptWithDisplayFlag:dept_display_type_display_emp_and_subdept];
            }else if (tempArray.count == 1) {
//                只显示当前部门
                [LogUtil debug:[NSString stringWithFormat:@"%s 登录用户的部门是二级部门，只显示用户所在二级部门",__FUNCTION__]];
                 [self displayParentDeptAndSubDept:deptId];
            }else if (tempArray.count >= 2) {
                //                    显示二级部门
                NSString *tempDeptId = tempArray[1];
                [self displayParentDeptAndSubDept:tempDeptId.intValue];
            }
        }
    }
}

/** 新华网 增加一个系统管理员用户 */
- (void)addSystemUser{
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (emp_id,emp_name) values(%d,'%@')",table_employee,95335,@"系统管理员"];
    BOOL result = [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"insert into %@ (emp_id,dept_id) values (%d,0)",table_emp_dept,95335];
    result = [self operateSql:sql Database:_handle toResult:nil];
}

/** 获取一个用户所在的部门 */
- (NSArray *)getDeptByEmpId:(int)empId{

    NSMutableArray *mArray = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"select b.* from %@ a,%@ b where a.emp_id = '%d'  and a.dept_id = b.dept_id order by a.dept_id",table_emp_dept,table_department,empId];
    
    NSArray *result = [self querySql:sql];
    
    for(NSDictionary *dic in result)
    {
        Dept *_dept = [[[Dept alloc]init]autorelease];
        _dept.dept_id = [dic[@"dept_id"]intValue];
        _dept.dept_name = dic[@"dept_name"];
        [mArray addObject:_dept];
    }
    return mArray;
}



//如果是蓝光，因为要显示常用联系人所在部门和职位，所以这里还要给常用联系人的部门属性赋值
- (void)setEmpDeptAttrOfLG:(Emp *)emp{
    
//    首先从内存里找，如果没找到，那么从数据库获取
//     [self setTaiheEmpDept:emp];
    
    if (emp.parent_dept_list.length == 0) {
//        从数据库获取
        NSString *sql = [NSString stringWithFormat:@"select a.emp_title,c.dept_id, c.dept_name_contain_parent from %@ a,%@ b,%@ c where a.emp_id = %d and a.emp_id = b.emp_id and b.dept_id = c.dept_id order by c.dept_id",table_employee,table_emp_dept,table_department,emp.emp_id];
        
        NSMutableString *mStr = [NSMutableString string];
        
        NSArray *result = [self querySql:sql];
        
        for (NSDictionary *dic in result) {
            NSString *tempStr = dic[@"dept_name_contain_parent"];
            NSArray *tempArray = [tempStr componentsSeparatedByString:@"/"];
            
            NSString *deptStr = nil;
            int _count = (int)tempArray.count;
            if (_count >= 2) {
                deptStr = [NSString stringWithFormat:@"%@-%@",tempArray[_count - 2],tempArray[_count - 1]];
            }else{
                deptStr = tempStr;
            }
            
            NSString *titleStr = dic[@"emp_title"];
            
            if (deptStr.length && titleStr.length) {
                deptStr = [NSString stringWithFormat:@"%@-%@",deptStr,titleStr];
            }else if (deptStr.length == 0){
                deptStr = [NSString stringWithString:titleStr];
            }
            
            if (mStr.length) {
                [mStr appendString:[NSString stringWithFormat:@",%@",deptStr]];
            }else{
                [mStr appendString:deptStr];
            }
        }
        emp.parent_dept_list = mStr;
    }
}



@end
