//
//  MassPicCell.m
//  eCloud
//
//  Created by Richard on 14-1-14.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "MassPicCell.h"
#import "MassTextCell.h"
#import "ConvRecord.h"
#import "talkSessionUtil.h"

@implementation MassPicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		[MassTextCell addCommonView:self];
		
		UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];
#pragma mark --图片消息--
		UIImageView *showPicView=[[UIImageView alloc]initWithFrame:CGRectZero];
		showPicView.tag = pic_tag;
		showPicView.contentMode=UIViewContentModeScaleAspectFit;
		[bodyView addSubview:showPicView];
		[showPicView release];
    }
    return self;
}

-(void)configureCell:(ConvRecord*)_convRecord
{
	[MassTextCell configureCommonView:self andConvRecord:_convRecord];
	
	UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];
	CGRect _frame = bodyView.frame;
	_frame.size = _convRecord.msgSize;
	bodyView.frame = _frame;

	UIImageView *showPicView=(UIImageView*)[self.contentView viewWithTag:pic_tag];
	showPicView.image=_convRecord.imageDisplay;
	showPicView.frame = CGRectMake(5, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
	showPicView.hidden = NO;
	
	[MassTextCell setBodyViewFrame:self];
}

+(float)cellHeight:(ConvRecord*)_convRecord
{
	[talkSessionUtil getPicMsgSize:_convRecord];
	float bodyHeight = _convRecord.msgSize.height;
	return [MassTextCell getHeightByBodyHeight:bodyHeight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
