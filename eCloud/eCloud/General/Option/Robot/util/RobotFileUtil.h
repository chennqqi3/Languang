//
//  RobotFileUtil.h
//  eCloud
// 和机器人消息 有关的文件的处理类
//  Created by shisuping on 16/12/28.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConvRecord;

@interface RobotFileUtil : NSObject

/*
 功能描述
 获取单例
 */
+ (RobotFileUtil *)getUtil;

/*
 功能描述
 如果列表里有本消息的文件正在下载，那么就设置为正在下载，并且保存下载对象
 */
-(void)setDownloadPropertyOfRecord:(ConvRecord*)_convRecord;

/*
 功能描述
 发起下载后，保存在列表里，下载完成后再从列表里删除
 */

-(void)addRecordToDownloadList:(ConvRecord*)_convRecord;

/*
 功能描述
 下载完成后，从列表里移除
 */
-(void)removeRecordFromDownloadList:(ConvRecord *)_convRecord;

/*
 功能描述
 下载机器人的文件 比如图文消息里的图片，音频消息里的mp3，视频消息里的mp4，文件消息等，下载成功或者失败后，发出通知
 
 参数
 包含机器人消息的ConvRecord对象
 
 */
- (void)downloadRobotFile1:(ConvRecord *)_convRecord;

@end
