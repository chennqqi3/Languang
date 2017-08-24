//
//  JBUnitGridView.m
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

#import "JBUnitGridView.h"

#ifndef TileCountInOneLine
#define TileCountInOneLine  7
#endif

#ifndef MaxTileRowInUnit
#define MaxTileRowInUnit
#define MaxTileRowInUnit_Month    6
#define MaxTileRowInUnit_Week     1
#endif


typedef struct {
    unsigned int row;   //  行
    unsigned int line;  //  列
} UnitTilePosition;



@interface JBUnitGridView ()

//  该UnitGridView中所有的UnitTileViews的Width
@property (nonatomic, assign) CGFloat unitTileViewWidth;
//  该UnitGridView中所有的UnitTileViews的Height
@property (nonatomic, assign) CGFloat unitTileViewHeight;


//  月视图 or 周视图
@property (nonatomic, assign, readwrite) UnitType unitType;

//  weekdaysBarView
@property (nonatomic, retain) UIView *weekdaysBarView;

//  月视图中的所有unitTileView
@property (nonatomic, retain) NSMutableArray *monthTileViews;
//  周视图中的所有unitTileView
@property (nonatomic, retain) NSMutableArray *weekTileViews;

//  当前Unit中的TileViews
@property (nonatomic, retain) NSMutableArray *tileViewsInSelectedUnit;

//  选中的unitTileView
@property (nonatomic, retain) JBUnitTileView *selectedUnitTileView;

//  计算日期
@property (nonatomic, retain) JBCalendarLogic *calendarLogic;


//  根据时间获取对应的JBUnitTileView对象
- (JBUnitTileView *)unitTileViewByCalendarDate:(JBCalendarDate *)calendarDate;


//  月视图中tile的数量
@property (nonatomic, assign) NSInteger monthTilesCount;
//  周视图中tile的数量
@property (nonatomic, assign) NSInteger weekTilesCount;


/**************************************************************
 *@Description:重新加载Tiles
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (void)reloadTiles;


@property (nonatomic, assign) dispatch_once_t onceToken;

@end


@implementation JBUnitGridView


#pragma mark -
#pragma mark - init
/**************************************************************
 *@Description:初始化方法
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        [self setUserInteractionEnabled:YES];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.dataSource = nil;
        self.delegate = nil;
        
        self.calendarLogic = [[JBCalendarLogic alloc] init];
        
        self.monthTileViews = [[NSMutableArray alloc] init];
        self.weekTileViews = [[NSMutableArray alloc] init];
        
        self.tileViewsInSelectedUnit = [[NSMutableArray alloc] init];
    }
    return self;
}

/**************************************************************
 *@Description:初始化方法
 *@Params:
 *  frame:框架
 *  unitType:月视图／周视图
 *@Return:JBUnitGridView对象
 **************************************************************/
- (id)initWithFrame:(CGRect)frame UnitType:(UnitType)unitType
{
    self = [self initWithFrame:frame];
    if (self) {
        self.unitType = unitType;
        self.unitTileViewWidth = self.bounds.size.width / TileCountInOneLine;
        
        if (self.unitType == UnitTypeMonth) {
            self.unitTileViewHeight = self.unitTileViewWidth;
        } else {
            self.unitTileViewHeight = DefaultTileSize_Week_H;
        }
    }
    
    return self;
}



#pragma mark -
#pragma mark - Object Methods
/**************************************************************
 *@Description:根据date刷新界面显示
 *@Params:
 *  date:选中的日期
 *@Return:nil
 **************************************************************/
- (void)updateUnitGridViewWithDate:(JBCalendarDate *)date
{
    JBUnitTileView *tileView = [self unitTileViewByCalendarDate:date];
    [tileView updateShowing];
}


/**************************************************************
 *@Description:重新加载calendarDate对应的日期的事件数据
 *@Params:
 *  date:日期
 *@Return:nil
 **************************************************************/
- (void)reloadEventsWithDate:(JBCalendarDate *)date
{
    if ([self.dataSource respondsToSelector:@selector(unitGridView:NumberOfEventsInCalendarDate:WithCompletedBlock:)]) {
        JBUnitTileView *tileView = [self unitTileViewByCalendarDate:date];
        if (tileView) {
            [self.dataSource unitGridView:self NumberOfEventsInCalendarDate:date WithCompletedBlock:^(NSInteger eventCount) {
                tileView.eventsCount = eventCount;
                [tileView updateShowing];
            }];
        }
    }
}

