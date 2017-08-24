//
//  WXCacheUtil.m
//  OpenCtx2017
//
//  Created by shisuping on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXCacheUtil.h"
#import "UserDefaults.h"
#import "StringUtil.h"
#import "LogUtil.h"
#import "UserTipsUtil.h"

static WXCacheUtil *util;
@implementation WXCacheUtil

/** 获取单例 */
+ (WXCacheUtil *)getUtil{
    if (!util) {
        util = [[super alloc]init];
    }
    return util;
}

/** 获取文件缓存 */
- (NSString *)getFileSize{
    long long fileSize = [[UserDefaults getFileStorage]longLongValue];
    NSString *fileSizeStr = [StringUtil getDisplayFileSize:fileSize];
    [LogUtil debug:[NSString stringWithFormat:@"%s file size is %@",__FUNCTION__,fileSizeStr]];
    return fileSizeStr;
}

/** 获取图片缓存 */
- (NSString *)getPicSize{
    long long picSize = [[UserDefaults getPicStorage]longLongValue];
    NSString *picSizeStr = [StringUtil getDisplayFileSize:picSize];
    [LogUtil debug:[NSString stringWithFormat:@"%s pic size is %@",__FUNCTION__,picSizeStr]];
    return picSizeStr;
}

/** 清理文件缓存 */
- (void)clearFileData{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
    
    [self performSelector:@selector(clearData:) withObject:@"file" afterDelay:1];
}

/** 清理图片缓存 */
- (void)clearPicData{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
    
    [self performSelector:@selector(clearData:) withObject:@"pic" afterDelay:1];

}

/** 清理文件和图片 */
- (void)clearAllData{
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
    
    [self performSelector:@selector(clearData:) withObject:@"all" afterDelay:1];
}


/** 找到并清除文件或图片 */
- (void)clearData:(NSString *)fileType{
    /** 确定是删除图片还是文件 */
    BOOL deletePic = NO;
    BOOL deleteFile = NO;
    BOOL deleteAll = NO;
    if ([fileType isEqualToString:@"pic"]) {
        deletePic = YES;
    }else if([fileType isEqualToString:@"file"]){
        deleteFile = YES;
    }else{
        deleteAll = YES;
    }
    
    NSString *documentDir = [StringUtil newRcvFilePath];
    NSError *error = nil;
    NSArray *fileList =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDir error:&error];
    
    //  所有子文件夹名
    for (NSString *file in fileList)
    {
        NSString *filePath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:file];
        
        if (deleteAll) {
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }else{
            if (([[file pathExtension] length] && ([[file pathExtension] isEqualToString:@"png"] || [[file pathExtension] isEqualToString:@"jpg"])) ||([[file pathExtension ]isEqualToString:@"gif"]||([[file pathExtension ]isEqualToString:@"bmp"]) || ([[file pathExtension ]isEqualToString:@"tiff"])))
            {
                //            图片类型
                if (deletePic) {
                    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
                }
                
            }else{
                //            文件类型
                if (deleteFile) {
                    [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
                }
            }
        }
    }
    
    [UserTipsUtil hideLoadingView];
}
@end
