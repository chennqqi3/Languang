//
//  PermissionUtil.h
//  eCloud
//  和用户权限相关的工具类
//  Created by shisuping on 14-4-11.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Emp;

@interface PermissionUtil : NSObject

#pragma mark 如果对方设置了消息屏蔽，那么应该提示用户
+ (void)showAlertWhenCanNotSendMsg:(Emp*)emp;

#pragma mark 如果对方设置了隐藏，那么应该提示用户
+ (void)showAlertWhenCanNotSee:(Emp*)emp;

#pragma mark 如果对方设置了资料隐藏，那么显示不可见
+ (NSString *)getHideInfoStr;
@end
