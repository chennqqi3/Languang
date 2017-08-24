//create by shisp 2012.9.25

#import "eCloud.h"
#import "MiLiaoUtilArc.h"
#import "eCloudUser.h"
#import "eCloudDefine.h"
#import "StringUtil.h"
#import "Dept.h"
#import "Emp.h"
#import "AutoSendMsg.h"
#import "Conversation.h"
#import "conn.h"
#import "EmpDeptDL.h"
#import "VirGroupObj.h"
#import "OffenGroup.h"
//一呼万应的sql
#import "MassSql.h"

#import "CollectionDAO.h"
#import "eCloudDAO.h"

#import "RobotDAO.h"
#import "AudioTxtDAO.h"
#import "VirtualGroupDAO.h"
#import "PublicServiceDAOSql.h"

#import "PublicServiceDAO.h"
#import "ReceiptDAO.h"
#import "AdvanceQueryDAO.h"
#import "MassDAO.h"
#import "PermissionDAO.h"
#import "KapokFlySql.h"
#import "KapokDAO.h"
#import "APPPlatformSql.h"
#import "APPPlatformDOA.h"
#import "StatusDAO.h"
#import "UserDataDAO.h"

#import "QueryDAO.h"

#import "FileAssistantSql.h"
#import "FileAssistantDOA.h"

#import "CloudFileSql.h"
#import "CloudFileDOA.h"

#import "FileAssistantRecordSql.h"
#import "FileAssistantRecordDOA.h"

