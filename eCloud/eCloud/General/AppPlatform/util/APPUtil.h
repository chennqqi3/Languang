//  和 应用相关的工具类
//  APPUtil.h
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    app_show_flag_show = 0, //显示在应用界面上
    app_show_flag_hide = 1 //不在应用界面上显示，但可以添加到应用界面上
}appShowFlagDef;

@class APPListModel;
@class APPStateRecord;
@interface APPUtil : NSObject{
    
}

/*
 功能描述
 根据应用模型获取应用的图标
 
 参数
 appModel:应用模型
 */
+(UIImage *)getAPPLogo:(APPListModel*)appModel;

/*
 功能描述
 下载某应用的图标
 
 参数
 appModel:应用模型
 */
+(void)downloadAPPLogo:(APPListModel *)appModel;

//deprecated
+(UIImage *)getMyAPPLogo:(APPListModel*)appModel;

//deprecated
+(void)downloadMyAPPLogo:(APPListModel *)appModel;

/*
 功能描述
 获取应用图标保存路径
 
 参数
 urlStr:应用图标url
 appId:应用id
 */
+(NSString*)getAPPLogoPathWithURLStr:(NSString *)urlStr withAppid:(NSInteger)appid;


/*
 功能描述
 获取应用资源目录
 
 参数
 appModel:应用模型
 */
+(NSString*)getAPPResPath:(APPListModel*)appModel;

//deprecated
+ (APPStateRecord *)getNewAPPStateRecordOfApp:(NSString *)appid;//生成一个新的统计数据模型

//deprecated
+ (void)webCacheWithAPPModel:(APPListModel*)appModel;//缓存页面

//deprecated
+(NSString *)getStandartUrlStr:(NSString *)urlStr;//规范化url

//deprecated
+(void)downloadAPPSummaryPics:(APPListModel *)appModel; //下载应用简介图片

//deprecated
+(UIImage *)getImageWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid; //根据url下载应用

//查看轻应用是否是 拥有 未读数 接口 的 轻应用 deprecated
+ (BOOL)isAppHasUnreadService:(int)appId;


/*
 功能描述
 根据图片url生成一个key，作为图片名字保存在本地，不同的url，会生成不同的key
 
 参数
 url:图片对应的url
 
 返回
 url对应的key
 */
+ (NSString *)keyForURL:(NSURL *)url;

/*
 功能描述
 国美版本 是否是默认的显示在工作页面的app

 参数
 APPListModel
 
 */
+ (BOOL)isDefaultApp:(APPListModel *)appModel;

@end
