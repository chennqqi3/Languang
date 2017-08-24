// add by shisp 和服务器建立连接的类

#import <Foundation/Foundation.h>

//升级标志定义
typedef enum
{
    /** 没有更新 */
    update_flag_no_update = 0,
    
    /** 强制更新 */
    update_flag_must_update = 1,
    
    /** 可选更新 */
    update_flag_option_update = 3
}update_flag;

@interface AccessConn : NSObject

/** 连接服务器是返回的错误码 */
@property (nonatomic,assign) int errCode;

/** 连接服务器返回的错误信息 */
@property (nonatomic,retain) NSString *errMsg;

/** 用户是否存在 */
@property (nonatomic,assign) BOOL isUserExist;

/** 未连接显示为连接中的次数 有些连接错误，界面上不会马上显示未连接，仍然显示连接中 */
@property (nonatomic,assign) int displayLinkingStatusTime;

/**
 功能描述
 连接接入管理服务器程序
 */
+ (AccessConn *)getConn;

/**
 功能描述
 连接接入管理服务器
 先尝试连接主服务器地址和端口，失败再尝试连接次服务器地址和端口
 连接成功后，会判断客户端是否需要升级
 
 返回值 int类型
 0：连接成功
 其它:连接失败
 */
- (int)connectServer;

/**
 功能描述
 将保存在NSUserDefaults中的最后一次连接的ip、端口、时间进行清空
 */
- (void)removeLastConnectData;

@end
