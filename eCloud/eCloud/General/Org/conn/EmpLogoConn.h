// 用户头像处理

#import <Foundation/Foundation.h>
#import "client.h"

@interface EmpLogoConn : NSObject

+ (EmpLogoConn *)getConn;


/**
 功能描述
 同步头像

 */
- (BOOL)syncEmpLogo;

/**
 功能描述
 处理头像变化
 
 参数 info 广播通知消息结构体指针

 */
- (void)processEmpLogoSyncAck:(TGetUserHeadIconListAck *)info;

/**
 功能描述
 头像下载失败后保存起来，下载前判断是否下载失败过，如果失败，则先不尝试，重新登录后再尝试
 如果头像下载失败则保存起来
 
 参数 empId 用户ID

 */
- (void)saveDownloadLogoFailEmp:(NSString *)empId;

/**
 功能描述
 下载前看看是否下载失败过
 
 参数 empId 用户ID
 返回值 YES 下载失败过 NO 没失败过
 */
- (BOOL)isDownloadLogoFailEmp:(NSString *)empId;

/**
 功能描述
 清空列表

 */
- (void)clearAllDownloadLogoFailEmp;

/**
 功能描述
 获取头像的下载路径
 
 参数 userAccount 账号
 参数 type 0 是小图
 参数 type 1 是大图
 
 返回值 找不到账号时或者用户还没有登陆成功 返回nil
 */
- (NSString *)getPortrailtDownloadUrlWithUserAccount:(NSString *)userAccount andLogoType:(int)type;

/**
 功能描述
 提供一个新下载头像的接口，参数是userAccout,异步下载完成后，发送通知出去，并且带上路径
 
 参数 userAccount 账号
 返回值 异步下载完成后，发送通知出去，并且带上路径
 */
- (void)downloadLogoByUserAccount:(NSString *)userAccount;

@end
