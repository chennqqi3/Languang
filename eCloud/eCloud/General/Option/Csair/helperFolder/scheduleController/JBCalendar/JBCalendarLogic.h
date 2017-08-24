//
//  JBCalendarLogic.h
//  JBCalendar
//
//  Created by YongbinZhang on 7/5/13.
//  Copyright (c) 2013 YongbinZhang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

#import "JBCalendarDate.h"
#import "NSDate+Calendar.h"



#ifndef UpdateTodayNotification
#define UpdateTodayNotification @"updateTodayNotification"
#endif

#ifndef UpdateSelectedDateNotification
#define UpdateSelectedDateNotification  @"UpdateSelectedDateNotification"
#endif


@interface JBCalendarLogic : NSObject


/*******************************************
 *@Description:类方法，为实现单例模型
 *@Params:nil
 *@return:返回唯一的
 *******************************************/
+ (JBCalendarLogic *)defaultCalendarLogic;


///////////////////////////////////////////
//                Month
///////////////////////////////////////////
/*******************************************
 *@Description:计算变量date所在月份的日历信息
 *@Params:
 *  date:日期
 *  completionBlock:参数为date所在月份的日期信息
 *@Return:nil
 *******************************************/
- (void)moveToMonthForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSArray *daysInFinalWeekOfPreviousMonth, NSArray *daysInSelectedMonth, NSArray *daysInFirstWeekOfFollowingMonth))completionBlock;


///////////////////////////////////////////
//                Week
///////////////////////////////////////////
/*******************************************
 *@Description:计算变量date所在周的日历信息
 *@Params:
 *  date:日期
 *  completionBlock:参数为date所在周的日期信息
 *@Return:nil
 *******************************************/
- (void)moveToWeekForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSArray *daysInSelectedWeekInPreviousMonth, NSArray *daysInSelectedWeekInSelectedMonth, NSArray *daysInSelectedWeekInFollowingMonth))completionBlock;

///////////////////////////////////////////
//                Day
///////////////////////////////////////////
/*******************************************
 *@Description:计算变量date所在日期的日历信息
 *@Params:
 *  date:日期
 *  completionBlock:参数与date相同
 *@Return:nil
 *******************************************/
- (void)moveToDayForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSDate *selectedDate))completionBlock;

@end