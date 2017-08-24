//定义保存在NSUserDefaults中的参数

#import <Foundation/Foundation.h>

#ifdef _GOME_FLAG_
#import "GOMEUserDefaults.h"
#endif

@interface UserDefaults : NSObject

#pragma mark =======用户账号，密码==========

/**
 获取NSUserDefaults对象

 @return NSUserDefaults单例
 */
+ (NSUserDefaults *)getUserDefaults;


/**
 保存字符串类型的数据

 @param keyStr 键值
 @param valueStr 字符串类型数据
 */
+ (void)setStringValueWithKey:(NSString *)keyStr andNewValue:(NSString *)valueStr;


/**
 获取字符串类型的数据

 @param keyStr 键值
 @return 字符串类型的数据
 */
+ (NSString *)getStringValueForKey:(NSString *)keyStr;

//保存int

/**
 保存int类型的数据

 @param keyStr 键值
 @param iValue int类型数据
 */
+ (void)setIntValueWithKey:(NSString *)keyStr andNewValue:(int)iValue;


/**
 获取int类型数据

 @param keyStr 键值
 @return int类型数据
 */
+ (int)getIntValueForKey:(NSString *)keyStr;

//获取用户账号
+ (NSString *)getUserAccount;

//获取用户密码
+ (NSString *)getUserPassword;

//用户登录成功后，登录应答里带了用户的empId，保存此id
+ (void)setLastUserId:(NSString *)lastUserId;

//获取上一次登录的用户的id (通过判断确定是否更换了用户)
+ (NSString *)getLastUserId;

//登录成功后，保存当前登录用户的账号
+ (void)setLastUserAccount:(NSString *)lastUserAccount;

//获取上次登录成功的账号 (登录界面默认填充)
+ (NSString *)getLastUserAccount;

//保存用户的账号和密码
+ (void)setPassword:(NSString *)password forAccount:(NSString *)account;

#pragma mark =======新版本相关==========

//如果有可选的更新 那么保存这个最新的版本
+ (void)setNewAppVersion:(NSString *)newAppVersion;

//获取本地保存的可选更新的最新版本
+ (NSString *)getNewAppVersion;

//如果有可选更新，那么保存更新url
+ (void)setNewVersionUrl:(NSString *)newVersionUrl;

//获取可选更新的url 当用户想升级的时候，使用这个url完成更新
+ (NSString *)getNewVersionUrl;

//保存新版本说明 url
+ (void)setNewVersionTipUrl:(NSString *)newVersionTipUrl;

//获取新版本说明 url
+ (NSString *)getNewVersionTipUrl;

#pragma mark =======状态 3个参数==========

//保存获取状态的时间间隔
+ (void)setGetStatusTimeInterval:(int)_minute;

//获取状态的时间间隔
+ (int)getStatusTimeInterval;

//保存获取状态时最大的人员数量
+ (void)setMaxGetStatusEmpNumber:(int)_max;

//获取状态时最大的人员数量
+ (int)getMaxGetStatusEmpNumber;

//保存获取 会话列表里 单人聊天的 人员的状态 最大个数
+ (void)setMaxGetStatusEmpNumberInContactList:(int)_max;
//会话列表里 单人聊天的 人员的状态 最大个数
+ (int)getMaxGetStatusEmpNumberInContactList;

#pragma mark ========其它系统参数 5 个参数 PC有关不处理===========

//保存创建讨论组的成员最大个数
+ (void)setMaxGroupMember:(int)_max;

//创建讨论组的成员最大个数
+ (int)getMaxGroupMember;

//保存移动端发送文件的最大size
+ (void)setMaxSendFileSize:(int)_max;

//移动端发送文件的最大size
+ (int)getMaxSendFileSize;

//保存心跳间隔
+ (void)setAliveInterval:(int)_second;
//心跳间隔
+ (int)getAliveInterval;

//服务器有效时间 deprecated
+ (void)setServerValidTime:(int)_hour;
+ (int)getServerValidTime;

