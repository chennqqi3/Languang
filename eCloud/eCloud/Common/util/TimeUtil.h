//
//  TimeUtil.h
//  eCloud
//
//  Created by shisuping on 15/11/5.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject

//计算时间对应的月份
+ (NSString *)getMonthOfTime:(int)msgTime;

//计算时间对应的日期yyyy-MM-dd
+ (NSString *)getDateOfTime:(int)time;

//计算时间所在的周
+ (NSString *)getWeekOfTime:(int)time;

//查看是否是本周
+ (BOOL)isCurWeek:(int)time;

@end
