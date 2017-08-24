//
//  GOMEUserDefaults.m
//  eCloud
//
//  Created by shisuping on 17/4/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "GOMEUserDefaults.h"
#import "UserDefaults.h"
#import "GOMEEmailUtilArc.h"
#import "LogUtil.h"

@implementation GOMEUserDefaults


#pragma mark ====国美邮箱服务===

#define GOME_SHOW_EAMIL_ACTIVE_FLAG @"emailactivate"
+ (void)saveGomeShowEmailActiveFlag{
    
    [[UserDefaults getUserDefaults]setValue:@"1" forKey:[NSString stringWithFormat:@"%@_%@",GOME_SHOW_EAMIL_ACTIVE_FLAG,[UserDefaults getUserAccount]]];
}

+ (NSString *)getGomeShowEmailActiveFlag{
    return [[UserDefaults getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",GOME_SHOW_EAMIL_ACTIVE_FLAG,[UserDefaults getUserAccount]]];
}
//邮箱账号和密码
#define GOME_EMAIL_ACCOUNT_KEY @"gomeEmailAccountKey"
#define GOME_EMAIL_PASSWORD_KEY @"gomeEmailPasswordKey"

+ (void)saveGOMEEmailAccount:(NSString *)account password:(NSString *)password
{
//    先加密，再保存
    NSString *tempStr = [[GOMEEmailUtilArc getEmailUtil]encryptEmailAccount:account];
    [[UserDefaults getUserDefaults] setObject:tempStr forKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_ACCOUNT_KEY,[UserDefaults getUserAccount]]];
    [LogUtil debug:[NSString stringWithFormat:@"%s account is %@ 加密后:%@",__FUNCTION__,account,tempStr]];

    
    tempStr = [[GOMEEmailUtilArc getEmailUtil]encryptEmailPassword:password];
    [[UserDefaults getUserDefaults] setObject:tempStr forKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_PASSWORD_KEY,[UserDefaults getUserAccount]]];
    [LogUtil debug:[NSString stringWithFormat:@"%s password is %@ 加密后:%@",__FUNCTION__,password,tempStr]];

}

+ (NSString *)getGOMEEmailAccount
{
//    先解密，再返回
    NSString *tempStr = [[UserDefaults getUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_ACCOUNT_KEY,[UserDefaults getUserAccount]]];
    [LogUtil debug:[NSString stringWithFormat:@"%s 账号密文是%@",__FUNCTION__,tempStr]];

    if (tempStr.length) {
        tempStr = [[GOMEEmailUtilArc getEmailUtil]decryptEmailAccount:tempStr];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 账号明文是%@",__FUNCTION__,tempStr]];
    NSArray *tempArray = [tempStr componentsSeparatedByString:@"@"];
    if (tempArray.count) {
        tempStr = tempArray[0];
    }
    
    return tempStr;
}

+ (NSString *)getGOMEEmailAddress{
    //    先解密，再返回
    NSString *tempStr = [[UserDefaults getUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_ACCOUNT_KEY,[UserDefaults getUserAccount]]];
    
    if (tempStr.length) {
        tempStr = [[GOMEEmailUtilArc getEmailUtil]decryptEmailAccount:tempStr];
    }
    
    return tempStr;
}


+ (NSString *)getGOMEEmailPassword
{
//    先解密，再返回
    NSString *tempStr = [[UserDefaults getUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_PASSWORD_KEY,[UserDefaults getUserAccount]]];
    [LogUtil debug:[NSString stringWithFormat:@"%s 密码密文是%@",__FUNCTION__,tempStr]];

    if (tempStr.length) {
        tempStr = [[GOMEEmailUtilArc getEmailUtil]decryptEmailPassword:tempStr];
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s 密码明文是%@",__FUNCTION__,tempStr]];

    return tempStr;
}

//邮箱登录状态
#define GOME_EMAIL_STATUS_KEY @"GOME_EMAIL_STATUS_KEY"

/** 保存邮箱登录状态 */
+ (void)saveGOMEEmailStatus:(NSString *)status
{
    [[UserDefaults getUserDefaults] setObject:status forKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_STATUS_KEY,[UserDefaults getUserAccount]]];
}

/** 获取邮箱登录状态 */
+ (NSString *)getGOMEEmailStatus
{
    return [[UserDefaults getUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",GOME_EMAIL_STATUS_KEY,[UserDefaults getUserAccount]]];
}

@end
