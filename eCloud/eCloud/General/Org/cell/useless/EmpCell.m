//
//  EmpCell.m
//  eCloud
//
//  Created by Richard on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "EmpCell.h"
#import "UserDisplayUtil.h"
#import "Emp.h"
#import "StringUtil.h"

#define default_name_width (255) // (205.0)
@implementation EmpCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
//		头像
		UIImageView *logoView = [UserDisplayUtil getUserLogoView];
        logoView.contentMode = UIViewContentModeScaleToFill;
        logoView.userInteractionEnabled = YES;
		logoView.tag = emp_logo_tag;
		CGRect _frame = logoView.frame;
		_frame.origin.x = 10;
		_frame.origin.y = (emp_row_height - logoView.frame.size.height) / 2;
		logoView.frame = _frame;
		[self.contentView addSubview:logoView];
        
//        empId label
        UILabel *empIdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        empIdLabel.tag = emp_id_tag;
        [logoView addSubview:empIdLabel];
        [empIdLabel release];
        
//        UIImageView *cellPhoneImageView = [logoView viewWithTag:1000];
//        cellPhoneImageView.frame = CGRectMake(chatview_logo_size-10,chatview_logo_size-10,15,15);
        
//		名字
		float x = logoView.frame.origin.x + logoView.frame.size.width + 5;
		float y = logoView.frame.origin.y;
		float w = default_name_width;
		float h = logoView.frame.size.height / 2;
		UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		nameLabel.tag = emp_name_tag;
		nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:nameLabel];
		[nameLabel release];
		
		x = nameLabel.frame.origin.x;
		y = 0;
		w = nameLabel.frame.size.width;
		h = 0;
//		签名
		UILabel *sigLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
		sigLabel.backgroundColor = [UIColor clearColor];
		sigLabel.textColor=[UIColor grayColor];
        sigLabel.font=[UIFont systemFontOfSize:12];
		sigLabel.contentMode = UIViewContentModeTop;
        sigLabel.numberOfLines = 2;
		sigLabel.tag = emp_signature_tag;
        sigLabel.lineBreakMode = UILineBreakModeTailTruncation;
		[self.contentView addSubview:sigLabel];
		[sigLabel release];
		
        
//        万达版本不显示详细资料按钮
        
//		详细资料btn
//		h = emp_row_height;
//		w = 100/96.0 * emp_row_height;
//		x = 0;
//		y = 0;
//		UIButton *detailButton=[[UIButton alloc]initWithFrame:CGRectMake(x,y,w,h)];
//		[detailButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"detail" andType:@"png"]] forState:UIControlStateNormal];
//		[detailButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"detail_click" andType:@"png"]] forState:UIControlStateHighlighted];
//		[detailButton setImage:[UIImage imageWithContentsOfFile:[StringUtil getResPath:@"detail_click" andType:@"png"]] forState:UIControlStateSelected];
//		detailButton.tag=emp_detail_tag;
//		[self.contentView addSubview:detailButton];
//		[detailButton release];
    }
    return self;
}

-(void)configureCell:(Emp*)emp
{
    [self configureCell:emp andDisplayStatus:YES];
}

-(void)configureCell:(Emp*)emp andDisplayStatus:(BOOL)displayStatus
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
    if (displayStatus) {
        [UserDisplayUtil setUserLogoView:logoView andEmp:emp];
    }
    else
    {
        [UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
    }
    
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
	
    float indentPoints = emp.emp_level * self.indentationWidth;
    
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
    if (displayStatus) {
        [UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
    }
	nameLabel.text = emp.emp_name;
    CGRect _frame = nameLabel.frame;
    _frame.size.width = default_name_width - indentPoints;
	nameLabel.frame = _frame;
    
	UILabel *sigLabel = (UILabel *)[self.contentView viewWithTag:emp_signature_tag];
	sigLabel.text = emp.signature;
    sigLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, 25);
	[sigLabel sizeToFit];
//    NSLog(@"%@",NSStringFromCGRect(sigLabel.frame));
    
    if (sigLabel.text == nil) {
        CGPoint _newCenter = nameLabel.center;
       _newCenter.y =  emp_row_height*0.5;
        nameLabel.center = _newCenter;
    }
    
    //    万达版本不显示详细资料按钮
    //	UIButton *detailButton = (UIButton*)[self.contentView viewWithTag:emp_detail_tag];
    //    _frame = detailButton.frame;
    //	_frame.origin.x = self.frame.size.width - detailButton.frame.size.width - (emp.emp_level * self.indentationWidth);
    //	detailButton.frame = _frame;
}

-(void)configureWithDeptCell:(Emp*)emp
{
	UIImageView *logoView = (UIImageView*)[self.contentView viewWithTag:emp_logo_tag];
	[UserDisplayUtil setOnlineUserLogoView:logoView andEmp:emp];
	
    UILabel *empIdLabel = (UILabel *)[logoView viewWithTag:emp_id_tag];
    empIdLabel.text = [StringUtil getStringValue:emp.emp_id];
    
	UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:emp_name_tag];
	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp];
	nameLabel.text = emp.emp_name;
    
    CGRect _frame = nameLabel.frame;
    _frame.size.width = default_name_width;
    nameLabel.frame = _frame;
	
	UILabel *sigLabel = (UILabel *)[self.contentView viewWithTag:emp_signature_tag];	
	sigLabel.frame = CGRectMake(nameLabel.frame.origin.x, 30, nameLabel.frame.size.width, 25);
    sigLabel.text = emp.parent_dept_list;
	[sigLabel sizeToFit];
    
    
    if (sigLabel.text != nil) {
        CGRect _newFrame = nameLabel.frame;
        _newFrame.origin.y = 7.5;
        nameLabel.frame = _newFrame;
    }
    
//
//	UIButton *detailButton = (UIButton*)[self.contentView viewWithTag:emp_detail_tag];
//    _frame = detailButton.frame;
//	_frame.origin.x = self.frame.size.width - detailButton.frame.size.width - (emp.emp_level * self.indentationWidth);
//	detailButton.frame = _frame;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
    float indentPoints = self.indentationLevel * self.indentationWidth;
    self.contentView.frame = CGRectMake(
										indentPoints,
										self.contentView.frame.origin.y,
										self.contentView.frame.size.width - indentPoints,
										self.contentView.frame.size.height
										);
}

@end
