//
//  JBUnitView.h
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

#import <UIKit/UIKit.h>

#import "JBUnitGridView.h"
#import "NSDate+Calendar.h"

//  JBUnitView的对齐方式
typedef enum {
    JBAlignmentRuleTop,     //  上对齐
    JBAlignmentRuleBottom,  //  下对齐
} JBAlignmentRule;


@protocol JBUnitViewDelegate, JBUnitViewDataSource;
@interface JBUnitView : UIView <JBUnitGridViewDelegate, JBUnitGridViewDataSource>

@property (nonatomic, strong, readonly) UIView *calendarView;

#pragma mark -
#pragma mark - 初始化方法
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
- (id)initWithFrame:(CGRect)frame UnitType:(UnitType)unitType SelectedDate:(NSDate *)selectedDate AlignmentRule:(JBAlignmentRule)alignmentRule Delegate:(id<JBUnitViewDelegate>)delegate DataSource:(id<JBUnitViewDataSource>)dataSource;


#pragma mark -
#pragma mark - 对象方法
/**************************************************************
 *@Description:选择某个日期
 *@Params:
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)selectDate:(NSDate *)date;

/**************************************************************
 *@Description:根据选择的日期更新界面显示
 *@Params:
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)updateUnitViewWithDate:(NSDate *)date;

/**************************************************************
 *@Description:重新加载calendarDate对应的日期的事件数据
 *@Params:
 *  date:日期
 *@Return:nil
 **************************************************************/
- (void)reloadEventsWithDate:(NSDate *)date;

/**************************************************************
 *@Description:重新加载当前UnitGridView对应的事件数据
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (void)reloadEvents;

@end


@protocol JBUnitViewDelegate <NSObject>

@optional

/**************************************************************
 *@Description:获取当前UnitView中UnitTileView的高度
 *@Params:
 *  unitView:当前unitView
 *@Return:当前UnitView中UnitTileView的高度
 **************************************************************/
- (CGFloat)heightOfUnitTileViewsInUnitView:(JBUnitView *)unitView;


/**************************************************************
 *@Description:获取当前UnitView中UnitTileView的宽度
 *@Params:
 *  unitView:当前unitView
 *@Return:当前UnitView中UnitTileView的宽度
 **************************************************************/
- (CGFloat)widthOfUnitTileViewsInUnitView:(JBUnitView *)unitView;



/**************************************************************
 *@Description:更新unitView的frame
 *@Params:
 *  unitView:当前unitView
 *  newFrame:新的frame
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView UpdatingFrameTo:(CGRect)newFrame;

/**************************************************************
 *@Description:重新设置unitView的frame
 *@Params:
 *  unitView:当前unitView
 *  newFrame:新的frame
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView UpdatedFrameTo:(CGRect)newFrame;

@end


@protocol JBUnitViewDataSource <NSObject>

@required
/**************************************************************
 *@Description:获得unitTileView
 *@Params:
 *  unitView:当前unitView
 *@Return:unitTileView
 **************************************************************/
- (JBUnitTileView *)unitTileViewInUnitView:(JBUnitView *)unitView;

/**************************************************************
 *@Description:设置unitView中的weekdayView
 *@Params:
 *  unitView:当前unitView
 *@Return:weekdayView
 **************************************************************/
- (UIView *)weekdaysBarViewInUnitView:(JBUnitView *)unitView;


@optional


/**************************************************************
 *@Description:选择某一天
 *@Params:
 *  unitView:当前unitView
 *  date:选择的日期
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView SelectedDate:(NSDate *)date;


/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件的数量
 *@Params:
 *  unitView:当前unitView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView NumberOfEventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSInteger eventCount))completedBlock;

/**************************************************************
 *@Description:获取calendarDate对应的时间范围内的事件
 *@Params:
 *  unitView:当前unitView
 *  calendarDate:时间范围
 *  completedBlock:回调代码块
 *@Return:nil
 **************************************************************/
- (void)unitView:(JBUnitView *)unitView EventsInCalendarDate:(JBCalendarDate *)calendarDate WithCompletedBlock:(void (^)(NSArray *events))completedBlock;

@end