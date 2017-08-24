/** 个人漫游数据使用到的类 */

#import <Foundation/Foundation.h>
#import "client.h"
#import "ASIHTTPRequest.h"

/** 固定组更新通知 */
#define SYSTEM_GROUP_UPDATE_NOTIFICATION @"SYSTEM_GROUP_UPDATE_NOTIFICATION"

/** 修改个人漫游数据通知名称 */
#define UPDATE_USER_DATA_NOTIFICATION @"UPDATE_USER_DATA_NOTIFICATION"

/** 修改个人漫游数据结果定义 */
typedef enum
{
    update_user_data_success = 200,
    update_user_data_fail,
    update_user_data_timeout
}update_user_data_result;


//#define ROAMINGDATA_FRE_CON	400		//常用联系人个数
//#define ROAMINGDATA_COM_DEP	20		//常用部门
//#define ROAMINGDATA_ATT_CON 100 	//关注人
//#define ROAMINGDATAREQSIZE  (ROAMINGDATA_FRE_CON*4 +100)	//请求包大小

//1：常用联系人 2：常用部门 （暂做1，2,3）3：关注人//4自定义（组信息）5自定义组成员变化 6缺省联系人
typedef enum
{
    user_data_type_emp = 1,
    user_data_type_dept,
    user_data_type_concern,
    user_data_type_common_group,
    user_data_type_default_common_emp = 6
}user_data_type;

/** 1：添加， 2：删除 */
typedef enum
{
    user_data_update_type_insert = 1,
    user_data_update_type_delete
}user_data_update_type;

@interface UserDataConn : NSObject<ASIHTTPRequestDelegate,ASIProgressDelegate>

/** 懒加载 */
+ (UserDataConn *)getConn;

/**
 功能描述
 个人数据同步请求
 
 参数 userDataType 枚举

 */
- (void)sendUserDataSync:(int)userDataType;

/**
 功能描述
 处理个人数据同步应答
 
 参数 info 通知类型实体

 */
- (void)processUserDataSyncAck:(ROAMDATASYNCACK *)info;

/**
 功能描述
 个人数据修改请求
 
 参数 userDataType 枚举
     updateType   枚举 1、添加 2、删除
     dataArray    员工ID数组
 返回值 NO 请求失败
 */
- (BOOL)sendModiRequestWithDataType:(int)userDataType andUpdateType:(int)updateType andData:(NSArray *)dataArray;

/**
 功能描述
 处理修改应答
 
 参数 info 通知类型实体
 
 */
- (void)processUserDataModiAck:(ROAMDATAMODIACK *)info;

/**
 功能描述
 接收漫游数据修改通知
 
 参数 info 通知类型实体
 
 */
- (void)processUserDataModiNotice:(ROAMDATAMODINOTICE *)info;

/**
 功能描述
 固定群组同步请求
 
 */
- (void)sendSystemGroupSync;

/**
 功能描述
 接收固定群组创建通知
 
 参数 info 通知类型实体
 
 */
- (void)processSystemGroupCreateNotice:(CREATEREGULARGROUPNOTICE *)info;

/**
 功能描述
 接收固定群组删除通知
 
 参数 info 通知类型实体
 
 */
- (void)processSystemGroupDeleteNotice:(DELETEREGULARGROUPNOTICE *)info;

/**
 功能描述
 接收固定群组成员变化通知
 
 参数 info 通知类型实体
 
 */
- (void)processSystemGroupMemberChangeNotice:(GULARGROUPMEMBERCHANGENOTICE *)info;

/**
 功能描述
 接收固定群组名称变化通知
 
 参数 info 通知类型实体
 
 */
- (void)processSystemGroupNameChangeNotice:(GULARGROUPNAMECHANGENOTICE *)info;

//
/**
 功能描述
 接收固定组创建通知 大群组 需要分包发送群组
 
 参数 info 通知类型实体
 
 */
- (void)processBigSystemGroupCreateNotice:(CREATEREGULARGROUPPROTOCOL2NOTICE *)info;

/**
 功能描述
 蓝光同步常用群组
 
 
 */
- (void)getLGCommonGroup:(NSDictionary *)dict;
@end
