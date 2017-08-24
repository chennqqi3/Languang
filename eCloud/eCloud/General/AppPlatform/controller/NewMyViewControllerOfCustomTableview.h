//
//  NewMyViewControllerOfCustomTableview.h
//  eCloud
//
//  Created by yanlei on 15/8/27.
//  Copyright (c) 2015年  lyong. All rights reserved.
//  办公界面控制器

#import <UIKit/UIKit.h>

@interface NewMyViewControllerOfCustomTableview : UIViewController<UITableViewDataSource,UITableViewDelegate>

/** 用户点击轻应用通知启动应用，这里记录通知所带的userInfo */
@property (nonatomic,retain) NSDictionary *appInfo;

/**
 *  自动打开待办界面
 */
- (void)autoOpenAgentList;

/**
 *  状态栏的frame发生变化后，重新计算表格的frame
 */
- (void)reCalculateFrame;

/**
 *  打开轻应用H5界面，若url中包含moapproval.longfor.com关键字时url要进行加token处理
 *  openUrl         ：要跳转的url
 *  curController   ：当前控制器
 */
+ (void)openLongHuHtml5:(NSString *)openUrl withController:(UIViewController *)curController;

/**
 *  根据字符串内容和字体大小，获得所需宽度
 *  string         ：要进行计算的字符串内容
 *  font           ：字符串字体大小
 *  height         ：计算宽度给出的默认高度
 */
+ (CGFloat)widthOfString:(NSString *)string font:(UIFont *)font height:(CGFloat)height;

/**
 *  获取工作圈消息未读数 并且设置设置界面 tabbar 上的显示
 */
+ (void)unReadForWorkWorld;

@end
