//
//  Header.h
//  eCloud
//
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#ifndef eCloud_Header_h
#define eCloud_Header_h

//应用平台应用列表
#define table_apps_list @"apps_list"
/*
 @property(assign) int *appid; //应用编号      (NSString->int)
 @property(nonatomic,retain) NSString *appname; //应用名称
 @property(nonatomic,retain) NSString *appauthname; //鉴权账号
 @property(nonatomic,retain) NSString *appauthpwd; //鉴权密码
 @property(assign) int appauthtype; //轻应用是否具备全员属性 1：企业全员均具备此轻应用
 @property(nonatomic,retain) NSString *apphomepage; //应用首页链接
 @property(nonatomic,retain) NSString *apppage1; //应用其他链接
 @property(nonatomic,retain) NSString *apppage2; //应用其他链接
 @property(nonatomic,retain) NSString *logopath; //logo下载路径
 @property (assign) int *sort; //应用排序位  客户端显示排序
 @property (assign) int *update_time; //更新时间
 @property(assign) int updatetype;//更新类型：1 新增、2 修改、3 删除(更新类型为3时后面的元素都不需要)   (synctype->updatetype)

 @property(assign) int apptype; //应用类型：1  HTML5、2 原生app
 @property(assign) int appscope;//应用范围：1 指定、2 公共

 @property(nonatomic,retain) NSString *appicon;//应用图标url
 @property(nonatomic,retain) NSString *appvers;   //应用版本号
 @property(nonatomic,retain) NSString *uptime;    //更新时间
 @property(nonatomic,retain) NSString *serverurl; //服务URL：应用类型为 1 表示主页URL、为2 表示app下载地址
 @property(assign) int permission;//应用权限：两个字节转成2进制16位每位代表一个权限该位为1表示具有该权限 第三方应用使用接口的权限
 @property(nonatomic,retain) NSArray *cacheurl;  //缓存URL：最多5个
 
 @property(assign) int isnew;                 //0.不是新应用 1.新应用
 @property(assign) int appShowFlag;              //是否添加到我的页面 0.没有 1.已添加到我的页面
 
 @property(assign) int showflag;              //应用推送是否在首页显示：1 显示 0 不显示
 @property(assign) int downloadFlag;              //应用是否已经下载：1 已下载 0 未下载
 @property(nonatomic,retain) NSString *appdesc; //应用简介文字描述
 @property(nonatomic,retain) NSArray *apppics;  //应用简介图片
 
 */

#define create_table_apps_list @"create table if not exists apps_list(appid TEXT PRIMARY KEY ,apptype INTEGER,appname TEXT,appicon TEXT,appvers TEXT,uptime TEXT,serverurl TEXT,permission INTEGER,cacheurl TEXT,isnew INTEGER,appShowFlag INTEGER,showflag INTEGER,downloadFlag INTEGER,appdesc TEXT,apppics TEXT)"

#define create_table_apps_list_new @"create table if not exists apps_list(appid INTEGER PRIMARY KEY ,appname TEXT,appauthname TEXT,appauthpwd TEXT,appauthtype INTEGER,apphomepage TEXT,apppage1 TEXT,apppage2 TEXT,sort INTEGER,update_time INTEGER,updatetype INTEGER,apptype INTEGER,logopath TEXT,appicon TEXT,appvers TEXT,uptime TEXT,serverurl TEXT,permission INTEGER,cacheurl TEXT,isnew INTEGER,appShowFlag INTEGER,showflag INTEGER,downloadFlag INTEGER,appdesc TEXT,apppics TEXT,groupId INTEGER default 0)"

//应用平台推送消息表
#define table_app_msg @"apps_msg_table"

/*
int msgId;     //消息id
int read_flag;                 //0.未读 1.已读
 
NSString *appid; //应用编号
int notinum;//相关通知数量
int pri; //优先级 范围：0-10 数字越大优先级越高
NSString *title;//通知标题
NSString *summary;//概要
NSString *pushurl;//推送消息URL
int notitime;//时间
NSString *src;//消息发送者
 */

#define create_table_apps_msg @"create table if not exists apps_msg_table(msgId INTEGER PRIMARY KEY,read_flag INTEGER,appid TEXT,notinum INTEGER,pri INTEGER,title TEXT,summary TEXT,pushurl TEXT,notitime integer,src TEXT)"





//应用平台统计数据上报数据表
#define table_app_state_record @"apps_state_record"

/*
 @property (assign) int recordid;     //记录id
 @property (nonatomic,retain) NSString *appid; //应用编号
 @property(assign) int  optype;//操作类型：1 访问 2 安装 3 卸载
 @property(nonatomic,retain) NSString *optime; //时间 格式: yyyymmdd
*/

#define create_table_app_state_record @"create table if not exists apps_state_record(recordid INTEGER PRIMARY KEY,appid TEXT,optype INTEGER,optime TEXT)"





#endif
