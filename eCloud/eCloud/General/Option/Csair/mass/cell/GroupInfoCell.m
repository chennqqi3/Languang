#import "GroupInfoCell.h"
#import "MessageView.h"
#import "talkSessionUtil.h"

@implementation GroupInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;

#pragma mark --群组变化通知--
		UIEdgeInsets _capInsets = UIEdgeInsetsMake(7,5,7,5);
		MessageView *messageView = [MessageView getMessageView];
		UIImageView *groupInfoBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:_capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
		
		groupInfoBg.tag = groupinfo_tag;
		
		UILabel *groupInfolabel=[[UILabel alloc]initWithFrame:CGRectZero];
		groupInfolabel.numberOfLines =  0;
		groupInfolabel.lineBreakMode = NSLineBreakByCharWrapping;
		groupInfolabel.backgroundColor=[UIColor colorWithRed:204 green:204 blue:204 alpha:0];
		groupInfolabel.font=[UIFont systemFontOfSize:groupInfo_font_size];
		groupInfolabel.textColor = [UIColor whiteColor];
		groupInfolabel.textAlignment = UITextAlignmentCenter;
		groupInfolabel.tag = groupinfo_text_tag;
		[groupInfoBg addSubview:groupInfolabel];
		[groupInfolabel release];
		
		[self.contentView addSubview:groupInfoBg];
		
		[groupInfoBg release];
    }
    return self;
}

-(void)configureCell:(ConvRecord*)_convRecord
{
	[talkSessionUtil configureGroupInfo:self convRecord:_convRecord];
}

+(float)cellHeight:(ConvRecord*)_convRecord
{
	[talkSessionUtil getGroupInfoSize:_convRecord];
	return _convRecord.msgSize.height + 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
