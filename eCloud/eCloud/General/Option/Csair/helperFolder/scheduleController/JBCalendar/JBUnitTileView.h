//
//  JBUnitTileView.h
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
#import "JBCalendarDate.h"


#ifndef DefaultTileSize
#define DefaultTileSize
#define DefaultTileSize_W          46.0f
#define DefaultTileSize_Month_H    46.0f
#define DefaultTileSize_Week_H     60.0f
#endif

#ifndef DefaultFontSize
#define DefaultFontSize
#define DefaultFontSize_Month_Day   15.0f
#define DafaultFontSize_Month_LunarDay  9.0f
#define DefaultFontSize_Week_Day    15.0f
#define DefaultFontSize_Week_LunarDay   10.0f
#endif


#ifndef SelectedUnitTileViewNotification
#define SelectedUnitTileViewNotification    @"SelectedUnitTileViewNotification"
#endif


@protocol JBUnitTileViewDelegate;
@interface JBUnitTileView : UIView

@property (nonatomic, assign)   id <JBUnitTileViewDelegate> delegate;


//  是否是当前Unit之外的日期
@property (nonatomic, assign)   BOOL previousUnit;  //  上一个Unit
@property (nonatomic, assign)   BOOL nextUnit;      //  下一个Unit

//  是否选中
@property (nonatomic, assign)   BOOL selected;
//  日期范围内的事件量
@property (nonatomic, assign)   NSInteger eventsCount;

//  日期
@property (nonatomic, strong)   JBCalendarDate *date;


//  通常情况下的背景
@property (nonatomic, strong)   UIView *backgroundView;

//  日期中“日”显示的Label
@property (nonatomic, strong)   UILabel *dayLabel;
//  日期中“阴历”显示的Label
//@property (nonatomic, strong)   UIImageView *lunarLabel;
//  日期中“事件数量”显示的Label
@property (nonatomic, strong) UILabel *eventCountLabel;

//  日期中“日”显示的Label
@property (nonatomic, strong)   UIImageView *selectedMarkImage;

#pragma mark -
#pragma mark - 对象方法
//  更新界面显示
- (void)updateShowing;


#pragma mark -
#pragma mark - 模版方法（请勿直接调用模版方法）
/****************************************************************
 *@Description:用户按下该Tile（模版方法）
 *@Params:
 *  animated:YES-切换效果延时 NO-切换效果非延时
 *@Return:nil
 ***************************************************************/
- (void)tappedOnUnitTileView;

/****************************************************************
 *@Description:用户双击该Tile（模版方法）
 *@Params:
 *  animated:YES-切换效果延时 NO-切换效果非延时
 *@Return:nil
 ***************************************************************/
//- (void)doubleTappedOnUnitTileView;

/****************************************************************
 *@Description:用户长时间按下该Tile（模版方法）
 *@Params:
 *  animated:YES-切换效果延时 NO-切换效果非延时
 *@Return:nil
 ***************************************************************/
- (void)longPressedOnUnitTileView;



/****************************************************************
 *@Description:根据UnitTile的状态设置界面显示
 *@Params:
 *  otherUnit:是否事当前Unit之外的日期
 *  selected:是否选中
 *  today:是否是当天
 *  eventsCount:该天的事件数量
 *@Return:nil
 ***************************************************************/
- (void)updateUnitTileViewShowingWithOtherUnit:(BOOL)otherUnit Selected:(BOOL)selected Today:(BOOL)today eventsCount:(NSInteger)eventsCount;


@end


@protocol JBUnitTileViewDelegate <NSObject>

//  点击了上一个Unit中的某个unitTileView
- (void)tappedInPreviousUnitOnUnitTileView:(JBUnitTileView *)unitTileView;
//  点击当前Unit中的某个unitTileView
- (void)tappedInSelectedUnitOnUnitTileView:(JBUnitTileView *)unitTileView;
//  点击了下一个Unit中的某个unitTileView
- (void)tappedInNextUnitOnUnitTileView:(JBUnitTileView *)unitTileView;

@end