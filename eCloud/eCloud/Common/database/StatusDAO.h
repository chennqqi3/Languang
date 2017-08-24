//获取状态用到的数据库

#import "eCloud.h"

//statusType定义
typedef enum
{
    status_type_contact_list = 0,
    status_type_single,
    status_type_group,
    status_type_dept
}get_status_type;

/** 状态类型为status_type_contact_list时对应的id */
#define default_contact_list_status_id @"0"

@interface StatusDAO : eCloud

+ (StatusDAO *)getDatabase;

/**
 功能描述
 建数据库表

 */
- (void)createTable;

/**
 功能描述
 判断是否需要获取
 
 参数 statusId 状态标识 statusType 状态type
 
 返回值 如果不需要则返回，如果需要则保存新的时间
 */
- (BOOL)needGetStatus:(NSString *)statusId andType:(int)statusType;

/**
 功能描述
 根据id和type
 
 参数 statusId 状态标识 statusType 状态type
 
 返回值 返回时间，如果没有则返回-1
 */
- (int)getStatusTimeById:(NSString *)statusId andType:(int)statusType;

/**
 功能描述
 根据id，type，增加一条新的记录
 
 参数 statusId 状态标识 statusType 状态type

 */
- (void)saveStatusTime:(NSString *)statusId andType:(int)statusType;

/**
 功能描述
 根据id，type，修改原有的记录
 
 参数 statusId 状态标识 statusType 状态type
 
 */
- (void)modifyStatusTime:(NSString *)statusId andType:(int)statusType;

/**
 功能描述
 删除所有时间超过的记录

 */
-(void)deleteInvalidStatusTime;

@end