//static eCloud *_eCloud = nil;
@implementation eCloud
@synthesize lastUserId;
#pragma mark ---数据库---
-(void)dealloc
{
	NSLog(@"%s",__FUNCTION__);
	[super dealloc];
}
////获取数据库的实例
//+(id)getDatabase
//{
//	if(_eCloud == nil)
//	{
//		_eCloud = [[eCloud alloc]init];
//	}
//	return _eCloud;
//}
////释放数据库
//+(void)releaseDatabase
//{
//	if(_eCloud)
//	{
//		[_eCloud release];
//		_eCloud = nil;
//	}
//}
//初始化数据库
-(void)initDatabase:(NSString *)userId
{
//	如果更换了用户，那么需要关闭之前的数据库并且重新打开，如果没有更换用户，那么就不用重新打开
	if(_handle)
	{
//		如果更改了用户
		if(self.lastUserId != nil && self.lastUserId.intValue != userId.intValue)
		{
			sqlite3_close(_handle);
			_handle =   nil;
			NSString *dbPath = [StringUtil getFileDir];
			dbPath = [dbPath stringByAppendingPathComponent:ecloud_db];
			
			NSLog(@"dbPath is %@",dbPath);
			//创建并打开数据库
			_handle  =  [self openSqliteDatabaseAtPath:dbPath];
		}
	}
	else
	{
		NSString *dbPath = [StringUtil getFileDir];
		dbPath = [dbPath stringByAppendingPathComponent:ecloud_db];
		
		NSLog(@"dbPath is %@",dbPath);
		//创建并打开数据库
		_handle  =  [self openSqliteDatabaseAtPath:dbPath];
	}
	
	[[ReceiptDAO getDataBase]setDbHandle:[self getDbHandle]];
	[[AdvanceQueryDAO getDataBase]setDbHandle:[self getDbHandle]];
	[[MassDAO getDatabase]setDbHandle:[self getDbHandle]];
	[[PublicServiceDAO getDatabase]setDbHandle:_handle];
    [[PermissionDAO getDatabase]setDbHandle:_handle];
    [[KapokDAO getDatabase]setDbHandle:[self getDbHandle]];
    [[APPPlatformDOA getDatabase] setDbHandle:[self getDbHandle]];
    [[FileAssistantDOA getDatabase]setDbHandle:[self getDbHandle]];
    
    [[QueryDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[StatusDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[UserDataDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[RobotDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[AudioTxtDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[VirtualGroupDAO getDatabase]setDbHandle:[self getDbHandle]];
    
    [[CollectionDAO shareDatabase]setDbHandle:[self getDbHandle]];
    
    [[CloudFileDOA getDatabase]setDbHandle:[self getDbHandle]];
    
    [[FileAssistantRecordDOA getFileDatabase]setDbHandle:[self getDbHandle]];

    
	self.lastUserId = userId;
	
	//		创建表 如果不存在，那么就创建
	
	[self operateSql:create_table_db_version Database:_handle toResult:nil];
	[self operateSql:create_table_department Database:_handle toResult:nil];
	[self operateSql:create_department_index_dept_parent Database:_handle toResult:nil];
	
	[self operateSql:create_table_employee Database:_handle toResult:nil];
	[self operateSql:create_employee_index_emp_dept_id Database:_handle toResult:nil];
	
	[self operateSql:create_table_emp_dept Database:_handle toResult:nil];
	[self operateSql:create_emp_dept_index_dept_id Database:_handle toResult:nil];
	[self operateSql:create_emp_dept_index_emp_id Database:_handle toResult:nil];

	[self operateSql:create_table_company Database:_handle toResult:nil];
	
	[self operateSql:create_table_conversation Database:_handle toResult:nil];
	[self operateSql:create_table_conv_emp Database:_handle toResult:nil];
	[self operateSql:create_table_conv_records Database:_handle toResult:nil];
	//			创建索引
	[self operateSql:create_conv_records_index Database:_handle toResult:nil];
	[self operateSql:create_conv_records_index_2 Database:_handle toResult:nil];

	[self operateSql:create_table_contact_person Database:_handle toResult:nil];
	[self operateSql:create_table_broadcast Database:_handle toResult:nil];
	[self operateSql:create_table_vir_group Database:_handle toResult:nil];
	[self operateSql:create_table_vir_group_emps_new Database:_handle toResult:nil];
	[self initContactItem];//常用联系人
    [self operateSql:create_table_datehelper Database:_handle toResult:nil];
	[self operateSql:create_table_helper_emp Database:_handle toResult:nil];
	//创建 木棉童飞 table_kapok_upload，table_kapok_imagelist
    [self operateSql:create_table_kapok_upload Database:_handle toResult:nil];
    [self operateSql:create_table_kapok_imagelist Database:_handle toResult:nil];
    
    
    //文件助手我的
    [self operateSql:create_table_file_assistant Database:_handle toResult:nil];
    

    //创建应用平台数据表table_apps_list,table_app_msg
    [self creatAPPPlatformTables];
    
    
	[self createPSTable];
	
	[self createReceiptTable];
	
	[self createMassTable];
	
	[self createAdvanceQueryTable];
    
    // 在部门表中增加一列，保存部门的所有父部门
	
	[self checkDbVersion];
	
//	[self updateRecordMsgSecond];
    
    [self addDeptNameContainParentToDeptTable];
    
    [self addPermission];
    
    [self addEmpLevel];
    
    [self addWandaColumns];
    
    [[StatusDAO getDatabase]createTable];
    [[UserDataDAO getDatabase]createTable];
    
    [[RobotDAO getDatabase]createTable];
    // 创建语音文本表
    [[AudioTxtDAO getDatabase]createTable];
    // 创建虚拟组相关表
    [[VirtualGroupDAO getDatabase]createTable];
    
    [[CollectionDAO shareDatabase]createTable];

    //文件助手数据库
    [self creatFileAssistantTables];
    
    //云文件数据库
    [[CloudFileDOA getDatabase]createTable];

    [self createIndexs];
    
#ifdef _LANGUANG_FLAG_
    [self initMiLiaoData];
#endif
}

/** 搜索数据 查询所有的密聊消息 放到内存里统一管理 */
- (void)initMiLiaoData{
    [self operateSql:create_table_encrypt_msg Database:_handle toResult:nil];
    
    [[MiLiaoUtilArc getUtil]initMiLiaoMsgArray];
}

//创建索引，优化查询速度
- (void)createIndexs
{
    [self operateSql:create_conversation_index_1 Database:_handle toResult:nil];
    [self operateSql:create_conv_records_index_3 Database:_handle toResult:nil];
}


//万达版本，修改原有的部门表，员工表，会话表，会话人员表，增加列
- (void)addWandaColumns
{
//    部门表里增加的列
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add dept_pinyin_all text",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add dept_pinyin_simple text",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add dept_name_eng text",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add dept_name_contain_parent_eng text",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
//    员工表里增加的列
    sql = [NSString stringWithFormat:@"alter table %@ add emp_pinyin_all text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add emp_pinyin_simple text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add emp_birthday integer default 0",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add emp_fax text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add emp_address text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add emp_postcode text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];

    sql = [NSString stringWithFormat:@"alter table %@ add emp_name_eng text",table_employee];
    [self operateSql:sql Database:_handle toResult:nil];
    
//    会话表里增加的列
    sql = [NSString stringWithFormat:@"alter table %@ add is_set_top integer default 0",table_conversation];
    [self operateSql:sql Database:_handle toResult:nil];

    sql = [NSString stringWithFormat:@"alter table %@ add set_top_time integer default 0",table_conversation];
    [self operateSql:sql Database:_handle toResult:nil];

    sql = [NSString stringWithFormat:@"alter table %@ add group_type integer default 0",table_conversation];
    [self operateSql:sql Database:_handle toResult:nil];

//    会话成员表里增加的列
    sql = [NSString stringWithFormat:@"alter table %@ add is_valid integer default 0",table_conv_emp];
    [self operateSql:sql Database:_handle toResult:nil];

    sql = [NSString stringWithFormat:@"alter table %@ add rcv_msg_flag integer default 0",table_conv_emp];
    [self operateSql:sql Database:_handle toResult:nil];

    sql = [NSString stringWithFormat:@"alter table %@ add is_admin integer default 0",table_conv_emp];
    [self operateSql:sql Database:_handle toResult:nil];
    
    //    广播表里增加已读未读标志
    sql = [NSString stringWithFormat:@"alter table %@ add read_flag integer default 1",table_broadcast];
    [self operateSql:sql Database:_handle toResult:nil];
    
//    广播表里增加广播类型
    sql = [NSString stringWithFormat:@"alter table %@ add broadcast_type integer default 0",table_broadcast];
    [self operateSql:sql Database:_handle toResult:nil];

    
    //    部门表里增加display_flag列
    sql = [NSString stringWithFormat:@"alter table %@ add display_flag integer default 2",table_department];
    [self operateSql:sql Database:_handle toResult:nil];

}

//创建文件助手数据库
- (void)creatFileAssistantTables{
    [self operateSql:create_table_file_upload Database:_handle toResult:nil];
    [self operateSql:create_table_file_download Database:_handle toResult:nil];
}


//创建应用平台数据表
- (void)creatAPPPlatformTables{
    NSString *applistCount = @"select * from apps_list";
    NSMutableArray *marr = [NSMutableArray array];
    [self operateSql:applistCount Database:_handle toResult:marr];
    if ([marr count] == 0) {
        NSString *dropAppsList = @"drop table apps_list";
        [self operateSql:dropAppsList Database:_handle toResult:nil];
        
        [self operateSql:create_table_apps_list_new Database:_handle toResult:nil];
        
//        在应用表里增加groupId列 默认值为0
        NSString *sql = [NSString stringWithFormat:@"alter table %@ add groupId integer default 0",table_apps_list];
        [self operateSql:sql Database:_handle toResult:nil];

        
        // 第一次创建数据库时，对表进行初始化
//        if ([eCloudConfig getConfig].needApplist) {
//            // 初始化轻应用列表数据 by yanlei 0831
//            [[APPPlatformDOA getDatabase] initAppData];
//        }
    }
    
    [self operateSql:create_table_apps_msg Database:_handle toResult:nil];
    [self operateSql:create_table_app_state_record Database:_handle toResult:nil];
}

//增加员工级别，级别高的应该显示在部门的最前面

- (void)addEmpLevel
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add emp_sort integer default 0",table_emp_dept];
    [self operateSql:sql Database:_handle toResult:nil];
}


//在部门表和员工部门表中增加permission 列
- (void)addPermission
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add dept_permission integer default 0",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add permission integer default 0",table_emp_dept];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add is_special integer default 0",table_emp_dept];
    [self operateSql:sql Database:_handle toResult:nil];
    
    [self operateSql:create_black_list_table Database:_handle toResult:nil];
    
    [self operateSql:create_white_list_table Database:_handle toResult:nil];
}

//    在部门表中，增加一列，保存部门名称，包含所有父部门
- (void)addDeptNameContainParentToDeptTable
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add dept_name_contain_parent TEXT",table_department];
    [self operateSql:sql Database:_handle toResult:nil];
    
}
//创建高级查询使用到的表
-(void)createAdvanceQueryTable
{
//	员工与部门关系表中增加三列
	NSString *sql = [NSString stringWithFormat:@"alter table %@ add rank_id integer",table_emp_dept];
	[self operateSql:sql Database:_handle toResult:nil];
	sql = [NSString stringWithFormat:@"alter table %@ add prof_id integer",table_emp_dept];
	[self operateSql:sql Database:_handle toResult:nil];
	sql = [NSString stringWithFormat:@"alter table %@ add area_id integer",table_emp_dept];
	[self operateSql:sql Database:_handle toResult:nil];

	[self operateSql:create_table_rank Database:_handle toResult:nil];
	[self operateSql:create_table_profession Database:_handle toResult:nil];
	[self operateSql:create_table_area Database:_handle toResult:nil];
    [self operateSql:create_table_temp_department Database:_handle toResult:nil];
    // 判断temp_employee表结构是否发生了变化，若发生变化就重新创建
    BOOL isExistEmp_name_eng = NO;
    sqlite3_stmt *statement;
    const char *getColumn = "PRAGMA table_info(temp_employee)";
    sqlite3_prepare_v2(_handle, getColumn, -1, &statement, nil);
    while (sqlite3_step(statement) == SQLITE_ROW) {
        char *nameData = (char *)sqlite3_column_text(statement, 1);
        NSString *columnName = [[NSString alloc] initWithUTF8String:nameData];
        if ([columnName rangeOfString:@"emp_name_eng"].length > 0) {
            isExistEmp_name_eng = YES;
            break;
        }
    }
    sqlite3_finalize(statement);
    
    if (!isExistEmp_name_eng) {// 当前的表中不存在emp_name_eng字段，将当前表进行删除
        [self operateSql:delete_table_temp_employee Database:_handle toResult:nil];
    }
    [self operateSql:create_table_temp_employee Database:_handle toResult:nil];
//	[self operateSql:create_table_emp_profession Database:_handle toResult:nil];
//	[self operateSql:create_table_emp_area Database:_handle toResult:nil];
	
//	[self operateSql:create_emp_profession_index_emp_id Database:_handle toResult:nil];
//	[self operateSql:create_emp_profession_index_profession_id Database:_handle toResult:nil];
//	
//	[self operateSql:create_emp_area_index_emp_id Database:_handle toResult:nil];
//	[self operateSql:create_emp_area_index_area_id Database:_handle toResult:nil];
	
//	NSString *sql = [NSString stringWithFormat:@"alter table %@ add rank_id integer",table_employee];
//	[self operateSql:sql Database:_handle toResult:nil];
}

//创建一呼万应使用到的表
-(void)createMassTable
{
	[self operateSql:create_table_mass_conversation Database:_handle toResult:nil];
	[self operateSql:create_table_mass_conv_member Database:_handle toResult:nil];
	
	[self operateSql:create_table_mass_conv_records Database:_handle toResult:nil];
	[self operateSql:create_mass_conv_records_index Database:_handle toResult:nil];
	[self operateSql:create_mass_conv_records_index_2 Database:_handle toResult:nil];
}


//创建一呼百应用到的数据表
-(void)createReceiptTable
{
	[self operateSql:create_table_msg_read_state Database:_handle toResult:nil];
	[self operateSql:create_msg_read_state_index Database:_handle toResult:nil];
	[self operateSql:create_table_conv_status Database:_handle toResult:nil];
	
	NSString *sql = [NSString stringWithFormat:@"alter table %@ add receipt_msg_flag integer",table_conv_records];
	[self operateSql:sql Database:_handle toResult:nil];
	
	sql = [NSString stringWithFormat:@"alter table %@ add read_time integer",table_msg_read_state];
	[self operateSql:sql Database:_handle toResult:nil];
	
}
//创建公众平台表和所以
-(void)createPSTable
{
	//	创建公众平台的table
	[self operateSql:create_table_public_service Database:_handle toResult:nil];
	[self operateSql:create_table_public_service_message Database:_handle toResult:nil];
	[self operateSql:create_table_public_service_message_detail Database:_handle toResult:nil];
	//	创建公众平台的索引
	[self operateSql:create_ps_message_index Database:_handle toResult:nil];
	[self operateSql:create_ps_message_detail_index Database:_handle toResult:nil];
	
    //公众平台自定义菜单
    [self operateSql:create_table_public_service_menu_list Database:_handle toResult:nil];

	NSString *sql = [NSString stringWithFormat:@"alter table %@ add service_type integer",table_public_service];
	[self operateSql:sql Database:_handle toResult:nil];
	
	sql = [NSString stringWithFormat:@"alter table %@ add service_status integer",table_public_service];
	[self operateSql:sql Database:_handle toResult:nil];
}

-(void)initContactItem
{
    NSDictionary *dic;
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"-2",@"virgroup_id",@"常用群组",@"virgroup_name",@"0",@"virgroup_updatetime",@"0",@"virgroup_usernum", nil];
    [self addVirGroup:[NSArray arrayWithObject:dic]];
    dic = [NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"virgroup_id",@"常用联系人",@"virgroup_name",@"0",@"virgroup_updatetime",@"0",@"virgroup_usernum", nil];
    [self addVirGroup:[NSArray arrayWithObject:dic]];
 
}
#pragma mark --检查更新数据库版本---
-(void)checkDbVersion
{
	NSString *dbVersion = [self getDbVersion];
	//			版本号不存在，
	if(!dbVersion)
	{
//		NSLog(@"保存数据库版本");
		[self insertDbVersion:ecloud_db_version];
	}
	else if([dbVersion compare:ecloud_db_version] == NSOrderedAscending)
	{
		if([dbVersion isEqualToString:@"2.6"])
		{
			[self db_update_26];
			[self updateDbVersion:ecloud_db_version];
		}
	}
	else {
//		NSLog(@"数据库版本ok");
	}
}

