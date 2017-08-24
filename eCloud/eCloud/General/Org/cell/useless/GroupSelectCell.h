// 最近群组展开后的每个分组的cell，包含分组的图片，分组的名称，和一个复选框
//  GroupSelectCell.h
//  eCloud
//
//  Created by shisuping on 14-7-1.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCell.h"
@class RecentGroup;

@interface GroupSelectCell : UITableViewCell

- (void)configCell:(RecentGroup *)itemObject;

- (UIButton *)getSelectButton;

@end
