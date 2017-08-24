//
//  LGOrgViewController.h
//  eCloud
//  蓝光 通讯录 选择联系人 界面
//  Created by shisuping on 17/7/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewChooseMemberViewController.h"



//底部工具栏属性定义
//总高度
#define bottom_bar_height (44.0)

/** 头像高度 */
#define bottom_header_height (30)
/** 背景颜色 */
#define bottom_bar_bgcolor [UIColor colorWithRed:0xF8/255.0 green:0xF8/255.0 blue:0xF8/255.0 alpha:1]

/** 头像左右两个空隙 */
#define bottom_header_space (8.15 * 0.5)

/** 确定 按钮背景颜色 */
#define bottom_button_bgcolor lg_main_color

/** 确定按钮 宽度 */
#define bottom_button_width (82)

/** 确定按钮 高度 */
#define bottom_button_height (32)

/** 确定按钮两侧空隙 */
#define bottom_button_space (12)
/** 确定按钮 文本size */
#define bottom_button_text_size (13)

//scrollview总宽度
#define bottom_scrollview_width (SCREEN_WIDTH - (bottom_button_width + 2 * bottom_button_space))

/** 头像icon tag base */
#define bottom_icon_tag_base (100)


@interface LGRootChooseMemberViewController : UIViewController

/** 已经选中的人 */
@property(nonatomic,retain) NSMutableArray *nowSelectedEmpArray;


/** 最多选人数量 */
@property (nonatomic,assign) int maxSelectCount;

/**
 参数说明:
 单选还是多选
 
 YES：单选 NO：多选
 */
@property (nonatomic,assign) BOOL isSingleSelect;

/** 保存不能选择的人 */
@property(nonatomic,retain) NSArray *oldEmpIdArray;


/**
 参数说明
 选择人员delegate
 
 协议名称：ChooseMemberDelegate
 
 需要实现以下代理方法
 - (void)didSelectContacts:(NSString *)retStr;
 */
@property (nonatomic,assign) id<ChooseMemberDelegate> chooseMemberDelegate;



@end
