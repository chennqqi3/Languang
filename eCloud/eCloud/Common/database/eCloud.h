//create by shisp 2012.9.25 

#import <Foundation/Foundation.h>
#import "LCLSqlite.h"
//企云库
#define ecloud_db  @"ecloud.sqlite"
//当前数据库版本

//2.0 修改描述
//部门表增加排序列
//会话表增加是否在最近会话中显示列

//2.1 修改描述
//会话记录表增加记录收到消息的原始的msgid，便于发送消息已读通知

//2.2 修改描述
//会话记录表增加消息已读通知是否发送成功的标志

//2.3 修改描述
//雇员表增加 工号，个性签名，登录类型三个字段

//2.4 修改描述

//1 创建广播表
//2 部门表里增加了dept_tel 和 dept_pinyin
//3 员工表里增加了emp_hometel 和 emp_emergencytel
//4 创建虚拟组以及虚拟组成员表
//5 会话记录表里增加了is_set_redstate
//6 会话表里增加了 lastmsg_body
//7 在会话表上，会话记录表上创建索引


//2.5 修改描述
//在会话表里增加最后一条消息的相关内容

//2.6修改描述
//在员工表中增加一个列，保存员工与部门关系时，保存这个列的值
//在部门表中增加两个列，分别保存部门的人数和在线的人数 emp_count,online_emp_count

//2.7修改描述
//群组会话保存到常用联系人，在vir_group_emps表中增加了一列（conv_title TEXT）并且设置了主键（PRIMARY KEY (virgroup_id,virgroup_emp_id)）
//在会话表中“conversation”增加了一列“,msg_group_time TEXT”保存群组消息带回的群组的时间，需要检查版本并创建

//修改描述
//在员工表的
//在部门表中增加一列，保存某部门的所有父部门，直到父部门为一级部门为止
//创建索引 在部门表的dept_parent列，建立索引，便于查找某个部门所有子部门
//创建索引，在员工表的emp_dept_id列，建立索引，便于查找某个部门下的所有员工
//创建索引，在员工部门表的dept_id列，建立索引，便于查找某个部门下的所有员工
//创建索引，在员工部门表的emp_id列，建立索引，便于查找某个员工的部门，可能是1个，也可能是多个

#define ecloud_db_version @"2.7"

//数据库版本表
#define table_db_version @"table_db_version"
#define create_table_db_version @"create table if not exists table_db_version(dbversion TEXT)"

//部门表
#define table_department @"department"
#define table_temp_department @"temp_department"
/*
 创建部门表
 部门id
 部门名称
 上级部门
 对应公司id
 
部门所有子部门
部门总人数
部门在线人数
部门所有父部门
保存部门名称，包含了所有父部门名称,dept_name_contain_parent
 add by shisp 增加保存部门权限字段，类型为int，主要是是否显示部门 permission
 部门拼音全拼 不带空格 dept_pinyin_all
 部门拼音简拼 dept_pinyin_simple
 部门英文名称 dept_name_eng
 包含父部门的部门名称 dept_name_contain_parent_eng
 
 // 增加一个display_flag字段 整型 默认是0 既显示人员也显示部门；只显示部门，不显示人员；部门及人员都不显示
 */
#define create_table_department @"create table if not exists department (dept_id INTEGER PRIMARY KEY,dept_name TEXT,dept_parent INTEGER,dept_comp_id INTEGER ,dept_sort INTEGER,dept_tel TEXT,dept_pinyin TEXT,sub_dept TEXT,emp_count INTEGER default 0,online_emp_count INTEGER default 0,dept_parent_dept TEXT,dept_name_contain_parent  TEXT,dept_permission INTEGER default 0,dept_pinyin_all text,dept_pinyin_simple text,dept_name_eng text,dept_name_contain_parent_eng text,display_flag integer default 2);"

#define create_table_temp_department @"create table if not exists temp_department (dept_id INTEGER PRIMARY KEY,dept_name TEXT,dept_parent INTEGER,sub_dept TEXT,dept_sort INTEGER,emp_count INTEGER,online_emp_count INTEGER,dept_parent_dept TEXT);"

