//
//  JBUnitView.m
//  JBCalendar
//
//  Created by YongbinZhang on 7/8/13.
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

#import "JBUnitView.h"
//#import "eCloudDAO.h"
//#import "helperObject.h"

@interface JBUnitView ()


@property (nonatomic, assign) id <JBUnitViewDelegate> delegate;
@property (nonatomic, assign) id <JBUnitViewDataSource> dataSource;

//  当前选择的时间
@property (nonatomic, strong) NSDate *selectedDate;

//  对齐方式
@property (nonatomic, assign) JBAlignmentRule alignmentRule;


@property (nonatomic, strong, readwrite) UIView *calendarView;


@property (nonatomic, assign) UnitType unitType;

@property (nonatomic, strong) JBUnitGridView *todayUnitGridView;
@property (nonatomic, strong) JBUnitGridView *previousUnitGridView;
@property (nonatomic, strong) JBUnitGridView *selectedUnitGridView;
@property (nonatomic, strong) JBUnitGridView *followingUnitGridView;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftGR;
- (void)selectorForSwipeLeftGR:(UISwipeGestureRecognizer *)swipeLeftGR;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightGR;
- (void)selectorForSwipeRightGR:(UISwipeGestureRecognizer *)swipeRightGR;


//  显示前一个Unit Grid View
- (void)showPreviousUnitGridViewWithDate:(JBCalendarDate *)date;
//  显示后一个Unit Grid View
- (void)showFollowingUnitGridViewWithDate:(JBCalendarDate *)date;

@end

@implementation JBUnitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];        
    }
    return self;
}

/**************************************************************
 *@Description:初始化方法
 *@Params:
 *  frame:框架
 *  unitType:月视图／周视图
 *  selectedDate:默认选中的日期
 *  alignmentRule:对齐方式
 *  delegate:协议
 *  dataSource:协议
 *@Return:JBUnitGridView对象
 **************************************************************/
- (id)initWithFrame:(CGRect)frame UnitType:(UnitType)unitType SelectedDate:(NSDate *)selectedDate AlignmentRule:(JBAlignmentRule)alignmentRule Delegate:(id<JBUnitViewDelegate>)delegate DataSource:(id<JBUnitViewDataSource>)dataSource
{
    self = [self initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.dataSource = dataSource;
        
        
        self.unitType = unitType;
        self.selectedDate = selectedDate;
        self.alignmentRule = alignmentRule;
        
        
        NSDate *previousUnitDate=nil;
        NSDate *nextUnitDate=nil;;
        if (self.unitType == UnitTypeMonth) {
            previousUnitDate = [self.selectedDate associateDayOfThePreviousMonth];
            nextUnitDate = [self.selectedDate associateDayOfTheFollowingMonth];
        } else {
            previousUnitDate = [self.selectedDate associateDayOfThePreviousWeek];
            nextUnitDate = [self.selectedDate associateDayOfTheFollowingWeek];
        }
        
        self.previousUnitGridView = [[JBUnitGridView alloc] initWithFrame:CGRectMake(0.0f - self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height) UnitType:unitType];
        self.previousUnitGridView.delegate = self;
        self.previousUnitGridView.dataSource = self;
        
        self.selectedUnitGridView = [[JBUnitGridView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height) UnitType:unitType];
        self.selectedUnitGridView.delegate = self;
        self.selectedUnitGridView.dataSource = self;
        self.selectedUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:self.selectedDate];
        self.frame = self.selectedUnitGridView.frame;
        
        self.followingUnitGridView = [[JBUnitGridView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height) UnitType:unitType];
        self.followingUnitGridView.delegate = self;
        self.followingUnitGridView.dataSource = self;
        
        
        self.calendarView = [[UIView alloc] initWithFrame:self.selectedUnitGridView.bounds];
        [self.calendarView setClipsToBounds:YES];
        [self.calendarView setContentMode:UIViewContentModeTopLeft];
        [self.calendarView addSubview:self.previousUnitGridView];
        [self.calendarView addSubview:self.followingUnitGridView];
        [self.calendarView addSubview:self.selectedUnitGridView];
        [self addSubview:self.calendarView];
        
        
        dispatch_async(dispatch_get_current_queue(), ^{
            self.previousUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:previousUnitDate];
            self.followingUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:nextUnitDate];
            
            self.swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeLeftGR:)];
            self.swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.calendarView addGestureRecognizer:self.swipeLeftGR];
            self.swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(selectorForSwipeRightGR:)];
            self.swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
            [self.calendarView addGestureRecognizer:self.swipeRightGR];
            
            self.todayUnitGridView = [[JBUnitGridView alloc] initWithFrame:CGRectMake(0.0f - self.bounds.size.width, 0.0f, self.bounds.size.width, self.bounds.size.height) UnitType:unitType];
            self.todayUnitGridView.delegate = self;
            self.todayUnitGridView.dataSource = self;
            self.todayUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:[NSDate date]];
        });
    }
    
    return self;
}


