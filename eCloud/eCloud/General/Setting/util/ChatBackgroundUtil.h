//
//  ChatBackgroundUtil.h
//  eCloud
//
//  Created by shisuping on 15-9-18.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatBackgroundUtil : NSObject

//通用聊天背景图片名称
+ (NSString *)getCommonBackgroundName;

//某个会话聊天背景图片名称
+ (NSString *)getCustomBackgroundNameOfConv:(NSString *)convId;

//通用聊天背景图片路径
+ (NSString *)getCommonBackgroundPath;

//某个会话聊天背景图片路径
+ (NSString *)getCustomBackgroundPathOfConv:(NSString *)convId;

//设置默认背景
+ (UIImage *)getDefaultBackground;

//获取某个会话的背景
+ (UIImage *)getBackgroundOfConv:(NSString *)convId;

@end