#define create_department_index_dept_parent @"create index if not exists department_index_dept_parent on department(dept_parent)"

#define table_temp_employee @"temp_employee"
#define create_table_temp_employee @"create table if not exists temp_employee(emp_id INTEGER PRIMARY KEY,emp_name TEXT,emp_sex INTEGER,emp_mail TEXT,emp_mobile TEXT,emp_tel TEXT,emp_hometel TEXT,emp_emergencytel TEXT,emp_title TEXT,emp_pinyin TEXT,emp_comp_id INTEGER,emp_status INTEGER,emp_logo TEXT,emp_info_flag TEXT,emp_code TEXT,emp_signature TEXT,emp_login_type INTEGER,emp_dept_id INTEGER,emp_pinyin_all text,emp_pinyin_simple text,emp_birthday integer default 0,emp_fax text,emp_address text,emp_postcode text,emp_name_eng text)"
#define delete_table_temp_employee @"drop table temp_employee"
//人员表
#define table_employee @"employee"
//创建人员表
/*
 人员ID
 人员名称
 人员性别
 人员mail
 人员手机号码
 人员电话
 职务
 拼音
 公司
 状态(在线，离开，离线） 0:离线 1:在线 2: 离开 3:退出

 员工logo
 资料是否已从服务器获取 如果已经从服务器取回了数据，就设为Y，默认是N
 
 工号
 个性签名
 登录类型
 中文姓名全拼 不带空格 emp_pinyin_all
 中文姓名简拼 emp_pinyin_simple
 生日 emp_birthday
 传真 emp_fax
 地址 emp_address
 邮编 emp_postcode
 英文姓名 emp_name_eng
 
 */
#define create_table_employee @"create table if not exists employee(emp_id INTEGER PRIMARY KEY,emp_name TEXT,emp_sex INTEGER,emp_mail TEXT,emp_mobile TEXT,emp_tel TEXT,emp_hometel TEXT,emp_emergencytel TEXT,emp_title TEXT,emp_pinyin TEXT,emp_comp_id INTEGER,emp_status INTEGER,emp_logo TEXT,emp_info_flag TEXT,emp_code TEXT,emp_signature TEXT,emp_login_type INTEGER,emp_dept_id INTEGER,emp_pinyin_all text,emp_pinyin_simple text,emp_birthday integer default 0,emp_fax text,emp_address text,emp_postcode text,emp_name_eng text)"

#define create_employee_index_emp_dept_id @"create index if not exists employee_index_emp_dept_id on employee(emp_dept_id)"

//人员部门表
#define table_emp_dept @"emp_dept"
//在人员部门表中增加3个字段，保存级别，业务和地域

//add by shisp 增加权限字段permission int类型，默认是正常显示，也可以隐藏，部分隐藏，不可发消息
//add by shisp 增加是否是特殊用户的列 int类型 0不是特殊用户 1是特殊用户
/*人员id，部门id*/
//add by shisp 增加 员工级别 emp_sort ，展示通讯录时级别高的显示在前面
#define create_table_emp_dept @"create table if not exists emp_dept(emp_id INTEGER,dept_id INTEGER,emp_title TEXT,rank_id integer,prof_id integer,area_id integer,permission integer default 0,is_special integer default 0,emp_sort INTEGER default 0, PRIMARY KEY(emp_id,dept_id))"
//在dept_id列创建索引
#define create_emp_dept_index_dept_id @"create index if not exists emp_dept_index_dept_id on emp_dept(dept_id)"
//在emp_id列创建索引
#define create_emp_dept_index_emp_id @"create index if not exists emp_dept_index_emp_id on emp_dept(emp_id)"

//公司表
#define table_company @"company"
/*公司id，公司名称*/
#define create_table_company @"create table if not exists company(comp_id INTEGER ,comp_name TEXT)"

//自动回复消息表
#define table_auto_send_msg @"auto_send_msg"
/*自动回复消息id，自动回复消息内容*/
#define create_table_auto_send_msg @"create table if not exists auto_send_msg(id INTEGER PRIMARY KEY,msg TEXT)"