#pragma mark -
#pragma mark - Object Methods
/**************************************************************
 *@Description:选择某个日期
 *@Params:
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)selectDate:(NSDate *)date
{    
    if (![date sameDayWithDate:self.selectedDate]) {
        self.selectedDate = date;
        
//        NSDate *previousUnitDate;
//        NSDate *nextUnitDate;
//        if (self.unitType == UnitTypeMonth) {
//            
//            previousUnitDate = [self.selectedDate associateDayOfThePreviousMonth];
//            nextUnitDate = [self.selectedDate associateDayOfTheFollowingMonth];
//        } else {
//            previousUnitDate = [self.selectedDate associateDayOfThePreviousWeek];
//            nextUnitDate = [self.selectedDate associateDayOfTheFollowingWeek];
//        }
        
        
        self.selectedUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:self.selectedDate];
        CGRect tmpFrame = self.frame;
        CGFloat tmpHeight = tmpFrame.size.height;
        tmpFrame.size.height = self.selectedUnitGridView.bounds.size.height;
        if (self.alignmentRule == JBAlignmentRuleBottom) {
            tmpFrame.origin.y += tmpHeight - tmpFrame.size.height;
        }
        
        [UIView animateWithDuration:0.5f animations:^{
            self.calendarView.frame = self.selectedUnitGridView.bounds;
            self.frame = tmpFrame;
            if ([self.delegate respondsToSelector:@selector(unitView:UpdatingFrameTo:)]) {
                [self.delegate unitView:self UpdatingFrameTo:self.frame];
            }
        } completion:^(BOOL finished) {            
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.previousUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:previousUnitDate];
//                self.followingUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:nextUnitDate];
//                
//                if ([self.delegate respondsToSelector:@selector(unitView:UpdatedFrameTo:)]) {
//                    [self.delegate unitView:self UpdatedFrameTo:self.frame];
//                }
            });
        }];
    }
}

/**************************************************************
 *@Description:根据选择的日期更新界面显示
 *@Params:
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)updateUnitViewWithDate:(NSDate *)date
{
    [self.selectedUnitGridView updateUnitGridViewWithDate:[JBCalendarDate dateFromNSDate:date]];
}

/**************************************************************
 *@Description:重新加载calendarDate对应的日期的事件数据
 *@Params:
 *  date:日期
 *@Return:nil
 **************************************************************/
- (void)reloadEventsWithDate:(NSDate *)date
{
    [self.selectedUnitGridView reloadEventsWithDate:[JBCalendarDate dateFromNSDate:date]];
}