//修改用户资料后审核期限 deprecated
+ (void)setModifyUserInfoAuditPeriod:(int)_hour;
+ (int)getModifiyUserInfoAuditPeriod;

#pragma mark ==========公司id============
+ (void)setCompId:(int)compId;
+ (int)getCompId;


#pragma mark ===========服务器和端口相关==============

//上次连接的im服务器 deprecated 现在每次都通过连接接入服务器分配im服务器
+ (void)setLastConnIp:(NSString *)ip;
+ (NSString *)getLastConnIp;

//上次连接的服务器端口 deprecated
+ (void)setLastConnPort:(int)port;
+ (int)getLastConnPort;

//上次连接的服务器时间 deprecated
+ (void)setLastConnTime:(int)_time;
+ (int)getLastConnTime;

//连接失败的服务器 deprecated
+ (void)setFailConnIp:(NSString *)ip;
+ (NSString *)getFailConnIp;

//连接失败的端口 deprecated
+ (void)setFailConnPort:(int)port;
+ (int)getFailConnPort;

#pragma mark ===========过载保护自动重连时间 deprcated==============
+ (void)setOverloadAutoConnectTime:(int)second;

+ (int)getOverloadAutoConnectTime;

#pragma mark ===========device_token 设备token 用于推送==============

+ (void)setDeviceToken:(NSString *)deviceToken;

+ (NSString *)getDeviceToken;

#pragma mark ========存储空间 图片 文件 保存在本地的图片或者文件的合计大小 当目录有变化时，就会自动计算==========
+ (void)setPicStorage:(NSNumber *)_picSize;
+ (NSNumber *)getPicStorage;

+ (void)setFileStorage:(NSNumber *)_fileSize;
+ (NSNumber *)getFileStorage;

+ (long long)getAllStorage;

#pragma mark ======修改群组名称相关========

//如果用户在群组未创建的情况下修改了群组名称，则记录一个标志
+ (void)saveModifyGroupNameFlag:(NSString *)convId;

//判断用户是否在群组未创建的情况下修改了群组名称
+ (BOOL)isGroupNameModify:(NSString *)convId;

//如果群组已经创建了则删除这个标志
+ (void)removeModifyGroupNameFlag:(NSString *)convId;


#pragma mark ========设置App Type ===========
//请参考OpenCtxDefine.h里的定义 combine_enterprise_type independent_enterprise_type
+ (void)setAppType:(NSString *)appType;

+ (NSString *)getAppType;

#pragma mark ========设置 当前 正在使用的服务器===========

+ (void)setCurrentServer:(NSString *)currentServer;

+ (NSString *)getCurrentServer;


#pragma mark ========龙湖 保存 应用的未读计数===========

/*
 获取某个应用的未读数
 
 appId:和应用对应的appId
 */
+ (int)getAppUnreadWithAppId:(int)appId;

/*
 保存某个应用的未读数
 
 appId:应用id
 unread:对应应用的未读数
 */
+ (void)saveAppUnreadWithAppId:(int)appId andUnread:(int)unread;

#pragma mark ========通用背景图===============
//设置聊天背景相关 系统提供了几种默认的背景图片，如果没有设置过 selectTag是-1
+ (void)setBackgroundSelected:(NSInteger)selectTag;
+ (NSInteger)getBackgroundSelected;

#pragma mark ========会话背景图===============
//设置某个会话的聊天背景图片
+ (void)setConvBackgroundSelected:(NSString *)convId andSelectTag:(NSInteger)selectTag;
+ (NSInteger)getConvBackgroundSelected:(NSString *)convId;


#pragma mark ========在其它应用中查看某文件，可以在我们应用中打开 暂时保存在此处===============
+ (void)saveUrlFromOtherApp:(NSURL *)url;

+ (NSURL *)getUrlFromOtherApp;

#pragma mark =========保存用户是否是退出登录状态==============

+ (BOOL)userIsExit;
+ (void)saveUserIsExit:(BOOL)isExit;

#pragma mark=======保存主题推送的时间=======
//deprecated
+ (void)saveRobotTopicSendDate:(NSString *)topic;
+ (NSString *)getRobotTopicSendDate:(NSString *)topic;

