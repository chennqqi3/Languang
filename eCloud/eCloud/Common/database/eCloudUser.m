#import "eCloudUser.h"
#import "UserDefaults.h"
#import "conn.h"
#import "AuthModel.h"
#import "StringUtil.h"
#import "UserInfo.h"
#import "Emp.h"
#import "ServerConfig.h"
#import "eCloudDefine.h"
#import "CollectionDAO.h"
#import "CollectionDAO.h"

static eCloudUser *_eCloudUser = nil;

@implementation eCloudUser
@synthesize purview_str;
//获取数据库的实例
+(id)getDatabase
{
	if(_eCloudUser == nil)
	{
		_eCloudUser = [[eCloudUser alloc]init];
	}
	return _eCloudUser;
}
//释放数据库
+(void)releaseDatabase
{
	if(_eCloudUser)
	{
		[_eCloudUser release];
		_eCloudUser = nil;
	}
}
//初始化数据库
-(void)initDatabase
{
//	if(NO == aleadyInit)
//	{
//		aleadyInit = YES;
		if(_handle)
		{
			sqlite3_close(_handle);
			_handle = nil;
		}
		NSString *appPath = [StringUtil getHomeDir];
		NSString *dbPath = [appPath stringByAppendingPathComponent:ecloud_user_db];
       
		_handle = [self openSqliteDatabaseAtPath:dbPath];
		[self operateSql:create_table_user_info Database:_handle toResult:nil];
//    update by shisp 版本表 和 服务器配置表 都不需要，所以不用创建
//		[self operateSql:create_table_version Database:_handle toResult:nil];
		//创建服务器配置表
//		[self operateSql:create_table_server_config Database:_handle toResult:nil];

//	}
	
	[self advanceSearch];
	
//	[self checkDbVersion];
    
    [self blacklist];
    
    [self addWandaUpdateTime];
}
//万达版本增加了很多时间戳 6个新的时间戳同时新增一个听筒模式字段
- (void)addWandaUpdateTime
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,user_receiver_mode_flag];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,default_common_emp_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,common_dept_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,common_emp_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,cur_user_info_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,cur_user_logo_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,emp_logo_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,robot_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,collect_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];
    
    sql = [NSString stringWithFormat:@"alter table %@ add %@ integer default 0",table_userinfo,dept_show_config_updatetime];
    [self operateSql:sql Database:_handle toResult:nil];

}

- (void)blacklist
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add black_list_updatetime text",table_userinfo];
    [self operateSql:sql Database:_handle toResult:nil];
}

-(void)advanceSearch
{
	NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@ integer",table_userinfo,rank_updatetime];
	[self operateSql:sql Database:_handle toResult:nil];
	sql = [NSString stringWithFormat:@"alter table %@ add %@ integer",table_userinfo,prof_updatetime];
	[self operateSql:sql Database:_handle toResult:nil];
	sql = [NSString stringWithFormat:@"alter table %@ add %@ integer",table_userinfo,area_updatetime];
	[self operateSql:sql Database:_handle toResult:nil];
}

//在当前数据库里增加一条记录，如果userId已经存在，那么修改这条记录，否则增加一条记录，只保存userid,useraccount,userpassword即可 add by shisp
- (void)saveCurUser
{
    conn *_conn = [conn getConn];
    NSString *userId = _conn.userId;
    
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = '%@'",user_id,table_userinfo,user_id,userId];
    NSArray *result = [self querySql:sql];
    if (result.count == 0) {
        sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@) values(%@,'%@','%@')",table_userinfo,user_id,user_mail,user_passwd,userId,[UserDefaults getUserAccount],[UserDefaults getUserPassword]];
    }
    else
    {
        sql = [NSString stringWithFormat:@"update %@ set %@ = '%@',%@ = '%@' where %@ = %@",table_userinfo,user_mail,[UserDefaults getUserAccount],user_passwd,[UserDefaults getUserPassword],user_id,userId];
    }
    [self operateSql:sql Database:_handle toResult:nil];
}
//将登陆时，用户的权限保存到数据库中
- (void)saveCurUserPurview:(NSString *)curUserId andPurview:(NSString *)userPurview
{
    conn *_conn = [conn getConn];
    NSString *userId = _conn.userId;
    
    NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@ = '%@'",user_id,table_userinfo,user_id,curUserId];
    NSArray *result = [self querySql:sql];
    if (result.count != 0) {
        sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where %@ = %@",table_userinfo,user_wPurview,userPurview,user_id,userId];
    }
    [self operateSql:sql Database:_handle toResult:nil];
}


