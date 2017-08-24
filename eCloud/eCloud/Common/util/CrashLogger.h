//
//  CrashLogger.h
//  eCloud
//  发生异常时，记录异常日志
//  Created by yanlei on 2017/2/20.
//  Copyright © 2017年 深圳市网信科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CrashLogger : NSObject<UIAlertViewDelegate>
+ (void)initCrashLogs;

/**
 将崩溃信息写入到文件中

 @param exception 崩溃的字典信息

 @return 是否写入成功
 */
+ (BOOL)writeCrashFileOnDocumentsException:(NSDictionary *)exception;

/**
 * 读取崩溃日志
 */
+ (nullable NSArray *)sd_getCrashLogs;

/**
 * 清除崩溃日志
 */
+ (BOOL)sd_clearCrashLogs;

/**
 获取当前异常日志文件的路径

 @return 异常日志文件的路径字符串
 */
+ (NSString *)getCurExpLogFilePath;

/**
 删除多余的异常日志文件
 */
+ (void)clearExpLogFile;

@end

@interface NSDate(myformatter)

/**
 获取特定格式的日期字符串

 @param format 日期格式字符串

 @return 日期字符串
 */
- (NSString *)my_formattedDateWithFormat:(NSString *)format;

/**
 根据当前地区获取特定格式的日期字符串

 @param format 日期格式字符串
 @param locale 当前地区local对象

 @return 日期字符串
 */
- (NSString *)my_formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale;

/**
 根据特定地区、特定NSTimeZone、特定格式字符串，获取日期字符串

 @param format   日期格式字符串
 @param timeZone 特定timeZone对象
 @param locale   特定地区local对象

 @return 日期字符串
 */
- (NSString *)my_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;
@end
