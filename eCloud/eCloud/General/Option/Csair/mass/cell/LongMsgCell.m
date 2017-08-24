//
//  LongMsgCell.m
//  eCloud
//
//  Created by Richard on 14-1-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "LongMsgCell.h"
#import "eCloudDefine.h"
#import "ConvRecord.h"
#import "talkSessionUtil.h"
#import "MassTextCell.h"


@implementation LongMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[MassTextCell addCommonView:self];

		UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];
#pragma mark --不带超链接一般文本消息--
		UILabel *normalTextView = [[UILabel alloc]initWithFrame:CGRectZero];
		normalTextView.font = [UIFont systemFontOfSize:message_font];
		normalTextView.numberOfLines = 0;
		normalTextView.backgroundColor = [UIColor clearColor];
		normalTextView.tag = normal_text_tag;
        normalTextView.textColor = [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0];
		[bodyView addSubview:normalTextView];
		[normalTextView release];

        // Initialization code
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
	
	[talkSessionUtil configureLongMsg:self convRecord:_convRecord];
	
	[MassTextCell setBodyViewFrame:self];
}

+(float)cellHeight:(ConvRecord*)_convRecord
{
	[talkSessionUtil getLongMsgSize:_convRecord];
	float bodyHeight = _convRecord.msgSize.height;
	return [MassTextCell getHeightByBodyHeight:bodyHeight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
