//
//  APPUtil.m
//  eCloud
//
//  Created by Pain on 14-6-16.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPUtil.h"
#import "APPListModel.h"
#import "StringUtil.h"
#import "UIRoundedRectImage.h"
#import "APPStateRecord.h"
#import "eCloudNotification.h"
#import "eCloudDefine.h"

#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "APPPlatformDOA.h"
#import "NotificationUtil.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation APPUtil


#pragma mark - 下载应用图标
+(NSString*)getAPPLogoPathWithURLStr:(NSString *)urlStr withAppid:(NSInteger)appid
{
	NSString *path = [StringUtil newAppIconPathWithAppid:[NSString stringWithFormat:@"%d",appid]];
	NSString *extension = [urlStr pathExtension];
	if (![extension length]) {
		extension = @"png";
	}
	path =  [path stringByAppendingPathComponent:[[[self class] keyForURL:[NSURL URLWithString:urlStr]] stringByAppendingPathExtension:extension]];
	return path;
}

+(UIImage *)getAPPLogo:(APPListModel*)appModel
{
    if ([appModel.logopath length]) {
        NSString *logoPath = [self getAPPLogoPathWithURLStr:appModel.logopath withAppid:appModel.appid];
        UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
        if(image == nil)
        {
            image = [StringUtil getImageByResName:@"app_default_icon.png"];
            [self downloadAPPLogo:appModel];
        }
//        else
//        {
//            image = [UIImage createRoundedRectImage:image size:CGSizeZero];
//        }
        return image;
    }
	return nil;
}