/**************************************************************
 *@Description:重新加载事件数据以显示界面
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (void)reloadEvents
{
    if ([self.dataSource respondsToSelector:@selector(unitGridView:NumberOfEventsInCalendarDate:WithCompletedBlock:)]) {
                
        for (JBUnitTileView *tileView in self.tileViewsInSelectedUnit) {
            [self.dataSource unitGridView:self NumberOfEventsInCalendarDate:tileView.date WithCompletedBlock:^(NSInteger eventCount) {
                tileView.eventsCount = eventCount;
                [tileView updateShowing];
            }];
        }
    }
}


#pragma mark -
#pragma mark - Class Extensions
//  根据时间获取对应的JBUnitTileView对象
- (JBUnitTileView *)unitTileViewByCalendarDate:(JBCalendarDate *)calendarDate
{
    if (self.unitType == UnitTypeMonth) {
        for (JBUnitTileView *tileView in self.monthTileViews) {
            if ([tileView.date compare:calendarDate] == NSOrderedSame) {
                return tileView;
            }
        }
    } else if (self.unitType == UnitTypeWeek) {
        for (JBUnitTileView *tileView in self.weekTileViews) {
            if ([tileView.date compare:calendarDate] == NSOrderedSame) {
                return tileView;
            }
        }
    }
    
    return nil;
}

/**************************************************************
 *@Description:重新加载Tiles
 *@Params:nil
 *@Return:nil
 **************************************************************/
