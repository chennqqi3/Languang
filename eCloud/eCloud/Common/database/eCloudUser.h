//create by shisp 2012.9.24

#import <Foundation/Foundation.h>
#import "LCLSqlite.h"

#import "ServerConfig.h"
//企云用户库
#define ecloud_user_db  @"ecloud_user.sqlite"
//#define ecloud_user_db_version @"1.0"

/* 
 2.0
 增加一张新表，table_server_config,保存服务器配置
 Primary_server
Primary_port
second_server
Second_port
 */

//2.1
//服务器配置表增加 文件服务器ip，文件服务器端口，文件服务器url三个字段

#define ecloud_user_db_version @"2.1"




//用户表的名字
#define table_userinfo @"user_info"

//用户表列的名字
#define user_id @"user_id"
#define user_name @"user_name"
#define user_passwd @"user_passwd"
#define user_mail @"user_mail"

//用户权限
#define user_wPurview @"user_wPurview"

#define comp_updatetime @"comp_updatetime"
#define dept_updatetime @"dept_updatetime"
#define emp_updatetime @"emp_updatetime"
#define emp_dept_updatetime @"emp_dept_updatetime"
#define vgroup_updatetime @"vgroup_updatetime"

//增加3个字段，级别，业务，区域的时间戳
#define rank_updatetime @"rank_updatetime"
#define prof_updatetime @"prof_updatetime"
#define area_updatetime @"area_updatetime"

//增加组织架构黑名单列
#define black_list_updatetime @"black_list_updatetime"

//缺省常用联系人时间戳
#define default_common_emp_updatetime @"default_common_emp_updatetime"
//是否开启听筒模式，默认值关闭
#define user_receiver_mode_flag @"user_receiver_mode_flag"
//常用部门时间戳
#define common_dept_updatetime @"common_dept_updatetime"
//常用联系人时间戳
#define common_emp_updatetime @"common_emp_updatetime"
//个人资料时间戳
#define cur_user_info_updatetime @"cur_user_info_updatetime"
//个人头像时间戳
#define cur_user_logo_updatetime @"cur_user_logo_updatetime"

//联系人头像时间戳
#define emp_logo_updatetime @"emp_logo_updatetime"

//机器人资料时间戳
#define robot_updatetime @"robot_updatetime"

/** 收藏时间戳 */
#define collect_updatetime @"collect_updatetime"

//增加一个时间戳 部门显示时间戳
#define dept_show_config_updatetime @"dept_show_config_updatetime"

#define user_msg_voice_flag @"user_msg_voice_flag"
#define user_msg_vibrate_flag @"user_msg_vibrate_flag"

#define user_remain01 @"user_remain01"
#define user_remain02 @"user_remain02"

#define create_table_user_info @"create table if not exists user_info(user_id INTEGER PRIMARY KEY,user_name TEXT,user_passwd TEXT,user_mail TEXT,comp_updatetime TEXT,dept_updatetime TEXT,emp_updatetime TEXT,emp_dept_updatetime TEXT,vgroup_updatetime TEXT,user_msg_voice_flag INTEGER default 1,user_receiver_mode_flag INTEGER default 0,user_msg_vibrate_flag INTEGER default 0,user_wPurview INTEGER,rank_updatetime integer default 0,prof_updatetime integer default 0,area_updatetime integer default 0,black_list_updatetime text,default_common_emp_updatetime integer default 0,common_dept_updatetime integer default 0, common_emp_updatetime integer default 0, cur_user_info_updatetime integer default 0, cur_user_logo_updatetime integer default 0, emp_logo_updatetime integer default 0,robot_updatetime integer default 0,dept_show_config_updatetime integer default 0,collect_updatetime integer default 0)"

////add by shisp 版本表，保存了数据库版本和应用程序的版本
//#define table_version @"table_version"
//#define create_table_version @"create table if not exists table_version(version_value TEXT,version_type int)"
//
////add by shisp 服务器配置表，保存了服务器的配置
//#define table_server_config @"table_server_config"
//#define create_table_server_config @"create table if not exists table_server_config(primary_server TEXT,primary_port INTEGER,second_server TEXT,second_port INTEGER,file_server TEXT,file_server_port INTEGER,file_server_url TEXT);"

@class UserInfo;

@interface eCloudUser : LCLSqlite
{
	NSString *purview_str; //
}
@property(nonatomic,retain)NSString *purview_str;
//获取数据库的实例
+(id)getDatabase;
//释放数据库
+(void)releaseDatabase;
//初始化数据库
-(void)initDatabase;

//在当前数据库里增加一条记录，如果userId已经存在，那么返回，否则增加一条记录，只保存userid即可 add by shisp
- (void)saveCurUser;

//将登陆时，用户的权限保存到数据库中
- (void)saveCurUserPurview:(NSString *)curUserId andPurview:(NSString *)userPurview
;

#pragma mark 保存当前的用户
-(void)addCurrentUser:(NSDictionary *)info;

#pragma mark 更新用户信息
-(void)updateCurrentUser:(NSDictionary *)info;

#pragma mark 保存公司信息同步时间
-(void)saveCompUpdateTime:(NSDictionary*)info;

#pragma mark 保存部门信息同步时间
-(void)saveDeptUpdateTime:(NSDictionary *)info;

#pragma mark 保存员工部门信息同步时间
-(void)saveEmpDeptUpdateTime:(NSDictionary *)info;

