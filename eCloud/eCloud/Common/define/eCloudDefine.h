//
//  eCloudDefine.h
//  eCloud
//
//  Created by robert on 12-10-11.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAdapterUtil.h"
#import "eCloudNOtification.h"

//#import "serverConfig/server_longhu.h"

#import "eCloudConfig.h"
#import "AppModeDefine.h"

#import "NotificationDefine.h"
#import "StringUtil.h"
#import "LogUtil.h"

//#import "SystemDefine.h"
//
//#import "OrgDefine.h"
//
#import "IOSSystemDefine.h"

@interface eCloudDefine : NSObject

/*
 功能描述
 生成数据库文件开关 0 关闭 1开启
 
 注意事项
 1 尽量使用模拟器运行，请先把模拟器的应用删除，对于南航来说，要使用级别为3的用户登录。使用模拟器可以方便把压缩好的数据库文件拷贝出来，上传到服务器
 2 请周期性生成通讯录文件，否则通讯录文件太久，下载下来后，仍然需要同步很多变化。
 3 通讯录文件名称和路径，请在 StringUtil的 zipDb方法中设置断点进行观察。
 4 通讯录文件包括两个数据库文件，一个是记录已登录用户的数据库。一个是记录用户通讯录、Im消息等的数据库。
 5 一定要使用指定应用的appconfig.plist，因为org部分的设置可能不同。
 */
#define CREATE_ORG_DATABASE_FILE (0)

#pragma mark 取消息间隔 s
#define sec_interval 0.05


#pragma mark 上传，下载文件超时重试次数
#define max_try_count 1

#pragma mark 是否屏蔽会话
typedef enum
{
	open_msg = 0,
	shield_msg
}msgPrompt;

#pragma mark add by shisp 定义会话类型
//单人会话 talksessionVC
//多人会话 talksessionVC
//服务号
//不在会话列表中显示的服务号消息入口
//应用平台消息入口 （南航特有，但是还未上线）
//普通广播消息类型
//从其它平台发到IM的推送消息(万达特有)
//一呼万应消息 (南航) talksessionVC
//收到的一呼万应消息 (南航) talksessionVC
//机组群 (南航)
//公众号展示消息类型，图文，文本，图片 (南航) talksessionVC
#pragma mark 增加一种新的会话类型，就是公众号消息类型，用来显示某个公众号的消息
typedef enum
{
	singleType = 0,
	mutiableType,
	serviceConvType,
	serviceNotInConvType,
    appInConvType,
    broadcastConvType,   //广播消息显示在会话列表
    imNoticeBroadcastConvType, //im消息提醒广播 显示在会话列表
	massType,
	rcvMassType,
    fltGroupConvType,
    publicServiceMsgDtlConvType,
    appNoticeBroadcastConvType //第三方应用提醒广播 显示在会话列表
}convType;

#pragma mark add by shisp 系统状态
//未连接、连接中、下载组织架构，收取中、正常
typedef enum
{
	not_connect_type = 0,
	linking_type,
	download_org,
	rcv_type,
	normal_type
}connect_type;

// 广告页下载标示
typedef enum
{
    download_guide = 1,
    download_final
}download_guide_type;


#pragma mark 定义信息类型 文本类型 图片 录音 视频 文件 撤回消息 群公告消息
typedef enum
{
	type_text=0,
	type_pic,
	type_record,
	type_video,
	type_file,
	type_long_msg = 7,
	type_group_info = 8,
    type_recall_msg = 50,
    type_group_notice = 51,
    type_imgtxt,
    type_wiki,
    /** 增加一种普通的图文类型 比如pc端发过来的包括截图和文字或多张截图的类型 */
    type_normal_imgtxt,
    //位置类型
    type_location,
    type_news
}msgType;



#pragma mark 定义组织架构信息改变类型，添加，修改，删除
typedef enum 
{
	insertRecord = 1,
	updateRecord,
	deleteRecord
}updateType;

#pragma mark 收发标识
typedef enum
{
	send_msg = 0,
	rcv_msg
}msgFlag;

#pragma mark 发送状态标识
typedef enum
{
	send_failure=-1,
	sending,
	send_success,
	send_uploading,
	send_upload_fail,
    send_upload_stop,
    send_upload_nonexistent,//服务器文件不存在
    send_upload_waiting, //准备上传
    save_location
}sendResult;

#pragma mark 用户状态
typedef enum
{
	status_online = 0,
	status_leave,//deprecated
	status_offline,
	status_exit,//deprecated
	status_no_connect //deprecated
}userStatus;

