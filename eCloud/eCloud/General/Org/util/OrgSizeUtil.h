//
//  OrgSizeUtil.h
//  eCloud
//  和通讯录界面布局有关的工具类
//  Created by yanlei on 15/9/6.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrgSizeUtil : NSObject

/** 导航栏 和 通讯录内容的间隔 */
+ (float)getSpaceBetweenDeptNavAndContent;

//部门导航栏字体
+ (float)getFontSizeOfDeptNav;
/**
 *  通讯录左侧部门索引在不同型号的iphone上宽度
 *
 *  @return 宽度
 */
+ (float)getLeftScrollViewWidth;
/**
 *  通讯录左侧部门索引在不同型号的iphone上每个部门的高度
 *
 *  @return 高度
 */
+ (float)getLeftScrollViewHeight;
/**
 *  通讯录人员选择界面table的内容距离左边scroller的间距
 *
 *  @return 宽度
 */
+ (float)getLeftSpaceSelectViewWidth;
@end
