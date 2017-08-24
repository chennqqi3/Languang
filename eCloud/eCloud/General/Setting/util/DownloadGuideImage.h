//
//  DownloadGuideImage.h
//  eCloud
//  下载广告页的工具类
//  Created by yanlei on 15/11/26.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface DownloadGuideImage : NSObject<ASIProgressDelegate>


/** 存放下载图片的结果 数组元素：1或2   1：下载成功  2：下载失败 */

@property (nonatomic,retain) NSMutableArray *picNameArray;

/**
 DownloadGuideImage单例

 @return 单例对象
 */
+ (id)shareDownloadGuideImageSingle;

/** 
 功能描述
 下载广告页图片
 
 参数
 guideUrl:管理台配置的应用里有一个应用是文件助手，这个应用的homePage属性里配置了广告页的Url，可以根据此Url下载显示广告页
 */
- (void)downloadGuideImage:(NSString *)guideUrl;

@end