- (void)reloadTiles
{
    dispatch_once(&_onceToken, ^{
        if (!self.weekdaysBarView) {
            self.weekdaysBarView = [[JBWeekdaysBarView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, DefaultWeekdaysBarHeight)];
        }
        CGRect tmpFrame = self.weekdaysBarView.frame;
        tmpFrame.origin = CGPointZero;
        self.weekdaysBarView.frame = tmpFrame;
        [self addSubview:self.weekdaysBarView];
                
        if (self.unitType == UnitTypeMonth) {
            for (NSInteger i = 0; i < MaxTileRowInUnit_Month; i++) {
                for (NSInteger j = 0; j < TileCountInOneLine; j++) {
                    UnitTilePosition position;
                    position.row = i;
                    position.line = j;
                    
                    JBUnitTileView *tileView = nil;
                    if (self.dataSource) {
                        tileView = [self.dataSource unitTileViewInUnitGridView:self];
                        tileView.frame = CGRectMake(j * self.unitTileViewWidth, self.weekdaysBarView.bounds.size.height + i * self.unitTileViewHeight, self.unitTileViewWidth, self.unitTileViewHeight);
                    } else {
                        tileView = [[JBUnitTileView alloc] initWithFrame:CGRectMake(j * self.unitTileViewWidth, self.weekdaysBarView.bounds.size.height + i * self.unitTileViewHeight, self.unitTileViewWidth, self.unitTileViewHeight)];
                    }
                    
                    tileView.delegate = self;
                    [self.monthTileViews addObject:tileView];
                    [self addSubview:tileView];
                }
            }
           
        } else if (self.unitType == UnitTypeWeek){
            for (NSInteger i = 0; i < MaxTileRowInUnit_Week; i++) {
                for (NSInteger j = 0; j < TileCountInOneLine; j++) {
                    UnitTilePosition position;
                    position.row = i;
                    position.line = j;
                    
                    JBUnitTileView *tileView = nil;
                    if (self.dataSource) {
                        tileView = [self.dataSource unitTileViewInUnitGridView:self];
                        tileView.frame = CGRectMake(j * self.unitTileViewWidth, self.weekdaysBarView.bounds.size.height + i * self.unitTileViewHeight, self.unitTileViewWidth, self.unitTileViewHeight);
                    } else {
                        tileView = [[JBUnitTileView alloc] initWithFrame:CGRectMake(j * self.unitTileViewWidth, self.weekdaysBarView.bounds.size.height + i * self.unitTileViewHeight, self.unitTileViewWidth, self.unitTileViewHeight)];
                    }
                    
                    tileView.delegate = self;
                    [self.weekTileViews addObject:tileView];
                    [self addSubview:tileView];
                }
            }
        }
    });
    
    [self.tileViewsInSelectedUnit removeAllObjects];
    
    switch (self.unitType) {
        case UnitTypeMonth:{
            CGRect tmpFrame = self.frame;
            tmpFrame.size.height = [[self.selectedDate nsDate] numberOfWeeksInMonth] * self.unitTileViewHeight + self.weekdaysBarView.bounds.size.height;
            self.frame = tmpFrame;
            
            [self.calendarLogic moveToMonthForDate:[self.selectedDate nsDate] WithCompletionBlock:^(NSArray *daysInFinalWeekOfPreviousMonth, NSArray *daysInSelectedMonth, NSArray *daysInFirstWeekOfFollowingMonth) {
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.monthTilesCount = 0;

                    if (daysInFinalWeekOfPreviousMonth && daysInFinalWeekOfPreviousMonth.count > 0) {
                        for (JBCalendarDate *date in daysInFinalWeekOfPreviousMonth) {
                            JBUnitTileView *tileView = [self.monthTileViews objectAtIndex:self.monthTilesCount];
                            tileView.previousUnit = YES;
                            tileView.nextUnit = NO;
                            tileView.selected = NO;
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                                                        
                            self.monthTilesCount++; //NSLog(@"daysInFinalWeekOfPreviousMonth self.monthTilesCount -- %d",self.monthTilesCount);
                        }
                        
                    }
                    
                    if (daysInSelectedMonth && daysInSelectedMonth.count > 0) {
                        for (JBCalendarDate *date in daysInSelectedMonth) {
                            JBUnitTileView *tileView = [self.monthTileViews objectAtIndex:self.monthTilesCount];
                            tileView.previousUnit = NO;
                            tileView.nextUnit = NO;
                            
                            if ([date compare:self.selectedDate] == NSOrderedSame) {
                                tileView.selected = YES;
                                self.selectedUnitTileView = tileView;
                            } else {
                                tileView.selected = NO;
                            }
                            
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                            
                            [self.tileViewsInSelectedUnit addObject:tileView];
                            
                            self.monthTilesCount++; //NSLog(@"daysInSelectedMonth self.monthTilesCount -- %d",self.monthTilesCount);
                        }
                        
                        [self performSelector:@selector(reloadEvents)];
                    }
                    
                    if (daysInFirstWeekOfFollowingMonth && daysInFirstWeekOfFollowingMonth.count > 0) {
                        for (JBCalendarDate *date in daysInFirstWeekOfFollowingMonth) {
                            if (self.monthTilesCount>=42) {
                                break;
                            }
                            JBUnitTileView *tileView = [self.monthTileViews objectAtIndex:self.monthTilesCount];
                            tileView.previousUnit = NO;
                            tileView.nextUnit = YES;
                            tileView.selected = NO;
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                                                        
                            self.monthTilesCount++;// NSLog(@"daysInFirstWeekOfFollowingMonth self.monthTilesCount -- %d %@",self.monthTilesCount,date.nsDate);
                        }
                        
                    }
                });
            }];
            
            
            break;
        }
        
        case UnitTypeWeek:{
            CGRect tmpFrame = self.frame;
            tmpFrame.size.height = self.unitTileViewHeight + self.weekdaysBarView.bounds.size.height;
            self.frame = tmpFrame;
            
            [self.calendarLogic moveToWeekForDate:[self.selectedDate nsDate] WithCompletionBlock:^(NSArray *daysInSelectedWeekInPreviousMonth, NSArray *daysInSelectedWeekInSelectedMonth, NSArray *daysInSelectedWeekInFollowingMonth) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.weekTilesCount = 0;

                    if (daysInSelectedWeekInPreviousMonth && daysInSelectedWeekInPreviousMonth.count > 0) {
                        for (JBCalendarDate *date in daysInSelectedWeekInPreviousMonth) {
                            JBUnitTileView *tileView = [self.weekTileViews objectAtIndex:self.weekTilesCount];
                            tileView.previousUnit = YES;
                            tileView.nextUnit = NO;
                            tileView.selected = NO;
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                            
                            self.weekTilesCount++;
                        }
                    }
                    
                    if (daysInSelectedWeekInSelectedMonth && daysInSelectedWeekInSelectedMonth.count > 0) {
                        for (JBCalendarDate *date in daysInSelectedWeekInSelectedMonth) {
                            JBUnitTileView *tileView = [self.weekTileViews objectAtIndex:self.weekTilesCount];
                            tileView.previousUnit = NO;
                            tileView.nextUnit = NO;
                            
                            if ([date compare:self.selectedDate] == NSOrderedSame) {
                                tileView.selected = YES;
                                self.selectedUnitTileView = tileView;
                            } else {
                                tileView.selected = NO;
                            }
                            
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                            
                            [self.tileViewsInSelectedUnit addObject:tileView];
                            
                            self.weekTilesCount++;
                        }
                        
                        [self performSelector:@selector(reloadEvents)];
                    }
                    
                    if (daysInSelectedWeekInFollowingMonth && daysInSelectedWeekInFollowingMonth.count > 0) {
                        for (JBCalendarDate *date in daysInSelectedWeekInFollowingMonth) {
                            JBUnitTileView *tileView = [self.weekTileViews objectAtIndex:self.weekTilesCount];
                            tileView.previousUnit = NO;
                            tileView.nextUnit = YES;
                            tileView.selected = NO;
                            tileView.eventsCount = 0;
                            tileView.date = date;
                            [tileView updateShowing];
                            
                            self.weekTilesCount++;
                        }
                    }
                });
            }];
            
            break;
        }
            
        default:
            break;
    }    
}


