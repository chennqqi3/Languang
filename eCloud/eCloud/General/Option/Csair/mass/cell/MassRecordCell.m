
#import "MassRecordCell.h"
#import "talkSessionUtil.h"
#import "MassTextCell.h"
#import "MessageView.h"

@implementation MassRecordCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		[MassTextCell addCommonView:self];
		
		UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];

#pragma mark --录音消息--
		UIButton *clickbutton=[[UIButton alloc]initWithFrame:CGRectZero];
		UIImage *normalImg = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"mass_msg_audio_btn" andType:@"png"]];
		UIImage *highlightedImg = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"mass_msg_audio_btn_click" andType:@"png"]];

		//	拉伸login图片
		MessageView *messageView = [MessageView getMessageView];
		UIEdgeInsets capInsets = UIEdgeInsetsMake(20,12,18,12);
		normalImg = [messageView resizeImageWithCapInsets:capInsets andImage:normalImg];
		highlightedImg = [messageView resizeImageWithCapInsets:capInsets andImage:highlightedImg];
		[clickbutton setBackgroundImage:normalImg forState:UIControlStateNormal];
		[clickbutton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
		[clickbutton setBackgroundImage:highlightedImg forState:UIControlStateSelected];
	
		clickbutton.tag=audio_tag;
		
		UIImageView *buttonimage=[[UIImageView alloc]initWithFrame:CGRectZero];
		buttonimage.tag=audio_playImageView_tag;
		
		UILabel *timeSecond = [[UILabel alloc]initWithFrame:CGRectZero];
		timeSecond.backgroundColor=[UIColor colorWithRed:178 green:225 blue:69 alpha:0];;
		timeSecond.font=[UIFont systemFontOfSize:16];
		timeSecond.tag = audio_second_tag;
		[clickbutton addSubview:buttonimage];
		[buttonimage release];
		
		[clickbutton addSubview:timeSecond];
		[timeSecond release];
		
		[bodyView addSubview:clickbutton];
		[clickbutton release];

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

	[talkSessionUtil configureAudioMsg:self convRecord:_convRecord];
	
	[MassTextCell setBodyViewFrame:self];
}

+(float)cellHeight:(ConvRecord*)_convRecord
{
	[talkSessionUtil getAudioMsgSize:_convRecord];
	float bodyHeight = _convRecord.msgSize.height;
	return [MassTextCell getHeightByBodyHeight:bodyHeight];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
