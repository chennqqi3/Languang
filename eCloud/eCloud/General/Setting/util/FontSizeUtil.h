//
//  FontSizeUtil.h
//  eCloud
//
//  Created by shisuping on 14-7-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#pragma mark ----------字号定义----------
typedef enum
{
    font_size_s = 14,
    font_size_m = 16,
    font_size_l = 18,
    font_size_xl = 22
}font_size_type;

@interface FontSizeUtil : NSObject

+ (void)setFontSize:(int)fontSize;

+ (int)getFontSize;

//获取通知类消息的字体大小

+ (int)getGroupInfoFontSize;

//是否参照系统字体
+ (BOOL)referOsFontSize;

//设置是否参照系统字体
+ (void)setReferOsFontSize:(BOOL)referOsFontSize;

@end