//问答机器人的id
+ (void)saveIRobotId:(int)robotId;
+ (int)getIRobotId;

//保存下载的引导页名称
//+ (void)saveGuideImageName:(NSDictionary *)guideImageNameDict;
//+ (NSDictionary *)getGuideImageName;

+ (void)saveGuideImageName:(NSString *)guideImageName;
+ (NSString *)getGuideImageName;

//保存下载的引导页图片后缀
+ (void)saveGuideImagSuffix:(NSString *)guideImageSuffix;
+ (NSString *)getGuideImageSuffix;

#pragma mark - 保存密码
+ (void)saveAccountInfo:(NSMutableDictionary *)accountInfoDic;
+ (NSMutableDictionary *)getAccountInfo;
+ (NSString *)md5HexDigest:(NSString*)password;

#pragma mark - 是否保存密码的状态
+ (void)saveSaveState:(NSNumber *)saveState;
+ (NSNumber *)getSaveState;

#pragma mark 给龙湖提供录音的接口 保存最近一次录音保存的文件路径
+ (void)saveCurrentRecordName:(NSString *)recordName;
+ (NSString *)getCurrentRecordName;

#pragma mark 判断轻应用小红点 有些应用是显示未读数字，有些则只是显示红点
//
//+ (void)saveAppId:(NSMutableDictionary *)appId;
//+ (NSMutableDictionary *)getAppId;

+ (void)saveRedDotOfAppId:(int)appId andRedDot:(BOOL)value;
+ (BOOL)getRedDotOfAppId:(int)appId;

//获取token 用于单点登录
+ (NSString *)getLoginToken;
//保存token
+ (void)saveLoginToken:(NSString *)token;

#pragma mark ========用户头像路径========

+ (void)setUserLogoPath:(NSString *)userLogoPath andUserAccount:(NSString *)userAccount;

+ (NSString *)getUserLogoPath:(NSString *)userAccount;

#pragma mark ======用户真正的rankId========
+ (int)getCurrentUserRank;
+ (void)saveCUrrentUserRank:(int)rank;


#pragma mark ======工作圈是否需要刷新=======
+ (void)saveWorkWorldIsreload:(NSString *)isReload;
+ (NSString *)getWorkWorldIsreload;

#pragma mark =====南航获取待办未读数的url=======
+ (NSString *)getDaibanUnreadUrl;
+ (void)setDaibanUnreadRul:(NSString *)url;

#pragma mark =====会话列表是否是编辑状态=======

+ (NSString *)getSessionIsEdit;
+ (void)setSessionIsEdit:(NSString *)isEdit;

#pragma mark =====是否从外部启动龙信=======
//在其它应用里查看的文件，可以保存到龙信云盘功能
+ (NSString *)getWhereStartFrom;
+ (void)setWhereStartFrom:(NSString *)whereFrom;

#pragma mark =====云盘token=======

+ (NSString *)getCloudFileToken;
+ (void)setCloudFileToken:(NSString *)cloudFileToken;

#pragma mark =====龙湖广告页是否显示=======

+ (NSString *)getGuideImageStatus;
+ (void)setGuideImageStatus:(NSString *)guideImageStatus;

#pragma mark ======国美要求的参数=======

+ (NSString *)getGOMEToken;
+ (void)saveGOMEToken:(NSString *)token;

+ (NSString *)getGOMEEmpId;
+ (void)saveGOMEEmpId:(NSString *)empId;

+ (NSString *)getGOMEEmpName;
+ (void)saveGOMEEmpName:(NSString *)empName;

#pragma mark =======国美banner图片轮播相关========
+ (NSArray *)getGomeAppBanner;
+ (void)saveGomeAppBanner:(NSArray *)appBannerArray;

+ (NSNumber *)getGomeAppBannerInterval;
+ (void)saveGomeAppBannerInterval:(NSNumber *)appBannerInterval;

#pragma mark =====国美邮件服务======

/**
 保存国美获取邮件未读数的结果

 @param resultStr
 */
