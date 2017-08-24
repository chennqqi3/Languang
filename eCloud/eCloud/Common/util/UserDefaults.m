

#import "UserDefaults.h"
#import "ServerConfig.h"
#import "StringUtil.h"
#import "eCloudUser.h"
#import "LogUtil.h"
#import "SSKeychain.h"
#import "EncryptFileManege.h"
#import <CommonCrypto/CommonDigest.h>
#import "conn.h"
#import "TimeUtil.h"
#import "eCloudDefine.h"
#import "eCloudDAO.h"
#import "JSONKit.h"

//登录账号和密码
#define user_account @"user_account"
#define user_password @"user_password"

#define SAVE_PASSWORD_KEY @"SAVE_PASSWORD_KEY"

#define last_user_account @"last_user_accout"
#define last_user_id @"last_user_id"

#define SERVICE @"QMENADAEMNDLKZJVOIUDFADFFD"


#define RANK_ARRAY_KEY @"RANK_ARRAY_KEY"

//新版本相关
#define new_app_version @"new_app_version"
#define new_version_url @"new_version_url"
#define new_version_flag @"new_version_flag"
#define new_version_tip_url @"new_version_tip_url"
//系统参数的值

//和获取状态相关

//移动客户端拉取状态超时时间：单位为分
#define sys_get_status_time_interval @"sys_get_status_time_interval"
//客户端状态拉取最大人数:  2字节，整数
#define sys_max_get_status_emp_number @"sys_max_get_status_emp_number"

////移动端登录后，获取状态时，上传的最近联系人，最大人数，2字节
#define sys_max_get_status_emp_number_in_contact_list @"sys_max_get_status_emp_number_in_contact_list"

//讨论组最大人数
#define sys_max_group_member @"sys_max_group_member"

//移动客户端文件最大发送大小 单位为M
#define sys_max_send_file_size @"sys_max_send_file_size"

//mobile客户端心跳包时间间隔：单位为秒，整数，2字节
#define sys_alive_time_interval @"sys_alive_time_interval"

//移动客户端接入服务地址有效时间：单位小时，1字节
#define sys_server_valid_time @"sys_server_valid_time"

//修改个人资料审核时间：1字节，小时
#define sys_modify_user_info_audit_period @"sys_modify_user_info_audit_period"

//公司id
#define comp_id @"comp_id"

//服务器和端口
#define last_conn_ip @"last_conn_ip"
#define last_conn_port @"last_conn_port"
#define last_conn_time @"last_conn_time"

#define fail_conn_ip @"fail_conn_ip"
#define fail_conn_port @"fail_conn_port"

#define overload_auto_connect_time @"overload_auto_connect_time"

#define device_Token @"device_Token"

//图片大小 文件大小
#define key_file_storage @"file_storage"
#define key_pic_storage @"pic_storage"

//app种类 appstore融合版  企业证书融合版  企业证书独立版
#define key_app_type @"app_type"

//快钱 有两台服务器 这里增加记录 当前正在使用的服务器 域名
#define key_current_server @"current_server"

// 通用背景图片的key
#define key_background_selected @"background_selected"


@implementation UserDefaults

+ (NSUserDefaults *)getUserDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

//保存字符串值
+ (void)setStringValueWithKey:(NSString *)keyStr andNewValue:(NSString *)valueStr
{
//    [LogUtil debug:[NSString stringWithFormat:@"%s,key is %@,value is %@",__FUNCTION__,keyStr,valueStr]];
    [[self getUserDefaults]setValue:valueStr forKey:keyStr];
}

//获取字符串
+ (NSString *)getStringValueForKey:(NSString *)keyStr
{
    return [[self getUserDefaults]valueForKey:keyStr];
}

//保存int
+ (void)setIntValueWithKey:(NSString *)keyStr andNewValue:(int)iValue
{
//    [LogUtil debug:[NSString stringWithFormat:@"%s,key is %@ value is %d",__FUNCTION__,keyStr,iValue]];
    [[self getUserDefaults]setValue:[StringUtil getStringValue:iValue] forKey:keyStr];
}

//获取int
+ (int)getIntValueForKey:(NSString *)keyStr
{
    return [[[self getUserDefaults]valueForKey:keyStr]intValue];
}

#pragma mark =======用户账号，密码==========

//+ (void)setUserAccount:(NSString *)userAccount
//{
//    [self setStringValueWithKey:user_account andNewValue:userAccount];
//}
//
//+ (void)setUserPassword:(NSString *)userPassword
//{
//    [self setStringValueWithKey:user_password andNewValue:userPassword];
//}

//- (NSData*)AES256EncryptWithKey:(NSString*)key;
//- (NSData*)AES256DecryptWithKey:(NSString*)key;

+ (NSString *)md5HexDigest:(NSString*)password
{
    const char *original_str = [password UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 14; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *mdfiveString = [hash lowercaseString];
    
    NSLog(@"Encryption Result = %@",mdfiveString);
    return mdfiveString;
}

+ (void)setPassword:(NSString *)password forAccount:(NSString *)_account
{
    NSString *account = [StringUtil trimString:_account];
    
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSArray *accouts = [SSKeychain accountsForService:SERVICE];
        if (accouts.count > 0)
        {
            NSDictionary *dic = [accouts lastObject];
            NSString *lastAccount = [dic objectForKey:@"acct"];
            [SSKeychain deletePasswordForService:SERVICE account:lastAccount];
        }
        
        NSString *accountMD5 = [UserDefaults md5HexDigest:account];
        NSString *accountPath = [NSString stringWithFormat:@"%@/%@",[StringUtil getHomeDir],accountMD5];
        NSString *passwordMD5 = [UserDefaults md5HexDigest:password];
        NSString *passwordPath = [NSString stringWithFormat:@"%@/%@",[StringUtil getHomeDir],passwordMD5];
        
        NSData *accountData = [account dataUsingEncoding:NSUTF8StringEncoding];
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        BOOL isAccountExist = [[NSFileManager defaultManager] fileExistsAtPath:accountPath];
        if (isAccountExist) {
            [[NSFileManager defaultManager] removeItemAtPath:accountPath error:nil];
        }
        [EncryptFileManege saveFileWithPath:accountPath withData:accountData];
        BOOL isPasswordExist = [[NSFileManager defaultManager] fileExistsAtPath:passwordPath];
        if (isPasswordExist) {
            [[NSFileManager defaultManager] removeItemAtPath:passwordPath error:nil];
        }
        [EncryptFileManege saveFileWithPath:passwordPath withData:passwordData];
        
        [SSKeychain setPassword:passwordMD5 forService:SERVICE account:accountMD5 error:nil];
    }
    else
    {
        [self setStringValueWithKey:user_account andNewValue:account];
        [self setStringValueWithKey:user_password andNewValue:password];
    }
}