#pragma mark 保存当前的用户 保存用户id，用户名称，用户mail，用户密码，是否声音提醒，用户权限等入库
-(void)addCurrentUser:(NSDictionary *)info
{
	NSArray *keys = [NSArray arrayWithObjects:user_id,user_name,user_passwd,user_mail,user_msg_voice_flag,user_wPurview,nil];
 	NSString *sql= [self insertTable:table_userinfo newInfo:info keys:keys];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		NSLog(@"%s,增加用户失败",__FUNCTION__);
	}
}
#pragma mark 更新用户信息
-(void)updateCurrentUser:(NSDictionary *)info
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set user_passwd='%@',user_mail='%@',user_wPurview=%@ where user_id = %@",
					 	table_userinfo,
					 [info valueForKey:@"user_passwd"],[info valueForKey:@"user_mail"],[info valueForKey:@"user_wPurview"],[info valueForKey:@"user_id"]];
	if(![self operateSql:sql Database:_handle toResult:nil])
	{
		NSLog(@"%s,修改当前用户密码失败",__FUNCTION__);
	}
}

#pragma mark 保存公司信息同步时间
-(void)saveCompUpdateTime:(NSDictionary*)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:comp_updatetime andValue:_conn.compUpdateTime];
}

#pragma mark 保存部门信息同步时间
-(void)saveDeptUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:dept_updatetime andValue:_conn.deptUpdateTime];
//    update by shisp 2014.1.5
    _conn.oldDeptUpdateTime = _conn.deptUpdateTime;
}


#pragma mark 保存员工部门信息同步时间
-(void)saveEmpDeptUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:emp_dept_updatetime andValue:_conn.empDeptUpdateTime];
    //    update by shisp 2014.1.5
    _conn.oldEmpDeptUpdateTime = _conn.empDeptUpdateTime;
}

#pragma mark 保存员工信息同步时间
-(void)saveEmpUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:emp_updatetime andValue:_conn.empUpdateTime];
}

#pragma mark 保存虚拟组信息同步时间
-(void)saveVGroupUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:vgroup_updatetime andValue:_conn.VgroupTime];
}

#pragma mark 保存用户级别同步时间
-(void)saveRankUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:rank_updatetime andValue:_conn.newRankUpdateTime];
}

#pragma mark 保存用户业务同步时间
-(void)saveProfUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:prof_updatetime andValue:_conn.newProfUpdateTime];
}

#pragma mark 保存用户地域同步时间
-(void)saveAreaUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:area_updatetime andValue:_conn.newAreaUpdateTime];
}

#pragma mark 保存黑名单的同步时间
-(void)saveBlacklistUpdateTime:(NSDictionary *)info
{
    conn *_conn = [conn getConn];
    [self saveTextUpdateTimeWithKey:black_list_updatetime andValue:_conn.newBlacklistUpdateTime];
}

//保存缺省常用联系人的时间戳
- (void)saveDefaultCommomEmpUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:default_common_emp_updatetime andValue:_conn.newDefaultCommonEmpUpdateTime];
}

