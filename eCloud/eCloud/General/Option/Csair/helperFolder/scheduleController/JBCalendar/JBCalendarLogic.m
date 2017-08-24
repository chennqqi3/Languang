//
//  JBCalendarLogic.m
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

#import "JBCalendarLogic.h"
#import "JBPlistFileManager.h"
#import "JBDefine.h"

#ifndef CalendarDataDir
#define CalendarDataDir @"JBCalendarData"
#endif

//  JBMonthData_2013_06.plist
#ifndef MonthDataPlistFile
#define MonthDataPlistFile  @"JBMonthData_"
#endif

//  JBWeekData_2013_27.plist
#ifndef WeekDataPlistFile
#define WeekDataPlistFile   @"JBWeekData_"
#endif

//  Calendar data dic key define
#ifndef CalendarDataDicKey
#define CalendarDataDicKey
#define CalendarDataDicKey_Previous     @"previous"
#define CalendarDataDicKey_Selected     @"selected"
#define CalendarDataDicKey_Following    @"following"
#endif


//  Error Define
#ifndef CalendarError
#define CalendarError

#define Error_Calendar_NoCorrespondingLocalData_Code    100001012
#define Error_Calendar_NoCorrespondingLocalData_Message @"Error_Calendar_NoCorrespondingLocalData_Message"

#define Error_Calendar_LocalDataError_Code      100001013
#define Error_Calendar_LocalDataError_Message   @"Error_Calendar_LocalDataError_Message"

#define Error_Calendar_WriteToPlistFileFailed_Code      100001014
#define Error_Calendar_WriteToPlistFileFailed_Message   @"Error_Calendar_WriteToPlistFileFailed_Message"

#endif

static BOOL MonthDataForInit, WeekDataForInit;

@interface JBCalendarLogic ()

//  今天
@property (nonatomic, retain) NSDate *today;
/********************************************
 *@Description:更新变量'today'（凌晨切换时间）
 *@Params:nil
 *@Return:nil
 ********************************************/
- (void)updateToday;


//  选择的日期
@property (nonatomic, retain) NSDate *selectedDate;


/********************************************
 *@Description:获取某个日期对应的月份或周的日期数据
 *@Params:
 *  date:某一个日期
 *  completionBlock:操作完成后调用的代码块
 *@Return:nil
 ********************************************/
- (void)getMonthCalendarDataByDate:(NSDate *)date WithComplectionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))complectionBlock;
- (void)getWeekCalendarDataByDate:(NSDate *)date WithComplectionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))complectionBlock;


//////////////////////////////////////////////
//            Month And Week
//////////////////////////////////////////////
//  本月日历中，上一个月最后一周的天数
- (NSUInteger)numberOfDaysInPreviousPartialWeek;
//  本月日历中，下一个月第一周的天数
- (NSUInteger)numberOfDaysInFollowingPartialWeek;

//  -------------------Month-----------------------

//  当月的第一天
@property (nonatomic, retain) NSDate *firstDateInSelectedMonth;
//  当月的最后一天
@property (nonatomic, retain) NSDate *lastDateInSelectedMonth;

//  日历上，左上角的日期
@property (nonatomic, retain) NSDate *firstDateOnCalendarOfSelectedMonth;
//  日历上，右下角的日期
@property (nonatomic, retain) NSDate *lastDateOnCalendarOfSelectedMonth;


@property (nonatomic, retain) NSArray *daysInSelectedMonth;
@property (nonatomic, retain) NSArray *daysInFinalWeekOfPreviousMonth;
@property (nonatomic, retain) NSArray *daysInFirstWeekOfFollowingMonth;

//  本月日历中，上一个月最后一周的日期列表
- (NSArray *)calculateDaysInFinalWeekOfPreviousMonth;
//  本月日历中，下一个月第一周的日期列表
- (NSArray *)calculateDaysInFirstWeekOfFollowingMonth;
//  本月日历中，本月的日期列表
- (NSArray *)calculateDaysInSelectedMonth;

