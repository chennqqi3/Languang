//
//  UploadFileObject.m
//  eCloud
// 上传文件 对象
//  Created by shisuping on 16/6/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadFileObject : NSObject

//上传文件的路径
@property (nonatomic,retain) NSString *uploadFilePath;
//上传文件类型
@property (nonatomic,assign) int uploadFileType;
//服务器url
@property (nonatomic,retain) NSString *uploadUrl;
//服务器应答
@property (nonatomic,retain) NSString *uploadResponse;

//从上传应答中获取文件token

- (NSString *)getFileToken;

@end
