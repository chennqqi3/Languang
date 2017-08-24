//
//  NewAPPTagUtil.h
//  eCloud
//  在某个view上增加显示新消息的view,可以红点、数字、new的方式提醒用户
//  Created by Pain on 14-6-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewAPPTagUtil : NSObject

/*
 功能描述
 在iconView上增加新消息提醒相关view
 
 参数
 iconView:定制tabbar的图标、应用图标等
 */
+(void)addAppTagView:(UIView*)iconView;

/*
 功能描述
 在普通的图标上显示用户提醒 deprcated
 
 参数
 iconView:要求显示新消息提醒的view
 newText: 如果有需求可以定义
 */
+(void)displayaddAppTagView:(UIView*)iconView withText:(NSString *)newText;

#pragma mark - tabr是否已显示
+(BOOL)isDidShowTagViewOnTabar:(UIView*)iconView;

/*
 功能描述
 在普通的图标上显示用户提醒
 
 参数
 iconView:要求显示新消息提醒的view
 newText: 
 new : 显示new字符串
 数字 ：显示数字
 Push :显示为红点
 nil :隐藏
 */
+(void)displayaddTagViewOnTabar:(UIView*)iconView withText:(NSString *)newText;



@end