//  计算某月的相关信息
- (void)recalculateVisibleDaysInSelectedMonthWithCompletionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))completionBlock;


//  ---------------------Week------------------------

@property (nonatomic, retain) NSDate *firstDateInSelectedWeekInSelectedMonth;
@property (nonatomic, retain) NSDate *lastDateInSelectedWeekInSelectedMonth;

@property (nonatomic, retain) NSDate *firstDateOnCalendarOfSelectedWeek;
@property (nonatomic, retain) NSDate *lastDateOnCalendarOfSelectedWeek;

@property (nonatomic, retain) NSArray *daysInSelectedWeekInSelectedMonth;
@property (nonatomic, retain) NSArray *daysInSelectedWeekInPreviousMonth;
@property (nonatomic, retain) NSArray *daysInSelectedWeekInFollowingMonth;

//  在前一个月中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekOfPreviousMonth;
//  本月日历中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekInSelectedMonth;
//  在后一个月中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekOfFollowingMonth;

//  计算某周的相关信息
- (void)recalculateVisibleDaysInSelectedWeekWithCompletionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))completionBlock;



//  --------------------本地存储--------------------
/**********************************************
 *@Description:将月份／周的日期信息数据转换为为字典
 *@Params:
 *  previousUnitDays:本月日历中，上一个月最后一周的日期列表／在前一个月中，本周的日期列表
 *  selectedUnitDays:本月日历中，本月的日期列表／本月日历中，本周的日期列表
 *  followingUnitDays:本月日历中，下一个月第一周的日期列表／  在后一个月中，本周的日期列表
 *  completionBlock:转换成功后调用的代码块
 *@Return:nil
 **********************************************/
- (void)dictionaryWithPreviousUnitDays:(NSArray *)previousUnitDays SelectedUnitDays:(NSArray *)selectedUnitDays FollowingUnitDays:(NSArray *)followingUnitDays CompletionBlock:(void (^)(NSDictionary *dictionary))completionBlock;

/**********************************************
 *@Description:将字典数据转换为月份／周的日期信息数据
 *@Params:
 *  dictionary:字典数据
 *  completionBlock:转换成功后调用的代码块
 *@Return:nil
 **********************************************/
- (void)getUnitDaysFromDictionary:(NSDictionary *)dictionary WithCompletionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))completionBlock;


/***********************************************
 *@Description:保存某一天对应的月份／周的日期数据到本地
 *@Params:
 *  monthData:日期数据
 *  date:日期
 *  successBlock:数据保存成功后调用的代码块
 *  failureBlock:数据保存失败后调用的代码块
 *@Return:nil
 ***********************************************/
- (void)saveMonthCalendarDataToLocal:(NSDictionary *)calendarData ForDate:(NSDate *)date WithSuccessBlock:(void (^)())successBlock FailureBlock:(void (^)())failureBlock;
- (void)saveWeekCalendarDataToLocal:(NSDictionary *)calendarData ForDate:(NSDate *)date WithSuccessBlock:(void (^)())successBlock FailureBlock:(void (^)())failureBlock;

/***********************************************
 *@Description:获取某一天对应的月份／周的日期的本地数据
 *@Params:
 *  date:日期
 *  successBlock:数据获取成功后调用的代码块
 *  failureBlock:数据获取失败后调用的代码块
 *@Return:nil
 ***********************************************/
- (void)getLocalMonthDataForDate:(NSDate *)date WithSuccessBlock:(void (^)(NSArray *daysInFinalWeekOfPreviousMonth, NSArray *daysInSelectedMonth, NSArray *daysInFirstWeekOfFollowingMonth))successBlock FailureBlock:(void (^)(NSInteger errorno, NSString *error))failureBlock;
- (void)getLocalWeekDataForDate:(NSDate *)date WithSuccessBlock:(void (^)(NSArray *daysInSelectedWeekInPreviousMonth, NSArray *daysInSelectedWeekInSelectedMonth, NSArray *daysInSelectedWeekInFollowingMonth))successBlock FailureBlock:(void (^)(NSInteger errorno, NSString *error))failureBlock;