+ (NSString *)getUserAccount
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSArray *accouts = [SSKeychain accountsForService:SERVICE];
        NSDictionary *dic = [accouts lastObject];
        NSString *accountMD5 = [dic objectForKey:@"acct"];
        NSString *path = [NSString stringWithFormat:@"%@/%@",[StringUtil getHomeDir],accountMD5];
//        NSLog(@"%s dic is %@",__FUNCTION__,[dic description]);
        
        NSData *password = [EncryptFileManege getDataWithPath:path];
        return  [[NSString alloc] initWithData:password encoding:NSUTF8StringEncoding];;
    }
    
    return [self getStringValueForKey:user_account];
}

//+ (NSString *)getUserAccountFromKeyChain
//{
//    NSArray *accouts = [SSKeychain accountsForService:SERVICE];
//    NSDictionary *dic = [accouts lastObject];
//    
//    return [dic objectForKey:@"acct"];
//}

+ (NSString *)getUserPassword
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        NSArray *accounts = [SSKeychain accountsForService:SERVICE];
        NSDictionary *dic = [accounts lastObject];
        NSString *account = [dic objectForKey:@"acct"];
        NSString *passwordMD5 = [SSKeychain passwordForService:SERVICE account:account];
        NSString *path = [NSString stringWithFormat:@"%@/%@",[StringUtil getHomeDir],passwordMD5];
        
//        NSLog(@"%s dic is %@",__FUNCTION__,[dic description]);
        NSData *password = [EncryptFileManege getDataWithPath:path];
        return  [[NSString alloc] initWithData:password encoding:NSUTF8StringEncoding];
    }
    return [self getStringValueForKey:user_password];
}

//+ (NSString *)getUserPasswordWithAccount:(NSString *)account
//{
//    return [SSKeychain passwordForService:SERVICE account:account];
//}

+ (void)setLastUserId:(NSString *)lastUserId
{
    [self setStringValueWithKey:last_user_id andNewValue:lastUserId];
}
+ (NSString *)getLastUserId
{
    return [self getStringValueForKey:last_user_id];
}

+ (void)setLastUserAccount:(NSString *)lastUserAccount
{
    [self setStringValueWithKey:last_user_account andNewValue:lastUserAccount];
}
+ (NSString *)getLastUserAccount
{
    return [self getStringValueForKey:last_user_account];
}

#pragma mark =======新版本相关==========
+ (void)setNewAppVersion:(NSString *)newAppVersion
{
    [self setStringValueWithKey:[NSString stringWithFormat:@"%@_%@",new_app_version,[UserDefaults getUserAccount]] andNewValue:newAppVersion];
}

+ (NSString *)getNewAppVersion
{
    NSString *newAppVersion = [self getStringValueForKey:[NSString stringWithFormat:@"%@_%@",new_app_version,[UserDefaults getUserAccount]]];
    if (newAppVersion.length > 0) {
        return newAppVersion;
    }
    eCloudUser *userDb = [eCloudUser getDatabase];
    return [userDb getVersion:app_version_type];
}

+ (void)setNewVersionUrl:(NSString *)newVersionUrl
{
    [self setStringValueWithKey:new_version_url andNewValue:newVersionUrl];
}

+ (NSString *)getNewVersionUrl
{
    return [self getStringValueForKey:new_version_url];
}

+ (void)setNewVersionTipUrl:(NSString *)newVersionTipUrl{
    
    [self setStringValueWithKey:new_version_tip_url andNewValue:newVersionTipUrl];
}

+ (NSString *)getNewVersionTipUrl{
    
    return [self getStringValueForKey:new_version_tip_url];
}
#pragma mark =======状态==========
//循环获取状态的时间间隔
+ (void)setGetStatusTimeInterval:(int)_minute
{
    if (_minute <= 0)
    {
        _minute = 3;
    }
    [self setIntValueWithKey:sys_get_status_time_interval andNewValue:_minute];
}

+ (int)getStatusTimeInterval
{
    return [self getIntValueForKey:sys_get_status_time_interval] * 60;
}

//获取状态的最大人数
+ (void)setMaxGetStatusEmpNumber:(int)_max
{
    [self setIntValueWithKey:sys_max_get_status_emp_number andNewValue:_max];
}

+ (int)getMaxGetStatusEmpNumber
{
    return [self getIntValueForKey:sys_max_get_status_emp_number];
}

//会话列表中单人状态获取的最大人数
+ (void)setMaxGetStatusEmpNumberInContactList:(int)_max
{
    [self setIntValueWithKey:sys_max_get_status_emp_number_in_contact_list andNewValue:_max];
}

+ (int)getMaxGetStatusEmpNumberInContactList
{
    return [self getIntValueForKey:sys_max_get_status_emp_number_in_contact_list];
}

