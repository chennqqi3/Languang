//
//  NSDate+GetNeededTime.h
//  GomeSubApplication
//
//  Created by 房潇 on 2016/12/2.
//  Copyright © 2016年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GSADate) {
    GSADateCurrentDay = 0,
    GSADateCurrentMonth,
    GSADateCurrentThreeMonth,
    GSADateCurrentHalfYear,
    GSADateCurrentYear
};

@interface NSDate (GetNeededTime)
/**
 获取查询奖罚需要的时间

 @param dateType 传入需要的Type
 @return 返回包含开始 结束时间的字典
 */
+ (NSMutableDictionary *)getNeededTime:(GSADate)dateType;

/**
 获取提奖需要的时间

 @param dateType 传入需要的日期Type 除当月、当天均返回空字符串
 @return 带相应年月日的字符串
 */
+ (NSString *)getAwardTime:(GSADate)dateType;

/**
 获取考核需要的时间

 @param dateType GSADateCurrentMonth  返回当前月至一月倒序，添加上下半年
                               GSADateCurrentYear    返回13年至上一年（考核数据最早只能查到13年，最晚能查到上一年）
 @return 时间数组
 */
+ (NSArray *)getExamineTime:(GSADate)dateType;

/**
 获取薪酬需要的时间

 @return Object为 yyyyMM的数组
 */
+ (NSArray *)getEmolumentTime;

@end
