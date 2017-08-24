
// 和系统通知相关的定义

#import "OpenNotificationDefine.h"

#ifndef eCloud_NotificationDefine_h
#define eCloud_NotificationDefine_h


#pragma mark 通知常量定义
//超时通知
#define TIMEOUT_NOTIFICATION @"TIMEOUT_NOTIFICATION"
//定义一些全局常量
#define LOGIN_NOTIFICATION @"LOGIN"

//已经在别处登录,此处下线的通知
#define OFFLINE_NOTIFICATION @"OFFLINE_NOTIFICATION"

/*#define LOGOUT_NOTIFICATION @"LOGOUT"
 #define MODIFY_USER_INFO_NOTIFICATION @"MODIFY_USER_INFO"
 #define GET_COMP_INFO_NOTIFICATION @"GET_COMP_INFO"*/

//会话相关的通知
#define CONVERSATION_NOTIFICATION @"CONVERSATION_NOTIFICATION"
//add by lyong 2012-10-27
//修改分组成员
#define MODIFYMEBER_NOTIFICATION @"MODIFYMEBER_NOTIFICATION"
//修改群组名称
#define MODIFYGROUPNAME_NOTIFICATION @"MODIFYGROUPNAME_NOTIFICATION"
//(已废弃)用户状态改变
#define USERCHANGESTATUS_NOTIFICATION @"USERCHANGESTATUS_NOTIFICATION"
//修改用户资料
#define MODIFYUSER_NOTIFICATION @"MODIFYUSER_NOTIFICATION"
//获取用户资料
#define GETUSERINFO_NOTIFICATION @"GETUSERINFO_NOTIFICATION"
//选择通讯录回调
#define js_choose_NOTIFICATION @"js_choose_NOTIFICATION"

//退出群组通知名称
#define QUIT_GROUP_NOTIFICATION @"QUIT_GROUP_NOTIFICATION"

//提示用户正在链接
//没有网络 或者 不能连接到服务器 通知
#define NO_CONNECT_NOTIFICATION @"NO_CONNECT_NOTIFICATION"

//网络切换通知
#define NETWORK_SWITCH @"Network switch"
//日程提醒应答
#define HELPER_MESSAGE_NOTIFICATION @"HELPER_MESSAGE_NOTIFICATION"
//正在连接通知
#define CONNECTING_NOTIFICATION @"CONNECTING_NOTIFICATION"

//广播通知
#define BROADCAST_NOTIFICATION @"BROADCAST_NOTIFICATION"

//接收到文件通知
#define RECEIVE_FILE_NOTIFICATION @"RECEIVE_FILE_NOTIFICATION"

//离线消息收取完毕通知
#define RCV_OFFLINE_MSG_NOTIFICATION @"RCV_OFFLINE_MSG_NOTIFICATION"

//打开网页
#define OPEN_WEB_NOTIFICATION @"OPEN_WEB_NOTIFICATION"

//组织架构信息通知
#define ORG_NOTIFICATION @"ORG_NOTIFICATION"

//聊天窗口--会话按钮，发出通知，收到通知的关闭自己
#define BACK_TO_CONV_LIST_NOTIFICATION @"BACK_TO_CONV_LIST_NOTIFICATION"
//聊天窗口点击返回按钮后，会pop到根目录，并且发出选中会话tab页的通知
#define AUTO_SELECT_CONVERSATION_NOTIFICATION @"AUTO_SELECT_CONVERSATION_NOTIFICATION"

//转发选择现有群组
#define FORWARD_TO_EXIST_GROUP @"FORWARD_TO_EXIST_GROUP"

//从通讯录打开的联系人资料界面打开的会话界面 返回时发出的通知
#define BACK_TO_CONTACTVIEW_FROM_NEWORG @"BACK_TO_CONTACTVIEW_FROM_NEWORG"

//从小万界面打开会话界面
#define BACK_TO_CONTACTVIEW_FROM_ROBOT @"BACK_TO_CONTACTVIEW_FROM_ROBOT"

//用户详细资料关闭时发出通知
#define PERSON_INFO_DISMISS_NOTIFICATION @"PERSON_INFO_DISMISS_NOTIFICATION"

//成员管理关闭时发出通知
#define ADMIN_MEMBER_DISMISS_NOTIFICATION @"ADMIN_MEMEBER_DISMISS_NOTIFICATION"

//显示分组成员关闭时发出通知
#define PERSON_GROUP_DISMISS_NOTIFICATION @"PERSON_GROUP_DISMISS_NOTIFICATION"

//设置屏蔽群组消息的通知
#define SET_CONV_RCV_MSG_FLAG_NOTIFICATION @"SET_CONV_RCV_MSG_FLAG_NOTIFICATION"
//语音片
#define SHORT_AUDIO_NOTIFICATION @"SHORT_AUDIO_NOTIFICATION"
//长语音
#define LONG_AUDIO_NOTIFICATION @"LONG_AUDIO_NOTIFICATION"

//应用平台推送消息
#define APP_PUSH_NOTIFICATION @"APP_PUSH_NOTIFICATION"

//应用平台Token
#define APP_TOKEN @"APP_TOKEN"

//应用平台有新应用
#define APP_NEW_DEFAULT @"APP_NEW_DEFAULT"

//应用平台有新应用推送
#define APP_NEW_NOTIFICATION @"APP_NEW_NOTIFICATION"

//应用平台刷新消息中心
#define APP_PUSH_REFRESH_NOTIFICATION @"APP_PUSH_REFRESH_NOTIFICATION"


//选择语言后 通知通讯录刷新当前语言
#define REFREASH_CONACTS_LANGUAGE @"REFREASH_CONACTS_LANGUAGE"

//文件助手批量转发页面刷新
#define FILE_ASSISTANT_REFRESH @"FILE_ASSISTANT_REFRESH"