//2.6 修改描述
//群组会话保存到常用联系人，在vir_group_emps表中增加了一列（conv_title TEXT）并且设置了主键（PRIMARY KEY (virgroup_id,virgroup_emp_id)）
//在会话表中“conversation”增加了一列“,msg_group_time TEXT”保存群组消息带回的群组的时间，需要检查版本并创建
-(void)db_update_26
{
	NSString *sql = [NSString stringWithFormat:@"alter table %@ add msg_group_time TEXT",table_conversation];
	[self operateSql:sql Database:_handle toResult:nil];

//	需要先删除表，再新建表
	char *errorMessage;
	pthread_mutex_lock(&add_mutex);
	sqlite3_exec(_handle, "BEGIN IMMEDIATE TRANSACTION", NULL, NULL, &errorMessage);
//	创建临时表
	sql =  [NSString stringWithFormat:@"create table %@_backup(virgroup_id TEXT,virgroup_emp_id TEXT)",table_vir_group_emps];
	
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
//	导入数据
	sql = [NSString stringWithFormat:@"INSERT INTO %@_backup SELECT virgroup_id,virgroup_emp_id FROM %@",table_vir_group_emps,table_vir_group_emps];
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
	
//删除原表
	sql = [NSString stringWithFormat:@"DROP TABLE %@",table_vir_group_emps];
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
	
//	新建表
	sql = create_table_vir_group_emps_new;
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
	
//	导入数据到新表
	sql = [NSString stringWithFormat:@"INSERT INTO %@(virgroup_id,virgroup_emp_id) SELECT virgroup_id,virgroup_emp_id FROM %@_backup",table_vir_group_emps,table_vir_group_emps];
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);