/**************************************************************
 *@Description:重新加载当前UnitGridView对应的事件数据
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (void)reloadEvents
{
    [self.selectedUnitGridView reloadEvents];
}


#pragma mark -
#pragma mark - Class Extensions
- (void)selectorForSwipeLeftGR:(UISwipeGestureRecognizer *)swipeLeftGR
{
    if (self.unitType == UnitTypeMonth) {
        [self showFollowingUnitGridViewWithDate:[JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfTheFollowingMonth]]];
         NSDate* date = [self.selectedDate associateDayOfTheFollowingMonth];
        [[NSNotificationCenter defaultCenter ]postNotificationName:@"YearMonthNotice" object:date userInfo:nil];

    } else {
        [self showFollowingUnitGridViewWithDate:[JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfTheFollowingWeek]]];
        NSDate* date = [self.selectedDate associateDayOfTheFollowingWeek];
        [[NSNotificationCenter defaultCenter ]postNotificationName:@"weekYearMonthNotice" object:date userInfo:nil];

    }
   }

- (void)selectorForSwipeRightGR:(UISwipeGestureRecognizer *)swipeRightGR
{
   
    if (self.unitType == UnitTypeMonth) {
        [self showPreviousUnitGridViewWithDate:[JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfThePreviousMonth]]];
          NSDate* date = [self.selectedDate associateDayOfThePreviousMonth];
         [[NSNotificationCenter defaultCenter ]postNotificationName:@"YearMonthNotice" object:date userInfo:nil];
    } else {
        [self showPreviousUnitGridViewWithDate:[JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfThePreviousWeek]]];
          NSDate* date = [self.selectedDate associateDayOfThePreviousWeek];
         [[NSNotificationCenter defaultCenter ]postNotificationName:@"weekYearMonthNotice" object:date userInfo:nil];
    }
   

   
}


//  显示前一个Unit Grid View
- (void)showPreviousUnitGridViewWithDate:(JBCalendarDate *)date
{       
    CGRect tmpPreviousFrame = self.previousUnitGridView.frame;
    tmpPreviousFrame.origin.y = 0.0f;
    self.previousUnitGridView.frame = tmpPreviousFrame;
    tmpPreviousFrame.origin.x = 0.0f;
    
    
    CGRect tmpSelectedFrame = self.selectedUnitGridView.frame;
    tmpSelectedFrame.origin.y = 0.0f;
    self.selectedUnitGridView.frame = tmpSelectedFrame;
    tmpSelectedFrame.origin.x = self.bounds.size.width;
    
    
    CGRect tmpFollowingFrame = self.followingUnitGridView.frame;
    tmpFollowingFrame.origin.y = 0.0f;
    tmpFollowingFrame.origin.x = 0.0f - self.bounds.size.width;
    self.followingUnitGridView.frame = tmpFollowingFrame;
    
    
    CGRect tmpFrame = self.frame;
    CGFloat tmpHeight = tmpFrame.size.height;
    tmpFrame.size.height = tmpPreviousFrame.size.height;
    if (self.alignmentRule == JBAlignmentRuleBottom) {
        tmpFrame.origin.y += tmpHeight - tmpFrame.size.height;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = tmpFrame;
        if ([self.delegate respondsToSelector:@selector(unitView:UpdatingFrameTo:)]) {
            [self.delegate unitView:self UpdatingFrameTo:self.frame];
        }
        self.calendarView.frame = tmpPreviousFrame;
        self.previousUnitGridView.frame = tmpPreviousFrame;
        self.selectedUnitGridView.frame = tmpSelectedFrame;
    } completion:^(BOOL finished) {        
        NSDate *previousUnitDate;
        if (self.unitType == UnitTypeMonth) {
            self.selectedDate = [self.selectedDate associateDayOfThePreviousMonth];
            previousUnitDate = [self.selectedDate associateDayOfThePreviousMonth];
        } else {
            self.selectedDate = [self.selectedDate associateDayOfThePreviousWeek];
            previousUnitDate = [self.selectedDate associateDayOfThePreviousWeek];
        }
        
        if ([self.delegate respondsToSelector:@selector(unitView:UpdatedFrameTo:)]) {
            [self.delegate unitView:self UpdatedFrameTo:self.frame];
        }
        
        JBUnitGridView *tmpUnitGridView = self.followingUnitGridView;
        self.followingUnitGridView = self.selectedUnitGridView;        
        self.selectedUnitGridView = self.previousUnitGridView;
        self.previousUnitGridView = tmpUnitGridView;
        
        CGRect tmpPreviousFrame = self.previousUnitGridView.frame;
        tmpPreviousFrame.origin.x = 0.0f - self.bounds.size.width;
        self.previousUnitGridView.frame = tmpPreviousFrame;
        self.previousUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:previousUnitDate];
    }];
}

//  显示后一个Unit Grid View
- (void)showFollowingUnitGridViewWithDate:(JBCalendarDate *)date
{        
    CGRect tmpPreviousFrame = self.previousUnitGridView.frame;
    tmpPreviousFrame.origin.y = 0.0f;
    tmpPreviousFrame.origin.x = self.bounds.size.width;
    self.previousUnitGridView.frame = tmpPreviousFrame;
    
    
    CGRect tmpSelectedFrame = self.selectedUnitGridView.frame;
    tmpSelectedFrame.origin.y = 0.0f;
    self.selectedUnitGridView.frame = tmpSelectedFrame;
    tmpSelectedFrame.origin.x = 0.0f - self.bounds.size.width;
    
    
    CGRect tmpFollowingFrame = self.followingUnitGridView.frame;
    tmpFollowingFrame.origin.y = 0.0f;
    self.followingUnitGridView.frame = tmpFollowingFrame;
    tmpFollowingFrame.origin.x = 0.0f;
    
    CGRect tmpFrame = self.frame;
    CGFloat tmpHeight = tmpFrame.size.height;
    tmpFrame.size.height = tmpFollowingFrame.size.height;
    if (self.alignmentRule == JBAlignmentRuleBottom) {
        tmpFrame.origin.y += tmpHeight - tmpFrame.size.height;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.frame = tmpFrame;
        if ([self.delegate respondsToSelector:@selector(unitView:UpdatingFrameTo:)]) {
            [self.delegate unitView:self UpdatingFrameTo:self.frame];
        }
        
        self.calendarView.frame = tmpFollowingFrame;
        self.selectedUnitGridView.frame = tmpSelectedFrame;
        self.followingUnitGridView.frame = tmpFollowingFrame;
    } completion:^(BOOL finished) {        
        NSDate *followingUnitDate;
        if (self.unitType == UnitTypeMonth) {
            self.selectedDate = [self.selectedDate associateDayOfTheFollowingMonth];
            followingUnitDate = [self.selectedDate associateDayOfTheFollowingMonth];
        } else {
            self.selectedDate = [self.selectedDate associateDayOfTheFollowingWeek];
            followingUnitDate = [self.selectedDate associateDayOfTheFollowingWeek];
        }
      
        if ([self.delegate respondsToSelector:@selector(unitView:UpdatedFrameTo:)]) {
            [self.delegate unitView:self UpdatedFrameTo:self.frame];
        }
        
        JBUnitGridView *tmpUnitGridView = self.previousUnitGridView;
        self.previousUnitGridView = self.selectedUnitGridView;
        self.selectedUnitGridView = self.followingUnitGridView;
        self.followingUnitGridView = tmpUnitGridView;
        
        CGRect tmpFollowingFrame = self.followingUnitGridView.frame;
        tmpFollowingFrame.origin.x = self.bounds.size.width;
        self.followingUnitGridView.frame = tmpPreviousFrame;
        self.followingUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:followingUnitDate];
    }];
}


#pragma mark -
#pragma mark - Settor
- (void)setSelectedDate:(NSDate *)selectedDate
{
    if (selectedDate && ![selectedDate isEqualToDate:_selectedDate]) {
        _selectedDate = [selectedDate retain];
        
        if ([self.dataSource respondsToSelector:@selector(unitView:SelectedDate:)]) {
            [self.dataSource unitView:self SelectedDate:_selectedDate];
        }
    }
}


#pragma mark -
#pragma mark - JBUnitGridViewDelegate
/**************************************************************
 *@Description:获取当前UnitGridView中UnitTileView的高度
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:当前unitGridView中UnitTileView的高度
 **************************************************************/