//会话表
#define table_conversation @"conversation"
/*
 会话id：当会话类型为担任会话时，会话id为对方的emp_id，否则由服务器生成保存在服务器端
 会话类型：0为两人会话 1为多人会话
 会话主题：创建人有权利修改会话状态
 会话备注：非创建人只能修改会话备注
 是否屏蔽会话：0是接收消息，1是屏蔽消息
 创建人
 创建时间
 最后一条消息id
 未读消息，可以通过查询会话记录表得到
 是否在最近会话中显示 display_flag 0:显示 1:不显示
 
 群组消息中包含了群组时间，需要在会话表中保存此时间 msg_group_time
 增加一个字段receipt_msg_flag,如果是一呼百应消息，那么这个字段的值为1,默认为0
 
 是否置顶 is_set_top 
 置顶时间 set_top_time
 群组类型 group_type 普通讨论组，固定群组，常用群组
 */
#define create_table_conversation @"create table if not exists conversation(conv_id TEXT PRIMARY KEY , conv_type INTEGER,conv_title TEXT,conv_remark TEXT,recv_flag INTEGER,create_emp_id INTEGER,create_time TEXT,last_msg_id INTEGER,display_flag INTEGER DEFAULT 0,lastmsg_body TEXT,last_msg_body TEXT,last_msg_time TEXT, last_emp_id INTEGER,last_msg_type INTEGER,msg_group_time TEXT,receipt_msg_flag integer,is_set_top integer default 0,set_top_time integer default 0,group_type integer default 0)"

//创建联合索引
#define create_conversation_index_1 @"create index if not exists conversation_index_1 on conversation(last_msg_time,display_flag)"

//会话人员表

//群组成员是否有效 is_valid 0有效，1是无效
//群组成员是否设置了消息屏蔽，rcv_msg_flag 0是没有设置屏蔽 1是设置了屏蔽

#define table_conv_emp @"conv_emp"
#define create_table_conv_emp @"create table if not exists conv_emp(conv_id TEXT,emp_id INTEGER,is_valid integer default 0,rcv_msg_flag integer default 0,is_admin integer default 0, PRIMARY KEY(conv_id,emp_id))"

//会话记录表
#define table_conv_records @"conv_records"

/*
 会话id
 发言人id
 发言类型: 0为文本类型 1为图片类型 2 其它类型
 发言内容
// 增加文件大小和文件名称
 发言时间
 未读标志：0为已读 1为未读
 发送/接收标志：0：发送 1：接收
 发送状态标识：0为正在发送，1为发送成功，-1为发送失败，如果是收到的消息，那么-1代表图片或录音已经超过了有效期
 原始消息id
 消息已读通知是否发送成功：read_notice_flag，0是成功，1是失败
 */
#define create_table_conv_records @"create table if not exists conv_records (id INTEGER PRIMARY KEY,conv_id TEXT,emp_id INTEGER,msg_type INTEGER,msg_body TEXT,file_name TEXT,file_size TEXT,msg_time TEXT ,read_flag INTEGER,msg_flag INTEGER,send_flag INTEGER,origin_msg_id TEXT, read_notice_flag INTEGER, is_set_redstate INTEGER,receipt_msg_flag integer)"

//在会话记录表上创建索引
#define create_conv_records_index @"create index if not exists conv_records_index on conv_records(conv_id)"
//创建一个唯一索引，就是发送人和消息id，如果是发送消息，那么消息id是按照一定规则生成的
#define create_conv_records_index_2 @"create unique index if not exists conv_records_index_2 on conv_records(emp_id,origin_msg_id)"

#define create_conv_records_index_3 @"create index if not exists conv_records_index_3 on conv_records(conv_id,msg_time)"

/*
 联系人
 */
#define table_contact_person @"contact_person"
#define create_table_contact_person @"create table if not exists contact_person (emp_id INTEGER)"

/*
 广播

 */
#define table_broadcast @"system_broadcast"
#define create_table_broadcast @"create table if not exists system_broadcast (sender_id TEXT,recver_id TEXT,msg_id TEXT,sendtime TEXT,msglen TEXT,asz_titile TEXT,broadcast_type INTEGER default 0,asz_message TEXT,read_flag INTEGER default 1)"

