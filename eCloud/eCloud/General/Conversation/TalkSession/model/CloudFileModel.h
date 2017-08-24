//
//  CloudFileModel.h
//  eCloud
//
//  Created by Ji on 16/11/3.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

// 以下宏定义应用于会话列表的显示   暂不生效
#define KEY_MSG_TYPE @"type"              // 会话消息类型
#define CLOUD_FILE_TYPE @"cloudFile"      // 云盘文件类型
#define KEY_FILE_URL @"FileUrl"           // 文件url
#define KEY_FILE_NAME @"FileName"         // 文件名称
#define KEY_FILE_SIZE @"FileSize"         // 文件大小


@interface CloudFileModel : NSObject

//云文件url
@property (nonatomic,strong) NSString *fileUrl;
//文件名
@property (nonatomic,strong) NSString *fileName;
//文件大小
@property (nonatomic,assign) int fileSize;

@end