//	删除临时表
	sql = [NSString stringWithFormat:@"drop table %@_backup",table_vir_group_emps];
	sqlite3_exec(_handle, [sql cStringUsingEncoding:NSUTF8StringEncoding], NULL, NULL, &errorMessage);
	
	sqlite3_exec(_handle, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
	pthread_mutex_unlock(&add_mutex);
}

#pragma mark ---数据库版本----
//插入版本记录
-(void)insertDbVersion:(NSString*)dbVersion
{
	NSString *sql = [NSString stringWithFormat:@"insert into %@(dbversion) values('%@')",table_db_version,dbVersion];
	[self operateSql:sql Database:_handle toResult:nil];
}
//修改版本
-(void)updateDbVersion:(NSString*)dbVersion
{
	NSString* sql = [NSString stringWithFormat:@"update %@ set dbversion = '%@'",table_db_version,dbVersion];
//	NSLog(@"sql is %@",sql);
	[self operateSql:sql Database:_handle toResult:nil];
}
//查询版本
-(NSString*)getDbVersion
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@",table_db_version];
//	NSLog(@"sql is %@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if([result count] == 1)
		return [[result objectAtIndex:0]objectForKey:@"dbversion"];
	return nil;
}

#pragma mark 事务开始
-(bool)beginTransaction
{
//	NSLog(@"begin:%@",[StringUtil currentTime]);
    int tryCount = 3;
    int count = 0;
    while (count < tryCount)
    {
        count++;
        unsigned char* errorMessage;
        pthread_mutex_lock(&add_mutex);
        sqlite3_exec(_handle, "BEGIN IMMEDIATE TRANSACTION", NULL, NULL, &errorMessage);
        pthread_mutex_unlock(&add_mutex);
        if(errorMessage)
        {
//            [LogUtil debug:[NSString stringWithFormat:@"%@",[NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]]];
            [NSThread sleepForTimeInterval:1];
            [LogUtil debug:[NSString stringWithFormat:@"休眠后重试%d",count]];
            continue;
        }
        else
        {
            [LogUtil debug:[NSString stringWithFormat:@"开启事务成功%d",count]];
            return true;
        }
    }
    
    return false;
}
#pragma mark 事务结束
-(void)commitTransaction
{
	char* errorMessage;
	pthread_mutex_lock(&add_mutex);
	sqlite3_exec(_handle, "COMMIT TRANSACTION", NULL, NULL, &errorMessage);
	pthread_mutex_unlock(&add_mutex);
	
	if(errorMessage)
	{
//		NSLog(@"%@",[NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]);
	}
    
//	NSLog(@"end:%@",[StringUtil currentTime]);
}

