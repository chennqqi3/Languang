//
//  PSContactViewUtil.m
//  eCloud
//
//  Created by Richard on 13-10-31.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "FltGroupListViewUtil.h"
#import "eCloudDefine.h"
#import "Conversation.h"
#import "StringUtil.h"
#import "MessageView.h"
#import "NewMsgNumberUtil.h"
#import "LastRecordView.h"
#import "UIAdapterUtil.h"

#define new_msg_number_parent_view_tag 8131100
#define newMsgBgImageView_tag 8131230

@implementation FltGroupListViewUtil

+(UITableViewCell*)initCell:(NSString*)identifier
{
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
	//		logo的frame
	float logoX = 10;
	float logoY = (row_height - chatview_logo_size) /2 ;
	
	//		name frame
	float nameX = logoX + chatview_logo_size + 10;
	float nameY = 5;
	
	float contentWidth = (screenW*300/320 - chatview_logo_size - 10);
	float nameWidth = contentWidth *0.8;
	float nameHeight = (row_height - logoY*2)/2;
	//		时间frame
	float timeX = nameX + nameWidth;
	float timeY = nameY;
	float timeWidth = contentWidth*0.2;
	float timeHeight = nameHeight;
	
	//		详细内容
	float detailX = nameX;
	float detailY = nameY + nameHeight + 5;
	float detailWidth = contentWidth - 50;
	float detailHeight = nameHeight;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
	
	UIImageView *iconview = [[UIImageView alloc]initWithFrame:CGRectMake(logoX, logoY, chatview_logo_size, chatview_logo_size)];
	iconview.tag = icon_view_tag;
	iconview.userInteractionEnabled=NO;
	
    // 南航版本不能用这种方式添加小红点了.
	// NewMsgNumberUtil addNewMsgNumberView: iconview];
    
	// [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
	[cell.contentView addSubview:iconview];
	[iconview release];
	
	UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(nameX, nameY, nameWidth, nameHeight)];
	namelable.tag=title_label_tag;
	namelable.font=[UIFont boldSystemFontOfSize:16];
	
	namelable.backgroundColor=[UIColor clearColor];
	namelable.textColor=[UIColor blackColor];
	[cell.contentView addSubview:namelable];
	[namelable release];
	
	UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(timeX, timeY, timeWidth+5, timeHeight)];
	timelabel.tag=time_label_tag;
	timelabel.font=[UIFont systemFontOfSize:13];
	timelabel.backgroundColor=[UIColor clearColor];
	timelabel.textColor=[UIColor grayColor];
	timelabel.textAlignment = NSTextAlignmentRight;
	[cell.contentView addSubview:timelabel];
	[timelabel release];
	
    LastRecordView *detailView = [[LastRecordView alloc]initWithFrame:CGRectMake(detailX, detailY, detailWidth, detailHeight)];
    detailView.tag = detail_view_tag;
    [cell.contentView addSubview:detailView];
    [detailView release];
    
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    
    // 设置红点的父view
    UIView *newMsgNumberParentView = [[UIView alloc]initWithFrame:CGRectMake(screenW -20-15, detailY-5, 15, 15)];
    newMsgNumberParentView.tag = new_msg_number_parent_view_tag;
    [cell.contentView addSubview:newMsgNumberParentView];
    [NewMsgNumberUtil addNewMsgNumberView:newMsgNumberParentView];
    [newMsgNumberParentView release];
	
	return cell;
}
// 配置cll
+(void)configCell:(UITableViewCell*)cell andConversation:(Conversation*)conv
{
	UIImageView *iconview=(UIImageView *)[cell.contentView viewWithTag:icon_view_tag];
    UIImage *image = [StringUtil getImageByResName:@"flt_group_log.png"];
	[iconview setImage:image];
	
	UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:title_label_tag];
	namelabel.text = conv.conv_title;
	
	UILabel *timelabel=(UILabel *)[cell.contentView viewWithTag:time_label_tag];
	
	//	如果是空会话，那么显示群组创建时间
	if(conv.last_record.msg_time)
	{
		timelabel.text=[StringUtil getLastMessageDisplayTime:conv.last_record.msg_time];
	}
	else
	{
		timelabel.text=[StringUtil getLastMessageDisplayTime:conv.create_time];
	}
	
	UIView *detailView = (UIView*)[cell.contentView viewWithTag:detail_view_tag];
	for(UIView *uiView in [detailView subviews])
	{
		[uiView removeFromSuperview];
	}
	
	//			add by shisp 如果是群聊，那么最后一条记录需要显示发送人
	//默认发送人为空
	NSString *_lastMsgEmpName = @"";
	if(conv.conv_type == mutiableType && conv.last_record.msg_body && conv.last_record.msg_body.length > 0)
	{
		_lastMsgEmpName = [NSString stringWithFormat:@"%@:",conv.last_record.emp_name];
	}
	
	if(conv.last_record.msg_body && conv.last_record.msg_body.length > 0)
	{
		int msgType = conv.last_record.msg_type;
		//如果最后一条消息类型是分组变化通知，那么不显示发言人名字
		if(msgType == type_group_info)
			_lastMsgEmpName = @"";
		
		if(msgType == type_text || msgType == type_long_msg || msgType == type_group_info)
		{
			[detailView addSubview:[[MessageView getLastMessageView] bubbleView:[NSString stringWithFormat:@"%@%@",_lastMsgEmpName,conv.last_record.msg_body]  from:true]];
		}
		else if(msgType == type_pic)
		{
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 100 , 20)];
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont systemFontOfSize:14];
			label.text = [NSString stringWithFormat:@"%@%@",_lastMsgEmpName, @"[图片]"];
			label.textColor = [UIColor redColor];
			
			[detailView addSubview:label];
			[label release];
		}
		else if(msgType == type_record)
		{
			UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 100 , 20)];
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont systemFontOfSize:14];
			label.text = [NSString stringWithFormat:@"%@%@",_lastMsgEmpName,@"[录音]"];
			label.textColor = [UIColor redColor];
			
			[detailView addSubview:label];
			[label release];
		}
	}
    
    // 父view 0813
    UIView *newMsgNumberParentView = [cell.contentView viewWithTag:new_msg_number_parent_view_tag];
    // 显示数值 0813
	[NewMsgNumberUtil displayNewMsgNumber:newMsgNumberParentView andNewMsgNumber:conv.unread];
}
@end