- (CGFloat)heightOfUnitTileViewsInUnitGridView:(JBUnitGridView *)unitGridView
{
    if ([self.delegate respondsToSelector:@selector(heightOfUnitTileViewsInUnitView:)]) {
        return [self.delegate heightOfUnitTileViewsInUnitView:self];
    }
    
    if (unitGridView.unitType == UnitTypeMonth) {
        return DefaultTileSize_Month_H;
    } else {
        return DefaultTileSize_Week_H;
    }
}


/**************************************************************
 *@Description:获取当前UnitGridView中UnitTileView的宽度
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:当前UnitGridView中UnitTileView的宽度
 **************************************************************/
- (CGFloat)widthOfUnitTileViewsInUnitGridView:(JBUnitGridView *)unitGridView
{
    if ([self.delegate respondsToSelector:@selector(widthOfUnitTileViewsInUnitView:)]) {
        return [self.delegate widthOfUnitTileViewsInUnitView:self];
    }
    
    return DefaultTileSize_W;
}


/**************************************************************
 *@Description:选中了当前Unit的上一个Unit中的时间点
 *@Params:
 *  unitGridView:当前unitGridView
 *  date:选中的时间点
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedOnPreviousUnitWithDate:(JBCalendarDate *)date
{
     self.selectedDate = [date nsDate];
    if (self.unitType == UnitTypeMonth)
    {  [[NSNotificationCenter defaultCenter ]postNotificationName:@"DayActionNotice" object:[date nsDate] userInfo:nil];
      
    }
    else
    {
        [[NSNotificationCenter defaultCenter ]postNotificationName:@"weekYearMonthNotice" object:[date nsDate] userInfo:nil];
    }
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy年MM月dd";
    NSString* dateString = [fmt stringFromDate:[date nsDate]];
   NSLog(@"-here-selectedOnPreviousUnitWithDate-当前--%@",dateString);
   
    //[self showPreviousUnitGridViewWithDate:date];
}

/**************************************************************
 *@Description:选中了当前Unit中的时间点
 *@Params:
 *  unitGridView:当前unitGridView
 *  date:选中的时间点
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedDate:(JBCalendarDate *)date
{
    
    self.selectedDate = [date nsDate];
//    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
//    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
//    fmt.dateFormat = @"yyyy年MM月dd";
//    NSString* dateString = [fmt stringFromDate:self.selectedDate];
   // NSLog(@"-here--当前--%@",dateString);
    if (self.unitType == UnitTypeMonth) {
    
        [[NSNotificationCenter defaultCenter ]postNotificationName:@"DayActionNotice" object:[date nsDate] userInfo:nil];
        
        self.previousUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfThePreviousMonth]];
        self.followingUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfTheFollowingMonth]];
        
    } else {
      //  NSLog(@"--- week--here --  %@",dateString);

        [[NSNotificationCenter defaultCenter ]postNotificationName:@"weekYearMonthNotice" object: self.selectedDate userInfo:nil];
        self.previousUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfThePreviousWeek]];
        self.followingUnitGridView.selectedDate = [JBCalendarDate dateFromNSDate:[self.selectedDate associateDayOfTheFollowingWeek]];
    }
}

/**************************************************************
 *@Description:选中了当前Unit的下一个Unit中的时间点
 *@Params:
 *  unitGridView:当前unitGridView
 *  date:选中的时间点
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView selectedOnNextUnitWithDate:(JBCalendarDate *)date
{
    self.selectedDate = [date nsDate];
    if (self.unitType == UnitTypeMonth)
    {
    [[NSNotificationCenter defaultCenter ]postNotificationName:@"DayActionNotice" object:[date nsDate] userInfo:nil];
   
    }
    else
    {[[NSNotificationCenter defaultCenter ]postNotificationName:@"weekYearMonthNotice" object:[date nsDate] userInfo:nil];
    }
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"yyyy年MM月dd";
    NSString* dateString = [fmt stringFromDate:[date nsDate]];
    NSLog(@"-here-selectedOnNextUnitWithDate-当前--%@",dateString);
  //  [self showFollowingUnitGridViewWithDate:date];
}


#pragma mark -
#pragma mark - JBUnitGridViewDataSource
/**************************************************************
 *@Description:获得unitTileView
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:unitTileView
 **************************************************************/