#pragma mark 保存员工信息同步时间
-(void)saveEmpUpdateTime:(NSDictionary *)info;

#pragma mark 保存虚拟组信息同步时间
-(void)saveVGroupUpdateTime:(NSDictionary *)info;

#pragma mark 保存用户级别同步时间
-(void)saveRankUpdateTime:(NSDictionary *)info;
#pragma mark 保存用户业务同步时间
-(void)saveProfUpdateTime:(NSDictionary *)info;
#pragma mark 保存用户地域同步时间
-(void)saveAreaUpdateTime:(NSDictionary *)info;

//增加一个用户
-(void)addUser:(NSDictionary *)info;

//根据user_id查询用户
-(NSDictionary *)searchUserByUserid:(NSString *)userid;

//根据email和密码查询用户,用于离线登录
-(NSDictionary *)searchUserByMail:(NSString *)mail andPasswd:(NSString *)passwd;

//修改用户信息
-(void)updateUser:(NSString *)userid;
//更新 听筒模式  0:关闭 1:打开
-(void)updateReceiverModeState:(int)onOrNot :(int)userid;
//获取 提醒类型
-(UserInfo *)searchUserObjectByUserid:(NSString *)userid;
//更新 声音提醒  0:关闭 1:打开
-(void)updateVoiceRemindState:(int)onOrNot :(int)userid;
//更新 震动提醒  0:关闭 1:打开
-(void)updateVibrateRemindState:(int)onOrNot :(int)userid;
//更新自动回复
-(void)updateAutoMsg:(NSString *)AutoMsg :(int)userid;

//修改用户状态
-(void)updateUserStatus:(NSString *)userId andStatus:(int)status;

//用户密码修改
-(void)updateUserPasswd:(NSString *)password :(int)userid;
//用户手机
-(void)updateUserTelephone:(NSString *)telephone :(int)userid;
-(void)updateUserMobile:(NSString *)mobileStr :(int)userid;
//增加版本信息
-(void)addVersion:(NSString*)version andVersionType:(int)versionType;
//修改版本信息
-(void)updateVersion:(NSString*)version  andVersionType:(int)versionType;
//获得版本信息
-(NSString*)getVersion:(int)versionType;

//更新 发送已读  0:关闭 1:打开
//-(void)updateReadRemindState:(int)onOrNot :(int)userid;
//获取和用户相关的服务器配置
-(ServerConfig*)getServerConfig;

//保存和用户相关的服务器配置
-(void)saveServerConfig:(ServerConfig *)serverConfig;
//用户宅电
-(void)updateUserHomeTel:(NSString *)telephone :(int)userid;
//用户紧急
-(void)updateUsereEmergencyTel:(NSString *)telephone :(int)userid;
//更新 发送已读  0:注册 1:不注册
//-(void)updateNoticeState:(int)onOrNot :(int)userid;

#pragma mark 保存黑名单的同步时间
-(void)saveBlacklistUpdateTime:(NSDictionary *)info;


//保存缺省常用联系人的时间戳
- (void)saveDefaultCommomEmpUpdateTime;
//保存常用联系人的时间戳
- (void)saveCommomEmpUpdateTime;
//保存常用部门的时间戳
- (void)saveCommomDeptUpdateTime;

//保存当前用户资料的时间戳
- (void)saveCurUserInfoUpdateTime;
//保存当前用户头像的时间戳
- (void)saveCurUserLogoUpdateTime;
//保存联系人头像的时间戳
- (void)saveEmpLogoUpdateTime;

/**
 功能描述
 保存收藏的时间戳

 */
- (void)saveCollectUpdateTime;

//返回用户是否设置了声音提醒
-(BOOL)needVoiceAlert;
#pragma mark 上传事件 总的记录个数
-(void)getPurviewValue;
#pragma mark 木棉童飞 权限
-(bool)isCanKapod;
#pragma mark 一呼万应 权限
-(bool)isCanMass;
#pragma mark 一呼百应 权限
-(bool)isCanHundred;
#pragma mark 一呼万应 群成员最大人数
-(int)isCanMass_maxGroupNum;


//增加一个方法，查看是否需要下载全量通讯录文件
- (BOOL)needDownloadOrgDb;

//增加一个方法，根据一个数据库的路径，打开数据库，并且查询其中的数据库表，找到相关的参数
- (void)saveUpdateTimeFromDownloadUserDb;

//增加一个方法，当开始手动刷新通讯录时，把保存在数据库里的时间戳修改为0
- (void)initOrgUpdateTime;

//保存机器人资料的时间戳
- (void)saveRobotUpdateTime;


//保存部门显示配置时间戳
- (void)saveDeptShowConfigUpdateTime;

//保存部门显示配置时间戳 带了参数
- (void)saveDeptShowConfigUpdateTime:(int)updateTime;


//根据账号和密码查询用户
-(NSDictionary *)searchUserByAccount:(NSString *)account andPasswd:(NSString *)passwd;


//查询登录成功的账户， 根据账号 得到 userid,-1是没有找到
- (int)getUserIdByUserAccount:(NSString *)userAccount;

//南航需求，程序通过rank_id来设置 通讯录 人员显示或隐藏。当用户自己的rank_id有变化 ，用户能看到的人员 也会有变化，这就需要把原先的emp_dept数据清楚，重新同步
- (void)initEmpDeptUpdateTime;

@end

