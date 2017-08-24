//
//  EmpCell.h
//  eCloud
//
//  Created by Richard on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define emp_row_height (60)

#define emp_logo_tag (100)
#define emp_name_tag (101)
#define emp_signature_tag (102)
#define emp_detail_tag (103)
#define emp_red_tag (104)

//add by shisp 在头像中增加一个子View，保存empId，方便点击头像的时候，可以获取用户的资料
#define emp_id_tag (105)

@class Emp;
@interface EmpCell : UITableViewCell

-(void)configureCell:(Emp*)emp;

//是否需要显示状态
-(void)configureCell:(Emp*)emp andDisplayStatus:(BOOL)displayStatus;

@end
