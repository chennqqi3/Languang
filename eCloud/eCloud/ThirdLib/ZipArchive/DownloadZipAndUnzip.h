//
//  DownloadZipAndUnzip.h
//  eCloud
//
//  Created by  lyong on 14-8-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadZipAndUnzip : NSObject
//实例
+(id)getInitDownloadZipAndUnzip;
//释放
+(void)releaseDownloadZipAndUnzip;

#pragma mark 下载zip
-(void)downloadZip:(NSString *)url_str;
#pragma mark 解压
- (NSString *) unZipClick;
#pragma mark Aes解密
-(void)doAES_Action;
@end
