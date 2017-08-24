//
//  UploadFileUtil.h
//  eCloud
//  上传文件工具栏 给h5应用提供JS接口时，上传图片、语音等功能使用
//  Created by shisuping on 16/6/16.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UploadFileUtil;

@protocol UploadFileDelegate <NSObject>

//
/*
 功能描述
 上传完毕 把上传的结果通知给delegate
 
 参数
 uploadFileUtil:
 uploadFinishArray:上传结果数组
 
 */
- (void)uploadFinish:(UploadFileUtil *)uploadFileUtil andResult:(NSArray *)uploadFinishArray;

@end

@interface UploadFileUtil : NSObject

@property (nonatomic,assign) id delegate;

- (void)upload:(NSArray *)fileArray;

@end
