//
//  PSUtil.h
//  eCloud
//  公众号工具类 下载公众号对应图标 获取公众号 图标
//  Created by Richard on 13-10-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceModel;

@interface PSUtil : NSObject
+(UIImage *)getServiceLogo:(ServiceModel*)serviceModel;

#pragma mark 异步下载头像，下载成功后，保存在本地
+(void)downloadPSLogo:(ServiceModel *)serviceModel;

@end