#pragma mark ========其它系统参数 5 个参数 PC有关不处理===========
+ (void)setMaxGroupMember:(int)_max
{
    if (_max <= 0) {
        _max = default_group_member;
    }
    [self setIntValueWithKey:sys_max_group_member andNewValue:_max];
}
+ (int)getMaxGroupMember
{
    return [self getIntValueForKey:sys_max_group_member];
}

+ (void)setMaxSendFileSize:(int)_max
{
    [self setIntValueWithKey:sys_max_send_file_size andNewValue:_max];
}
+ (int)getMaxSendFileSize
{
    return [self getIntValueForKey:sys_max_send_file_size];
}

+ (void)setAliveInterval:(int)_second
{
    [LogUtil debug:[NSString stringWithFormat:@"登录返回的移动端心跳间隔是%ds",_second]];
    [self setIntValueWithKey:sys_alive_time_interval andNewValue:_second];
}
+ (int)getAliveInterval
{
    return [self getIntValueForKey:sys_alive_time_interval];
}

+ (void)setServerValidTime:(int)_hour
{
    [self setIntValueWithKey:sys_server_valid_time andNewValue:_hour];
}
+ (int)getServerValidTime
{
    return [self getIntValueForKey:sys_server_valid_time];
}

+ (void)setModifyUserInfoAuditPeriod:(int)_hour
{
    [self setIntValueWithKey:sys_modify_user_info_audit_period andNewValue:_hour];
}
+ (int)getModifiyUserInfoAuditPeriod
{
    return [self getIntValueForKey:sys_modify_user_info_audit_period];
}

#pragma mark ==========公司id============
+ (void)setCompId:(int)compId
{
    [self setIntValueWithKey:comp_id andNewValue:compId];
}

+ (int)getCompId
{
    return [self getIntValueForKey:comp_id];
}

#pragma mark ===========服务器和端口相关==============
+ (void)setLastConnIp:(NSString *)ip
{
    [self setStringValueWithKey:last_conn_ip andNewValue:ip];
}
+ (NSString *)getLastConnIp
{
    return [self getStringValueForKey:last_conn_ip];
}

+ (void)setLastConnPort:(int)port
{
    [self setIntValueWithKey:last_conn_port andNewValue:port];
}
+ (int)getLastConnPort
{
    return [self getIntValueForKey:last_conn_port];
}

+ (void)setLastConnTime:(int)_time
{
    [self setIntValueWithKey:last_conn_time andNewValue:_time];
}
+ (int)getLastConnTime
{
    return [self getIntValueForKey:last_conn_time];
}

+ (void)setFailConnIp:(NSString *)ip
{
    [self setStringValueWithKey:fail_conn_ip andNewValue:ip];
}
+ (NSString *)getFailConnIp
{
    return [self getStringValueForKey:fail_conn_ip];
}

+ (void)setFailConnPort:(int)port
{
    [self setIntValueWithKey:fail_conn_port andNewValue:port];
}
+ (int)getFailConnPort
{
    return [self getIntValueForKey:fail_conn_port];
}


#pragma mark ===========过载保护自动重连时间==============
+ (void)setOverloadAutoConnectTime:(int)second
{
    [self setIntValueWithKey:overload_auto_connect_time andNewValue:second];
}

- (int)getOverloadAutoConnectTime
{
    return [self getIntValueForKey:overload_auto_connect_time];
}

#pragma mark ===========device_token==============

+ (void)setDeviceToken:(NSString *)deviceToken
{
    [self setStringValueWithKey:device_Token andNewValue:deviceToken];
}

+ (NSString *)getDeviceToken
{
    return [self getStringValueForKey:device_Token];
}

#pragma mark ========存储空间 图片 文件==========
+ (void)setPicStorage:(NSNumber *)_picSize
{
//    NSLog(@"%s,%@",__FUNCTION__,[_picSize stringValue]);
    [[self getUserDefaults]setObject:_picSize forKey:key_pic_storage];
}
+ (NSNumber *)getPicStorage
{
    return [[self getUserDefaults]valueForKey:key_pic_storage];
}

+ (void)setFileStorage:(NSNumber *)_fileSize
{
//    NSLog(@"%s,%@",__FUNCTION__,[_fileSize stringValue]);
    [[self getUserDefaults]setValue:_fileSize forKey:key_file_storage];
}
+ (NSNumber *)getFileStorage
{
    return [[self getUserDefaults]valueForKey:key_file_storage];
}

+ (long long)getAllStorage
{
    NSNumber *picStorage = [self getPicStorage];
    NSNumber *fileStorage = [self getFileStorage];
    return [picStorage longLongValue] + [fileStorage longLongValue];
}

#pragma mark ======修改群组名称相关========

//如果用户在群组未创建的情况下修改了群组名称，则记录一个标志
+ (void)saveModifyGroupNameFlag:(NSString *)convId
{
    [[self getUserDefaults]setValue:[NSNumber numberWithInt:1] forKey:convId];
}

//判断用户是否在群组未创建的情况下修改了群组名称
+ (BOOL)isGroupNameModify:(NSString *)convId
{
    if (!convId) {
        return NO;
    }
    NSNumber *number = [[self getUserDefaults]valueForKey:convId];
    if (number)
    {
        return YES;
    }
    return NO;
}

//如果群组已经创建了则删除这个标志
+ (void)removeModifyGroupNameFlag:(NSString *)convId
{
    [[self getUserDefaults]removeObjectForKey:convId];
}

#pragma mark ========设置App Type===========
+ (void)setAppType:(NSString *)appType
{
    [[self getUserDefaults]setValue:appType forKey:key_app_type];
}

+ (NSString *)getAppType
{
    return [[self getUserDefaults]valueForKey:key_app_type];
}

#pragma mark ========设置 当前 正在使用的服务器===========

+ (void)setCurrentServer:(NSString *)currentServer
{
    [[self getUserDefaults]setValue:currentServer forKey:key_current_server];
}

