//
//  OpenCtxDefine.h
//  NewOpenCtxTest

//  以SDK方式集成到其它App 开放以下定义 宏定义、enum定义、block定义 方便其它App使用

//  Created by shisuping on 16/7/8.
//  Copyright © 2016年 shisuping. All rights reserved.
//

#ifndef OpenCtxDefine_h
#define OpenCtxDefine_h


// ============应用类型定义==============
//合并版本 appstore版本 deprecated
#define combine_appstore_type @"1.01.001"

//合并版本(就是我们提供SDK，其它公司打包的版本) inhouse版本 需要使用合并版本的推送证书实现推送
#define combine_enterprise_type @"2.01.001"

//独立版本(我们自己打包的版本) inhouse版本 使用独立版本的推送证书进行推送
#define independent_enterprise_type @"3.01.001"


#pragma mark ==========enum 定义============

typedef enum
{
    viewuserinfo_result_ok = 0,
    viewuserinfo_result_can_not_find_user = -1
}viewUserInfoResult;

typedef enum
{
    createAndOpenConvResult_ok = 0,
    createAndOpenConvResult_create_group_fail = -1,
    createAndOpenConvResult_create_group_timeout = -2,
    createAndOpenConvResult_user_not_login = -3,
    createAndOpenConvResult_can_not_find_user = -4
}createAndOpenConvResult;


//定义进入选择联系人的功能的类型
typedef enum
{
    //    从会话列表和通讯录的创建会话按钮进入
    type_create_conversation = 0,
    //    从查看聊天资料界面的增加联系人按钮进入
    type_add_conv_emp,
    //    日程进入
    type_schedule,
    //    html5应用进入 第三方应用访问通讯录
    type_app_open_contacts,
    //    html5应用进入 从第三方应用进入会话页面
    type_app_create_conversation,
    //    增加常用联系人进入
    type_add_common_emp,
    //    增加常用部门进入
    type_add_common_dept,
    //    转发消息-新建会话进入
    type_transfer_msg_create_new_conversation,
    //    其它应用 选择 联系人 接口 类型
    type_app_select_contacts,
//    国美选择联系人类型
    type_app_select_contact_gome = 10,
    /** 增加密聊会话 */
    type_add_miliao_conv,
    /** 华夏幸福选择联系人类型 */
    type_hxxf_select_contacts,
    /** 蓝光新闻分享 */
    type_LG_news_share
    
}open_type;

//选择联系人类型定义 单选 多选
typedef enum
{
    select_type_single = 0,
    select_type_multi = 1
}select_type_def;


/** 语言类型 */
typedef enum {
    lan_type_cn = 0,
    lan_type_en
}lan_type_def;

#pragma mark ==========block定义============

/*
 登录结果block
 
 参数说明：
 loginResult：0 登录成功；其它失败
 */
typedef void(^LoginResultBlock)(int loginResult);

//获取状态
typedef void(^GetStatusResultBlock)(NSArray *statusArray);

/*
 获取头像block
 
 参数说明：
 logoPath：用户的头像本地路径;如果头像不存在那么返回@“”
 */
typedef void(^GetPortraitResultBlock)(NSString *logoPath);

/*
 设置用户头像block
 
 参数说明：
 resultCode: 
 0：修改成功
 -1：修改失败
 
 resultMsg:
 当resultCode为0时，resultMsg是头像路径
 当resultCode为-1时，resultMsg是错误提示
 */
typedef void(^SetPortraitResultBlock)(int resultCode,NSString *resultMsg);

/*
 选择联系人结果block
 
 参数说明：
 selectUsers:用户选择的联系人的账号，多个账号使用逗号分隔
 
 参数例子：
 
 */
typedef void(^SelectContactsResultBlock)(NSString *selectUsers);


//查看用户资料结果block
typedef void(^ViewUserInfoResultBlock)(int result,UIViewController *userInfo);

//创建并打开会话结果block
typedef void(^CreateAndOpenConvResultBlock)(int result,UIViewController *talkSession);

//打开选择联系人界面结果block
typedef void (^OpenChooseMemberViewResultBlock)(UIViewController *chooseMember);


#endif /* OpenCtxDefine_h */