#pragma mark 事务回滚
-(void)rollbackTransaction
{
	char* errorMessage;
	pthread_mutex_lock(&add_mutex);
	sqlite3_exec(_handle, "ROLLBACK TRANSACTION", NULL, NULL, &errorMessage);
	pthread_mutex_unlock(&add_mutex);
	
	if(errorMessage)
	{
//		NSLog(@"%@",[NSString stringWithCString:errorMessage encoding:NSUTF8StringEncoding]);
	}
    
    //	NSLog(@"end:%@",[StringUtil currentTime]);
}

//1 虚拟组相关
-(void)addVirGroup:(NSArray *) info
{
	NSArray *keys           =   [NSArray arrayWithObjects:@"virgroup_id", @"virgroup_name", @"virgroup_updatetime", @"virgroup_usernum",nil];
	NSString    *sql        =   nil;
	for (NSDictionary *dic in info)
	{
        sql =   [self replaceIntoTable:table_vir_group newInfo:dic keys:keys];
        [self operateSql:sql Database:_handle toResult:nil];
    }
}

#pragma mark 如果是录音消息，如果秒数带了",那么去除"并保存
-(void)updateRecordMsgSecond
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	
	NSString *sql = [NSString stringWithFormat:@"select id,file_size from %@ where msg_type = %d and file_size like '%%\"' ",table_conv_records,type_record];
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	NSString *fileSize;
	NSMutableArray *sqlArray = [NSMutableArray array];
	for(NSDictionary *dic in result)
	{
		fileSize = [dic valueForKey:@"file_size"];
		fileSize = [fileSize substringToIndex:(fileSize.length - 1)];
		sql = [NSString stringWithFormat:@"update %@ set file_size = '%@' where id = %@",table_conv_records,fileSize,[dic valueForKey:@"id"]];
		[sqlArray addObject:sql];
	}
	char *errorMessage;
	if([self beginTransaction])
	{
		for(NSString*sql in sqlArray)
		{
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
		}
		[self commitTransaction];
	}
	
	//	如果秒数大于60，那么就设置为60
	sql = [NSString stringWithFormat:@"select id,file_size from %@ where msg_type = %d and abs(file_size) > 60",table_conv_records,type_record];
	
	[result removeAllObjects];
	[sqlArray removeAllObjects];
	
	[self operateSql:sql Database:_handle toResult:result];
	
	for(NSDictionary *dic in result)
	{
		sql = [NSString stringWithFormat:@"update %@ set file_size = '10' where id = %@",table_conv_records,[dic valueForKey:@"id"]];
		[sqlArray addObject:sql];
	}
	
	if([self beginTransaction])
	{
		for(NSString*sql in sqlArray)
		{
			pthread_mutex_lock(&add_mutex);
			sqlite3_exec(_handle, [sql UTF8String], NULL, NULL, &errorMessage);
			pthread_mutex_unlock(&add_mutex);
		}
		[self commitTransaction];
	}
	
	[pool release];
}

