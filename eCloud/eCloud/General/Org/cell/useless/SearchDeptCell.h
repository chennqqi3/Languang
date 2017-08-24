//
//  SearchDeptCell.h
//  eCloud
//
//  Created by Richard on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define phone_button_tag (4)
@class Dept;
@interface SearchDeptCell : UITableViewCell

/**
 初始化控件的位置和默认图片

 @param dept 部门对象
 */
-(void)configureCell:(Dept*)dept;
@end