+ (NSString *)getCurrentServer
{
    NSString *_currentServer = [[self getUserDefaults]valueForKey:key_current_server];
    if (_currentServer.length > 0)
    {
        return _currentServer;
    }
    return [[eCloudConfig getConfig]primaryServerUrl];
}

#pragma mark ========龙湖 保存 应用的未读计数===========

+ (int)getAppUnreadWithAppId:(int)appId
{
    NSString *_key = [NSString stringWithFormat:@"%@_%d_unread",[UserDefaults getUserAccount],appId];
    NSNumber *_number = (NSNumber *)[[self getUserDefaults] valueForKey:_key];
    if (!_number || _number.intValue < 0) {
        return 0;
    }
    return _number.intValue;
}

+ (void)saveAppUnreadWithAppId:(int)appId andUnread:(int)unread
{
    NSString *_key = [NSString stringWithFormat:@"%@_%d_unread",[UserDefaults getUserAccount],appId];
    [[self getUserDefaults] setValue:[NSNumber numberWithInt:unread] forKey:_key];
}

#pragma mark ========通用背景图===============
+ (void)setBackgroundSelected:(NSInteger)selectTag
{
    NSNumber *_number = [NSNumber numberWithInt:selectTag];
    [[self getUserDefaults]setValue:_number forKey:key_background_selected];
}
+ (NSInteger)getBackgroundSelected
{
    NSNumber *_number = [[self getUserDefaults]valueForKey:key_background_selected];
    if (!_number) {
        return -1;
    }
    
    return _number.integerValue;
}

#pragma mark ========会话背景图===============
+ (void)setConvBackgroundSelected:(NSString *)convId andSelectTag:(NSInteger)selectTag
{
    NSNumber *_number = [NSNumber numberWithInt:selectTag];
    [[self getUserDefaults]setValue:_number forKey:[NSString stringWithFormat:@"%@_of_%@",key_background_selected,convId]];
}
+ (NSInteger)getConvBackgroundSelected:(NSString *)convId
{
    NSNumber *number = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_of_%@",key_background_selected,convId]];
    if (!number) {
        return -1;
    }
    return number.integerValue;
}

#pragma mark ========在其它应用中查看某文件，可以在我们应用中打开 暂时保存在此处===============

#define KEY_URL_FROM_OTHER_APP @"url_from_other_app"

+ (void)saveUrlFromOtherApp:(NSURL *)url
{
    if (url)
    {
        [[self getUserDefaults]setValue:[url absoluteString] forKey:KEY_URL_FROM_OTHER_APP];
    }
    else
    {
        [[self getUserDefaults]removeObjectForKey:KEY_URL_FROM_OTHER_APP];
    }
}

+ (NSURL *)getUrlFromOtherApp
{
    NSString *strUrl = [[self getUserDefaults]objectForKey:KEY_URL_FROM_OTHER_APP];
    if (strUrl) {
        return [NSURL URLWithString:strUrl];
    }
    return nil;
}

#pragma mark =========保存用户是否是退出登录状态==============

#define KEY_USER_IS_EXIT @"isExit"

+ (BOOL)userIsExit
{
    id _value = [[self getUserDefaults]valueForKey:KEY_USER_IS_EXIT];
    if (!_value) {
//        如果这个还不存在，那就是还没有登录过
        return YES;
    }
    return [[self getUserDefaults]boolForKey:KEY_USER_IS_EXIT];
}

+ (void)saveUserIsExit:(BOOL)isExit
{
    [LogUtil debug:[NSString stringWithFormat:@"%s isExit is %@",__FUNCTION__,(isExit?@"YES":@"NO")]];
    [[self getUserDefaults]setBool:isExit forKey:KEY_USER_IS_EXIT];
}

#pragma mark=======保存主题推送的时间=======

#define KEY_SEND_TOPIC @"send_topic_of_"

+ (void)saveRobotTopicSendDate:(NSString *)topic
{
    NSString *_key = [NSString stringWithFormat:@"%@%@",KEY_SEND_TOPIC,topic];
   
    int _time = [[conn getConn]getCurrentTime];
    NSString *_value = [TimeUtil getDateOfTime:_time];
    
    [[self getUserDefaults]setValue:_value forKey:_key];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s _key is %@ _value is %@",__FUNCTION__,_key,_value]];
}

+ (NSString *)getRobotTopicSendDate:(NSString *)topic
{
    NSString *_key = [NSString stringWithFormat:@"%@%@",KEY_SEND_TOPIC,topic];
    NSString *_value = [[self getUserDefaults]valueForKey:_key];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s _key is %@ _value is %@",__FUNCTION__,_key,_value]];

    return _value;
}

//保存小万的userid
#define KEY_IROBOT_ID @"irobot_id"
+ (void)saveIRobotId:(int)robotId
{
    [[self getUserDefaults]setValue:[NSNumber numberWithInt:robotId] forKey:KEY_IROBOT_ID];
}

+ (int)getIRobotId
{
    NSNumber *_value = [[self getUserDefaults]valueForKey:KEY_IROBOT_ID];
    if (!_value) {
        return -1;
    }
    return _value.intValue;
}

//保存下载的引导页名称
#define KEY_GUIDE_IMAGE @"guide_image"
//+ (void)saveGuideImageName:(NSDictionary *)guideImageNameDict
//{
//    [[self getUserDefaults]setValue:guideImageNameDict forKey:KEY_GUIDE_IMAGE];
//}
//
//+ (NSDictionary *)getGuideImageName
//{
//    NSDictionary *_value = [[self getUserDefaults]valueForKey:KEY_GUIDE_IMAGE];
//    if (!_value) {
//        return nil;
//    }
//    return _value;
//}
+ (void)saveGuideImageName:(NSString *)guideImageName
{
    [[self getUserDefaults]setValue:guideImageName forKey:KEY_GUIDE_IMAGE];
}