-(NSMutableArray*)querySql:(NSString*)sql
{
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	return result;
}


// 把_handle设置为nil，以免更换用户后还能看到上一次的用户记录
- (void)setDBHandleToNil
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    self.lastUserId = nil;
    [[CollectionDAO shareDatabase]setDbHandle:nil];
    
    [[ReceiptDAO getDataBase]setDbHandle:nil];
    
    [[MassDAO getDatabase]setDbHandle:nil];
    
    [[PublicServiceDAO getDatabase]setDbHandle:nil];
    
    [[PermissionDAO getDatabase]setDbHandle:nil];
    
    [[APPPlatformDOA getDatabase] setDbHandle:nil];
    
    [[QueryDAO getDatabase]setDbHandle:nil];
    
    [[StatusDAO getDatabase]setDbHandle:nil];
    
    [[UserDataDAO getDatabase]setDbHandle:nil];
    
    [[eCloudDAO getDatabase]setDbHandle:nil];
    
    [[FileAssistantDOA getDatabase]setDbHandle:nil];
    
    [[RobotDAO getDatabase]setDbHandle:nil];
    
    [[AudioTxtDAO getDatabase]setDbHandle:nil];
    
    [[VirtualGroupDAO getDatabase]setDbHandle:nil];
 
    [[FileAssistantRecordDOA getFileDatabase]setDbHandle:nil];

}

@end
