//
//  OrgDeptCell.h
//  eCloud
//
//  Created by Alex L on 16/8/25.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface OrgDeptCell : MGSwipeTableCell

/** 左滑出来的选项的title */
@property (nonatomic, copy) NSString *optionButtonTitle;
/** 部门名称 */
@property (nonatomic, copy) NSString *name;
/** 添加左滑出来的按钮 */
- (void)addRightButton;

@end