+ (NSString *)getGuideImageName
{
    NSString *_value = [[self getUserDefaults]valueForKey:KEY_GUIDE_IMAGE];
    if (!_value) {
        return nil;
    }
    return _value;
}

//保存下载的引导页图片后缀
#define KEY_IMAGE_SUFFIX @"image_Suffix"
+ (void)saveGuideImagSuffix:(NSString *)guideImageSuffix
{
    [[self getUserDefaults]setValue:guideImageSuffix forKey:KEY_IMAGE_SUFFIX];
}

+ (NSString *)getGuideImageSuffix
{
    NSString *_value = [[self getUserDefaults]valueForKey:KEY_IMAGE_SUFFIX];
    if (!_value) {
        return nil;
    }
    return _value;
}

#pragma mark - 保存密码
#define KEY_ACCOUNT_INFO @"account_info"
+ (void)saveAccountInfo:(NSMutableDictionary *)accountInfoDic{
    [[self getUserDefaults]setObject:accountInfoDic forKey:KEY_ACCOUNT_INFO];
}

+ (NSMutableDictionary *)getAccountInfo{
    NSMutableDictionary *_value = [[self getUserDefaults]valueForKey:KEY_ACCOUNT_INFO];
    if (!_value) {
        return nil;
    }
    return _value;
}
#define KEY_ACCOUNT_SAVE_STATE @"account_save_state"
+ (void)saveSaveState:(NSNumber *)saveState{
    [[self getUserDefaults]setObject:saveState forKey:KEY_ACCOUNT_SAVE_STATE];
}
+ (NSNumber *)getSaveState{
    NSNumber *_value = [[self getUserDefaults]valueForKey:KEY_ACCOUNT_SAVE_STATE];
    if (!_value) {
        return nil;
    }
    return _value;
}
#pragma mark 给龙湖提供录音的接口 保存最近一次录音保存的文件路径
#define KEY_CURRENT_RECORD_NAME @"current_record_name"
+ (void)saveCurrentRecordName:(NSString *)recordName
{
    [[self getUserDefaults]setValue:recordName forKey:KEY_CURRENT_RECORD_NAME];
}

+ (NSString *)getCurrentRecordName
{
    return [[self getUserDefaults]valueForKey:KEY_CURRENT_RECORD_NAME];
}

#pragma mark 判断轻应用小红点
#define MARK_ID @"mark_id"
//
//+ (void)saveAppId:(NSMutableDictionary *)appId
//{
//    [[self getUserDefaults]setObject:appId forKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],MARK_ID]];
//}
//+ (NSMutableDictionary *)getAppId
//{
//    NSMutableDictionary *dict = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],MARK_ID]];
//    if (!dict) {
//        dict = [[NSMutableDictionary alloc]init];
//    }
//    return (NSMutableDictionary *)dict;
//}

//保存是否显示红点
+ (void)saveRedDotOfAppId:(int)appId andRedDot:(BOOL)value
{
    [[self getUserDefaults]setBool:value forKey:[NSString stringWithFormat:@"%@_%@_%d",[self getUserAccount],MARK_ID,appId]];
}
//获取是否显示红点
+ (BOOL)getRedDotOfAppId:(int)appId{
    BOOL _value = [[self getUserDefaults]boolForKey:[NSString stringWithFormat:@"%@_%@_%d",[self getUserAccount],MARK_ID,appId]];
    return _value;
}


#pragma mark 打开轻应用时传的token
#define KEY_LOGIN_TOKEN @"loginToken"

//保存token
+ (void)saveLoginToken:(NSString *)token
{
    if (token.length) {
        [[self getUserDefaults]setValue:token forKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],KEY_LOGIN_TOKEN]];
    }
}
//获取token
+ (NSString *)getLoginToken
{
    NSString *loginToken = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],KEY_LOGIN_TOKEN]];
    if (loginToken.length) {
        return loginToken;
    }
    return @"";
}

#pragma mark ========用户头像路径========
//记录本次取到的头像路径，便于下此未登录时，不能显示头像
#define key_user_logo_path @"user_logo_path"

+ (void)setUserLogoPath:(NSString *)userLogoPath andUserAccount:(NSString *)userAccount
{
    if (userLogoPath == nil) {
        userLogoPath = @"";
    }
    [[self getUserDefaults]setValue:userLogoPath forKey:[NSString stringWithFormat:@"%@_%@",key_user_logo_path,userAccount]];
}

+ (NSString *)getUserLogoPath:(NSString *)userAccount
{
    NSString *userLogoPath = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",key_user_logo_path,userAccount]];
    if (userLogoPath == nil) {
        userLogoPath = @"";
    }
    return userLogoPath;
}

#pragma mark ======用户真正的rankId========
#define KEY_CURRENT_USER_RANK @"current_user_rank"
+ (int)getCurrentUserRank
{
    NSNumber *rank = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",KEY_CURRENT_USER_RANK,[self getUserAccount]]];
    if (!rank) {
        return -1;
    }
    return [rank intValue];
}

+ (void)saveCUrrentUserRank:(int)rank
{
    [[self getUserDefaults]setValue:[NSNumber numberWithInt:rank] forKey:[NSString stringWithFormat:@"%@_%@",KEY_CURRENT_USER_RANK,[self getUserAccount]]];
}

#pragma mark ======工作圈是否需要刷新=======
#define KEY_IS_WORK_WORLD @"is_work_world"
+ (void)saveWorkWorldIsreload:(NSString *)isReload{
    
    if (isReload) {
        [[self getUserDefaults]setValue:isReload forKey:KEY_IS_WORK_WORLD];
    }
}

+ (NSString *)getWorkWorldIsreload{
    
    NSString *isRelad =  [[self getUserDefaults] objectForKey:KEY_IS_WORK_WORLD];
    if (isRelad.length) {
        
        return isRelad;
    }
    return @"";
}

