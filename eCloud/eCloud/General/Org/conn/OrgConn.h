// 通讯录同步 相关的程序

#import <Foundation/Foundation.h>
#import "client.h"
#import "ASIHTTPRequest.h"

@class OrgSyncTypeAck;
@interface OrgConn : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>


/** 同步方式定义
 0:文件下载  1:数据包下载（即原来的老流程）*/
@property (nonatomic,retain) OrgSyncTypeAck *orgSyncTypeAck;

/** 懒加载 */
+ (OrgConn *)getConn;

/**
 功能描述
 查看组织架构同步方式 包含部门及员工与部门关系
 
 */
- (void)getOrgSyncType;

/**
 功能描述
 处理应答组织架构同步应答
 
 参数 info 通知类实体
 */
- (void)processGetOrgSyncTypeAck:(GETDATALISTTYPEACK *)info;

/**
 功能描述
 新的同步部门

 */
- (void)syncDept;

/**
 功能描述
 新的同步部门
 
 */
- (void)syncEmpDept;


#pragma mark ========获取和处理部门隐藏配置========

//获取有哪些部门隐藏
- (void)syncDeptShowConfig;

//解析部门隐藏的返回结果
- (void)processDeptShowConfig:(GETDEPTSHOWCONFIGACK *)getDeptShowConfigAck;

#pragma mark ====祥源获取部门显示配置=====
- (void)getXYDeptShowConfig;

@end
