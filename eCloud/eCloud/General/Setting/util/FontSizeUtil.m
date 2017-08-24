//
//  FontSizeUtil.m
//  eCloud
//
//  Created by shisuping on 14-7-10.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "FontSizeUtil.h"
#import "StringUtil.h"


//是否跟随系统字号
#define refer_os_font_size @"refer_os_font_size"
//用户选择的字号
#define custom_font_size @"custom_font_size"

@implementation FontSizeUtil

+ (void)setFontSize:(int)fontSize
{
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    switch (fontSize) {
        case font_size_s:
            [_defaults setValue:[StringUtil getStringValue:font_size_s] forKey:custom_font_size];
            break;
        case font_size_m:
            [_defaults setValue:[StringUtil getStringValue:font_size_m] forKey:custom_font_size];
            break;
        case font_size_l:
            [_defaults setValue:[StringUtil getStringValue:font_size_l] forKey:custom_font_size];
            break;
        case font_size_xl:
            [_defaults setValue:[StringUtil getStringValue:font_size_xl] forKey:custom_font_size];
            break;
        default:
//            默认是中号字体
            [_defaults setValue:[StringUtil getStringValue:font_size_m] forKey:custom_font_size];
            break;
    }
}

+ (int)getFontSize
{
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];

    if ([self referOsFontSize]) {
        UIFont *systemFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//        NSLog(@"使用系统字体，字体大小：%d",(int)systemFont.pointSize);
        return (int)systemFont.pointSize;
    }
    else
    {
        NSString *fontSizeStr = [_defaults valueForKey:custom_font_size];
        if (fontSizeStr)
        {
//            NSLog(@"使用自定义字体，字体大小：%d",fontSizeStr.intValue);
            return fontSizeStr.intValue;
        }
//        NSLog(@"使用默认字体，字体大小：%d",font_size_m);
        return font_size_m;
    }
}

//获取通知类消息的字体大小，是在消息字体的基础上-2

+ (int)getGroupInfoFontSize
{
    return [self getFontSize] - 2;
}

//是否参照系统字体
+ (BOOL)referOsFontSize
{
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    id object = [_defaults objectForKey:refer_os_font_size];
    if (object) {
        return [_defaults boolForKey:refer_os_font_size];
    }
//    NSLog(@"还没有保存是否参照系统字体的值");
    return NO;
}

//设置是否参照系统字体
+ (void)setReferOsFontSize:(BOOL)referOsFontSize
{
    NSUserDefaults *_defaults = [NSUserDefaults standardUserDefaults];
    [_defaults setBool:referOsFontSize forKey:refer_os_font_size];
}
@end