//保存常用联系人的时间戳
- (void)saveCommomEmpUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:common_emp_updatetime andValue:_conn.newCommonEmpUpdateTime];
}
//保存常用部门的时间戳
- (void)saveCommomDeptUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:common_dept_updatetime andValue:_conn.newCommonDeptUpdateTime];
}
//保存当前用户资料的时间戳
- (void)saveCurUserInfoUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:cur_user_info_updatetime andValue:_conn.newCurUserInfoUpdateTime];
}
//保存当前用户头像的时间戳
- (void)saveCurUserLogoUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:cur_user_logo_updatetime andValue:_conn.newCurUserLogoUpdateTime];
}
//保存联系人头像的时间戳
- (void)saveEmpLogoUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:emp_logo_updatetime andValue:_conn.newEmpLogoUpdateTime];
}

//保存收藏的时间戳
- (void)saveCollectUpdateTime
{
    //    conn *_conn = [conn getConn];
    int collectTime = [[CollectionDAO shareDatabase]getLastCollectTime];
    [self saveUpdateTimeWithKey:collect_updatetime andValue:collectTime];
}

//对应的列的类型为text类型
- (void)saveTextUpdateTimeWithKey:(NSString *)keyStr andValue:(NSString *)strValue
{
//    strValue = @"123";
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = '%@' where user_id = %@ ",table_userinfo,keyStr,strValue,_conn.userId];
    [self operateSql:sql Database:_handle toResult:nil];
    
    [self searchUserByUserid:_conn.userId];
}
//对应的列的类型为int
- (void)saveUpdateTimeWithKey:(NSString *)keyStr andValue:(int)iValue
{
    if (iValue == SERVER_INIT_TIMESTAMP) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 时间戳是服务器初始时间戳 不要保存",__FUNCTION__]];
        return;
    }
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = %d where user_id = %@ ",table_userinfo,keyStr,iValue,_conn.userId];
    [self operateSql:sql Database:_handle toResult:nil];
}


//增加一个用户
-(void)addUser:(NSDictionary *)info
{
//    update by shisp useless
    return;
}

//根据user_id查询用户
-(NSDictionary *)searchUserByUserid:(NSString *)userid
{
	if(userid && [userid length]>0)
	{
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_id = %@",table_userinfo,userid];
		NSArray *result = [self querySql:sql];
		if(result.count >= 1)
		{
			return [result objectAtIndex:0];
		}
		return nil;		
	}
	return nil;
}
//获取 提醒类型
-(UserInfo *)searchUserObjectByUserid:(NSString *)userid
{
	if(userid && [userid length]>0)
	{
		NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_id = %@",table_userinfo,userid];
		NSMutableArray *result = [NSMutableArray array];
		if([self operateSql:sql Database:_handle toResult:result] && [result count]==1)
		{
            NSDictionary *dic=[result objectAtIndex:0];
            UserInfo *userinfo = [[[UserInfo alloc]init]autorelease];
            
            if ([dic objectForKey:@"user_msg_voice_flag"]==nil) {
                userinfo.voiceFlag =0; //表示关闭
            }else
            {
             userinfo.voiceFlag = [[dic objectForKey:@"user_msg_voice_flag"] intValue];
            }
           
            if ([dic objectForKey:@"user_msg_vibrate_flag"]==nil) {
               userinfo.vibrateFlag =0;//表示关闭
            }else
            {
              userinfo.vibrateFlag = [[dic objectForKey:@"user_msg_vibrate_flag"] intValue];
            }
            
            if ([dic objectForKey:@"user_receiver_mode_flag"]==nil)
            {
                userinfo.receiver_model_Flag =0;//听筒模式
            }else
            {
                userinfo.receiver_model_Flag = [[dic objectForKey:@"user_receiver_mode_flag"] intValue];
            }
            
            userinfo.userName=[dic objectForKey:@"user_name"];
            userinfo.userPasswd=[dic objectForKey:@"user_passwd"];
            userinfo.userId=[[dic objectForKey:@"user_id"] intValue];
           
			return userinfo;
		}
		return nil;
	}
	return nil;
}
//更新 听筒模式  0:关闭 1:打开
-(void)updateReceiverModeState:(int)onOrNot :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set user_receiver_mode_flag = %d where user_id=%d ",table_userinfo,onOrNot,userid];
    
	[self operateSql:sql Database:_handle toResult:nil];
    
}
//更新 声音提醒  0:关闭 1:打开
-(void)updateVoiceRemindState:(int)onOrNot :(int)userid
{
    NSString *sql;

    sql = [NSString stringWithFormat:@"update %@ set user_msg_voice_flag = %d where user_id=%d ",table_userinfo,onOrNot,userid];

	[self operateSql:sql Database:_handle toResult:nil];

}
//更新 震动提醒  0:关闭 1:打开
-(void)updateVibrateRemindState:(int)onOrNot :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set user_msg_vibrate_flag = %d where user_id=%d ",table_userinfo,onOrNot,userid];
    
	[self operateSql:sql Database:_handle toResult:nil];
    
}


