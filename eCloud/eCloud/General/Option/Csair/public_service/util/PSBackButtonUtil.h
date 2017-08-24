//
//  PSBackButtonUtil.h
//  eCloud
//  导航栏设置 左边 右边 按钮 的工具类
//  Created by Richard on 13-11-7.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define default_left_button_width (70.0)
#define default_right_button_width (50.0)

#define default_button_font_size (17)
@class eCloudDAO;
@interface PSBackButtonUtil : NSObject

/** 获取并显示未读记录数 */
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton;

/** 初始化左边按钮 */
+(UIButton*)initBackButton;

/** 增加一个参数，可以传入button title */
+(UIButton*)initBackButton:(NSString *)btnTitle;

/** 增加一个方法，可以传button title */
+(void)showNoReadNum:(eCloudDAO*)db andButton:(UIButton*)backButton andBtnTitle:(NSString *)btnTitle;

/** 返回右边按钮 */
+ (UIButton *)initRightButton:(NSString *)btnTitle;

@end
