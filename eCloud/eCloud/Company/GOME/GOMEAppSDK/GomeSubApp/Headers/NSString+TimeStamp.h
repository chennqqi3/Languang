//
//  NSString+timeStamp.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/11/9.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TimeStamp)

/**
 获取当前时间戳

 @return 时间戳字符串
 */
+ (NSString *)getCurrentTimeStamp;

/**
 时间戳转时间Str

 @return 2016/11/9
 */
- (NSString *)getDateStr;

/**
 转换专项需要的时间
 
 @return Aug 28, 2015 12:00:00 AM 转换成 2015/08/28
 */
- (NSString *)getSpecialTime;

/**
 根据传入的时间算出任务是否超期

 @param current 当前时间
 @param end 任务结束时间
 @return 任务是否超期
 */
+ (BOOL)overDueWithCurrent:(NSString *)current End:(NSString *)end;

+ (NSInteger)deadDayWithCurrent:(NSString *)current End:(NSString *)end Start:(NSString *)start;

@end