#pragma mark =====南航获取待办未读数的url=======

#define KEY_GET_DAIBAN_UNREAD_URL @"getDaibanUnreadUrl"

+ (void)setDaibanUnreadRul:(NSString *)url
{
    if (!url || url.length == 0 ) {
        [LogUtil debug:[NSString stringWithFormat:@"%s url不合法"]];
        return;
    }
    [[self getUserDefaults]setValue:url forKey:[NSString stringWithFormat:@"%@",KEY_GET_DAIBAN_UNREAD_URL]];
}

+ (NSString *)getDaibanUnreadUrl
{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",KEY_GET_DAIBAN_UNREAD_URL]];
}

#pragma mark =====会话列表是否是编辑状态=======

#define KEY_GET_SESSION_IS_EDIT @"getSessionIsEdit"
+ (NSString *)getSessionIsEdit{
    
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",KEY_GET_SESSION_IS_EDIT]];
}

+ (void)setSessionIsEdit:(NSString *)isEdit{
    
    [[self getUserDefaults]setValue:isEdit forKey:[NSString stringWithFormat:@"%@",KEY_GET_SESSION_IS_EDIT]];
}

#pragma mark =====是否从外部启动龙信=======
#define KEY_GET_WHERE_START_FROM @"getWhereStartFrom"
+ (NSString *)getWhereStartFrom{
    
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",KEY_GET_WHERE_START_FROM]];
}
+ (void)setWhereStartFrom:(NSString *)whereFrom{
    
    [[self getUserDefaults]setValue:whereFrom forKey:[NSString stringWithFormat:@"%@",KEY_GET_WHERE_START_FROM]];
}

#pragma mark =====云盘token=======