//用户状态选择
-(void)updateUserStatus:(NSString *)userId andStatus:(int)status
{
//    
//    NSString *sql = [NSString stringWithFormat:@"update %@ set user_status = %d where user_id=%@ ",table_userinfo,status,userId];
//    
//	[self operateSql:sql Database:_handle toResult:nil];
//
}

//更新自动回复
-(void)updateAutoMsg:(NSString *)AutoMsg :(int)userid
{
//    NSString *sql;
//    
//    sql = [NSString stringWithFormat:@"update %@ set Emp_auto_msg ='%@' where user_id=%d ",table_userinfo,AutoMsg,userid];
//    
//	[self operateSql:sql Database:_handle toResult:nil];
    
}

//用户密码修改
-(void)updateUserPasswd:(NSString *)password :(int)userid
{
    NSString *sql;
    
    sql = [NSString stringWithFormat:@"update %@ set user_passwd ='%@' where user_id=%d ",table_userinfo,password,userid];
    
	[self operateSql:sql Database:_handle toResult:nil];
    
}
//用户宅电
-(void)updateUserHomeTel:(NSString *)telephone :(int)userid
{
//    
//    NSString *sql;
//    
//    sql = [NSString stringWithFormat:@"update %@ set user_hometel ='%@' where user_id=%d ",table_userinfo,telephone,userid];
//    
//    //	NSLog(@"sql is %@",sql);
//	
//	[self operateSql:sql Database:_handle toResult:nil];
    
}
//用户紧急
-(void)updateUsereEmergencyTel:(NSString *)telephone :(int)userid
{
//    NSString *sql;
//    
//    sql = [NSString stringWithFormat:@"update %@ set user_emergencytel ='%@' where user_id=%d ",table_userinfo,telephone,userid];
//    
//    //	NSLog(@"sql is %@",sql);
//	
//	[self operateSql:sql Database:_handle toResult:nil];
    
}
//用户手机
-(void)updateUserTelephone:(NSString *)telephone :(int)userid
{
//    NSString *sql;
//    
//    sql = [NSString stringWithFormat:@"update %@ set user_tel ='%@' where user_id=%d ",table_userinfo,telephone,userid];
//    
////	NSLog(@"sql is %@",sql);
//	
//	[self operateSql:sql Database:_handle toResult:nil];
    
}
-(void)updateUserMobile:(NSString *)mobileStr :(int)userid
{
//    NSString *sql;
//    
//    sql = [NSString stringWithFormat:@"update %@ set user_mobile ='%@' where user_id=%d ",table_userinfo,mobileStr,userid];
//    
//    //	NSLog(@"sql is %@",sql);
//	
//	[self operateSql:sql Database:_handle toResult:nil];
    
}

//根据email和密码查询用户,用于离线登录
-(NSDictionary *)searchUserByMail:(NSString *)mail andPasswd:(NSString *)passwd
{
	NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_mail = '%@' and user_passwd = '%@'",table_userinfo,mail,passwd];
//	NSLog(@"sql is %@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] == 1)
	{
		return [result objectAtIndex:0];
	}
	return nil;
}

//修改用户信息
-(void)updateUser:(NSString *)userid
{
	
}

