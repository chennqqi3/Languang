//
//  DownloadFileObject.h
//  eCloud
//  从文件服务器下载文件对应的文件模型
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

//下载结果定义
typedef enum
{
    download_success = 0, //下载成功
    download_fail //下载失败
}download_result_define;

@interface DownloadFileObject : NSObject

//文件下载后保存在本地的路径
@property (nonatomic,retain) NSString *downloadFilePath;

//文件对应的下载url
@property (nonatomic,retain) NSString *downloadUrl;

//下载进度UIView
@property (nonatomic,retain) UIProgressView *progressView;

//下载结果
@property (nonatomic,assign) int downloadResult;

//上下文 字典
@property (nonatomic,retain) NSDictionary *userInfo;

@end