#pragma mark 查看会话记录
//每页显示的会话记录个数
#define perpage_conv 20

//每页显示的会话消息的个数
#define perpage_conv_detail 20

//会话界面显示的记录数
#define num_convrecord 10

//根据搜索结果进行定位，每次加载条数
#define num_of_load_search_result (20)

#pragma mark PC端截图消息格式定义
#define PC_CROP_PIC_START @"[#"
#define PC_CROP_PIC_END @"]"

#pragma mark 表情格式定义
#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

#define byteToG(size)    ((double)(size))/(1024 * 1024 * 1024)
#define byteToM(size)    ((double)(size))/(1024 * 1024)
#define byteToK(size)    ((double)(size))/(1024)

//#define app_version @"1.0"
#pragma mark 版本类型
typedef enum
{
	db_version_type = 0,
	app_version_type
} versionType;

//add by shisp ========头像尺寸定义 貌似现在没有再用到==========
#pragma mark 头像尺寸定义
//在用户资料界面展示的头像的大小
#define person_info_logo_size 60

//登录用户个人资料页面头像大小
#define user_info_logo_size 70

//首页显示登录用户头像大小
#define small_user_logo_size 40
#define chat_user_logo_size 40
#define user_logo_size 40

#ifdef _LANGUANG_FLAG_

#define chatview_logo_size 45

#else

#define chatview_logo_size 48

#endif


#pragma mark 多少分钟(目前是3分钟)之内的会话，只显示一个会话时间
#define msg_time_sec 180

#pragma mark 离线消息收取超时时间
#define rcv_offline_msg_timeout 10

#pragma mark 聊天内容的字体
#define message_font 16

#pragma mark 消息时间字体
#define time_font_size 12

#pragma mark 群组消息字体
#define groupInfo_font_size 14

#pragma mark 离线消息数量较大的情况下，停留在会话界面时，加载的离线消息的数量，默认为10
#define default_offline_msgs_display_num 10


#pragma mark 定义用户输入的文本的类型，包括字母letter，数字number，中文hanzi，其它
typedef enum
{
	letter_type = 0,
	number_type,
	hanzi_type,
    special_char_type,
	other_type
}textType;

#pragma mark 在会话列表显示的数据的种类包含 普通会话，包含日历，包含服务号，包含机组群
typedef enum
{
	normal_conv_type = 0,
	flt_group_type,
    miliao_conv_type
}convListRecordType;

#pragma mark 展示消息记录
//普通消息
//公众号消息
//一呼万应消息
typedef enum
{
	normal_conv_record_type,
	ps_conv_record_type,
	mass_conv_record_type
}convRecordType;

#pragma mark 新消息类型
//普通新消息
//新的公众号消息
//新的应用平台消息
//新的一呼万应回复消息
typedef enum
{
	normal_new_msg_type,
	ps_new_msg_type,
    app_new_msg_type,
	mass_reply_msg_type
}newMsgType;

#pragma mark 公众平台 消息类型
//add by shisp 增加了录音和图片类型
typedef enum
{
	ps_msg_type_text = 0,
	ps_msg_type_news,
    ps_msg_type_record,
    ps_msg_type_pic
}psMsgType;

//会话所处状态
//普通状态
//一呼百应消息状态
//回执消息状态
typedef enum{
    conv_status_normal,
    conv_status_receipt,
    conv_status_huizhi = 100
}convStatusType;


#pragma mark 群发成员的类型，可能是部门也可能是普通员工
typedef enum
{
	dept_member_type = 0,
	emp_member_type
}massMemberType;

#pragma mark 群组成员的默认数
#define default_group_member (80)

#pragma mark 群组成员的最大数
#define max_group_member (500)

#pragma mark 会话列表显示的会话的最大个数
#define max_recent_conv_count (100)

#pragma mark-转发显示最近群组最大个数
#define forward_max_recent_conv_count (60)

//热点名称
#define redian_name @"南航热点"
//南航通知名称
#define csair_tongzhi_name @"通知"

#pragma mark ============群组类型：普通讨论组，固定群组，常用群组，通过会话表里的一个字段进行标识==============
typedef enum
{
    normal_group_type = 0,
    system_group_type,
    common_group_type
}group_type;

//搜索员工资料时 可以匹配 哪些员工的属性定义
typedef enum
{
    emp_match_simple_pinyin = 1,
    emp_match_pinyin_withoutspace = 2,
    emp_match_empcode = 4,
    emp_match_empname = 8
}emp_match_attribute_define;

