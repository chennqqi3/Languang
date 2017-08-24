//
//  DownloadFileUtil.h
//  eCloud
//  从文件服务器下载文件的工具类
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadFileUtil;

@class ASIHTTPRequest;
@class DownloadFileObject;

@protocol DownloadFileDelegate <NSObject>

/*
 功能说明
 文件下载完毕回调
 
 参数
 downloadFileUtil:
 resultArray:下载结果数组
 */
- (void)downloadFinish:(DownloadFileUtil *)downloadFileUtil andResult:(NSArray *)resultArray;

@end

@interface DownloadFileUtil : NSObject

@property (nonatomic,assign) id<DownloadFileDelegate> delegate;

//下载数组里包含的文件
- (void)downloadFile:(NSArray *)fileArray;

/** 根据一个对象 生成一个request */
+ (ASIHTTPRequest *)getRequestWith:(DownloadFileObject *)downloadFileObject;


@end
