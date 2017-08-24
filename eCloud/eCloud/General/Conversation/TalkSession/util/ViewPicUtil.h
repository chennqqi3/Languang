//
//  ViewPicUtil.h
//  eCloud
//  和下载、预览图片相关的工具类
//  Created by shisuping on 15/11/30.
//  Copyright © 2015年  lyong. All rights reserved.
//


#import <Foundation/Foundation.h>

//图片类型定义 缩略图 裁剪为正方形的缩略图 原图
typedef enum
{
    pic_type_small = 0,
    pic_type_square,
    pic_type_origin
}pic_type_def;

@interface ViewPicUtil : NSObject

/**
 功能描述
 获取图片的名字
 
 参数
 msgBody:图片对应的token
 picType:参照pic_type_def定义
 
 返回
 图片保存名字
 */
+ (NSString *)getPicNameWithMsgBody:(NSString *)msgBody andPicType:(int)picType;

//图片的路径
/**
 功能描述
 获取图片的路径
 
 参数
 msgBody:图片对应的token
 picType:参照pic_type_def定义
 
 返回
 图片保存在本地的路径
 */
+ (NSString *)getPicPathWithMsgBody:(NSString *)msgBody andPicType:(int)picType;

//图片
/**
 功能描述
 获取图片
 
 参数
 msgBody:图片对应的token
 picType:参照pic_type_def定义
 
 返回
 图片Image
 */
+ (UIImage *)getPicWithMsgBody:(NSString *)msgBody andPicType:(int)picType;

/**
 功能描述
 把UIImage转换为NSData
 
 参数
 image
 
 */
+ (NSData *)convertImageToData:(UIImage *)image;

/**
 功能描述
 获取下载图片的Url
 
 参数
 msgBody:图片对应的token
 picType:参照pic_type_def定义
 
 返回
 下载图片的url
 */
+ (NSString *)getPicDownloadUrl:(NSString *)msgBody andPicType:(int)picType;


@end