+(void)downloadAPPLogo:(APPListModel *)appModel
{
	NSString *logo = [StringUtil trimString:appModel.logopath] ;
    
    if(logo && logo.length > 0)
	{
		NSString *logoPath =  [self getAPPLogoPathWithURLStr:logo withAppid:appModel.appid];
		UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
		if(img == nil)
		{
			dispatch_queue_t _queue = dispatch_queue_create("download_app_logo", NULL);
			dispatch_async(_queue, ^{
				NSURL *url = [NSURL URLWithString:[logo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				NSData *imageData = [NSData dataWithContentsOfURL:url];
				if(imageData != nil && imageData.length > 0)
				{
					if([imageData writeToFile:logoPath atomically:YES]){
						NSLog(@"应用图标下载成功保存成功，%@",logo);
                        // 图标下载成功后，更新downloadFlag字段
                        [[APPPlatformDOA getDatabase] updateDownLoadFlag:appModel];
					}
					else{
						NSLog(@"应用图标下载成功保存失败，%@",logo);
					}
				}
				else{
					NSLog(@"应用图标下载失败%@",logo);
				}
                //更新Tabar提示
                [[NSNotificationCenter defaultCenter] postNotificationName:APPLIST_UPDATE_NOTIFICATION object:nil];
			} );
            dispatch_release(_queue);
		}
	}
}

+(UIImage *)getMyAPPLogo:(APPListModel*)appModel
{
    if ([appModel.logopath length]) {
        NSString *logoPath = [self getAPPLogoPathWithURLStr:[appModel.logopath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] withAppid:appModel.appid];
        UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
        if (!image)
            return nil;
//        image = [UIImage createRoundedRectImage:image size:CGSizeZero];
        return image;
    }
    return nil;
}

+(void)downloadMyAPPLogo:(APPListModel *)appModel
{
    NSString *logo = [StringUtil trimString:appModel.logopath] ;
    
    if(logo && logo.length > 0)
    {
        logo = [logo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *logoPath =  [self getAPPLogoPathWithURLStr:logo withAppid:appModel.appid];
        
        UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
        if (!img) {
            dispatch_queue_t _queue = dispatch_queue_create("download_app_logo", NULL);
            dispatch_async(_queue, ^{
                NSURL *url = [NSURL URLWithString:logo];
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                if(imageData != nil && imageData.length > 0)
                {
                    if([imageData writeToFile:logoPath atomically:YES]){
                        // logopath下载成功后，发出通知更新对应的行
                        eCloudNotification *_notificationObject = [[[eCloudNotification alloc]init]autorelease];
                        _notificationObject.cmdId = refresh_app_section;
                        _notificationObject.info = [NSDictionary dictionaryWithObject:appModel forKey:@"appModel"];
                        
                        [[NotificationUtil getUtil]sendNotificationWithName:APPLIST_UPDATE_NOTIFICATION andObject:_notificationObject andUserInfo:nil];
                        
                        NSLog(@"应用图标下载成功保存成功，%@",logo);
                    }
                    else{
                        NSLog(@"应用图标下载成功保存失败，%@",logo);
                    }
                }
                else{
                    NSLog(@"应用图标下载失败%@",logo);
                }
            } );
            dispatch_release(_queue);
        }
    }
}

#pragma mark - 生成一个新的统计数据模型
+ (APPStateRecord *)getNewAPPStateRecordOfApp:(NSString *)appid{
    APPStateRecord *newAPPStateRec = [[APPStateRecord alloc] init];
    newAPPStateRec.appid = appid;
    newAPPStateRec.optype = 1;//访问数据
    newAPPStateRec.optime = [self getSystemCurrentTime];//获取当前时间
    return [newAPPStateRec autorelease];
}

+(NSString *)getSystemCurrentTime{
    //获取系统当前时间
//    update by shisp
    NSDate * currentDate = [NSDate date];
    
    //设置时间输出格式：
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyyMMdd"];
//    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currenTimeStr = [df stringFromDate:currentDate];
    [df release];
    return currenTimeStr;
}


#pragma mark - 缓存页面
+ (void)webCacheWithAPPModel:(APPListModel*)appModel{
    for (NSString *urlstr in appModel.cacheurl) {
        if ([urlstr length]) {
            NSString *strUrl = [[self getStandartUrlStr:urlstr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *url = [NSURL URLWithString:strUrl];
            [self loadURL:url];
        }
    }
}

+(void)loadURL:(NSURL*)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setDownloadDestinationPath:[[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
    [request startAsynchronous];
}


+(NSString *)getStandartUrlStr:(NSString *)_urlStr{
    NSMutableString *standarStr = [NSMutableString stringWithFormat:@"%@",_urlStr];
    if (![standarStr hasPrefix:@"http"]) {
        [standarStr insertString:@"http://" atIndex:0];
    }
    return standarStr;
}

#pragma mark - 下载应用简介图片
+(void)downloadAPPSummaryPics:(APPListModel *)appModel{
    for (NSString *urlstr in appModel.apppics) {
        if ([urlstr length]) {
            NSString *strUrl = [[self getStandartUrlStr:urlstr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [self downloadPicWithURLStr:strUrl withAppid:appModel.appid];
        }
    }
}

+ (void)downloadPicWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid{
    NSString *logoPath =  [self getAppSummaryPicWithURLStr:urlStr withAppid:appid];
    UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
    if(img == nil)
    {
        dispatch_queue_t _queue = dispatch_queue_create("download_app_logo", NULL);
        dispatch_async(_queue, ^{
            NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if(imageData != nil && imageData.length > 0)
            {
                if([imageData writeToFile:logoPath atomically:YES]){
                    NSLog(@"应用图标下载成功保存成功，%@",urlStr);
                }
                else{
                    NSLog(@"应用图标下载成功保存失败，%@",urlStr);
                }
            }
            else{
                NSLog(@"应用图标下载失败%@",urlStr);
            }
        } );
        dispatch_release(_queue);
    }
}

+(UIImage *)getImageWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid{
    NSString *logoPath = [self getAppSummaryPicWithURLStr:urlStr withAppid:appid];
	UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
	if(image == nil)
	{
		[self downloadPicWithURLStr:urlStr withAppid:appid];
	}
	else
	{
//		image = [UIImage createRoundedRectImage:image size:CGSizeZero];
	}
	return image;
}

+ (NSString *)getAppSummaryPicWithURLStr:(NSString *)urlStr withAppid:(NSString *)appid
{
	NSString *path = [StringUtil newAppIconPathWithAppid:appid];
	NSString *extension = [urlStr pathExtension];
	if (![extension length]) {
		extension = @"png";
	}
	path =  [path stringByAppendingPathComponent:[[[self class] keyForURL:[NSURL URLWithString:urlStr]] stringByAppendingPathExtension:extension]];
	return path;
}

+ (NSString *)keyForURL:(NSURL *)url
{
	NSString *urlString = [url absoluteString];
	if ([[urlString substringFromIndex:[urlString length]-1] isEqualToString:@"/"]) {
		urlString = [urlString substringToIndex:[urlString length]-1];
	}
	const char *cStr = [urlString UTF8String];
	unsigned char result[16];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
}

#pragma mark - 获取应用资源目录
+(NSString*)getAPPResPath:(APPListModel*)appModel{
    NSString *path = [StringUtil newAppIconPathWithAppid:appModel.appid];
    return path;
}

//查看轻应用是否是 拥有 未读数 接口 的 轻应用
+ (BOOL)isAppHasUnreadService:(int)appId
{
    if (appId == LONGHU_DAIBAN_APP_ID || appId == LONGHU_MAIL_APP_ID || appId == LONGHU_MY_ALARM_APP_ID) {
        return YES;
    }
    return NO;
}

+ (BOOL)isDefaultApp:(APPListModel *)appModel{
    switch (appModel.appid) {
        case 200:
        case 201:
        case 202:
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}

@end
