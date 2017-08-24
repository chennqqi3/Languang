//
//  AdvanceQueryDAO.m
//  eCloud
//
//  Created by Richard on 13-12-18.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "AdvanceQueryDAO.h"
#import "Rank.h"
#import "Profession.h"
#import "Area.h"
#import "RecentMember.h"
#import "Emp.h"
#import "Dept.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"

static AdvanceQueryDAO *advanceQueryDAO;

@implementation AdvanceQueryDAO

+(id)getDataBase
{
	if(advanceQueryDAO == nil)
	{
		advanceQueryDAO = [[AdvanceQueryDAO alloc]init];
	}
	return advanceQueryDAO;
}

-(NSMutableArray*)query:(NSString*)sql
{
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	return result;
}

//获取所有级别
-(NSArray*)getAllRank
{
	NSString *sql = [NSString stringWithFormat:@"select rank_id,rank_name from %@",table_rank];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Rank *_rank = [[Rank alloc]init];
			_rank.rankId = [[dic valueForKey:@"rank_id"]intValue];
			_rank.rankName = [dic valueForKey:@"rank_name"];
			[result addObject:_rank];
			[_rank release];
		}
		return result;
	}
	return nil;
}
#pragma mark 级别
-(NSArray *)getrRankArray
{
	NSMutableArray *types = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RecentMember *typeObject = [[RecentMember alloc]init];
    typeObject.type_name=@"级别";
    typeObject.type_level=0;
    typeObject.type_parent=0;
    typeObject.type_id=1;
    typeObject.isExtended=true;
    typeObject.isChecked=false;
    [types addObject:typeObject];
    [typeObject release];
    // NSArray *temp=[self getRecentEmpInfoWithSelected:@"1" andLevel:1 andSelected:false];
    NSArray *temp=[self getAllRank];
    [types addObjectsFromArray:temp];
    [pool release];
    
	return types;
}

//保存级别数据
-(BOOL)saveRank:(NSArray*)dataArray
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	BOOL ret = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	char* errorMessage;
	if([self beginTransaction])
	{
		for(Rank *_rank in dataArray)
		{
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(rank_id,rank_name) values(%d,?)",table_rank,_rank.rankId];
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
				ret = NO;
				break;
			}
			//		绑定值
			pthread_mutex_lock(&add_mutex);
			sqlite3_bind_text(stmt, 1, [_rank.rankName UTF8String],-1,NULL);//rank_name
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
				ret = NO;
				break;
			}
			//释放资源
			pthread_mutex_lock(&add_mutex);
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
		}
		[self commitTransaction];
	}
	else
	{
		ret = NO;
	}
	[pool release];
	
	return ret;

}

//获取所有业务
-(NSArray*)getAllProfession
{
	NSString *sql = [NSString stringWithFormat:@"select prof_id,prof_name from %@",table_profession];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Profession *_prof = [[Profession alloc]init];
			_prof.profId = [[dic valueForKey:@"prof_id"]intValue];
			_prof.profName = [dic valueForKey:@"prof_name"];
			[result addObject:_prof];
			[_prof release];
		}
		return result;
	}
	return nil;
}

#pragma mark 业务
-(NSArray *)getrBusinessArray
{
	NSMutableArray *types = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RecentMember *typeObject = [[RecentMember alloc]init];
    typeObject.type_name=@"业务";
    typeObject.type_level=0;
    typeObject.type_parent=0;
    typeObject.type_id=1;
    typeObject.isExtended=true;
    typeObject.isChecked=false;
    [types addObject:typeObject];
    [typeObject release];
    // NSArray *temp=[self getRecentEmpInfoWithSelected:@"1" andLevel:1 andSelected:false];
    NSArray *temp=[self getAllProfession];
    [types addObjectsFromArray:temp];
    [pool release];
    
	return types;
}

//保存级别数据
-(BOOL)saveProf:(NSArray*)dataArray
{
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	BOOL ret = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	char* errorMessage;
	if([self beginTransaction])
	{
		for(Profession *_profession in dataArray)
		{
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(prof_id,prof_name) values(%d,?)",table_profession,_profession.profId];
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
				ret = NO;
				break;
			}
			//		绑定值
			pthread_mutex_lock(&add_mutex);
			sqlite3_bind_text(stmt, 1, [_profession.profName UTF8String],-1,NULL);
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
				ret = NO;
				break;
			}
			//释放资源
			pthread_mutex_lock(&add_mutex);
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
		}
		[self commitTransaction];
	}
	else
	{
		ret = NO;
	}
	[pool release];
	
	return ret;
	
}
#pragma mark 筛选结果
-(NSArray *)getChooseArrayByRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
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
    
    NSArray *temp=[self getResultByRank:rank_list andBusiness:business_list andCity:city_list];
    if ([temp count]>0) {
        [types addObject:typeObject];
        [typeObject release];
    }
    [types addObjectsFromArray:temp];
    [pool release];
    
	return types;
}
//获取数量
-(int)getAllNumFromResult:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
     NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from employee where emp_id in(select emp_id from emp_dept where %@) order by emp_status",find_by];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}