//增加版本信息
-(void)addVersion:(NSString*)version andVersionType:(int)versionType
{
//	NSString* sql = [NSString stringWithFormat:@"insert into %@(version_value,version_type) values('%@',%d ) ",table_version,version,versionType];
//	[self operateSql:sql Database:_handle toResult:nil];
}
//修改版本信息
-(void)updateVersion:(NSString*)version  andVersionType:(int)versionType
{
//	NSString *sql = [NSString stringWithFormat:@"update %@ set version_value = '%@' where version_type = %d",table_version,version,versionType];
////	NSLog(@"sql is %@",sql);
//	[self operateSql:sql Database:_handle toResult:nil];
    
}
	
//获得版本信息
-(NSString*)getVersion:(int)versionType
{
	if(versionType == app_version_type)
	{
		NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
		NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
		return appVersion;
	}
    return nil;
//	NSString *sql = [NSString stringWithFormat:@"select version_value from %@ where version_type = %d",table_version,versionType];
////	NSLog(@"sql is %@",sql);
//	NSMutableArray *result = [NSMutableArray array];
//	[self operateSql:sql Database:_handle toResult:result];
//	if([result count] == 1)
//	{
//		return [[result objectAtIndex:0]objectForKey:@"version_value"];
//	}
//	return nil;
}


#pragma mark --检查更新数据库版本---
-(void)checkDbVersion
{
//	检查应用程序版本号是否存在，如果不存在，那么增加应用程序版本号
//	NSString *appVersion = [self getVersion:app_version_type];
//	if(!appVersion)
//	{
//		//		保存本地的版本号
//		NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//		appVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
//		[self addVersion:appVersion andVersionType:app_version_type];
//	}
//	
//	NSString *dbVersion = [self getVersion:db_version_type];
//	//			版本号不存在，
//	if(!dbVersion)
//	{
////		NSLog(@"保存数据库版本");
//		[self addVersion:ecloud_user_db_version andVersionType:db_version_type];		
//	}
//	else if([dbVersion compare:ecloud_user_db_version] == NSOrderedAscending)
//	{
////		NSLog(@"数据库版本升级");
//		if([dbVersion compare:@"1.0"] == NSOrderedSame)
//		{
//			//创建服务器配置表
//			[self operateSql:create_table_server_config Database:_handle toResult:nil];
//			
//			[self updateVersion:ecloud_user_db_version andVersionType:db_version_type];
//			
//		}
//		else if([dbVersion compare:@"2.0"] == NSOrderedSame)
//		{
//			NSString * sql = [NSString stringWithFormat:@"alter table %@ add file_server TEXT",table_server_config];
//			[self operateSql:sql Database:_handle toResult:nil];
//			
//			sql = [NSString stringWithFormat:@"alter table %@ add file_server_port INTEGER",table_server_config];
//			[self operateSql:sql Database:_handle toResult:nil];
//			
//			sql = [NSString stringWithFormat:@"alter table %@ add file_server_url TEXT",table_server_config];
//			[self operateSql:sql Database:_handle toResult:nil];
//			
//			[self updateVersion:ecloud_user_db_version andVersionType:db_version_type];
//		}
//	}
//	else {
////		NSLog(@"数据库版本ok");
//	}
}


