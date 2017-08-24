//
//  eCloudDAO.h
//  eCloud
//
//  Created by Richard on 13-9-27.
//  Copyright (c) 2013年  lyong. All rights reserved.
//
#import "ConvDAO.h"
@interface eCloudDAO : ConvDAO
//获取数据库的实例
+(eCloudDAO *)getDatabase;
//释放数据库
+(void)releaseDatabase;

@end
