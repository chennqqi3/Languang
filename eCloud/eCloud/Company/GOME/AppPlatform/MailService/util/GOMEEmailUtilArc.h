//
//  GOMEEmailUtil.h
//  eCloud
//
//  Created by Alex-L on 2017/4/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GOMEEmailUtilArc : NSObject

+ (GOMEEmailUtilArc *)getEmailUtil;

/** 开始轮询 */
- (void)startEmailTimer;

/** 停止轮询 */
- (void)stopEmailTimer;

/** 同步获取邮件未读数 */
- (void)getNewMailCount;

/** 异步获取邮件未读数 */
- (void)getNewMailCountAsync;

/**
 根据账号和密码获取用来校验账号和密码是否匹配的URL

 @param email 邮箱账号
 @param password 邮箱密码
 @return 可以用来校验用户和密码是否正确的URL String
 */
- (NSString *)getCheckEmailAndPasswordUrlWithEmail:(NSString *)email andPassword:(NSString *)password;


/**
 根据服务器返回的数据判断账号和密码是否正确

 @param dic 服务器返回的数据转成了字典
 @return 如果账号和密码正确则返回YES，否则返回NO
 */
- (BOOL)isEmailAndPasswordCorrect:(NSDictionary *)dic;


/**
 对明文的账号进行加密

 @param mail 邮箱账号
 @return 加过密的邮箱账号
 */
- (NSString *)encryptEmailAccount:(NSString *)mail;

/**
 对邮箱密码进行加密

 @param password 邮箱密码
 @return 对邮箱密码加密后的内容
 */
- (NSString *)encryptEmailPassword:(NSString *)password;


/**
 对加密的邮箱账号进行解密

 @param encryptMail 加过密的账号
 @return 邮箱账号
 */
- (NSString *)decryptEmailAccount:(NSString *)encryptMail;


/**
 对加密的密码进行解密

 @param encryptPassword 加过密的密码
 @return 密码
 */
- (NSString *)decryptEmailPassword:(NSString *)encryptPassword;

@end