//获取和用户相关的服务器配置
-(ServerConfig*)getServerConfig
{
	ServerConfig * serverConfig = [ServerConfig shareServerConfig];// [[[ServerConfig alloc]init] autorelease];
	
    return serverConfig;
    
//    update by shisp 不再从数据库里读，而是取配置文件里的配置，已经在ServerConfig里实现了。
    
//	NSString *sql = [NSString stringWithFormat: @"select * from %@",table_server_config];
//	NSMutableArray *result = [NSMutableArray array];
//	[self operateSql:sql Database:_handle toResult:result];
//	if(result == nil || [result count] == 0)
//	{
//		//		设置默认值
//		NSString *sql = [NSString stringWithFormat:@"insert into %@ (primary_server,primary_port,second_server,second_port,file_server,file_server_port,file_server_url) values('%@',%d,'%@',%d,'%@',%d,'%@')",table_server_config,primary_ip,primary_port,second_ip,second_port,default_file_server,default_file_server_port,default_file_server_url];
//	//	NSLog(@"%@",sql);
//
//		[self operateSql:sql Database:_handle toResult:nil];
//		
//		serverConfig.primaryServer = primary_ip;
//		serverConfig.primaryPort = primary_port;
//		serverConfig.secondServer = second_ip;
//		serverConfig.secondPort = second_port;
//		serverConfig.fileServer = default_file_server;
//		serverConfig.fileServerPort = default_file_server_port;
//		serverConfig.fileServerUrl = default_file_server_url;
//	}
//	
//	if(result && [result count] == 1)
//	{
//		NSDictionary *dic = [result objectAtIndex:0];
//		serverConfig.primaryServer = [dic objectForKey:@"primary_server"];
//
//		serverConfig.primaryPort = [[dic objectForKey:@"primary_port"] intValue];
//		
//		serverConfig.secondServer = [dic objectForKey:@"second_server"];
//		
//		serverConfig.secondPort = [[dic objectForKey:@"second_port"]intValue];
//		
//		serverConfig.fileServer = [dic objectForKey:@"file_server"];
//		if([serverConfig.fileServer length] == 0)
//		{
//			serverConfig.fileServer = default_file_server;
//		}
//		serverConfig.fileServerPort = [[dic objectForKey:@"file_server_port"]intValue];
//		if(serverConfig.fileServerPort == 0)
//		{
//			serverConfig.fileServerPort = default_file_server_port;
//		}
//		serverConfig.fileServerUrl = [dic objectForKey:@"file_server_url"];
//		if([serverConfig.fileServerUrl length] == 0)
//		{
//			serverConfig.fileServerUrl = default_file_server_url;
//		}
//		
//	}
//	return serverConfig;
}

//保存和用户相关的服务器配置
-(void)saveServerConfig:(ServerConfig *)serverConfig
{
    
//  update by shisp 服务器配置放在配置文件里，不再保存在数据库里
    
//	NSString *sql = [NSString stringWithFormat:@"update %@ set primary_server = '%@',primary_port = %d,second_server = '%@' ,second_port = %d ,file_server = '%@',file_server_port = %d ,file_server_url = '%@' ",table_server_config,serverConfig.primaryServer,serverConfig.primaryPort,serverConfig.secondServer,serverConfig.secondPort,serverConfig.fileServer,serverConfig.fileServerPort,serverConfig.fileServerUrl];
////	NSLog(@"%@",sql);
//	[self operateSql:sql Database:_handle toResult:nil];
	
}

//返回用户是否设置了声音提醒
-(BOOL)needVoiceAlert
{
	conn* _conn = [conn getConn];
    NSString *userid=_conn.userId;
    UserInfo *userinfo= [self searchUserObjectByUserid:userid];
	
	if (userinfo.voiceFlag==1)
	{
		return YES;
	}
	return NO;
}