//==========我的界面的显示方式 一是南航九宫格方式 而是万达的tableView方式============
typedef enum
{
    myview_type_of_grid = 0,
    myview_type_of_tableview = 1,
    myview_type_of_customgrid = 2,
//    龙湖目前使用的方式
    myview_type_of_customtableview = 3,
//    国美目前使用的方式
    myview_type_of_collectionView = 4,
//    泰禾主页使用方式
    myview_type_of_customView = 5,
}myview_type;

//=======龙湖地产======
//待办应用的app id
#define LONGHU_DAIBAN_APP_ID (101)
//邮件应用的app id
#define LONGHU_MAIL_APP_ID (102)
//客储应用的app id
#define LONGHU_GUSET_APP_ID (110)
//我的预警 app id
#define LONGHU_MY_ALARM_APP_ID (104)
//工作圈 app id
#define LONGHU_WORK_APP_ID (111)
//HR助手 appid
#define LONGHU_HR_ASSISTANT_APP_ID (105)

//=======祥源======
//报表应用的app id
#define XIANGYUAN_BAOBIAO_APP_ID (1)
//待办应用的app id
#define XIANGYUAN_DAIBAN_APP_ID (2)
//制度应用的app id
#define XIANGYUAN_ZHIDU_APP_ID (6)

//泛微token的key值
#define XIANGYUAN_FANWEI_TOKEN_KEY "30b3e212-2821-4039-b711-40624201cbeb"

//========通讯录中右向箭头所占位置=========
#define RIGHT_ROW_SIZE (30.0)

//=========通知类型=========
typedef enum
{
    local_notification_normal_msg = 0,
    // 代办通知
    notification_agent_msg = 3,//祥源通告也用3
    //祥源待办通知
    xy_notification_agent_msg = 2
}LocalNotificationType;
#define KEY_NOTIFICATION_MSG_TYPE @"msgtype"
#define KEY_NOTIFICATION_APP_ID @"appid"
#define KEY_NOTIFICATION_APP_URL @"lighturl"
//增加定义通知内容 通知标题
#define KEY_NOTIFICATION_TITLE @"title"
#define KEY_NOTIFICATION_MESSAGE @"message"

//是否点通知进入程序
#define APPLICATION_PUSH @"applicationPush"
//小万的工号
#define USERCODE_OF_IROBOT @"iRobot"
//文件助手的工号
#define USERCODE_OF_FILETRANSFER @"Filetransfer"

//@All相关定义
#define AT_ALL_CN @"全体成员"
#define AT_ALL_EN @"ALL"

//龙湖轻应用域名
#define LONGHU_HTML5_DOMAIN @"moapproval.longfor.com"

//从文件服务器下载图片或者文件时，需要在http头增加属性
#define DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_NAME @"netsense"
#define DOWNLOAD_FROM_FILESERVER_ADD_HEADER_KEY_VALUE @"netsense"

//我的电脑 部门 名称 南航需求
#define MY_COMPUTER_DEPT_NAME @"我的电脑"

//是否启用南航的隐藏部分人员的功能
#define START_CSAIR_HIDE_ORG (YES)

//小万回复 xml 格式
#define XML_START @"<soap:Body>"
#define XML_END @"</soap:Body>"

//服务器 端 返回的初始时间戳
#define SERVER_INIT_TIMESTAMP (1420934400)

/** 收藏删除通知 */
#define COLLECT_DELETED_SUCCESSFULLY @"CollectDeletedSuccessfully"

/** 点击statubar滚动回顶部 */
#define SCROLL_TO_TOP_NOTIFICATION @"SCROLL_TO_TOP_NOTIFICATION"

//广播类型
typedef enum
{
    normal_broadcast = 0,
    mass_notice_broadcast = 1,
    imNotice_broadcast = 2,
    appNotice_broadcast = 3
}broadcastType;

//聊天记录是否可以编辑
#define CAN_EDIT_CONVRECORD (YES)

//第一条新消息提示内容
#define FIRST_NEW_MSG_TIPS  @"点击跳转到第一条新消息"

#define MILIAO_PRE @"m_"

#define APPROVAL_PRE @"666666"

#define EMP_NOT_FOUND -1

#define XYGXViewController @"GXViewController"
//部门显示类型定义
typedef enum {
    //    不显示
    dept_display_type_hide = 0,
    
    //显示子部门
    dept_display_type_display_sub_dept = 1,
    
    //    显示人员和子部门
    dept_display_type_display_emp_and_subdept = 2
}DeptDisplayTypeDef;

@end
