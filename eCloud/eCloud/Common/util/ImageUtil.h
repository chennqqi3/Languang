//
//  ImageUtil.h
//  eCloud
//
//  Created by robert on 13-1-14.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emp.h"

@interface ImageUtil : NSObject

/**
 裁剪图片

 @param source  原图片
 @param size    目标size
 @param quality CGInterpolationQuality对象，没有用到

 @return 裁剪后的图片
 */
+ (UIImage *)scaledImage:(UIImage *)source toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;

/**
 新的修改图片尺寸的方法

 @param image  原图片
 @param width  自定义宽度
 @param height 自定义高度

 @return 裁剪后的图片
 */
+ (UIImage*)resizeImage:(UIImage*)image withWidth:(CGFloat)width withHeight:(CGFloat)height;

/**
 获取用户头像

 @param emp 员工

 @return 员工头像
 */
+(UIImage*)getLogo:(Emp*)emp;

/**
 根据员工权限状态、性别获取默认图像

 @param emp 员工

 @return 默认头像
 */
+(UIImage*)getDefaultLogo:(Emp*)emp;

/** 获取密聊默认头像 */
+(UIImage*)getDefaultMiLiaoLogo:(Emp*)emp;

/**
 先尝试获取员工头像，若头像返回为nil则返回默认头像

 @param emp 员工

 @return 员工头像或默认头像
 */
+(UIImage *)getEmpLogo:(Emp*)emp;

/**
 获取员工logo，若本地没有logo文件进行下载

 @param emp 员工

 @return 员工头像
 */
+ (UIImage *)getEmpLogoWithoutDownload:(Emp *)emp;

/**
 获取在线的头像，若在线头像为nil的话使用默认头像

 @param emp 员工

 @return 员工头像
 */
+(UIImage *)getOnlineEmpLogo:(Emp*)emp;

/**
 获取用户真实的头像

 @param emp 员工

 @return 真实头像
 */
+(UIImage*)getOnlineLogo:(Emp*)emp;

/**
 用户没有设置头像，根据性别获取默认的头像

 @param emp 员工

 @return 默认头像
 */
+(UIImage*)getDefaultOnlineLogo:(Emp*)emp;

/**
 获取消息不提醒的UIImage

 @param type 0：返回会话列表的灰色图片 1：返回标题栏的白色图片

 @return 图像
 */
+ (UIImage *)getNoAlarmImage:(int)type;

/**
 通过指定颜色获取对应的图像

 @param color 指定颜色

 @return 指定颜色对应的图像
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 (已废弃)
 自定义缩放图片
 
 @param image 原始图片
 @param size  自定义size
 
 @return 缩放到自定义size的新图片
 */
+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;

/**
 （已废弃）
 旋转缩放图片
 
 @param source      原图片的CGImageRef属性
 @param orientation 旋转方式
 @param size        自定义size
 @param quality     CGInterpolationQuality对象
 
 @return 处理后的新图片CGImageRef属性
 */
+ (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality;


/**
 生产马赛克图片

 @param image 原始图片
 @return 打了马赛克的图片
 */
+ (UIImage*)imageProcess:(UIImage*)image;

/** 生成自定义头像 生成的头像不清楚 没有用到 */
+ (UIImage *)createUserDefinedLogo:(NSDictionary *)logoDic;

/** 根据一个color生成一个image */
+ (UIImage *)createImageWithColor:(UIColor*) color;


@end