#pragma mark 上传事件 总的记录个数
-(void)getPurviewValue
{   conn* _conn = [conn getConn];
    NSString *userid=_conn.userId;
	int user_wPurview_int = 0;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	NSString * sql = [NSString stringWithFormat:@"select user_wPurview from %@ where user_id=%@",table_userinfo,userid];
	// [LogUtil debug:[NSString stringWithFormat:@"--sql-- :%@",sql);
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	if(result && [result count] == 1)
	{
		user_wPurview_int = [[[result objectAtIndex:0]objectForKey:@"user_wPurview"]intValue];
        self.purview_str=[StringUtil toBinaryStr:user_wPurview_int andByteCount:2];
	}
	[pool release];
	
//    NSLog(@"---self.purview_str-  %@",self.purview_str);
}
#pragma mark 木棉童飞 权限
-(bool)isCanKapod  
{
    return [[AuthModel getModel]canMMTF];
    
    bool is_can=false;
    NSRange range=NSMakeRange(7, 1);
    NSString *sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
        is_can=true;
    }
    return is_can;
}
#pragma mark 一呼万应 权限
-(bool)isCanMass
{
    return [[AuthModel getModel]canYHWY];
    
    bool is_can=false;
    NSRange range=NSMakeRange(9, 1); //200 人最多
    NSString *sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
        is_can=true;
    }
    range=NSMakeRange(8, 1); //10000人最多
    sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
        is_can=true;
    }
    
    return is_can;
}
#pragma mark 一呼万应 群成员最大人数
-(int)isCanMass_maxGroupNum
{
    return [[AuthModel getModel]maxYHWY];
    
    conn* _conn = [conn getConn];
    int maxGroupNum=_conn.maxGroupMember;
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic=[_defaults objectForKey:@"wPurviewDic"];
    NSRange range=NSMakeRange(9, 1); //200 人最多
    NSString *sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
       maxGroupNum=[[dic objectForKey:@"7"]intValue];
    }
    range=NSMakeRange(8, 1); //10000人最多
    sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
       maxGroupNum=[[dic objectForKey:@"8"]intValue];
    }
    
    return maxGroupNum;
}

#pragma mark 一呼百应 权限
-(bool)isCanHundred
{
//    使用新的权限类
    return [[AuthModel getModel]canYHBY];
    
    bool is_can=false;
    NSRange range=NSMakeRange(10, 1);
    NSString *sub_binary=[self.purview_str substringWithRange:range];
    if (sub_binary.intValue==1) {
        is_can=true;
    }
    return is_can;
}


-(NSArray*)querySql:(NSString*)sql
{
	NSMutableArray *result = [NSMutableArray array];
	[self operateSql:sql Database:_handle toResult:result];
	return result;
}

#pragma mark =======下载数据库文件相关代码=========
//增加一个方法，根据一个数据库的路径，打开数据库，并且查询其中的数据库表，找到相关的参数
- (void)saveUpdateTimeFromDownloadUserDb
{
    conn *_conn = [conn getConn];
    
    NSString *downloadUserdbPath = [StringUtil getDownloadecloudUserDbPath];
    sqlite3 *dbHandle = [self openSqliteDatabaseAtPath:downloadUserdbPath];
    
    if (dbHandle)
    {
        NSString *sql = [NSString stringWithFormat:@"select %@,%@ from %@",dept_updatetime,emp_dept_updatetime,table_userinfo];
        NSMutableArray *result = [NSMutableArray array];
        [self operateSql:sql Database:dbHandle toResult:result];
        if (result && result.count == 1)
        {
            [LogUtil debug:@"user db 里已经保存了时间戳，现在保存这个时间戳"];
            NSString *deptUpdateTime = [[result objectAtIndex:0] valueForKey:dept_updatetime];
            NSString *empDeptUpdateTime = [[result objectAtIndex:0] valueForKey:emp_dept_updatetime];
            
            if (deptUpdateTime)
            {
                _conn.oldDeptUpdateTime = deptUpdateTime;
                [LogUtil debug:[NSString stringWithFormat:@"保存部门时间戳:%@",deptUpdateTime]];
                [self saveTextUpdateTimeWithKey:dept_updatetime andValue:deptUpdateTime];
            }
            else
            {
                _conn.oldDeptUpdateTime = @"0";
            }
            
            if (empDeptUpdateTime)
            {
                _conn.oldEmpDeptUpdateTime = empDeptUpdateTime;
                [LogUtil debug:[NSString stringWithFormat:@"保存员工与部门关系时间戳:%@",empDeptUpdateTime]];
                [self saveTextUpdateTimeWithKey:emp_dept_updatetime andValue:empDeptUpdateTime];
            }
            else
            {
                _conn.oldEmpDeptUpdateTime = @"0";
            }
        }
        sqlite3_close(dbHandle);
        dbHandle  =   nil;
        
        [[NSFileManager defaultManager]removeItemAtPath:downloadUserdbPath error:nil];
    }
}

