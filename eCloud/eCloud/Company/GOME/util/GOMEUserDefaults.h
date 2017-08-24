//
//  GOMEUserDefaults.h
//  eCloud
//  国美小虫保存在UserDefaults里的数据
//  Created by shisuping on 17/4/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOMEUserDefaults : NSObject

#pragma mark ====国美邮箱服务===
/**
 保存是否提示用户激活邮箱标志
 */
+ (void)saveGomeShowEmailActiveFlag;


/**
 获取提示用户激活邮箱标志
 
 @return 如果长度大于0，表示已经提示过，这次就不用再次提示
 */
+ (NSString *)getGomeShowEmailActiveFlag;

/**
 加密保存邮箱账号和密码
 
 @param account 邮箱账号
 @param password 密码
 */
+ (void)saveGOMEEmailAccount:(NSString *)account password:(NSString *)password;

/** 获取邮箱账号 如果用户输入的是带@的邮箱地址，那么只返回@前的内容 */
+ (NSString *)getGOMEEmailAccount;

/** 获取用户输入的邮箱账号，可能带了@ */
+ (NSString *)getGOMEEmailAddress;

/** 获取邮箱密码 */
+ (NSString *)getGOMEEmailPassword;

/** 保存邮箱登录状态 */
+ (void)saveGOMEEmailStatus:(NSString *)status;

/** 获取邮箱登录状态 */
+ (NSString *)getGOMEEmailStatus;

@end
