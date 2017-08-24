// 单人聊天 导航栏增加 拨打电话功能
//  PhoneUtil.h
//  eCloud
//
//  Created by shisuping on 14-7-14.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Emp;
@interface PhoneUtil : NSObject

/** 不隐藏，并且至少有一个电话，才可以显示拨打电话按钮 */
+ (BOOL)needDisplayPhoneButton:(Emp *)emp;

/** 如果有一个电话，那么可以直接拨打，否则弹出菜单 */
+ (void *)showPopView:(UIViewController *)currentController andTargetButton:(UIButton *)targetButton andEmp:(Emp *)p;

@end