//根据级别，业务，区域 搜索
-(NSArray*)getResultByRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
	NSString *sql = [NSString stringWithFormat:@"select * from employee where emp_id in(select emp_id from emp_dept where %@) order by emp_status",find_by];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Emp *emp = [[Emp alloc]init];
            [self putDicData:dic toEmp:emp];
            emp.emp_dept=1;
            emp.emp_level=1;
            emp.isSelected=false;
            [result addObject:emp];
            [emp release];
		}
		return result;
	}
	return nil;
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
}
-(int)getEmpNumByParentDeptID:(NSString *)dept_id
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select emp_count from %@ where dept_id=%@",table_temp_department,dept_id];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"emp_count"] intValue];
	}
	[pool release];
	return _count;
}
//某成员所在所有部门
-(void)createTempDeptsByEmpIdList:(NSString *)emp_id_list
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ ",table_temp_department];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where dept_id in(select dept_id from emp_dept where emp_id  in (%@) )",table_department,emp_id_list];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
           NSString *dept_parent_dept=[dic objectForKey:@"dept_parent_dept"];
           NSArray *array = [dept_parent_dept componentsSeparatedByString:@","];
            int count_num=[array count];
            NSString *dept_id= [NSString stringWithFormat:@"%d",[[dic objectForKey:@"dept_id"]intValue]];
            int dept_emp_num=[self getTempDeptEmpNumByEmpIdList:dept_id andList:emp_id_list];
            NSString *dept_emp_num_str=[NSString stringWithFormat:@"%d",dept_emp_num];
            NSDictionary *tempdic=[NSDictionary dictionaryWithObjectsAndKeys:dept_id,@"dept_id",dept_emp_num_str,@"emp_count",[dic objectForKey:@"dept_parent"],@"dept_parent",[dic objectForKey:@"dept_name"],@"dept_name",@"0",@"sub_dept",[dic objectForKey:@"dept_sort"],@"dept_sort",[dic objectForKey:@"dept_parent_dept"],@"dept_parent_dept", nil];
            [self addItemToTempDept:tempdic];
            for (int i=0; i<count_num; i++) {
                if (i+1<count_num) {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=[array objectAtIndex:i+1];
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }else
                {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=@"0";
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }
               
            }
            
		}
		
	}
	[pool release];
}
//某成员所在所有部门
-(void)createTempDepts:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *deletesql = [NSString stringWithFormat:@"delete from %@ ",table_temp_department];
	[self operateSql:deletesql Database:_handle toResult:nil];
    
    NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where dept_id in(select dept_id from emp_dept where %@ )",table_department,find_by];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
            NSString *dept_parent_dept=[dic objectForKey:@"dept_parent_dept"];
            NSArray *array = [dept_parent_dept componentsSeparatedByString:@","];
            int count_num=[array count];
            NSString *dept_id= [NSString stringWithFormat:@"%d",[[dic objectForKey:@"dept_id"]intValue]];
            int dept_emp_num=[self getTempDeptEmpNum:dept_id andRank:rank_list andBusiness:business_list andCity:city_list];
            NSString *dept_emp_num_str=[NSString stringWithFormat:@"%d",dept_emp_num];
            NSDictionary *tempdic=[NSDictionary dictionaryWithObjectsAndKeys:dept_id,@"dept_id",dept_emp_num_str,@"emp_count",[dic objectForKey:@"dept_parent"],@"dept_parent",[dic objectForKey:@"dept_name"],@"dept_name",@"0",@"sub_dept",[dic objectForKey:@"dept_sort"],@"dept_sort",[dic objectForKey:@"dept_parent_dept"],@"dept_parent_dept", nil];
            [self addItemToTempDept:tempdic];
            for (int i=0; i<count_num; i++) {
                if (i+1<count_num) {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=[array objectAtIndex:i+1];
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }else
                {
                    NSString *parent_dept=[array objectAtIndex:i];
                    NSString *parent_dept_parent=@"0";
                    NSDictionary *tdic=[self getDeptNameByID:parent_dept];
                    int oldnum=[self getEmpNumByParentDeptID:parent_dept];
                    int sum_num=dept_emp_num+oldnum;
                    dept_emp_num_str=[NSString stringWithFormat:@"%d",sum_num];
                    NSDictionary *temp_dic=[NSDictionary dictionaryWithObjectsAndKeys:parent_dept,@"dept_id",parent_dept_parent,@"dept_parent",[tdic objectForKey:@"dept_name"],@"dept_name",@"1",@"sub_dept",[tdic objectForKey:@"dept_sort"],@"dept_sort",dept_emp_num_str,@"emp_count", nil];
                    
                    [self addItemToTempDept:temp_dic];
                }
                
            }
            
		}
		
	}
	[pool release];
}
-(NSDictionary *)getDeptNameByID:(NSString *)dept_id
{
    NSString *sql = [NSString stringWithFormat:@"select dept_name,dept_sort from %@ where dept_id =%@ ",table_department,dept_id];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
        NSDictionary *getdic= [queryResult objectAtIndex:0];
		
		return getdic;
	}
	return nil;
}
-(void)addItemToTempDept:(NSDictionary *)dic
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"dept_id",@"dept_parent",@"dept_name",@"dept_parent_dept",@"sub_dept",@"dept_sort",@"emp_count",nil];// sub_dept 1表示有子部门，其他表示没有
	NSString    *sql        =   nil;

    sql =   [self replaceIntoTable:table_temp_department newInfo:dic keys:keys];
    [self operateSql:sql Database:_handle toResult:nil];
    
}