@end

@implementation JBCalendarLogic

#pragma mark -
#pragma mark - Class Methods

/*******************************************
 *@Description:类方法，为实现单例模型
 *@Params:nil
 *@return:返回唯一的
 *******************************************/
+ (JBCalendarLogic *)defaultCalendarLogic
{
    static JBCalendarLogic *staticCalendarLogic;
    if (!staticCalendarLogic) {
        staticCalendarLogic = [[JBCalendarLogic alloc] init];
    }
    
    return staticCalendarLogic;
}


#pragma mark -
#pragma mark - and init
- (id)init
{
    if ((self = [super init])) {
        self.today = [NSDate date];
        self.selectedDate = [self.today retain];
        
        MonthDataForInit = YES;
        WeekDataForInit = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToday) name:UIApplicationSignificantTimeChangeNotification object:nil];
    }
    
    return self;
}


#pragma mark -
#pragma mark - Setter
- (void)setToday:(NSDate *)today
{
    if (today && [today isKindOfClass:[NSDate class]]) {
        if (_today && today.year == _today.year && today.month == _today.month && today.day == _today.day) {
        } else {
            _today = today;
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTodayNotification object:_today];
        }
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (selectedDate && [selectedDate isKindOfClass:[NSDate class]]) {
        if (_selectedDate && selectedDate.year == _selectedDate.year && selectedDate.month == _selectedDate.month && selectedDate.day == _selectedDate.day) {
        } else {
            _selectedDate = selectedDate;
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateSelectedDateNotification object:_selectedDate];
        }
    }
}



#pragma mark -
#pragma mark - Class Extensions
/********************************************
 *@Description:更新变量'today'（凌晨切换时间）
 *@Params:nil
 *@Return:nil
 ********************************************/
- (void)updateToday
{
    self.today = [NSDate date];
}



/********************************************
 *@Description:获取某个日期对应的月份或周的日期数据
 *@Params:
 *  date:某一个日期
 *  completionBlock:操作完成后调用的代码块
 *@Return:nil
 ********************************************/
- (void)getMonthCalendarDataByDate:(NSDate *)date WithComplectionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))complectionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getLocalMonthDataForDate:date WithSuccessBlock:complectionBlock FailureBlock:^(NSInteger errorno, NSString *error) {
            [self recalculateVisibleDaysInSelectedMonthWithCompletionBlock:complectionBlock];
        }];
    });
}

- (void)getWeekCalendarDataByDate:(NSDate *)date WithComplectionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))complectionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getLocalWeekDataForDate:date WithSuccessBlock:complectionBlock FailureBlock:^(NSInteger errorno, NSString *error) {
            [self recalculateVisibleDaysInSelectedWeekWithCompletionBlock:complectionBlock];
        }];
    });
}

//////////////////////////////////////////////
//            Month And Week
//////////////////////////////////////////////
//  ------------------------Public------------------------

//  本月日历中，上一个月最后一周的天数
- (NSUInteger)numberOfDaysInPreviousPartialWeek
{
    return (self.firstDateInSelectedMonth.weekday - 1);
}

//  本月日历中，下一个月第一周的天数
- (NSUInteger)numberOfDaysInFollowingPartialWeek
{
    return (7 - [self.selectedDate lastDayOfTheMonth].weekday);
}



//////////////////////////////////////////////
//                  Month
//////////////////////////////////////////////
//  本月日历中，上一个月最后一周的日期列表
- (NSArray *)calculateDaysInFinalWeekOfPreviousMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSDate *beginningOfPreviousMonth = [self.firstDateInSelectedMonth firstDayOfThePreviousMonth];
    NSUInteger numberOfDaysOfPreviousMonth = [beginningOfPreviousMonth numberOfDaysInMonth];
    NSUInteger numberOfDaysInPreviousPartialWeek = [self numberOfDaysInPreviousPartialWeek];