- (JBUnitTileView *)unitTileViewInUnitGridView:(JBUnitGridView *)unitGridView
{
    if ([self.dataSource respondsToSelector:@selector(unitTileViewInUnitView:)]) {
        return [self.dataSource unitTileViewInUnitView:self];
    }
        
    return [[JBUnitTileView alloc] initWithFrame:CGRectZero];
}

/**************************************************************
 *@Description:设置unitGridView中的weekdaysBarView
 *@Params:
 *  unitGridView:当前unitGridView
 *@Return:weekdaysBarView
 **************************************************************/
- (UIView *)weekdaysBarViewInUnitGridView:(JBUnitGridView *)unitGridView
{
    if ([self.dataSource respondsToSelector:@selector(weekdaysBarViewInUnitView:)]) {
        return [self.dataSource weekdaysBarViewInUnitView:self];
    }
    
    return [[JBWeekdaysBarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, DefaultWeekdaysBarHeight)];
}


/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件的数量
 *@Params:
 *  unitGridView:当前unitGridView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView NumberOfEventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSInteger eventCount))completedBlock
{
    if ([self.dataSource respondsToSelector:@selector(unitView:NumberOfEventsInCalendarDate:WithCompletedBlock:)]) {
        [self.dataSource unitView:self NumberOfEventsInCalendarDate:calendarDate WithCompletedBlock:completedBlock];
    } else {
        completedBlock(0);
    }
}

/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件
 *@Params:
 *  unitGridView:当前unitGridView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitGridView:(JBUnitGridView *)unitGridView EventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSArray *events))completedBlock
{
    if ([self.dataSource respondsToSelector:@selector(unitView:EventsInCalendarDate:WithCompletedBlock:)]) {
        [self.dataSource unitView:self EventsInCalendarDate:calendarDate WithCompletedBlock:completedBlock];
    } else {
        completedBlock(nil);
    }
}

@end
