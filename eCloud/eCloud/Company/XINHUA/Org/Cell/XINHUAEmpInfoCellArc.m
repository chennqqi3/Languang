//
//  XINHUAEmpInfoCellArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAEmpInfoCellArc.h"
#import "ImageUtil.h"

@interface XINHUAEmpInfoCellArc ()

@property (retain, nonatomic) IBOutlet UIImageView *logoImage;

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation XINHUAEmpInfoCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.logoImage.layer.cornerRadius = 4;
    self.logoImage.clipsToBounds = YES;
}

- (void)setEmp:(Emp *)emp
{
    _emp = emp;
    
    self.logoImage.image = [ImageUtil getEmpLogo:_emp];
    self.titleLabel.text = _emp.emp_name;
    self.subTitleLabel.text = self.emp.empCode;
}

@end