//    NSLog(@"上一个月最后一周的日期列表---beginningOfPreviousMonth-%@,numberOfDaysOfPreviousMonth-%d,numberOfDaysOfPreviousMonth-%d,self.firstDateInSelectedMonth-%@",beginningOfPreviousMonth,numberOfDaysOfPreviousMonth,numberOfDaysInPreviousPartialWeek,self.firstDateInSelectedMonth);
    for (NSUInteger day = numberOfDaysOfPreviousMonth - numberOfDaysInPreviousPartialWeek + 1; day <= numberOfDaysOfPreviousMonth; day++) {
        [days addObject:[JBCalendarDate dateWithYear:beginningOfPreviousMonth.year Month:beginningOfPreviousMonth.month Day:day]];
    }
    
    return days;
}

//  本月日历中，本月的日期列表
- (NSArray *)calculateDaysInSelectedMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSUInteger numberOfDaysInSelectedMonth = [self.firstDateInSelectedMonth numberOfDaysInMonth];
    for (NSUInteger day = 1; day <= numberOfDaysInSelectedMonth; day++) {
        [days addObject:[JBCalendarDate dateWithYear:self.firstDateInSelectedMonth.year Month:self.firstDateInSelectedMonth.month Day:day]];
    }
    
    return days;
}

//  本月日历中，下一个月第一周的日期列表
- (NSArray *)calculateDaysInFirstWeekOfFollowingMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSDate *firstDayOfTheFollowingMonth = [self.firstDateInSelectedMonth firstDayOfTheFollowingMonth];
    
    NSUInteger numberOfDaysInFollowingPartialWeek = [self numberOfDaysInFollowingPartialWeek];
//    NSLog(@"下一个月第一周的日期列表--firstDayOfTheFollowingMonth-%@ numberOfDaysInFollowingPartialWeek-%d self.firstDateInSelectedMonth-%@",firstDayOfTheFollowingMonth,numberOfDaysInFollowingPartialWeek,self.firstDateInSelectedMonth);
    for (NSUInteger day = 1; day <= numberOfDaysInFollowingPartialWeek+7; day++) {
        [days addObject:[JBCalendarDate dateWithYear:firstDayOfTheFollowingMonth.year Month:firstDayOfTheFollowingMonth.month Day:day]];
    }
    
    return days;
}


//  计算某月的相关信息
- (void)recalculateVisibleDaysInSelectedMonthWithCompletionBlock:(void (^)(NSArray *, NSArray *, NSArray *))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.daysInSelectedMonth = [self calculateDaysInSelectedMonth];
        self.daysInFinalWeekOfPreviousMonth = [self calculateDaysInFinalWeekOfPreviousMonth];
        self.daysInFirstWeekOfFollowingMonth = [self calculateDaysInFirstWeekOfFollowingMonth];
                
        self.lastDateInSelectedMonth = [[[self.daysInSelectedMonth lastObject] nsDate] endOfDay];
        
        JBCalendarDate *from = (self.daysInFinalWeekOfPreviousMonth.count > 0) ? [self.daysInFinalWeekOfPreviousMonth objectAtIndex:0] : [self.daysInSelectedMonth objectAtIndex:0];
        JBCalendarDate *to = (self.daysInFirstWeekOfFollowingMonth.count > 0) ? [self.daysInFirstWeekOfFollowingMonth lastObject] : [self.daysInSelectedMonth lastObject];
        
        self.firstDateOnCalendarOfSelectedMonth = [[from nsDate] beginingOfDay];
        self.lastDateOnCalendarOfSelectedMonth = [[to nsDate] endOfDay];
        
        if (completionBlock) {
            completionBlock(self.daysInFinalWeekOfPreviousMonth, self.daysInSelectedMonth, self.daysInFirstWeekOfFollowingMonth);
        }
        
        [self dictionaryWithPreviousUnitDays:self.daysInFinalWeekOfPreviousMonth SelectedUnitDays:self.daysInSelectedMonth FollowingUnitDays:self.daysInFirstWeekOfFollowingMonth CompletionBlock:^(NSDictionary *dictionary) {
            [self saveMonthCalendarDataToLocal:dictionary ForDate:self.selectedDate WithSuccessBlock:^{} FailureBlock:^{}];
        }];
    });
}


