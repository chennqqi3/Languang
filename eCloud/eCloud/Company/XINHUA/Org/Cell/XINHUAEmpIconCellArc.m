//
//  XINHUAEmpIconCellArc.m
//  eCloud
//
//  Created by Alex-L on 2017/4/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAEmpIconCellArc.h"
#import "StringUtil.h"
#import "ImageUtil.h"

@interface XINHUAEmpIconCellArc ()

@property (nonatomic, strong) UIImageView *icon;

@end

@implementation XINHUAEmpIconCellArc

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:self.icon];
    }
    
    return self;
}

- (void)setEmp:(Emp *)emp
{
    _emp = emp;
    
    self.icon.image = [ImageUtil getEmpLogo:_emp];
}

@end
