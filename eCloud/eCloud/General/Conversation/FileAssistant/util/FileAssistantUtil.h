//
//  FileAssistantUtil.h
//  eCloud
//  文件助手相关的工具类
//  Created by 风影 on 15/1/12.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ConvRecord;

@interface FileAssistantUtil : NSObject{
    
}
/*
 功能说明
 文件助手界面、聊天界面 文件上传下载状态显示配置
 
 参数
 cell:文件对应的cell
 _convRecord:文件对应的消息模型
 editing:是否编辑状态
 */
+(void)configureFileResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord editState:(BOOL)editing; //文件断点续传设置

/*
 功能说明
 选择文件界面 文件上传下载状态显示配置
 
 参数
 cell:文件对应的cell
 _convRecord:文件对应的消息模型
 */
+(void)configureChooseFileResumeDownOrUpLoadSateLabelCell:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord; //文件断点续传设置

+(void)hideProgressView:(UIProgressView*)progressView; //设置进度条为透明
+(void)displayProgressView:(UIProgressView*)progressView; //显示进度条

+ (void)showFileNonexistViewInView:(UIView *)view inTalkSession:(BOOL)talkSession; //提示文件过期
@end