//////////////////////////////////////////////
//                  Week
//////////////////////////////////////////////
//  在前一个月中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekOfPreviousMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSUInteger numberOfDaysInTheWeekInMonth = [self.firstDateInSelectedWeekInSelectedMonth numberOfDaysInTheWeekInMonth];
    if (numberOfDaysInTheWeekInMonth == 7) {
        [days removeAllObjects];
        return days;
    } else {
        NSDate *firstDayOfTheWeek = [self.firstDateInSelectedWeekInSelectedMonth firstDayOfTheWeek];
        if (firstDayOfTheWeek.month == self.firstDateInSelectedWeekInSelectedMonth.month) {
            [days removeAllObjects];
            return days;
        } else {
            for (NSUInteger i = 0; i < 7 - numberOfDaysInTheWeekInMonth; i++) {
                [days addObject:[JBCalendarDate dateWithYear:firstDayOfTheWeek.year Month:firstDayOfTheWeek.month Day:firstDayOfTheWeek.day + i]];
            }
            
            return days;
        }
    }
}

//  本月日历中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekInSelectedMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSUInteger numberOfDaysInTheWeekInMonth = [self.firstDateInSelectedWeekInSelectedMonth numberOfDaysInTheWeekInMonth];
    
    if (numberOfDaysInTheWeekInMonth == 7) {
        for (NSUInteger i = 0; i < 7; i++) {
            [days addObject:[JBCalendarDate dateWithYear:self.firstDateInSelectedWeekInSelectedMonth.year Month:self.firstDateInSelectedWeekInSelectedMonth.month Day:self.firstDateInSelectedWeekInSelectedMonth.day + i]];
        }
    } else {
        for (NSUInteger i = 0; i < numberOfDaysInTheWeekInMonth; i++) {
            [days addObject:[JBCalendarDate dateWithYear:self.firstDateInSelectedWeekInSelectedMonth.year Month:self.firstDateInSelectedWeekInSelectedMonth.month Day:self.firstDateInSelectedWeekInSelectedMonth.day + i]];
        }
    }
    
    return days;
}


//  在后一个月中，本周的日期列表
- (NSArray *)calculateDaysInSelectedWeekOfFollowingMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSUInteger numberOfDaysInTheWeekInMonth = [self.firstDateInSelectedWeekInSelectedMonth numberOfDaysInTheWeekInMonth];
    if (numberOfDaysInTheWeekInMonth == 7) {
        return days;
    } else {
        NSDate *firstDayOfTheWeek = [self.firstDateInSelectedWeekInSelectedMonth firstDayOfTheWeek];
        if (firstDayOfTheWeek.month == self.firstDateInSelectedWeekInSelectedMonth.month) {
           // NSDate *firstDayOfTheFollowingMonth = [self.firstDateInSelectedWeekInSelectedMonth firstDayOfTheFollowingMonth];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.day = numberOfDaysInTheWeekInMonth;
            NSDate *firstDayOfTheFollowingMonth= [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.firstDateInSelectedWeekInSelectedMonth options:0];
            [components release];
            for (NSUInteger i = 0; i < 7 - numberOfDaysInTheWeekInMonth; i++) {
                [days addObject:[JBCalendarDate dateWithYear:firstDayOfTheFollowingMonth.year Month:firstDayOfTheFollowingMonth.month Day:firstDayOfTheFollowingMonth.day + i]];
            }
            
            return days;
        } else {
            return days;
        }
    }
}