#pragma mark 根据上级部门id，获取直接子部门，并定位级别
-(NSArray *)getTempDeptInfoWithLevel:(NSString *)deptParent andLevel:(int)level andSelected:(bool)isSelected
{
	NSMutableArray *depts = [NSMutableArray array];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat: @"select * from %@ where dept_parent = '%@' order by dept_sort",table_temp_department,deptParent];
	NSMutableArray * result = [NSMutableArray array];
	if([self operateSql:sql Database:_handle toResult:result] && [result count] > 0)
	{
		//		[LogUtil debug:[NSString stringWithFormat:@"deptid is %@ child_dept is %@",deptParent , result]];
		for(int i = 0;i<[result count];i++)
		{
			Dept *dept = [[Dept alloc]init];
			NSDictionary *dic = [result objectAtIndex:i];
			NSString *dept_id = [dic objectForKey:@"dept_id"];
			dept.dept_id = [dept_id intValue];
			dept.dept_name = [dic objectForKey:@"dept_name"];
			dept.dept_parent = [deptParent intValue];
			dept.dept_level=level;
			dept.dept_emps = nil;
            dept.isChecked=isSelected;
            dept.totalNum=[[dic objectForKey:@"emp_count"]intValue];
            dept.subDeptsStr=[dic objectForKey:@"sub_dept"];
			[depts addObject:dept];
			[dept release];
		}
	}
	[pool release];
	return depts;
}
-(NSArray *)getTempDeptEmpByParent:(NSString *)dept_id andSelected:(bool)isSelected andRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    
    
    NSString *numsql=[NSString stringWithFormat:@"select distinct(dept_id) from %@ where dept_parent_dept = %@ or dept_parent_dept like '%%,%@,%' or dept_parent_dept like '%%,%@'  or dept_parent_dept like '%@,%%'",table_temp_department,dept_id,dept_id,dept_id,dept_id];
    NSMutableArray *queryResult = [self query:numsql];
	int tempcount = [queryResult count];
    NSString *parent_str=dept_id;
	if(tempcount > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:tempcount]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			if (parent_str==nil) {
                parent_str=[NSString stringWithFormat:@"%d",[[dic objectForKey:@"dept_id"]intValue]];
            }else
            {
                parent_str=[NSString stringWithFormat:@"%@,%d",parent_str,[[dic objectForKey:@"dept_id"]intValue]];
            }
		}
		
	}

   NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
    
    NSString *sql = [NSString stringWithFormat:@"select * from employee where emp_id in(select emp_id from emp_dept where dept_id in(%@) and %@ ) order by emp_status",parent_str,find_by];
	queryResult = [self query:sql];
	int count = [queryResult count];
    
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
         NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
		for(NSDictionary *dic in queryResult)
		{
			Emp *emp = [[Emp alloc]init];
            [self putDicData:dic toEmp:emp];
            emp.emp_dept=[dept_id intValue];
            emp.isSelected=isSelected;
            [result addObject:emp];
            [emp release];
		}
        [pool release];
		return result;
	}
	return nil;
}
-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
    
    NSString *sql = [NSString stringWithFormat:@"select * from employee where emp_id in(select emp_id from emp_dept where dept_id=%@ and %@ ) order by emp_status",dept_id,find_by];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Emp *emp = [[Emp alloc]init];
            [self putDicData:dic toEmp:emp];
            emp.emp_dept=[dept_id intValue];
            emp.emp_level=level;
            emp.isSelected=isSelected;
            [result addObject:emp];
            [emp release];
		}
		return result;
	}
	return nil;
}
-(NSArray *)getTempDeptEmpInfoWithLevel:(NSString *)dept_id andLevel:(int)level andSelected:(bool)isSelected andEmpList:(NSString *)emp_id_list
{
    NSString *sql = [NSString stringWithFormat:@"select * from employee where emp_id in(select emp_id from emp_dept where dept_id=%@ and emp_id in (%@) ) order by emp_status",dept_id,emp_id_list];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Emp *emp = [[Emp alloc]init];
            [self putDicData:dic toEmp:emp];
            emp.emp_dept=[dept_id intValue];
            emp.emp_level=level;
            emp.isSelected=isSelected;
            [result addObject:emp];
            [emp release];
		}
		return result;
	}
	return nil;
}
//获取临时部门的人数
-(int)getTempDeptEmpNum:(NSString *)dept_id andRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *find_by=[self makeSqlItemByRank:rank_list andBusiness:business_list andCity:city_list];
    
	 NSString *sql = [NSString stringWithFormat:@"select count(*) as _count from employee where emp_id in(select emp_id from emp_dept where dept_id=%@ and %@) order by emp_status",dept_id,find_by];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