+ (NSString *)getCloudFileToken{
    
    NSString *cloudFileToken = [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",[UserDefaults getUserAccount]]];
    if (cloudFileToken == nil) {
        cloudFileToken = @"";
    }
    return cloudFileToken;
}
+ (void)setCloudFileToken:(NSString *)cloudFileToken{
    
    [[self getUserDefaults]setValue:cloudFileToken forKey:[NSString stringWithFormat:@"%@",[UserDefaults getUserAccount]]];
}

#pragma mark =====龙湖广告页是否显示=======
#define KEY_GET_GUIDE_IMAGE_STATUS @"getGuideImageStatus"
+ (NSString *)getGuideImageStatus{
    
    NSString *status =  [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",KEY_GET_GUIDE_IMAGE_STATUS]];
    
    return status;
}
+ (void)setGuideImageStatus:(NSString *)guideImageStatus{
    
    [[self getUserDefaults]setValue:guideImageStatus forKey:[NSString stringWithFormat:@"%@",KEY_GET_GUIDE_IMAGE_STATUS]];
    [[self getUserDefaults]synchronize];
}

#pragma mark ======国美要求的参数=======

#define GOME_TOKEN_KEY @"accesstoken"
#define GOME_EMP_ID_KEY @"employeeId"
#define GOME_EMP_NAME_KEY @"employeeName"

+ (NSString *)getGOMEToken{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",GOME_TOKEN_KEY]];
}
+ (void)saveGOMEToken:(NSString *)token{
    [[self getUserDefaults]setValue:token forKey:[NSString stringWithFormat:@"%@",GOME_TOKEN_KEY]];
}

+ (NSString *)getGOMEEmpId{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",GOME_EMP_ID_KEY]];
}
+ (void)saveGOMEEmpId:(NSString *)empId{
    [[self getUserDefaults]setValue:empId forKey:[NSString stringWithFormat:@"%@",GOME_EMP_ID_KEY]];
}

+ (NSString *)getGOMEEmpName{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",GOME_EMP_NAME_KEY]];
}
+ (void)saveGOMEEmpName:(NSString *)empName{
    [[self getUserDefaults]setValue:empName forKey:[NSString stringWithFormat:@"%@",GOME_EMP_NAME_KEY]];
}

#pragma mark =======国美banner图片轮播相关========
#define GOME_APP_BANNER_KEY @"gomeAppBanner"
#define GOME_APP_BANNER_INTERVAL_KEY @"gomeAppBannerInterval"

+ (NSArray *)getGomeAppBanner{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",GOME_APP_BANNER_KEY]];
}
+ (void)saveGomeAppBanner:(NSArray *)appBannerArray{
    [[self getUserDefaults]setValue:appBannerArray forKey:[NSString stringWithFormat:@"%@",GOME_APP_BANNER_KEY]];
}

+ (NSNumber *)getGomeAppBannerInterval{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@",GOME_APP_BANNER_INTERVAL_KEY]];
    
}
+ (void)saveGomeAppBannerInterval:(NSNumber *)appBannerInterval{
    [[self getUserDefaults]setValue:appBannerInterval forKey:[NSString stringWithFormat:@"%@",GOME_APP_BANNER_INTERVAL_KEY]];
}

#pragma mark =====国美邮件服务======
#define GOME_MAIL_UNREAD_RESULT_KEY @"GOME_MAIL_UNREAD_RESULT"
+ (void)saveGomeMailUnreadResult:(NSString *)resultStr{
    [[self getUserDefaults]setValue:resultStr forKey:[NSString stringWithFormat:@"%@_%@",GOME_MAIL_UNREAD_RESULT_KEY,[self getUserAccount]]];

}
+ (NSString *)getGomeMailUnreadResult
{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",GOME_MAIL_UNREAD_RESULT_KEY,[self getUserAccount]]];
}

#pragma mark =====泰禾App Token======
#define TAIHE_APP_TOKEN_KEY @"TaiHeAppToken"
+ (void)saveTaiHeAppToken:(NSString *)_token{
    if (_token.length) {
        [[self getUserDefaults] setValue:_token forKey:TAIHE_APP_TOKEN_KEY];
    }
}
+ (NSString *)getTaiHeAppToken{
    NSString *_token = [[self getUserDefaults] valueForKey:TAIHE_APP_TOKEN_KEY];
    if (_token.length) {
        return _token;
    }
    return @"";
}


#pragma mark =====泰禾App 广告页url======
#define TAIHE_APP_GUIDE_IMAGE_URL_KEY @"taiHeAppGuideImageUrl"

+ (void)saveTaiHeAppGuideImageUrl:(id)arr{
    
    [[self getUserDefaults] setValue:arr forKey:TAIHE_APP_GUIDE_IMAGE_URL_KEY];
}

+ (id)getTaiHeAppGuideImageUrl{
    
    return [[self getUserDefaults]valueForKey:TAIHE_APP_GUIDE_IMAGE_URL_KEY];
}

#pragma mark =====泰禾App 邮件未读数======
#define TAIHE_APP_UN_READ_EMAIL @"taiHeAppUnReadEmail"
+ (void)saveTaiHeAppUnReadEmail:(int)unReadEmail{
    
    [self setIntValueWithKey:TAIHE_APP_UN_READ_EMAIL andNewValue:unReadEmail];
}

+ (int)getTaiHeAppUnReadEmail{
    
    return [self getIntValueForKey:TAIHE_APP_UN_READ_EMAIL];
}

#pragma mark =====泰禾App 待办未读数======
#define TAIHE_APP_UN_READ_DIABAN @"taiHeAppUnReadDaiban"
+ (void)saveTaiHeAppUnReadDaiban:(int)unReadDaiban{

//    [self setIntValueWithKey:TAIHE_APP_UN_READ_DIABAN andNewValue:unReadDaiban];
    [[self getUserDefaults]setObject:[NSString stringWithFormat:@"%d",unReadDaiban] forKey:[NSString stringWithFormat:@"%@_%@",TAIHE_APP_UN_READ_DIABAN,[self getUserAccount]]];
}

+ (int)getTaiHeAppUnReadDaiban{
    
    int count = [[[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",TAIHE_APP_UN_READ_DIABAN,[self getUserAccount]]] intValue];
    
//    return [self getIntValueForKey:TAIHE_APP_UN_READ_DIABAN];
    return count;
}

#pragma mark =====泰禾App 登录页面广告json======
#define TAIHE_APP_LOGIN_JSON_STRING @"taiHeAppLoginJsonString"
+ (void)saveTaiHeAppLoginJsonString:(id)jsonString{
    
    [[self getUserDefaults] setValue:jsonString forKey:TAIHE_APP_LOGIN_JSON_STRING];
}

+ (id)getTaiHeAppLoginJsonString{
    
    return [[self getUserDefaults]valueForKey:TAIHE_APP_LOGIN_JSON_STRING];
}

#define md5_password @"wanxin@`!321^&*"

+ (void)saveRankArray
{
    dispatch_queue_t queue = dispatch_queue_create("get user rank ", NULL);
    dispatch_async(queue, ^{
        Emp *emp = [conn getConn].curUser;
        /** 获取能看的级别范围，不需要传自己的rankid了，只需要用户id即可 */
//        int rankId = [[eCloudDAO getDatabase] getRankIdWithUserId:emp.emp_id];
//        [LogUtil debug:[NSString stringWithFormat:@"%s 登录用户%@的rankid is %d",__FUNCTION__,emp.emp_name,rankId]];
//        
//        if (rankId) {
            NSString *curTime = [[conn getConn] getSCurrentTime];
            NSString *empID = [NSString stringWithFormat:@"%d",emp.emp_id];
            NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",empID,curTime,md5_password]];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@//%@:%d/FilesService/getUserLevel?userid=%@&t=%@&mdkey=%@",[[ServerConfig shareServerConfig] getProtocol],[[ServerConfig shareServerConfig] getFileServer],[ServerConfig shareServerConfig].fileServerPort,empID,curTime,md5Str];
            
            NSURL *url = [NSURL URLWithString:urlStr];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            
            
            NSDictionary *dic = [data objectFromJSONData];
            
            NSArray *arr = dic[@"data"];
            
//            if (!arr || arr.count == 0) {
//                //            如果服务器没有返回，则保存为当前用户自己的级别
//                arr = [NSArray arrayWithObject:[NSNumber numberWithInt:rankId]];
//            }else{
//                NSMutableArray *mArray = [NSMutableArray arrayWithArray:arr];
//                [mArray addObject:[NSNumber numberWithInt:rankId]];
//                arr = [NSArray arrayWithArray:mArray];
////            }
        
            [LogUtil debug:[NSString stringWithFormat:@"%s 登录用户%@ 可以看的权限是%@ 具体是%@",__FUNCTION__,emp.emp_name,dic,arr]];

            [[self getUserDefaults] setValue:arr forKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],RANK_ARRAY_KEY]];
//        }
        
    });
    dispatch_release(queue);

}

+ (NSArray *)getRankArray
{
    return [[self getUserDefaults]valueForKey:[NSString stringWithFormat:@"%@_%@",[self getUserAccount],RANK_ARRAY_KEY]];
}

+ (void)saveIsSavePassword:(BOOL)isSave
{
    [[self getUserDefaults] setBool:isSave forKey:SAVE_PASSWORD_KEY];
}

+ (BOOL)getIsSavePassword
{
    return [[self getUserDefaults] boolForKey:SAVE_PASSWORD_KEY];
}

//蓝光待办id
#define KEY_LAN_GUANG_DAIBAN_ID @"LAN_GUANG_DAIBAN_ID"
+ (int)getLanGuangDaiBanId{
    return [[[self getUserDefaults] valueForKey:KEY_LAN_GUANG_DAIBAN_ID]intValue];
}

+ (void)setLanGuangDaiBanId:(int)daibanId{
    [[self getUserDefaults] setValue:[NSNumber numberWithInt:daibanId] forKey:KEY_LAN_GUANG_DAIBAN_ID];
}



+ (NSDictionary *)getLanGuangMeetingSign:(NSString *)access{
    
    NSDictionary *dict = [[self getUserDefaults]valueForKey:access];
    
    return dict;
}

+ (void)setLanGuangMeetingSign:(NSString *)access dict:(NSDictionary *)dict;{
    
    [[self getUserDefaults] setValue:dict forKey:access];
}

/** 修改头像权限 0为启动，1为禁用*/
#define KEY_LAN_GUANG_HEAD_ALBUM @"LAN_GUANG_HEAD_ALBUM"
+ (BOOL)getLanGuangModifyHead{
    
    NSNumber *album = [[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_HEAD_ALBUM,[self getUserAccount]]];
    if (album.intValue == 0) {
        return YES;
    }
    return NO;

}


+ (void)setLanGuangModifyHead:(NSNumber *)album{
    
    [[self getUserDefaults]setObject:album forKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_HEAD_ALBUM,[self getUserAccount]]];
}


/** 密聊权限 0为启动，1为禁用*/
#define KEY_LAN_GUANG_SECRET @"LAN_GUANG_SECRET"
+ (BOOL)getLanGuangSecret{
    
     NSNumber *secret = [[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_SECRET,[self getUserAccount]]];
    if ([secret intValue] == 0) {
        return YES;
    }
    return NO;
    
}

+ (void)setLanGuangSecret:(NSNumber *)secret{
    
    [[self getUserDefaults]setObject:secret forKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_SECRET,[self getUserAccount]]];
}

