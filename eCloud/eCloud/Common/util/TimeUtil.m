//
//  TimeUtil.m
//  eCloud
// 和时间相关的工具类
//  Created by shisuping on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "TimeUtil.h"
#import "StringUtil.h"

@implementation TimeUtil

//计算时间对应的月份
+ (NSString *)getMonthOfTime:(int)msgTime
{
    
    return [self formatDateWithTime:msgTime andFormatStr:[StringUtil getLocalizableString:@"file_header_time_format"]];
}

//计算时间对应的日期yyyy-MM-dd
+ (NSString *)getDateOfTime:(int)time
{
    return [self formatDateWithTime:time andFormatStr:@"yyyy-MM-dd"];
}

+ (NSString *)formatDateWithTime:(int)time andFormatStr:(NSString *)formatStr
{
    NSDate *_msgDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSLocale *zh_Locale = [[[NSLocale alloc] initWithLocaleIdentifier:[StringUtil getPreferredLanguage]]autorelease];
    
    NSDateFormatter *formatter 	= [[[NSDateFormatter alloc] init]autorelease];
    [formatter setLocale:zh_Locale];
    
    [formatter setDateFormat:formatStr];
    
    NSString *dateStr=[formatter stringFromDate:_msgDate];
    return dateStr;
}

//计算时间所在的周
+ (NSString *)getWeekOfTime:(int)time
{
    return [self formatDateWithTime:time andFormatStr:@"EEE"];
}

//查看是否是本周
+ (BOOL)isCurWeek:(int)time
{
    NSDate *_msgDate = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDate *_now = [NSDate date];
    
    //	年 月 日 星期
    int _unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekCalendarUnit;
    
    NSCalendar *_cal = [NSCalendar currentCalendar];

    NSDateComponents *_msgDc = [_cal components:_unitFlags fromDate:_msgDate];
    
    NSDateComponents *_nowDc = [_cal components:_unitFlags fromDate:_now];
    
    if (_msgDc.year == _nowDc.year && _msgDc.week == _nowDc.week) {
        return YES;
    }
    return NO;
}

@end
