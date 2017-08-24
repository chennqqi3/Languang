//
//  LanUtill.m
//  eCloud
//
//  Created by SH on 14-7-18.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "LanUtil.h"
#import "StringUtil.h"
#import "LogUtil.h"

//中文语言包名称
#define ZH_LAN_NAME @"zh-Hans"
//英文语音包名称
#define EN_LAN_NAME @"en"

@implementation LanUtil
//创建静态变量bundle，以及获取方法bundle
static NSBundle *bundle = nil;

//是否中文的静态变量
static bool isChinese;

+(NSBundle *)bundle
{
    return bundle;
}

//初始化方法：userLanguage储存在NSUserDefaults中，首次加载时要检测是否存在，如果不存在的话读AppleLanguages，并赋值给userLanguage。


+(void)initUserLanguage{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *string = [def valueForKey: @"userLanguage"];
    if(string == nil || string.length == 0)
    {
        //获取系统当前语言版本(中文zh-Hans,英文en)
        NSArray *languages = [def objectForKey:@"AppleLanguages"];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,languages]];
        
        string = [languages objectAtIndex:0];
    }
    
    if ([string rangeOfString:ZH_LAN_NAME].length > 0) {
        string = ZH_LAN_NAME;
    }
    else
    {
        string = EN_LAN_NAME;
    }
    
    [def setValue:string forKey: @"userLanguage"];
    
    [def synchronize];//持久化，不加的话不会保存
    
    [self setIsChinese:string];
    
    //获取文件路径
    
    NSString *path = [[StringUtil getBundle] pathForResource:string ofType:@"lproj"];
    
    bundle= [NSBundle bundleWithPath:path];//生成bundle
}

+(NSString *)userLanguage
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *language = [def valueForKey:@"userLanguage"];
    
    return language;
    
}

//设置语言方法
+(void)setUserlanguage:(NSString *)language
{
    [self setIsChinese:language];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //1.第一步改变bundle的值
    NSString *path = [[StringUtil getBundle] pathForResource:language ofType :@"lproj"];
    
    bundle = [NSBundle bundleWithPath :path];
    
    //2.持久化
    [def setValue:language forKey :@"userLanguage"];
    
    [def synchronize];
}

+ (void)setIsChinese:(NSString *)language
{
    if ([language rangeOfString:ZH_LAN_NAME].length > 0)
    {
        isChinese = YES;
    }
    else
    {
        isChinese = NO;
    }
}


+(BOOL)isChinese
{
    return isChinese;
}

@end
