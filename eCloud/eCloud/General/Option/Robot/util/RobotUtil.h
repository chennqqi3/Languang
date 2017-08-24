//
//  RobotUtil.h
//  eCloud
// 和机器人相关的util方法
//  Created by shisuping on 16/12/27.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConvRecord;

@interface RobotUtil : NSObject

/*
 功能描述
 根据机器人的回复类型，设置显示在界面上的消息类型
 
 如果不是机器人消息，那么直接返回原来的类型
 
 */
+ (int)getIMMsgTypeOfRobotRecord:(ConvRecord *)convRecord;


/*
 功能描述
 根据URL，获取下载文件的名称
 
 参数
 NSString:文件的URL，可以是一个图片的url，也可以是一个其它格式文件的URL
 
 返回值
 根据URL返回一个对应的文件名称
 
 */

+ (NSString *)getDownloadFileNameByFileUrl:(NSString *)urlStr;

/*
 功能描述
 获取机器人消息下载的文件的路径
 
 参数
 convRecord:对应的机器人消息
 
 返回值
 下载后保存的路径
 */
+ (NSString *)getDownloadFilePathWithConvRecord:(ConvRecord *)_convRecord;


@end
