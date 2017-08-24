//
//  SearchDeptCell.m
//  eCloud
//
//  Created by Richard on 14-1-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "SearchDeptCell.h"
#import "Dept.h"
#import "StringUtil.h"
@implementation SearchDeptCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		
//		部门名称
		UILabel *nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, 180, 30)];
		nameLabel.backgroundColor=[UIColor clearColor];
		nameLabel.tag=1;
		nameLabel.font=[UIFont systemFontOfSize:12];
		[self.contentView addSubview:nameLabel];
		[nameLabel release];
		
//		部门电话label
		UILabel *tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 25, 200, 30)];
		tipLabel.backgroundColor=[UIColor clearColor];
		tipLabel.tag=2;
		tipLabel.text=@"部门电话:";
		tipLabel.textColor=[UIColor grayColor];
		tipLabel.font=[UIFont systemFontOfSize:12];
		[self.contentView addSubview:tipLabel];
		[tipLabel release];
		
//		电话label
		UILabel *telLabel=[[UILabel alloc]initWithFrame:CGRectMake(75, 25, 190, 30)];
		telLabel.backgroundColor=[UIColor clearColor];
		telLabel.tag=3;
		telLabel.textColor=[UIColor grayColor];
		telLabel.textAlignment=UITextAlignmentRight;
		telLabel.font=[UIFont systemFontOfSize:12];
		[self.contentView addSubview:telLabel];
		[telLabel release];
		
//		拨电话button
		UIButton *phoneButton=[[UIButton alloc]initWithFrame:CGRectMake(270, 25, 27, 27)];
		[phoneButton setImage:[StringUtil getImageByResName:@"tel_ico.png"] forState:UIControlStateNormal];
		[phoneButton setImage:[StringUtil getImageByResName:@"tel_click_ico.png"] forState:UIControlStateHighlighted];
		[phoneButton setImage:[StringUtil getImageByResName:@"tel_click_ico.png"] forState:UIControlStateSelected];
		phoneButton.tag=4;
		phoneButton.hidden=YES;
		[self.contentView addSubview:phoneButton];
		[phoneButton release];
	}
    return self;
}

-(void)configureCell:(Dept*)dept
{
	UILabel *nameLabel=(UILabel *)[self.contentView viewWithTag:1];
	nameLabel.text=dept.dept_name;
	
	nameLabel.frame=CGRectMake(20+dept.dept_level*self.indentationWidth, 5, 180, 30);
	
	UILabel *tipLabel=(UILabel *)[self.contentView viewWithTag:2];
	tipLabel.frame=CGRectMake(20+dept.dept_level*self.indentationWidth, 25, 200, 30);
	
	UILabel *telLabel=(UILabel *)[self.contentView viewWithTag:3];
	
	if (dept.isExtended)
	{
		self.imageView.image=[StringUtil getImageByResName:@"arrow_down.png"];
	}else
	{
		self.imageView.image=[StringUtil getImageByResName:@"arrow_right.png"];
	}
	    
	if (dept.dept_tel.length>0)
	{
		UIButton *phoneButton=(UIButton *)[self.contentView viewWithTag:4];
		phoneButton.titleLabel.text=dept.dept_tel;
		phoneButton.hidden=NO;
		
		telLabel.text=dept.dept_tel;
	}
	else
	{
		UIButton *phoneButton=(UIButton *)[self.contentView viewWithTag:4];
		phoneButton.hidden=YES;
		telLabel.text=@"暂无号码";
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
