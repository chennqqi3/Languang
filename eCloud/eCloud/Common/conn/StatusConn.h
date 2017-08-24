//和获取状态有关的类

#import <Foundation/Foundation.h>
#import "client.h"

#define EMP_STATUS_CHANGE_NOTIFICATION @"EMP_STATUS_CHANGE_NOTIFICATION"

#define key_status_change_array @"status_change_array"

@interface StatusConn : NSObject

/** 常用联系人数组 */
@property (nonatomic,retain) NSArray *commonEmpArray;

/** 当前正在显示的控制器 */
@property (nonatomic,retain) UIViewController *curViewController;

/** 懒加载 */
+ (StatusConn *)getConn;

/**
 功能描述
 主动拉取固定订阅者状态
 
 返回值 NO 拉取失败
 */
- (BOOL)getCommonEmpStatus;

/**
 功能描述
 主动获取状态

 */
- (void)getStatus;

/**
 功能描述
 得到计时器的状态，用于重新拉取状态
 
 */
- (void)startGetStatusTimer;

/**
 功能描述
 获取某部门的用户的状态
 
 参数 deptId 部门ID
 返回值 NO 获取失败
 */
- (BOOL)getDeptStatus:(int)deptId;

@end