/*
 虚拟组
 
 */
#define table_vir_group @"vir_group"
#define create_table_vir_group @"create table if not exists vir_group (virgroup_id TEXT PRIMARY KEY,virgroup_name TEXT,virgroup_updatetime TEXT,virgroup_usernum TEXT)"

/*
 虚拟组
 */
#define table_vir_group_emps @"vir_group_emps"
#define create_table_vir_group_emps @"create table if not exists vir_group_emps (virgroup_id TEXT,virgroup_emp_id TEXT)"

//新的创建表的语句
#define create_table_vir_group_emps_new @"create table if not exists vir_group_emps (virgroup_id TEXT,virgroup_emp_id TEXT,conv_title TEXT,PRIMARY KEY (virgroup_id,virgroup_emp_id))"
//创建日程助手  is_read 0已读 1未读
#define table_datehelper @"datehelper_new"
//#define create_table_datehelper @"create table if not exists datehelper(helper_id TEXT PRIMARY KEY ,helper_title TEXT,helper_detail TEXT,helper_create_emp_id INTEGER,create_time TEXT,start_time TEXT,end_time TEXT,warnning_type INTEGER,warnning_str TEXT)"
#define create_table_datehelper @"create table if not exists datehelper_new(helper_id TEXT PRIMARY KEY ,group_id TEXT,helper_title TEXT,helper_detail TEXT,helper_create_emp_id INTEGER,create_time TEXT,start_time TEXT,end_time TEXT,start_date TEXT,warnning_type INTEGER,warnning_str TEXT,is_read INTEGER)"
#define table_helper_emp @"helper_emp"
#define create_table_helper_emp @"create table if not exists helper_emp(helper_id TEXT,emp_id INTEGER,PRIMARY KEY(helper_id,emp_id))"

//公众平台相关定义
//表名:public_service
//
//列名:
//
//服务号id: service_id
//服务号：service_code
//名称：service_name
//服务号名称拼音：service_pinyin
//服务号对应的URL:service_url 
//服务号对应的图片URL:service_icon 下载下来后，保存在本地，可以用service_code为前缀来保存
//描述：service_desc
//是否关注：follow_flag
//是否收消息:rcv_msg_flag
//没有来的及发送的用户的上行消息:last_input_msg 

//取消关注和是否收消息的概念有什么不同？

//公众服务号表
#define table_public_service @"public_service"
#define create_table_public_service @"create table if not exists public_service(service_id integer primary key,service_code text,service_name text,service_pinyin text,service_url text,service_icon text,service_desc text,follow_flag integer,rcv_msg_flag integer,last_input_msg text,service_type integer,service_status integer)"

//收到的公众号的消息
//表名：public_service_message
//
//消息id：msg_id
//消息对应的服务号：service_id
//消息时间:msg_time
//消息主题:msg_body
//消息的图片的URL:msg_url
//对应的超链接:msg_link
//消息类型:msg_type
//收发标识:msg_flag 如果是发消息那就是向这个公众号，发送消息
//未读标志:read_flag

//file_size send_flag is_set_redstate
#define table_public_service_message @"public_service_message"
#define create_table_public_service_message @"create table if not exists public_service_message(msg_id integer primary key,service_id integer,msg_time integer,msg_body text,msg_url text,msg_link text,msg_type integer,msg_flag integer,read_flag integer,file_size integer,send_flag integer,red_dot_flag integer)"

//在服务号消息表上创建索引
#define create_ps_message_index @"create index if not exists ps_message_index on public_service_message(service_id)"

//
//每条消息对应的明细消息
//表名：public_service_message_detail
//
//计算列 msg_id 
//对应的消息id service_msg_id 对应public_service_message表中的msg_id主键
//消息对应的文字内容 msg_body
//消息对应的图片的url msg_url
//消息对应的超链接 msg_link
#define table_public_service_message_detail @"public_service_message_detail"
#define create_table_public_service_message_detail @"create table if not exists public_service_message_detail (msg_id integer primary key,service_msg_id integer,msg_body text,msg_url text,msg_link text)"