//  计算某周的相关信息
- (void)recalculateVisibleDaysInSelectedWeekWithCompletionBlock:(void (^)(NSArray *, NSArray *, NSArray *))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.daysInSelectedWeekInPreviousMonth = [self calculateDaysInSelectedWeekOfPreviousMonth];
        
        
        self.daysInSelectedWeekInSelectedMonth = [self calculateDaysInSelectedWeekInSelectedMonth];
        self.daysInSelectedWeekInFollowingMonth = [self calculateDaysInSelectedWeekOfFollowingMonth];
        
        self.lastDateInSelectedWeekInSelectedMonth = [[[self.daysInSelectedWeekInSelectedMonth lastObject] nsDate] endOfDay];
        
        JBCalendarDate *from = (self.daysInSelectedWeekInPreviousMonth.count > 0) ? [self.daysInSelectedWeekInPreviousMonth objectAtIndex:0] : [self.daysInSelectedWeekInSelectedMonth objectAtIndex:0];
        JBCalendarDate *to = (self.daysInSelectedWeekInFollowingMonth.count > 0) ? [self.daysInSelectedWeekInFollowingMonth lastObject] : [self.daysInSelectedWeekInSelectedMonth lastObject];
        
        self.firstDateOnCalendarOfSelectedWeek = [[from nsDate] beginingOfDay];
        self.lastDateOnCalendarOfSelectedWeek = [[to nsDate] endOfDay];
        
        if (completionBlock) {
            completionBlock(self.daysInSelectedWeekInPreviousMonth, self.daysInSelectedWeekInSelectedMonth, self.daysInSelectedWeekInFollowingMonth);
        }
        
        [self dictionaryWithPreviousUnitDays:self.daysInSelectedWeekInPreviousMonth SelectedUnitDays:self.daysInSelectedWeekInSelectedMonth FollowingUnitDays:self.daysInSelectedWeekInFollowingMonth CompletionBlock:^(NSDictionary *dictionary) {
            [self saveWeekCalendarDataToLocal:dictionary ForDate:self.selectedDate WithSuccessBlock:^{} FailureBlock:^{}];
        }];
    });
}



//  --------------------本地存储--------------------
/**********************************************
 *@Description:将月份／周的日期信息数据转换为为字典
 *@Params:
 *  previousUnitDays:本月日历中，上一个月最后一周的日期列表／在前一个月中，本周的日期列表
 *  selectedUnitDays:本月日历中，本月的日期列表／本月日历中，本周的日期列表
 *  followingUnitDays:本月日历中，下一个月第一周的日期列表／  在后一个月中，本周的日期列表
 *  completionBlock:转换成功后调用的代码块
 *@Return:nil
 **********************************************/
- (void)dictionaryWithPreviousUnitDays:(NSArray *)previousUnitDays SelectedUnitDays:(NSArray *)selectedUnitDays FollowingUnitDays:(NSArray *)followingUnitDays CompletionBlock:(void (^)(NSDictionary *dictionary))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (completionBlock) {
            NSMutableArray *previous = [[NSMutableArray alloc] init];
            for (JBCalendarDate *calendarDate in previousUnitDays) {
                [previous addObject:[calendarDate dictionary]];
            }
            
            NSMutableArray *selected = [[NSMutableArray alloc] init];
            for (JBCalendarDate *calendarDate in selectedUnitDays) {
                [selected addObject:[calendarDate dictionary]];
            }
            
            NSMutableArray *following = [[NSMutableArray alloc] init];
            for (JBCalendarDate *calendarDate in followingUnitDays) {
                [following addObject:[calendarDate dictionary]];
            }
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:nilToNSNull(previous), nilToNSNull(selected), nilToNSNull(following), nil] forKeys:[NSArray arrayWithObjects:CalendarDataDicKey_Previous, CalendarDataDicKey_Selected, CalendarDataDicKey_Following, nil]];
            completionBlock(dic);
        }
    });
}

