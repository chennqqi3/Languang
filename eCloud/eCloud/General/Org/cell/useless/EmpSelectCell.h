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

@class Emp;
@interface EmpSelectCell : UITableViewCell
-(void)configureCell:(Emp*)emp;

-(void)configureWithDeptCell:(Emp*)emp;

+(void)selectBtn:(UIButton*)selectButton andSelected:(BOOL)isSelected;

@end
