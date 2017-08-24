//
//  LGOrgViewController.h
//  eCloud
//  蓝光 通讯录 二级界面
//  Created by shisuping on 17/7/25.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#define dept_tag_base (100)

/** 搜索框高度 */
#define searchbar_height (44.0)

/** 顶部的高度  */
#define top_dept_height (51.0)
/** 顶部部门层级 激活字体颜色 #2481fc */
#define top_dept_name_active_color lg_main_color
/** 顶部部门层级 非激活字体颜色 #666666*/
#define top_dept_name_inactive_color [UIColor colorWithRed:0x66/255.0 green:0x66/255.0 blue:0x66/255.0 alpha:1.0]
/** 顶部部门层级 部门名称左右两侧的空白 */
#define top_dept_name_space (12.0)
/** 顶部部门层级 部门名称 字体大小 */
#define top_dpet_name_font_size (15.0)
/** 导航视图与tableview的间距  */
#define top_to_tableview_space (12.0)

#define DEF_HEAD_TITLE_ARR @[@"同事",@"讨论组",@"公司群",@"部门"]
typedef enum {
    title_emp,
    title_custom_group,
    title_group,
    title_dept
} headerTitle;

@class Dept;

@interface LGOrgViewController : UIViewController

@property (nonatomic,assign) int curDeptId;

/** 根据部门名称返回自定义头像的颜色和要显示的文本 */
+ (NSDictionary *)getUserDefineLogoDic:(Dept *)_dept;

@end