/**********************************************
 *@Description:将字典数据转换为月份／周的日期信息数据
 *@Params:
 *  dictionary:字典数据
 *  completionBlock:转换成功后调用的代码块
 *@Return:nil
 **********************************************/
- (void)getUnitDaysFromDictionary:(NSDictionary *)dictionary WithCompletionBlock:(void (^)(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (dictionary) {
            if (completionBlock) {
                NSMutableArray *previous = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [dictionary objectForKey:CalendarDataDicKey_Previous]) {
                    [previous addObject:[JBCalendarDate dateFromNSDictionary:dic]];
                }
                
                NSMutableArray *selected = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [dictionary objectForKey:CalendarDataDicKey_Selected]) {
                    [selected addObject:[JBCalendarDate dateFromNSDictionary:dic]];
                }
                
                NSMutableArray *following = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [dictionary objectForKey:CalendarDataDicKey_Following]) {
                    [following addObject:[JBCalendarDate dateFromNSDictionary:dic]];
                }
                
                completionBlock(NSNullTonil(previous), NSNullTonil(selected), NSNullTonil(following));
            }
        } else {
            if (completionBlock) {
                completionBlock(nil, nil, nil);
            }
        }
    });
}


/***********************************************
 *@Description:保存某一天对应的月份／周的日期数据到本地
 *@Params:
 *  monthData:日期数据
 *  date:日期
 *  successBlock:数据保存成功后调用的代码块
 *  failureBlock:数据保存失败后调用的代码块
 *@Return:nil
 ***********************************************/
- (void)saveMonthCalendarDataToLocal:(NSDictionary *)calendarData ForDate:(NSDate *)date WithSuccessBlock:(void (^)())successBlock FailureBlock:(void (^)())failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (calendarData) {
            NSString *path = [JBPlistFileManager pathInDocumentsWithDirPath:CalendarDataDir filePath:[NSString stringWithFormat:@"%@%i_%i", MonthDataPlistFile, date.year, date.month]];
            
            if ([JBPlistFileManager writeDicData:calendarData ToPlistFileAtPath:path]) {
                if (successBlock) {
                    successBlock();
                }
            } else {
                if (failureBlock) {
                    failureBlock(Error_Calendar_WriteToPlistFileFailed_Code, Error_Calendar_WriteToPlistFileFailed_Message);
                }
            }
        }
    });
}

- (void)saveWeekCalendarDataToLocal:(NSDictionary *)calendarData ForDate:(NSDate *)date WithSuccessBlock:(void (^)())successBlock FailureBlock:(void (^)())failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if (calendarData) {
            NSString *path = [JBPlistFileManager pathInDocumentsWithDirPath:CalendarDataDir filePath:[NSString stringWithFormat:@"%@%i_%i_%i", WeekDataPlistFile, date.year, date.month, date.week]];
            if ([JBPlistFileManager writeDicData:calendarData ToPlistFileAtPath:path]) {
                if (successBlock) {
                    successBlock();
                }
            } else {
                if (failureBlock) {
                    failureBlock(Error_Calendar_WriteToPlistFileFailed_Code, Error_Calendar_WriteToPlistFileFailed_Message);
                }
            }
        }
    });
}

/***********************************************
 *@Description:获取某一天对应的月份／周的日期的本地数据
 *@Params:
 *  date:日期
 *  successBlock:数据获取成功后调用的代码块
 *  failureBlock:数据获取失败后调用的代码块
 *@Return:nil
 ***********************************************/
