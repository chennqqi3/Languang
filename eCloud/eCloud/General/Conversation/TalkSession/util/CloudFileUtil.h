//
//  CloudFileUtil.h
//  eCloud
//  龙湖云文件相关的工具栏
//  Created by Ji on 16/12/12.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConvRecord;
/** 规定存在相同文件名时的处理方式 */
typedef enum
{
    upload_method_cover,             // 覆盖
    upload_method_noinganderror,     // 不处理，返回失败
    upload_method_new                // 建立一个新版本
}upload_method;

@interface CloudFileUtil : NSObject

/**
 功能描述
    文件预览(暂未对龙湖开放)
 参数
    convRecord:会话实体
 */
+ (void)clounFilePreView:(ConvRecord *)convRecord;

/**
 功能描述
    文件上传到云盘
 参数
    convRecord:会话实体
 */
+ (void)savedTocloud:(ConvRecord *)convRecord;
@end
