//
//  UserLogoUtil.h
//  eCloud
//
//  Created by Richard on 13-12-31.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

//在头像上增加一个UILabel，显示头像对应的文字消息 默认是隐藏
#define logo_text_tag (998)

@class Emp;
@class Conversation;
@interface UserDisplayUtil : NSObject

/** 根据logoview的高度给出一个UIIMageView */
+ (UIImageView *)getUserLogoViewWithLogoHeight:(float)logoHeight;

/**
 统一用户头像的显示View

 @return 用户头像
 */
+(UIImageView*)getUserLogoView;

/**
 聊天界面头像展示

 @return 用户聊天界面头像
 */
+(UIImageView*)getUserChatLogoView;

/**
 如果用户设置了自己的头像，那么显示自己的头像，否则根据性别显示默认头像，然后再根据在线或离线显示在线或离线头像，还要根据登录客户端类型，确定是否显示手机登录图标

 @param logoView logo视图
 @param emp      员工
 */
+(void)setUserLogoView:(UIImageView*)logoView andEmp:(Emp*)emp;

/**
 增加一个标识，登录用户自己是否需要显示头像

 @param logoView             logo视图
 @param emp                  员工
 @param displayCurUserStatus 是否显示用户状态
 */
+(void)setUserLogoView:(UIImageView*)logoView andEmp:(Emp*)emp andDisplayCurUserStatus:(BOOL)displayCurUserStatus;

/**
 显示小头像

 @param logoView logo视图
 @param emp      员工
 */
+(void)displayLittleView:(UIImageView*)logoView andEmp:(Emp*)emp;

/**
 如果用户在线，那么名字标签显示蓝色，否则黑色

 @param nameLabel  员工姓名label
 @param empStatus 员工状态
 */
+(void)setNameColor:(UILabel*)nameLabel andEmpStatus:(int)empStatus;

/**
 如果用户在线，那么名字标签显示蓝色，否则黑色

 @param nameLabel 员工姓名label
 @param emp       员工
 */
+(void)setNameColor:(UILabel*)nameLabel andEmp:(Emp *)emp;

/**
 会话列表界面显示会话logo

 @param logoView logo视图
 @param conv     会话
 */
+(void)setUserLogoView:(UIImageView*)logoView andConversation:(Conversation*)conv;

/**
 （万达版本）
 移动端 通讯录 不展示用户状态

 @param logoView logo视图
 @param emp      员工
 */
+ (void)setOnlineUserLogoView:(UIImageView *)logoView andEmp:(Emp *)emp;

/**
 判断是否手机登录

 @param emp 员工

 @return 是否手机登录
 */
+(BOOL)isLoginWithCellPhone:(Emp *)emp;

/**
 查找聊天纪录页面显示人员状态

 @param logoView   logo视图
 @param permission 权限
 */
+(void)setUserLogoView:(UIImageView*)logoView andEmpPermission:(int)permission;

/**
 获取 默认 的头像的尺寸

 @return 头像size
 */
+ (CGSize)getDefaultUserLogoSize;

/**
 判断是否PC登录

 @param emp 员工

 @return 是否PC登录
 */
+ (BOOL)isLoginWithPC:(Emp *)emp;

/**
 原来程序生成头像圆角会占用内存，现在修改为通过设置layer的方法实现圆角，因此需要修改代码，把真正的view作为一个子view来显示

 @param logoView 头像view
 @return <#return value description#>
 */
+ (UIImageView *)getSubLogoFromLogoView:(UIImageView *)logoView;


/**
 获取讨论组头像

 @param conv 会话对象
 @return 讨论组头像
 */
+ (UIImage *)getImageWithConv:(Conversation *)conv;

/** 根据头像图片的大小，计算状态图片的中心位置 */
+ (CGPoint)getStatusCenterWithLogoView:(UIView *)logoView;

//隐藏状态UIView
+ (void)hideStatusView:(UIImageView *)logoView;

//获取头像上的文本label
+ (UILabel *)getLogoTextLabelFromLogoView:(UIImageView *)logoView;

/** 根据自定义logo的属性 显示logo */
+ (void)setUserDefinedLogo:(UIImageView *)logoView andLogoDic:(NSDictionary *)logoDic;

/** 生成一个用户自定义头像的属性字典 */
+ (NSDictionary *)getUserDefinedLogoDicOfEmp:(Emp *)emp;

/** 隐藏logo文本 */
+ (void)hideLogoText:(UIImageView *)logoView;

/** 在logoView上增加一个UILabel */
+ (void)addLogoTextLabelToLogoView:(UIImageView *)logoView;

/** 群组头像 根据用户名字生成 的 头像属性 */
+ (NSDictionary *)getUserDefinedGroupLogoDicOfEmp:(Emp *)emp;

/** 聊天资料界面 根据用户名字生成 的 头像属性 */
+ (NSDictionary *)getUserDefinedChatMessageLogoDicOfEmp:(Emp *)emp;

@end
