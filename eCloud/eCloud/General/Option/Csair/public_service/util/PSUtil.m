//
//  PSUtil.m
//  eCloud
//
//  Created by Richard on 13-10-29.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSUtil.h"
#import "ServiceModel.h"
#import "StringUtil.h"
#import "UIRoundedRectImage.h"
#import "eCloudDefine.h"

@implementation PSUtil

+(NSString*)getServiceLogoPath:(ServiceModel*)serviceModel
{
	int serviceId = serviceModel.serviceId;
	NSString *logoName = [NSString stringWithFormat:@"%d.png",serviceId];
	NSString *logoPath = [[StringUtil newLogoPath]stringByAppendingPathComponent:logoName];
	return logoPath;
}

+(UIImage *)getServiceLogo:(ServiceModel*)serviceModel
{
//	如果是南航热点，那么就固定一个图标
	if([serviceModel.serviceName rangeOfString:redian_name].length > 0)
	{
		UIImage *image = [StringUtil getImageByResName:@"nanhangredian.png"];
		return image;
	}
	
	NSString *logoPath = [self getServiceLogoPath:serviceModel];
	UIImage *image = [UIImage imageWithContentsOfFile:logoPath];
	if(image == nil)
	{
        image = [StringUtil getImageByResName:@"ps_logo.png"];
		//		异步下载logo
		[self downloadPSLogo:serviceModel];
	}
	else
	{
//		image = [UIImage createRoundedRectImage:image size:CGSizeZero];
	}
	return image;
}

#pragma mark 异步下载头像，下载成功后，保存在本地
+(void)downloadPSLogo:(ServiceModel *)serviceModel
{
//	把服务号头像的url去掉两边空格，否则获取头像失败
	NSString *logo = [StringUtil trimString:serviceModel.serviceIcon] ;
	
	//	判断本地是否有头像，如果没有就下载
	if(logo && logo.length > 0)
	{
		NSString *logoPath =  [self getServiceLogoPath:serviceModel];
		UIImage *img = [UIImage imageWithContentsOfFile:logoPath];
		if(img == nil)
		{
			dispatch_queue_t _queue = dispatch_queue_create("download_service_logo", NULL);
			dispatch_async(_queue, ^{
				NSURL *url = [NSURL URLWithString:logo];
				NSData *imageData = [NSData dataWithContentsOfURL:url];
				if(imageData != nil && imageData.length > 0)
				{
//					//				先删除原来的头像
//					[StringUtil deleteUserLogoIfExist:empId];
					
					if([imageData writeToFile:logoPath atomically:YES])
					{
						NSLog(@"头像下载成功保存成功，%@",logo);
					}
					else
					{
						NSLog(@"头像下载成功保存失败，%@",logo);
					}
				}
				else
				{
					NSLog(@"头像下载失败%@",logo);
				}
			} );
		}
	}
}

@end