//轻应用同步完成之后
#define APPLIST_UPDATE_NOTIFICATION @"APPLIST_UPDATE_NOTIFICATION"

//国美应用界面banner配置获取后发出通知，给界面刷新
#define GOME_APP_BANNER_UPDATE_NOTIFICATION @"GOME_APP_BANNER_UPDATE_NOTIFICATION"

//新待办获取未读数
#define APPLIST_RECUNREAD_NOTIFICATION @"APPLIST_RECUNREAD_NOTIFICATION"
//有新待办进入新待办详情
#define APPLIST_GOTOAGENTDETAIL_NOTIFICATION @"APPLIST_GOTOAGENTDETAIL_NOTIFICATION"

//弹出升级提示框
#define NEW_VERSION_TIP_URL @"NEW_VERSION_TIP_URL"

/** 泰禾退出登录，释放首页计时器和jS代理 */
#define TAI_HE_LOG_OUT @"taiHeLogOut"
//泰禾刷新首页通知
#define TAI_HE_REFRESH_PAGE @"REFRESH_PAGE"

//泰禾去oa首页通知
#define TAI_HE_GO_OA_HOME @"goOAHome"

//泰禾工作界面回oa首页通知
#define TAI_HE_WORK_GO_OA_HOME @"workGoOAHome"

//刷新首页
#define REFRESH_PAGE @"RefreshPage"

//刷新邮箱
#define REFRESH_EMAIL @"Email"

//刷新代办
#define REFRESH_OA @"OA"

//回原生首页
#define GO_NATIVE_HOME @"NativeHome"

//回原生会话界面
#define GO_NATIVE_SESSION @"NativeSession"

//回原生工作界面
#define GO_NATIVE_WORK @"NativeWork"

//回OA首页
#define GO_OA_HOME @"OAHome"

//工作界面回OA首页
#define WORK_GO_OA_HOME @"workGoOAHome"

//祥源刷新待办数量
#define XIANGYUAN_REFRESH_COUNT @"refreshCount"

//祥源修改常用讨论组
#define XIANGYUAN_COMMON_GROUP @"XYCommonGroup"

//祥源修改常用讨论组状态
#define XIANGYUAN_STATUS @"XYstatus"

/** 蓝光退出登录，释放首页jS代理 */
#define LG_LOG_OUT @"LGLogOut"

#pragma mark 会话通知类型
typedef enum
{
    //	超时
    cmd_timeout = 0,
    //	登录成功
    login_success = 1,
    //	登录失败
    login_failure = 2,
    //	登录超时
    login_timeout = 3,
    
    //	用户在别处登录，此处离线
    user_offline = 4,
    
    //	获取群组信息成功，需要通知会话界面刷新
    get_group_info_success = 5,
    
    //分组创建成功
    create_group_success = 6,
    
    //分组创建失败
    create_group_failure = 7,
    
    create_group_timeout = 8,
    
    //修改群组成员成功
    modify_group_success = 9,
    
    //修改群组成员失败
    modify_group_failure = 10,
    //修改群组成员成功
    modify_groupname_success = 11,
    
    //修改群组成员失败
    modify_groupname_failure = 12,
    //消息发送成功
    send_msg_success = 13,
    
    //消息发送失败
    send_msg_failure = 14,
    //修改用户信息成功
    modify_userinfo_success = 15,
    
    //修改用户信息失败
    modify_userinfo_failure = 16,
    
    change_status_success = 17,
    
    change_status_failure = 18,
    
    //收到消息通知
    rev_msg = 19,
    
    //	未及时发出通知的消息，在离线消息处理完毕或超时后，发出去
    offline_msgs = 20,
    
    //	收到消息已读通知
    msg_read_notice = 21,
    
    //获取用户资料成功
    get_user_info_success = 22,
    //	获取用户资料失败
    get_user_info_failure = 23,
    get_user_info_timeout = 24,
    //    计划在用户资料界面打开的时候，
    //获取用户资料成功
    get_user_info_success_new = 25,
    //	获取用户资料失败
    get_user_info_failure_new = 26,
    get_user_info_timeout_new = 27,
    
    refresh_org = 28,
    first_load_org = 29,
    refresh_org_byhand_finish = 30,
    
    //	离线通知收取完毕
    rcv_offline_msg_finish = 31,
    
    //	主动退出群组成功，失败，超时
    quit_group_success = 32,
    quit_group_failure = 33,
    quit_group_timeout = 34,
    //	群组成员变化通知，如果用户已经不在群组里了，那么就不能查看群组信息，否则可以查看
    group_member_change = 35,
// 群组资料修改通知
    group_name_modify = 36,
//    被退群
    removed_from_group = 37,
// 服务号消息已读
    ps_msg_read = 38,
// 一呼百应消息已读发送成功
    receipt_msg_send_read_success = 39,
// 正在检查网络
    start_check_network = 40,
    end_check_network = 41,
    
    //    收到消息已读通知
    receive_msg_read_notify = 42,
    // 刷新全部轻应用
    refresh_app_list = 43,
    // 刷新指定轻应用
    refresh_app_section = 44,
    // 获取待办未读数
    rcv_app_agentunread = 45,
    // 获取新待办url
    rcv_app_agentdetail_url = 46,
//    机器人文件下载成功
    download_robot_file_complete = 47,
//    机器人文件下载失败
    download_robot_file_fail = 48,
//    机器人文件开始下载 这时需要显示 正在下载提示
    start_download_robot_file = 49,
    /** 用户打开了某密聊消息 */
    open_encrypt_msg = 50
}conv_cmd_type;


//机器人文件已经下载
#define DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION @"DOWNLOAD_ROBOT_FILE__RESULT_NOTIFICATION"
#endif