#pragma mark -
#pragma mark - Setter
- (void)setSelectedDate:(JBCalendarDate *)selectedDate
{
    if (selectedDate && [selectedDate isKindOfClass:[JBCalendarDate class]]) {
        if (!_selectedDate) {
            _selectedDate = selectedDate;
            [self reloadTiles];
        } else {
            self.selectedUnitTileView.selected = NO;
            [self.selectedUnitTileView updateShowing];
            
            if ([_selectedDate compare:selectedDate] != NSOrderedSame) {
                if (self.unitType == UnitTypeMonth) {
                    //  检查是否是同一个月
                    if (_selectedDate.month != selectedDate.month) {
                        _selectedDate = selectedDate;
                        [self reloadTiles];
                    } else {
                        _selectedDate = selectedDate;
                    }
                } else {
                    //  检查是否是同一周
                    if (![[_selectedDate nsDate] sameWeekWithDate:[selectedDate nsDate]]) {
                        _selectedDate = selectedDate;
                        [self reloadTiles];
                    } else {
                        _selectedDate = selectedDate;
                    }
                }
            }
            
            self.selectedUnitTileView = [self unitTileViewByCalendarDate:_selectedDate];
            if (self.selectedUnitTileView) {
                self.selectedUnitTileView.selected = YES;
                [self.selectedUnitTileView updateShowing];
            }
        }
    }
}

- (void)setDelegate:(id<JBUnitGridViewDelegate>)delegate
{
    if (delegate && ![delegate isEqual:_delegate]) {
        _delegate = delegate;
        
        if ([_delegate respondsToSelector:@selector(heightOfUnitTileViewsInUnitGridView:)]) {
            self.unitTileViewHeight = [_delegate heightOfUnitTileViewsInUnitGridView:self];
        }
        
        if ([_delegate respondsToSelector:@selector(widthOfUnitTileViewsInUnitGridView:)]) {
            self.unitTileViewWidth = [_delegate widthOfUnitTileViewsInUnitGridView:self];
        }
    }
}

- (void)setDataSource:(id<JBUnitGridViewDataSource>)dataSource
{
    if (dataSource && ![dataSource isEqual:_dataSource]) {
        _dataSource = dataSource;
        
        if (![_dataSource respondsToSelector:@selector(unitTileViewInUnitGridView:)]) {
            NSAssert(NO, @"Protocol Method (unitTileViewInUnitGridView:) must be implemented.");
        } else {
            JBUnitTileView *tileView = [_dataSource unitTileViewInUnitGridView:self];
            if (!tileView || ![tileView isKindOfClass:[JBUnitTileView class]]) {
                NSAssert(NO, @"A JBUnitTileView object must be returned in (unitTileViewInUnitGridView:) method.");
            }
        }
        
        
        if (![_dataSource respondsToSelector:@selector(weekdaysBarViewInUnitGridView:)]) {
            NSAssert(NO, @"Protocol Methods (weekdaysBarViewInUnitGridView:) must be implemented.");
        } else {
            self.weekdaysBarView = [_dataSource weekdaysBarViewInUnitGridView:self];
            if (!self.weekdaysBarView || ![self.weekdaysBarView isKindOfClass:[UIView class]]) {
                NSAssert(NO, @"A UIView object must be returned in (weekdaysBarViewInUnitGridView:) methods.");
            }
        }
    }
}



#pragma mark -
#pragma mark - JBUnitTileViewDelegate
//  点击了上一个Unit中的某个unitTileView
- (void)tappedInPreviousUnitOnUnitTileView:(JBUnitTileView *)unitTileView
{
//    if (self.unitType==UnitTypeWeek) {
       self.selectedDate = unitTileView.date;
//    }
    if ([self.delegate respondsToSelector:@selector(unitGridView:selectedOnPreviousUnitWithDate:)]) {
        [self.delegate unitGridView:self selectedOnPreviousUnitWithDate:unitTileView.date];
    }
}

//  点击当前Unit中的某个unitTileView
- (void)tappedInSelectedUnitOnUnitTileView:(JBUnitTileView *)unitTileView
{
    self.selectedDate = unitTileView.date;
    
    if ([self.delegate respondsToSelector:@selector(unitGridView:selectedDate:)]) {
        [self.delegate unitGridView:self selectedDate:unitTileView.date];
    }
}

//  点击了下一个Unit中的某个unitTileView
- (void)tappedInNextUnitOnUnitTileView:(JBUnitTileView *)unitTileView
{
   // if (self.unitType==UnitTypeWeek) {
        self.selectedDate = unitTileView.date;
  //  }
    if ([self.delegate respondsToSelector:@selector(unitGridView:selectedOnNextUnitWithDate:)]) {
        [self.delegate unitGridView:self selectedOnNextUnitWithDate:unitTileView.date];
    }
}

@end