+ (void)saveGomeMailUnreadResult:(NSString *)resultStr;

/**
 获取上次保存的获取邮件未读数的结果

 @return
 */
+ (NSString *)getGomeMailUnreadResult;

#pragma mark =====泰禾App Token======
+ (void)saveTaiHeAppToken:(NSString *)_token;
+ (NSString *)getTaiHeAppToken;


/**
 功能描述
 泰禾首页链接保存本地
 
 参数 arr url图片数组
 */
+ (void)saveTaiHeAppGuideImageUrl:(id)arr;

/**
 功能描述
 取出保存在本地广告页url
 
 参数 url数组
 */
+ (id)getTaiHeAppGuideImageUrl;

/**
 功能描述
 保存邮件未读数
 
 参数 unReadEmail 邮件未读数
 */
+ (void)saveTaiHeAppUnReadEmail:(int)unReadEmail;

/**
 功能描述
 取出邮件未读数
 
 返回值 邮件未读数
 */
+ (int)getTaiHeAppUnReadEmail;

/**
 功能描述
 保存待办未读数
 
 参数 unReadEmail 待办未读数
 */
+ (void)saveTaiHeAppUnReadDaiban:(int)unReadDaiban;

/**
 功能描述
 取出待办未读数
 
 返回值 待办未读数
 */
+ (int)getTaiHeAppUnReadDaiban;

/**
 功能描述
 保存登录页面广告json
 
 参数 jsonString 登录页面接口返回的json
 */
+ (void)saveTaiHeAppLoginJsonString:(id)jsonString;

/**
 功能描述
 取出登录页面广告json
 
 返回值 json格式的字符串
 */
+ (id)getTaiHeAppLoginJsonString;


/** 获取并保存自己能查看电话的人的rank */
+ (void)saveRankArray;

/** 获取自己能查看电话的人的rank */
+ (NSArray *)getRankArray;

/** 保存是否保存密码 */
+ (void)saveIsSavePassword:(BOOL)isSave;

/** 获取是否保存密码 */
+ (BOOL)getIsSavePassword;

/** 蓝光待办id */
+ (int)getLanGuangDaiBanId;

+ (void)setLanGuangDaiBanId:(int)daibanId;


/** 蓝光会议是签到还是签退 */
+ (NSDictionary *)getLanGuangMeetingSign:(NSString *)access;

+ (void)setLanGuangMeetingSign:(NSString *)access dict:(NSDictionary *)dict;

/** 蓝光是否有修改头像权限 */
+ (BOOL)getLanGuangModifyHead;

+ (void)setLanGuangModifyHead:(NSNumber *)album;

/** 蓝光是否有密聊权限 */
+ (BOOL)getLanGuangSecret;

+ (void)setLanGuangSecret:(NSNumber *)secret;

/** 蓝光消息撤回时间 */
+ (NSNumber *)getLanGuangRecallTime;

+ (void)setLanGuangRecallTime:(NSNumber *)RecallTime;

/** 常用信息 */
+ (NSMutableArray *)getLGCommonMsg;

+ (void)setLGCommonMsg:(NSMutableArray *)dict;

/** 祥源oatoken */
+ (void)setXIANGYUANAppToken:(NSString *)_token;

+ (NSString *)getXIANGYUANAppToken;

/** 祥源待办未读数 */
+ (void)setXIANGYUANAppDAIBAN:(NSNumber *)count;

+ (NSNumber *)getXIANGYUANAppDAIBAN;

/** 祥源未读数时间戳 */
+ (void)setXIANGYUANAppDAIBANTimeStamp:(NSNumber *)time;

+ (NSNumber *)getXIANGYUANAppDAIBANTimeStamp;

/** 蓝信小秘书提示语相关处理 -----LANGUANG--------*/
+ (void)saveExistStatus:(BOOL)isExist;

+ (BOOL)getExistStatus;

// 处理过的账号数组
+ (void)saveDidLoginUserWithArr:(NSMutableArray *)userArr;

+ (NSMutableArray *)getDidLoginUserWithArr;
@end
