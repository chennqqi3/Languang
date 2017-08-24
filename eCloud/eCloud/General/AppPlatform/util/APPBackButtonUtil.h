//  以前实现的应用的功能用到的工具类 deprecated
//  APPBackButtonUtil.h
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class eCloudDAO;
@interface APPBackButtonUtil : NSObject
#pragma mark 获取并显示未读记录数
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton;

#pragma mark 初始化左边按钮
+(UIButton*)initBackButton;

#pragma mark 增加一个参数，可以传入button title
+(UIButton*)initBackButton:(NSString *)btnTitle;

#pragma mark 增加一个方法，可以传button title
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton andBtnTitle:(NSString *)btnTitle;

@end
