//
//  EmpSelectCell.h
//  eCloud
//
//  Created by Richard on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define emp_row_height (60)

#define emp_logo_tag (100)
#define emp_name_tag (101)
#define emp_select_tag (102)
#define emp_dept_tag (103)

#define emp_id_tag (105)

#define emp_info_btn_tag (106)


@class Emp;
@interface NewEmpSelectCell : UITableViewCell{
    
}
/** 背景view */
@property (nonatomic,retain) UIButton *infoView;

/**
 功能描述
 给cell赋值
 
 参数 emp 人员模型
 */
-(void)configureCell:(Emp*)emp;

/**
 功能描述
 给部门cell赋值
 
 参数 emp 人员模型
 */
-(void)configureWithDeptCell:(Emp*)emp;

+(void)selectBtn:(UIButton*)selectButton andSelected:(BOOL)isSelected;

@end
