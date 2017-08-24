//
//  UserinfoUtil.h
//  eCloud
//  提供给国美使用的获取当前登录用户资料的工具类
//  Created by Alex L on 17/3/7.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserinfoUtil : NSObject

/**
 功能描述:
 获取用户ID
 */
+ (NSString *)getEmpID;

/**
 功能描述:
 获取用户的登录账号
 */
+ (NSString *)getUserAccount;

/**
 功能描述:
 获取国美token
 */
+ (NSString *)getGOMEToken;

/**
 功能描述:
 获取userCode
 */
+ (NSString *)getUserCode;

/**
 功能描述:
 获取没有a5 的 userCode
 */
+ (NSString *)getUserCodeWithoutA5;

/**
 功能描述:
 获取用户头像
 */
+ (UIImage *)getEmpLogo;

/**
 功能描述:
 获取用户名
 */
+ (NSString *)getEmpName;

/**
 功能描述:
 获取用户性别
 */
+ (int)getEmpSex;

/**
 功能描述:
 获取用户 e-mail
 */
+ (NSString *)getEmpMail;

/**
 功能描述:
 获取用户手机号码
 */
+ (NSString *)getEmpMobile;

/**
 功能描述:
 获取用户职务 国美要求返回部门，不返回职务
 */
+ (NSString *)getEmpTitle;


@end
