//
//  FileAssistantConn.h
//  eCloud
//
//  Created by Pain on 14-11-21.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UploadFileModel;
@interface FileAssistantConn : NSObject{
    
}

+ (NSDictionary *)getUploadFileToken:(UploadFileModel *)uploadFile; //获取token和起始终位置
+ (int)getStatusCodeOfValidatingFileWithURLString:(NSString *)urlStr; //判断文件是否有效


@end