/** 蓝光消息撤回时间 */
#define KEY_LAN_GUANG_RECALL_TIME @"LAN_GUANG_RECALL_TIME"
+ (NSNumber *)getLanGuangRecallTime{
    
    NSNumber *time = [[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_RECALL_TIME,[self getUserAccount]]];
    
    return time;
}

+ (void)setLanGuangRecallTime:(NSNumber *)RecallTime{
    
    [[self getUserDefaults]setObject:RecallTime forKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_RECALL_TIME,[self getUserAccount]]];
}

/** 常用信息 */
#define KEY_LAN_GUANG_COMMON_MSG @"LAN_GUANG_COMMON_MSG"
+ (NSMutableArray *)getLGCommonMsg{
    
    return [[self getUserDefaults] valueForKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_COMMON_MSG,[self getUserAccount]]];;
}

+ (void)setLGCommonMsg:(NSMutableArray *)arr{
    
    [[self getUserDefaults] setValue:arr forKey:[NSString stringWithFormat:@"%@_%@",KEY_LAN_GUANG_COMMON_MSG,[self getUserAccount]]];
}

/** 祥源oatoken */
#define XIANGYUAN_APP_TOKEN_KEY @"XiangYuanAppToken"
+ (void)setXIANGYUANAppToken:(NSString *)_token{
    
    [[self getUserDefaults] setValue:_token forKey:XIANGYUAN_APP_TOKEN_KEY];
}

+ (NSString *)getXIANGYUANAppToken{
    
    NSString *_token = [[self getUserDefaults] valueForKey:XIANGYUAN_APP_TOKEN_KEY];
    if (_token.length) {
        return _token;
    }
    return @"";
}

/** 祥源待办 */
#define XIANGYUAN_APP_DAIBAN @"XiangYuanAppDAIBAN"
+ (void)setXIANGYUANAppDAIBAN:(NSNumber *)count{
    
    [[self getUserDefaults]setObject:count forKey:[NSString stringWithFormat:@"%@_%@",XIANGYUAN_APP_DAIBAN,[self getUserAccount]]];
}

+ (NSNumber *)getXIANGYUANAppDAIBAN{
    
    NSNumber *count = [[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",XIANGYUAN_APP_DAIBAN,[self getUserAccount]]];
    
    return count;
}

/** 祥源未读数时间戳 */
#define XIANGYUAN_APP_DAIBAN_TIME_STAMP @"XiangYuanAppDAIBANTimeStamp"
+ (void)setXIANGYUANAppDAIBANTimeStamp:(NSNumber *)time{
    
    [[self getUserDefaults]setObject:time forKey:[NSString stringWithFormat:@"%@_%@",XIANGYUAN_APP_DAIBAN_TIME_STAMP,[self getUserAccount]]];
}

+ (NSNumber *)getXIANGYUANAppDAIBANTimeStamp{
    
    NSNumber *time = [[self getUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",XIANGYUAN_APP_DAIBAN_TIME_STAMP,[self getUserAccount]]];
    
    return time;
}

/** 蓝信小秘书提示语相关处理 -----LANGUANG--------*/
#define KEY_USER_EXIST @"KEY_USER_EXIST"
+ (void)saveExistStatus:(BOOL)isExist
{
    [[self getUserDefaults]setBool:isExist forKey:KEY_USER_EXIST];
}

+ (BOOL)getExistStatus
{
    BOOL isDidSave = [[self getUserDefaults]boolForKey:KEY_USER_EXIST];
    return isDidSave;
}

#define KEY_DIDLOGIN_USER_ARR @"KEY_DIDLOGIN_USER_ARR"
+ (void)saveDidLoginUserWithArr:(NSMutableArray *)userArr
{
    [[self getUserDefaults]setObject:userArr forKey:KEY_DIDLOGIN_USER_ARR];
}

+ (NSMutableArray *)getDidLoginUserWithArr
{
    NSMutableArray *userArr = [NSMutableArray arrayWithArray:[[self getUserDefaults]valueForKey:KEY_DIDLOGIN_USER_ARR]];

    return userArr;
}
@end
