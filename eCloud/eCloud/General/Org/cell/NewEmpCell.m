//
//  NewEmpCell.m
//  DTNavigationController
//
//  Created by Pain on 14-11-4.
//  Copyright (c) 2014年 Darktt. All rights reserved.
//

#import "NewEmpCell.h"
#import "eCloudConfig.h"
#import "eCloudDefine.h"

#import "UserDisplayUtil.h"
#import "Emp.h"
#import "StringUtil.h"
#import "OrgSizeUtil.h"
#import "UIAdapterUtil.h"

#define default_name_width (220) // (205.0)

@implementation NewEmpCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [UIAdapterUtil customSelectBackgroundOfCell:self];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //头像
		UIImageView *logoView = [UserDisplayUtil getUserLogoView];
        logoView.contentMode = UIViewContentModeScaleToFill;
        logoView.userInteractionEnabled = YES;
		logoView.tag = emp_logo_tag;
		CGRect _frame = logoView.frame;
		_frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth]+15;
		_frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
		logoView.frame = _frame;
		[self.contentView addSubview:logoView];
        
        //empId label
        UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        empIdLabel.tag = emp_id_tag;
        [logoView addSubview:empIdLabel];
        [empIdLabel release];
        
        //        UIImageView *cellPhoneImageView = [logoView viewWithTag:1000];
        //        cellPhoneImageView.frame = CGRectMake(chatview_logo_size-10,chatview_logo_size-10,15,15);
        
        //名字
		float x = logoView.frame.origin.x + logoView.frame.size.width + 5;
		float y = logoView.frame.origin.y;
		float w = default_name_width;
		float h = logoView.frame.size.height / 2;
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		nameLabel.tag = emp_name_tag;
		nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        nameLabel.font = [UIFont systemFontOfSize:16.5];
        nameLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
		[self.contentView addSubview:nameLabel];
        
//        nameLabel.backgroundColor = [UIColor redColor];
        
		[nameLabel release];
		
		x = nameLabel.frame.origin.x;
		y = 0;
		w = nameLabel.frame.size.width;
		h = 0;
        
        //职位
		UILabel *sigLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		sigLabel.backgroundColor = [UIColor clearColor];
		sigLabel.textColor=[UIColor colorWithRed:155/255.0 green:155/255.0 blue:155/255.0 alpha:1];
        sigLabel.font=[UIFont systemFontOfSize:14];
		sigLabel.contentMode = UIViewContentModeTop;
        if ([UIAdapterUtil isTAIHEApp]) {
            sigLabel.numberOfLines = 2;
        }
		sigLabel.tag = emp_signature_tag;
        sigLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:sigLabel];
		[sigLabel release];
//        sigLabel.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)configureCell:(Emp*)emp
{
    [self configureCell:emp andDisplayStatus:YES];
}

-(void)configureCell:(Emp*)emp andDisplayStatus:(BOOL)displayStatus
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    if (displayStatus) {
        [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
    }
    else
    {
        [UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
    }
    
    CGRect _frame = logoView.frame;
    _frame.origin.x = [OrgSizeUtil getLeftScrollViewWidth] + [OrgSizeUtil getSpaceBetweenDeptNavAndContent];
    _frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
    
    //名字
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
    /*
    if (displayStatus) {
//        [UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
        [nameLabel setTextColor:[UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1]];
    }
     */
//	nameLabel.text = [NSString stringWithFormat:@"%@(%@)",emp.emp_name,emp.empCode];
    // 不显示工号
    nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];
    
    float x = logoView.frame.origin.x + logoView.frame.size.width + 10;
    float y = logoView.frame.origin.y;
    float w = [UIAdapterUtil getTableCellContentWidth] - x - RIGHT_ROW_SIZE;
    float h = logoView.frame.size.height / 2;
    nameLabel.frame = CGRectMake(x, y, w, h);
	
    //职位
	UILabel *sigLabel = (UILabel *)[self.contentView viewWithTag:emp_signature_tag];
	sigLabel.text = emp.signature;
    sigLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, 25);
	[sigLabel sizeToFit];
    
    if (sigLabel.text == nil) {
        CGPoint _newCenter = nameLabel.center;
        _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
    
#ifdef _XIANGYUAN_FLAG_
    
    if (sigLabel.text.length == 0) {
        CGPoint _newCenter = nameLabel.center;
        _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
    
#endif
}

-(void)configureWithDeptCell:(Emp*)emp
{
//    这是用来显示 通讯录 人员搜索结果的cell
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    [UserDisplayUtil setUserLogoView:logoView andEmp:emp andDisplayCurUserStatus:YES];
    CGRect _frame = logoView.frame;
    _frame.origin.x = 10;
    logoView.frame = _frame;
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
    
    //名称
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
//	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];

    if ([[eCloudConfig getConfig]dspUserCodeWhenSearchOrg]) {
        nameLabel.text = [NSString stringWithFormat:@"%@(%@)",emp.emp_name,emp.empCode];
    }
    else
    {
        nameLabel.text = [NSString stringWithFormat:@"%@",emp.emp_name];
    }
    
    float x = logoView.frame.origin.x + logoView.frame.size.width + 10;
    float y = logoView.frame.origin.y;
    float w = [UIAdapterUtil getTableCellContentWidth] - x - RIGHT_ROW_SIZE;// default_name_width;
    float h = logoView.frame.size.height / 2;
    nameLabel.frame = CGRectMake(x, y, w, h);
    
#define default_sig_label_height (25)
	//职位
	UILabel *sigLabel = (UILabel *)[self.contentView viewWithTag:emp_signature_tag];
	sigLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, default_sig_label_height);
    sigLabel.text = emp.parent_dept_list;
//	[sigLabel sizeToFit];
    
    if (sigLabel.text != nil) {
        CGRect _newFrame = nameLabel.frame;
        _newFrame.origin.y = 7.5;
        nameLabel.frame = _newFrame;
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        //        展示部门需要的实际高度
        CGFloat labelHeight = [sigLabel sizeThatFits:CGSizeMake(sigLabel.frame.size.width, MAXFLOAT)].height;
        if (labelHeight > default_sig_label_height) {
            
            float diff = labelHeight - default_sig_label_height;
            
            //重新设置nameLabel的高度
            _frame = nameLabel.frame;
            _frame.size.height -= diff;
            nameLabel.frame = _frame;
            
            //            重新设置deptLabel的高度 和 y值
            _frame = sigLabel.frame;
            _frame.size.height += diff;
            _frame.origin.y -= diff;
            sigLabel.frame = _frame;
        }

    }
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//	
//    float indentPoints = self.indentationLevel * self.indentationWidth;
//    
//    self.contentView.frame = CGRectMake(
//										indentPoints,
//										self.contentView.frame.origin.y,
//										self.contentView.frame.size.width - indentPoints,
//										self.contentView.frame.size.height
//										);
//}



@end
