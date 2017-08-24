//
//  OpenCtxUtil.h
//  eCloud
//  在h5应用中使用的开放平台工具类
//  Created by shisuping on 16/1/4.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenCtxDefine.h"

@interface OpenCtxUtil : NSObject

//创建打开讨论组结果block 定义了创建结果 如果创建成功，那么返回talksessionViewController实例，用户可以打开聊天界面
@property (nonatomic,copy) CreateAndOpenConvResultBlock createAndOpenConvResultBlock;

+ (OpenCtxUtil *)getUtil;

/*
 功能说明
 创建打开临时讨论组
 
 参数
 empCodeArray:成员账号数组
 convTitle:讨论组标题
 
 */
- (void)createAndOpenConvWithEmpCodes:(NSArray *)empCodeArray andConvTitle:(NSString *)convTitle andCompletionHandler:(CreateAndOpenConvResultBlock)completionHandler;


/*
 功能说明
 蓝光创建或打开流程审批群组
 
 参数
 empCodeArray:成员账号数组
 convTitle:讨论组标题
 
 */
- (void)LGcreateAndOpenConvWithEmpCodes:(NSArray *)empCodeArray andConvTitle:(NSString *)convTitle groupID:(NSString *)groupID andCompletionHandler:(CreateAndOpenConvResultBlock)completionHandler;

@end
