//
//  WXCacheUtil.h
//  OpenCtx2017
//  和缓存有关的util
//  Created by shisuping on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXCacheUtil : NSObject

/** 获取单例 */
+ (WXCacheUtil *)getUtil;

/** 获取文件缓存 */
- (NSString *)getFileSize;

/** 获取图片缓存 */
- (NSString *)getPicSize;

/** 清理文件缓存 */
- (void)clearFileData;

/** 清理图片缓存 */
- (void)clearPicData;

/** 清理文件和图片 */
- (void)clearAllData;

@end
