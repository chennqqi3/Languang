#import "MassTextCell.h"
#import "MessageView.h"
#import "TextLinkView.h"
#import "talkSessionUtil.h"
#import "ConvRecord.h"
#import "UITableViewCell+getCellContentWidth.h"

@implementation MassTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		[MassTextCell addCommonView:self];

		UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];
#pragma mark --不带超链接一般文本消息--
		UILabel *normalTextView = [[UILabel alloc]initWithFrame:CGRectZero];
		normalTextView.font = [UIFont systemFontOfSize:message_font];
		normalTextView.numberOfLines = 0;
		normalTextView.backgroundColor = [UIColor clearColor];
		normalTextView.tag = normal_text_tag;
		[bodyView addSubview:normalTextView];
		[normalTextView release];
		
#pragma mark --不带超链接图文混合消息--
		TextMessageView *textPicView = [[TextMessageView alloc]initWithFrame:CGRectZero];
		textPicView.maxWidth = 280;
		textPicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		textPicView.tag = nolink_text_pic_tag;
		[bodyView addSubview:textPicView];
		[textPicView release];
		
#pragma mark --带超链接的文本消息--
		TextLinkView *linkView=[[TextLinkView alloc]initWithFrame:CGRectZero];
		linkView.tag = link_text_tag;
		[bodyView addSubview:linkView];
		[linkView release];		
    }
    return self;
}

+(float)cellHeight:(ConvRecord*)_convRecord
{
	[talkSessionUtil getTextMsgSize:_convRecord];
	float bodyHeight = _convRecord.msgSize.height;
	return [self getHeightByBodyHeight:bodyHeight];
}

-(void)configureCell:(ConvRecord*)_convRecord
{
	[MassTextCell configureCommonView:self andConvRecord:_convRecord];

	UIView *bodyView = (UIView*)[self.contentView viewWithTag:body_tag];
	CGRect _frame = bodyView.frame;
	_frame.size = _convRecord.msgSize;
	bodyView.frame = _frame;
	
	UILabel *normalTextView = (UILabel*)[self.contentView viewWithTag:normal_text_tag];
	normalTextView.hidden = YES;
	
	TextMessageView *textPicView = (TextMessageView*)[self.contentView viewWithTag:nolink_text_pic_tag];
	textPicView.hidden = YES;
	
	TextLinkView *linkView = (TextLinkView*)[self.contentView viewWithTag:link_text_tag];
	linkView.hidden = YES;
	
	[talkSessionUtil configureTextMsg:self convRecord:_convRecord];
	
	[MassTextCell setBodyViewFrame:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(void)addCommonView:(UITableViewCell*)cell
{
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
//	增加背景图片
	MessageView *messageView = [MessageView getMessageView];
	UIEdgeInsets capInsets = UIEdgeInsetsMake(28, 12, 28, 37);
	UIImage *normalImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"section_top_bg" andType:@"png"]];
	normalImage = [messageView resizeImageWithCapInsets:capInsets andImage:normalImage];
	UIImage *highlightImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"section_top_bg_hl" andType:@"png"]];
	highlightImage = [messageView resizeImageWithCapInsets:capInsets andImage:highlightImage];
	
	UIButton *replyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 1, [cell getCellContentWidth] - 20, reply_bg_btn_height)];
	replyButton.tag = reply_bg_btn_tag;
	[replyButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	[replyButton setBackgroundImage:highlightImage forState:UIControlStateSelected];
	[replyButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
	[cell.contentView addSubview:replyButton];
	[replyButton release];
	
	//		文本
	UILabel *replyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, [cell getCellContentWidth] - 40, replyButton.frame.size.height)];
//	replyLabel.userInteractionEnabled = YES;
	replyLabel.tag = reply_label_tag;
	replyLabel.font = [UIFont systemFontOfSize:groupInfo_font_size];
	replyLabel.textColor = [UIColor grayColor];
	replyLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:replyLabel];
	[replyLabel release];
	
#pragma mark --消息内容--
	UIView *bodyView = [[UIView alloc]initWithFrame:CGRectZero];
	bodyView.frame = CGRectMake(10, replyButton.frame.origin.y + replyButton.frame.size.height + 10, 0, 0);
	bodyView.userInteractionEnabled = YES;
	bodyView.tag = body_tag;
	[cell.contentView addSubview:bodyView];
	[bodyView release];
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.tag = status_spinner_tag;
	[bodyView addSubview:spinner];
	[spinner release];
}

+(float)getCommonHeight
{
	return reply_bg_btn_height;
}

+(void)configureCommonView:(UITableViewCell*)cell andConvRecord:(ConvRecord*)_convRecord
{
	UILabel *replyLabel = (UILabel*)[cell.contentView viewWithTag:reply_label_tag];
	replyLabel.text = [NSString stringWithFormat:@"%d位接收者，%d位已回复",_convRecord.mass_total_emp_count,_convRecord.mass_reply_emp_count];
}

+(void)setBodyViewFrame:(UITableViewCell*)cell
{
	UIView *bodyView = (UIView*)[cell.contentView viewWithTag:body_tag];
	CGRect bodyFrame = bodyView.frame;
	
	if(bodyFrame.size.height < min_body_height)
	{
		bodyFrame.origin.y = [self getCommonHeight] + (min_body_height - bodyFrame.size.height)/2;
        bodyView.frame = bodyFrame;
	}
	
	UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];

	int spinnerX = (cell.contentView.frame.size.width - spinner.frame.size.width)/2 - bodyView.frame.origin.x;
	int spinnerY = (bodyView.frame.size.height - spinner.frame.size.height)/2;

	spinner.frame = CGRectMake(spinnerX ,spinnerY,spinner.frame.size.width,spinner.frame.size.height);
	
}

+(float)getHeightByBodyHeight:(float)bodyHeight
{
	float replyHeight = [self getCommonHeight];
	
	if(bodyHeight + 20 < min_body_height)
		return min_body_height + replyHeight;
	return replyHeight + bodyHeight + 20;
}


@end
