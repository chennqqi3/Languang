//
//  NewMsgNumberUtil.h
//  eCloud
//
//  Created by Richard on 14-1-6.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define new_msg_number_bg_tag (100)
#define new_msg_number_label_tag (101)


@interface NewMsgNumberUtil : NSObject

+(void)addNewMsgNumberView:(UIView*)iconView;

+(void)displayNewMsgNumber:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber;

//传入一个数字，确定如何显示未读消息数(在NewMyViewController中使用)
+(void)displayNewMsgNumberForMyViewCtrl:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber;

/*
 功能描述
 把未读消息数防止父view的右上角
 */
+ (void)setUnreadViewFrame:(UIView *)iconView;


/**
 显示未读数

 @param iconView 未读数所在的父view
 @param newMsgNumber 未读数
 @param newMsgBgH 未读数显示高度
 @param newMsgFontSize 未读数显示size
 */
+ (void)displayNewMsgNumber:(UIView*)iconView andNewMsgNumber:(int)newMsgNumber andNewMsgBgHeight:(float)newMsgBgH andNewMsgFontSize:(float)newMsgFontSize;

@end
