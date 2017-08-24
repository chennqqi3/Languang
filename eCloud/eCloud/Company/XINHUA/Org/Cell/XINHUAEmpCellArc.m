//
//  XINHUAEmpCell.m
//  eCloud
//
//  Created by Alex-L on 2017/4/13.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "XINHUAEmpCellArc.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "UIAdapterUtil.h"
#import "UserDisplayUtil.h"

#define MAX_COUNT 6

@interface XINHUAEmpCellArc ()

@property (retain, nonatomic) IBOutlet UIImageView *selectedIcon;
@property (retain, nonatomic) IBOutlet UIImageView *empLogo;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *selectedIconLeftConstraint;

@end

@implementation XINHUAEmpCellArc

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.empLogo.layer.cornerRadius = 4;
    self.empLogo.clipsToBounds = YES;
    
    CGFloat height = 1.0/[UIScreen mainScreen].scale;
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, height)];
    view1.backgroundColor = [UIColor colorWithWhite:.9f alpha:1];
    [self addSubview:view1];
}

- (void)setEmp:(Emp *)emp
{
    _emp = emp;
    
    self.empLogo.image = [ImageUtil getEmpLogo:_emp];
    self.empName.text = _emp.emp_name;
    self.empClass.text = self.emp.deptName ?: _emp.parent_dept_list;
    
}

- (void)setConv:(Conversation *)conv
{
    _conv = conv;
    
    self.empName.text = _conv.conv_title;
    self.empLogo.image = [UserDisplayUtil getImageWithConv:conv];
    
    NSMutableString *str = [NSMutableString string];
    
    int count = 0;
    for (Emp *emp in _conv.convEmps) {
        if (count>MAX_COUNT) {
            break;
        }
        [str appendString:emp.emp_name];
        if (count < MAX_COUNT && (_conv.convEmps.count-1)!=count)
        {
            [str appendString:@"、"];
        }
        count++;
    }
    
    self.empClass.text = str;
    
}

- (void)setIsselected:(BOOL)isselected
{
    _isselected = isselected;
    
    NSString *selectedIcon = _isselected? @"Selection_01_ok" : @"Selection_01";
    self.selectedIcon.image = [StringUtil getImageByResName:selectedIcon];
}

- (void)setSearchEmpStr:(NSString *)searchEmpStr
{
    _searchEmpStr = searchEmpStr;
    self.empName.attributedText = [self getAttributedStringWithOriginStr:_emp.emp_name searchStr:_searchEmpStr];
}

- (void)setCanBeSelected:(BOOL)canBeSelected
{
    _canBeSelected = canBeSelected;
    
    self.selectedIcon.hidden = canBeSelected;
}

- (NSMutableAttributedString *)getAttributedStringWithOriginStr:(NSString *)originStr searchStr:(NSString *)searchStr
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:originStr];
    
    NSRange range = [originStr rangeOfString:searchStr];
    
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIAdapterUtil getDominantColor]
                             range:range];
    
    return attributedString;
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    
    if (_isEditing)
    {
        self.selectedIconLeftConstraint.constant = 15;
    }
    else
    {
        self.selectedIconLeftConstraint.constant = -30;
    }
}

@end
