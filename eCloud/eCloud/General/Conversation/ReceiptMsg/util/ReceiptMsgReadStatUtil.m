//
//  ReceiptMsgReadStatUtil.m
//  eCloud
//
//  Created by Richard on 13-12-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ReceiptMsgReadStatUtil.h"
#import "Emp.h"
#import "ImageUtil.h"
#import "StringUtil.h"
#import "UserDisplayUtil.h"

#define logo_tag (100)
#define name_tag (101)
#define time_tag (102)

@implementation ReceiptMsgReadStatUtil

+(UITableViewCell*)cellWithReuseIdentifier:(NSString*)indentifier
{
	UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier]autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UIImageView *logoView = [UserDisplayUtil getUserLogoView];
	logoView.tag = logo_tag;
	
	float x = 10;
	float y = (row_height - logoView.frame.size.height)/2;
	CGRect _frame = logoView.frame;
	_frame.origin.x = x;
	_frame.origin.y = y;
	logoView.frame = _frame;

	[cell.contentView addSubview:logoView];
	
	float w;
	float h;

	x = logoView.frame.origin.x + logoView.frame.size.width + 5;
	y = 0;
	w = 150;
	h = row_height;
	UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.font = [UIFont boldSystemFontOfSize:16];
	nameLabel.tag = name_tag;
	[cell.contentView addSubview:nameLabel];
	[nameLabel release];
	
	x = nameLabel.frame.origin.x + nameLabel.frame.size.width;
	y = 0;
	w = cell.frame.size.width - x - 10;
	h = row_height;
	UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, w, h)];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.font = [UIFont systemFontOfSize:13];
	timeLabel.textColor = [UIColor grayColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.tag = time_tag;
    timeLabel.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:timeLabel];
	[timeLabel release];
	
	return cell;
}

+(void)configCell:(UITableViewCell*)cell andEmp:(Emp*)emp andReadFlag:(BOOL)isRead
{
	UIImageView *logoView = (UIImageView*)[cell.contentView viewWithTag:logo_tag];
	[UserDisplayUtil setUserLogoView:logoView andEmp:emp];
	
	UILabel *nameLabel = (UILabel*)[cell.contentView viewWithTag:name_tag];
	nameLabel.text = emp.emp_name;
	[UserDisplayUtil setNameColor:nameLabel andEmpStatus:emp.emp_status];
	
	UILabel *timeLabel = (UILabel*)[cell.contentView viewWithTag:time_tag];
	if(isRead)
	{
		timeLabel.hidden = NO;
		timeLabel.text = [StringUtil getDisplayTimeOfMsgRead:emp.msgReadTime];
	}
	else
	{
		timeLabel.hidden = YES;
	}
	
}

@end
