//
//  NewOrgViewController.h
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DAOverlayView;
@class Dept;
@class NewDeptCell;

@interface NewOrgViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>{
    UIScrollView *scrollView;
}
/** 当前部门的人员 */
@property (nonatomic,retain)NSMutableArray *itemArray;
/** 群组数组 */
@property (nonatomic,retain)NSMutableArray *groupArray;
/** 部门数组 */
@property (nonatomic,retain)NSMutableArray *deptArray;
/** 搜索结果 */
@property (nonatomic,retain)NSMutableArray *searchResults;
/** 用来记录之前的层级所在的位置，返回时就让界面在上次离开时的位置 */
@property (nonatomic,retain)NSMutableArray *contentOffSetYArray;
/** 该属性已废弃 */
@property (nonatomic,retain) NSTimer *searchTimer;
/** 搜索的关键字 */
@property (nonatomic,retain) NSString *searchStr;
/** 删除的部门的下标 (如果是常用部门里删除 则从table中移除) */
@property (nonatomic,retain) NSIndexPath *removeIndexPath;

/** 可以左滑的cell */
@property (retain, nonatomic) NewDeptCell *cellDisplayingMenuOptions;
/** 在编辑状态时的遮罩层 */
@property (retain, nonatomic) DAOverlayView *overlayView;
/** 是否在编辑状态 */
@property (assign, nonatomic) BOOL customEditing;
/** 动画是否已经完成 */
@property (assign, nonatomic) BOOL customEditingAnimationInProgress;
/** 在编辑状态时让其它地方不能点击 */
@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;
/**打开用户资料*/
+ (void)openUserInfoById:(NSString *)empId andCurController:(UIViewController *)curController;
/** 重新计算tableView的宽度 */
- (void)reCalculateFrame;
/** 获取南航的根部门 */
+ (NSArray *)getCsairRootOrgItems;
/** 获取南航的根部门 */
+ (NSArray *)getRootOrgItems;
/** 获取祥源的根部门 */
+ (NSArray *)getXIANGYUANRootOrgItems;
/** 获取碧桂园的根部门 */
+ (NSArray *)getBGYRootOrgItems;

#pragma mark =====提供给SDK调用的接口======

/**
 功能描述：
 获取导航栏右侧按钮
 */
- (UIButton *)rightBarButton;

/**
 功能描述：
 点击导航栏右侧按钮事件
 */
- (void)onRightBarButton;

@end