//在服务号消息明细表上创建索引
#define create_ps_message_detail_index @"create index if not exists ps_message_detail_index on public_service_message_detail(service_msg_id)"


//一呼百应需要用到的表
//表名：MsgReadState
//列名：msg_id int
//         emp_id int
//         read_flag int

#define table_msg_read_state @"msg_read_state"
#define create_table_msg_read_state @"create table if not exists msg_read_state(msg_id integer,emp_id integer,read_flag integer, read_time integer, primary key(msg_id,emp_id))"
#define create_msg_read_state_index @"create index if not exists msg_read_state_index on msg_read_state(msg_id)"

//记录会话的状态，是普通消息状态，还是一呼百应消息状态
//表名：conv_status
//列名: conv_id text
//		   conv_status int 默认为0，是普通消息状态，一呼百应消息状态为1
#define table_conv_status @"conv_status"
#define create_table_conv_status @"create table if not exists conv_status(conv_id text primary key,conv_status integer)"


//=======高级查询用到的表=======
//用户等级表
//表名: rank
//列名：rank_id
//			rank_name
#define table_rank @"rank"
#define create_table_rank @"create table if not exists rank(rank_id integer primary key,rank_name text)"

//用户业务表
//表名：profession
//列名：prof_id
//	        prof_name
#define table_profession @"profession"
#define create_table_profession @"create table if not exists profession(prof_id integer primary key,prof_name text)"
//
////用户业务关系表
////表名：emp_profession
////列名：emp_id
////	        prof_id
//#define table_emp_profession @"emp_profession"
//#define create_table_emp_profession @"create table if not exists emp_profession(emp_id integer,prof_id integer)"
////在emp_id列创建索引
//#define create_emp_profession_index_emp_id @"create index if not exists emp_profession_index_emp_id on emp_profession(emp_id)"
////在profession_id列创建索引
//#define create_emp_profession_index_profession_id @"create index if not exists emp_profession_index_profession_id on emp_profession(prof_id)"


//用户区域表
//表名：area
//列名：area_id
//	        area_name
//         parent_area
#define table_area @"area"
#define create_table_area @"create table if not exists area(area_id integer primary key,area_name text,parent_area integer)"

////用户区域关系表
////表名：emp_area
////列名：emp_id
////         area_id
//#define table_emp_area @"emp_area"
//#define create_table_emp_area @"create table if not exists emp_area(emp_id integer,area_id integer)"
////在emp_id列创建索引
//#define create_emp_area_index_emp_id @"create index if not exists emp_area_index_emp_id on emp_area(emp_id)"
////在area_id列创建索引
//#define create_emp_area_index_area_id @"create index if not exists emp_area_index_area_id on emp_area(area_id)"

/** 收到的密聊消息表 默认保存在这张表里 如果用户点开了，那么从这个表里删除*/
#define table_encrypt_msg @"encrypt_msg"
#define create_table_encrypt_msg @"create table if not exists encrypt_msg(encrypt_msg_id integer primary key)"

@interface eCloud : LCLSqlite
{
}
@property (retain) NSString *lastUserId;

#pragma mark ---数据库---
////获取数据库的实例
//+(id)getDatabase;
////释放数据库
//+(void)releaseDatabase;
//初始化数据库
-(void)initDatabase:(NSString *)userId;

#pragma mark ---数据库版本表----
//插入版本记录
-(void)insertDbVersion:(NSString*)dbVersion;

//修改版本
-(void)updateDbVersion:(NSString*)dbVersion;
//查询版本
-(NSString*)getDbVersion;

#pragma mark 事务开始
-(bool)beginTransaction;
#pragma mark 事务结束
-(void)commitTransaction;
#pragma mark 事务回滚
-(void)rollbackTransaction;
//1 虚拟组相关
-(void)addVirGroup:(NSArray *) info;

//
-(NSMutableArray*)querySql:(NSString*)sql;

// 把_handle设置为nil，以免更换用户后还能看到上一次的用户记录
- (void)setDBHandleToNil;
@end