- (void)getLocalMonthDataForDate:(NSDate *)date WithSuccessBlock:(void (^)(NSArray *daysInFinalWeekOfPreviousMonth, NSArray *daysInSelectedMonth, NSArray *daysInFirstWeekOfFollowingMonth))successBlock FailureBlock:(void (^)(NSInteger errorno, NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [JBPlistFileManager pathInDocumentsWithDirPath:CalendarDataDir filePath:[NSString stringWithFormat:@"%@%i_%i", MonthDataPlistFile, date.year, date.month]];
        if ([JBPlistFileManager isExistFileAtPath:path]) {
            NSDictionary *dic = [JBPlistFileManager readDicDataFromPlistFileAtPath:path];
            if (dic) {
                [self getUnitDaysFromDictionary:dic WithCompletionBlock:^(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays) {
                    if (successBlock) {
                        successBlock(previousUnitDays, selectedUnitDays, followingUnitDays);
                    }
                }];
            } else {
                if (failureBlock) {
                    if (failureBlock) {
                        failureBlock(Error_Calendar_LocalDataError_Code, Error_Calendar_LocalDataError_Message);
                    }
                }
            }
        } else {
            if (failureBlock) {
                failureBlock(Error_Calendar_NoCorrespondingLocalData_Code, Error_Calendar_NoCorrespondingLocalData_Message);
            }
        }
    });
}

- (void)getLocalWeekDataForDate:(NSDate *)date WithSuccessBlock:(void (^)(NSArray *daysInSelectedWeekInPreviousMonth, NSArray *daysInSelectedWeekInSelectedMonth, NSArray *daysInSelectedWeekInFollowingMonth))successBlock FailureBlock:(void (^)(NSInteger errorno, NSString *error))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [JBPlistFileManager pathInDocumentsWithDirPath:CalendarDataDir filePath:[NSString stringWithFormat:@"%@%i_%i_%i", WeekDataPlistFile, date.year, date.month, date.week]];
        if ([JBPlistFileManager isExistFileAtPath:path]) {
            NSDictionary *dic = [JBPlistFileManager readDicDataFromPlistFileAtPath:path];
            if (dic) {
                [self getUnitDaysFromDictionary:dic WithCompletionBlock:^(NSArray *previousUnitDays, NSArray *selectedUnitDays, NSArray *followingUnitDays) {
                    if (successBlock) {
                        successBlock(previousUnitDays, selectedUnitDays, followingUnitDays);
                    }
                }];
            } else {
                if (failureBlock) {
                    failureBlock(Error_Calendar_LocalDataError_Code, Error_Calendar_LocalDataError_Message);
                }
            }
        } else {
            if (failureBlock) {
                failureBlock(Error_Calendar_NoCorrespondingLocalData_Code, Error_Calendar_NoCorrespondingLocalData_Message);
            }
        }
    });
}


#pragma mark -
#pragma mark - Object Methods

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
- (void)moveToMonthForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSArray *daysInFinalWeekOfPreviousMonth, NSArray *daysInSelectedMonth, NSArray *daysInFirstWeekOfFollowingMonth))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (MonthDataForInit || ![self.selectedDate sameDayWithDate:date]) {
            MonthDataForInit = NO;
            
            self.selectedDate = date;
            self.firstDateInSelectedMonth = [date firstDayOfTheMonth];
            [self getMonthCalendarDataByDate:self.selectedDate WithComplectionBlock:completionBlock];
        }
    });
}



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
- (void)moveToWeekForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSArray *daysInSelectedWeekInPreviousMonth, NSArray *daysInSelectedWeekInSelectedMonth, NSArray *daysInSelectedWeekInFollowingMonth))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (WeekDataForInit || ![self.selectedDate sameDayWithDate:date]) {
            WeekDataForInit = NO;
            
            self.selectedDate = date;
            self.firstDateInSelectedWeekInSelectedMonth = [date firstDayOfTheWeekInTheMonth];
            [self getWeekCalendarDataByDate:self.selectedDate WithComplectionBlock:completionBlock];
        }
    });
}


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
- (void)moveToDayForDate:(NSDate *)date WithCompletionBlock:(void (^)(NSDate *selectedDate))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![self.selectedDate sameDayWithDate:date]) {
            self.selectedDate = date;
        }
        
        if (completionBlock) {
            completionBlock(date);
        }
    });
}

@end