-(NSString *)makeSqlItemByRank:(NSString *)rank_list andBusiness:(NSString *)business_list andCity:(NSString *)city_list
{
    NSString *find_by=nil;
    
    if (rank_list!=nil) {
        find_by=[NSString stringWithFormat:@" rank_id in(%@)",rank_list];
    }
    if (business_list!=nil) {
        if (find_by==nil) {
          find_by=[NSString stringWithFormat:@" prof_id in(%@)",business_list];
        }else{
        find_by=[NSString stringWithFormat:@"%@ and prof_id in(%@)",find_by,business_list];
        }
    }
    if (city_list!=nil) {
        if (find_by==nil) {
        find_by=[NSString stringWithFormat:@" area_id in(%@)",city_list];
        }else{
        find_by=[NSString stringWithFormat:@"%@ and area_id in(%@)",find_by,city_list];
        }
    }
    return find_by;
}
//获取临时部门的人数
-(int)getTempDeptEmpNumByEmpIdList:(NSString *)dept_id andList:(NSString *)emp_id_list
{
    int _count = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    NSString *sql = [NSString stringWithFormat:@"select count(*) as _count  from emp_dept where dept_id=%@ and emp_id in(%@)",dept_id,emp_id_list];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
	{
		_count = [[[result objectAtIndex:0]objectForKey:@"_count"] intValue];
	}
	[pool release];
	return _count;
}
//根据父级别，获取所有级别
-(NSArray*)getAllArea:(int)parentArea
{
	NSString *sql = [NSString stringWithFormat:@"select area_id,area_name from %@ where parent_area = %d ",table_area,parentArea];
	NSMutableArray *queryResult = [self query:sql];
	int count = [queryResult count];
	if(count > 0)
	{
		NSMutableArray *result = [[[NSMutableArray alloc]initWithCapacity:count]autorelease];
		for(NSDictionary *dic in queryResult)
		{
			Area *_area = [[Area alloc]init];
			_area.areaId = [[dic valueForKey:@"area_id"]intValue];
			_area.areaName = [dic valueForKey:@"area_name"];
			_area.parentArea = parentArea;
			[result addObject:_area];
			[_area release];
		}
		return result;
	}
	return nil;
}
#pragma mark 选择市
-(NSArray *)getrCityArray:(int)parentArea
{
	NSMutableArray *types = [NSMutableArray array];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    RecentMember *typeObject = [[RecentMember alloc]init];
    typeObject.type_name=@"全部";
    typeObject.type_level=0;
    typeObject.type_parent=0;
    typeObject.type_id=1;
    typeObject.isExtended=true;
    typeObject.isChecked=false;
    [types addObject:typeObject];
    [typeObject release];
    // NSArray *temp=[self getRecentEmpInfoWithSelected:@"1" andLevel:1 andSelected:false];
     NSArray *temp=[self getAllArea:parentArea];
    [types addObjectsFromArray:temp];
    [pool release];
    
	return types;
}
//保存地域数据
-(BOOL)saveArea:(NSArray*)dataArray
{
	BOOL ret = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	char* errorMessage;
	if([self beginTransaction])
	{
		for(Area *_area in dataArray)
		{
			NSString *sql = [NSString stringWithFormat:@"insert or replace into %@(area_id,area_name,parent_area) values(%d,?,%d)",table_area,_area.areaId,_area.parentArea];
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
				ret = NO;
				break;
			}
			//		绑定值
			pthread_mutex_lock(&add_mutex);
			sqlite3_bind_text(stmt, 1, [_area.areaName UTF8String],-1,NULL);
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
				ret = NO;
				break;
			}
			//释放资源
			pthread_mutex_lock(&add_mutex);
			sqlite3_finalize(stmt);
			pthread_mutex_unlock(&add_mutex);
		}
		[self commitTransaction];
	}
	else
	{
		ret = NO;
	}
	[pool release];
	
	return ret;
	
}



@end