//增加一个方法，查看是否需要下载全量通讯录文件
- (BOOL)needDownloadOrgDb
{
    //    万达需要第一次登录时，从服务器下载数据库文件，此数据库里应该已经包含下载好的组织架构，以及对应的时间戳,如果需要生成这样的数据库文件，就要直接返回NO
//    return NO;
    
    conn *_conn = [conn getConn];
    if (_conn.userId)
    {
        NSDictionary *dic = [self searchUserByUserid:_conn.userId];
        if (dic)
        {
            NSString *oldDeptUpdateTime = [dic objectForKey:dept_updatetime];
            
            NSString *oldEmpDeptUpdateTime = [dic objectForKey:emp_dept_updatetime];
            
            NSNumber *curUserInfoUpdateTime = [dic valueForKey:cur_user_info_updatetime];
            
//            字符串类型
            if (oldDeptUpdateTime.length == 0 && oldEmpDeptUpdateTime.length == 0 && curUserInfoUpdateTime.intValue == 0) {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    return YES;
}

//增加一个方法，当开始手动刷新通讯录时，把保存在数据库里的时间戳修改为0
- (void)initOrgUpdateTime
{
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"update %@ set dept_updatetime = 0,emp_dept_updatetime = 0,dept_show_config_updatetime = 0 where user_id = %@ ",table_userinfo,_conn.userId];
    [self operateSql:sql Database:_handle toResult:nil];
}

//保存机器人资料的时间戳
- (void)saveRobotUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:robot_updatetime andValue:_conn.newRobotUpdateTime];
}

//根据账号和密码查询用户
-(NSDictionary *)searchUserByAccount:(NSString *)account andPasswd:(NSString *)passwd
{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where user_name = '%@' and user_passwd = '%@'",table_userinfo,account,passwd];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    if(result && [result count] == 1)
    {
        return [result objectAtIndex:0];
    }
    return nil;
}


//查询登录成功的账户， 根据账号 得到 userid,-1是没有找到
- (int)getUserIdByUserAccount:(NSString *)userAccount
{
    NSString *sql = [NSString stringWithFormat:@"select user_id from %@ where user_name = '%@'  COLLATE NOCASE ",table_userinfo,userAccount];
    
    NSMutableArray *result = [NSMutableArray array];
    [self operateSql:sql Database:_handle toResult:result];
    //    根据账号查id，只查询到一个就有用，否则没用
    if(result && [result count] > 0)
    {
        if (result.count > 1) {
            [LogUtil debug:[NSString stringWithFormat:@"%s sql is %@ result is %@",__FUNCTION__,sql,[result description]]];
        }else{
            return [[[result objectAtIndex:0]valueForKey:@"user_id"]intValue];
        }
    }
    return -1;
}


//南航需求，程序通过rank_id来设置 通讯录 人员显示或隐藏。当用户自己的rank_id有变化 ，用户能看到的人员 也会有变化，这就需要把原先的emp_dept数据清楚，重新同步
- (void)initEmpDeptUpdateTime
{
    conn *_conn = [conn getConn];
    NSString *sql = [NSString stringWithFormat:@"update %@ set emp_dept_updatetime = '0' where user_id = %@ ",table_userinfo,_conn.userId];
    [self operateSql:sql Database:_handle toResult:nil];
}


//保存部门显示配置时间戳
- (void)saveDeptShowConfigUpdateTime
{
    conn *_conn = [conn getConn];
    [self saveUpdateTimeWithKey:dept_show_config_updatetime andValue:_conn.newDeptShowConfigUpdateTime];
}
//保存部门显示配置时间戳 带了参数
- (void)saveDeptShowConfigUpdateTime:(int)updateTime
{
    [self saveUpdateTimeWithKey:dept_show_config_updatetime andValue:updateTime];
}

@end
