//
//  NewDeptCell.h
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import <UIKit/UIKit.h>
#define dept_row_height (45.0)
#define arrow_image_tag (101)
#define dept_name_tag (102)
#define dept_emp_count_tag (103)

#define name_font_size (17.0)
#define emp_count_font_size (12.0)
#import "QueryResultCell.h"

@class Dept;
@interface NewDeptCell : UITableViewCell<UIGestureRecognizerDelegate>{
    
}

/** 相当于contentView */
@property (nonatomic,retain) UIView *cellView;
/** 该属性已废弃 */
@property (assign, nonatomic, getter = isContextMenuHidden) BOOL contextMenuHidden;
/** 删除按钮的标题 */
@property (retain, nonatomic) NSString *deleteButtonTitle;
/** 是否可编辑 */
@property (assign, nonatomic) BOOL editable;
/** 左滑显示范围 */
@property (assign, nonatomic) CGFloat menuOptionButtonTitlePadding;
/** 取消编辑状态所需的时间 */
@property (assign, nonatomic) CGFloat menuOptionsAnimationDuration;
/** 可以超出左滑显示范围的距离 */
@property (assign, nonatomic) CGFloat bounceValue;
/** 删除按钮 */
@property (retain, nonatomic) UIButton *deleteButton;

@property (assign, nonatomic) id<menuCellDelegate> delegate;

- (void)configCell:(Dept *)dept;

#pragma mark 把需要显示的view增加到cell中，因为要和带选择功能的cell共用，所以增加了这个接口
+ (void)addCommonView:(UITableViewCell *)cell;

-(void)configContextMenuView;

/** 搜索结果里有部门 */
- (void)configSearchResultCell:(Dept *)dept;

@end
