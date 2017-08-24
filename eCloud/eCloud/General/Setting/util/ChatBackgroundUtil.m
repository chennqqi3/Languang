//
//  ChatBackgroundUtil.m
//  eCloud
//
//  Created by shisuping on 15-9-18.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "ChatBackgroundUtil.h"
#import "StringUtil.h"

@implementation ChatBackgroundUtil

//通用聊天背景图片名称
+ (NSString *)getCommonBackgroundName
{
    return @"ChatBackground.jpg";
}


//某个会话聊天背景图片名称
+ (NSString *)getCustomBackgroundNameOfConv:(NSString *)convId
{
    return [NSString stringWithFormat:@"%@.jpg",convId];
}

//通用聊天背景图片路径
+ (NSString *)getCommonBackgroundPath
{
    return [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:[self getCommonBackgroundName]];
}


//某个会话聊天背景图片路径
+ (NSString *)getCustomBackgroundPathOfConv:(NSString *)convId
{
    return [[StringUtil newChatBackgroudPath] stringByAppendingPathComponent:[self getCustomBackgroundNameOfConv:convId]];
}

//获取默认背景
+ (UIImage *)getDefaultBackground
{
    UIImage *backImage = nil;
    
    NSString *defaultPath = [ChatBackgroundUtil getCommonBackgroundPath];
    if ([[NSFileManager defaultManager]fileExistsAtPath:defaultPath]) {
        backImage = [UIImage imageWithContentsOfFile:defaultPath];
    }
    else
    {
        backImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"ChatBackground_0" andType:@"png"]];
    }
    return  backImage;
}

//获取某个会话的背景
+ (UIImage *)getBackgroundOfConv:(NSString *)convId
{
    UIImage *backImage = nil;
    
    NSString *curPath = [ChatBackgroundUtil getCustomBackgroundPathOfConv:convId];
    if ([[NSFileManager defaultManager]fileExistsAtPath:curPath]) {
        backImage = [UIImage imageWithContentsOfFile:curPath];
    }
    else
    {
        backImage = [self getDefaultBackground];
    }
    return backImage;
}

@end
