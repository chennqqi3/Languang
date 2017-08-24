
#import "DateCell.h"
#import "MessageView.h"
#import "talkSessionUtil.h"
#import "ConvRecord.h"
@implementation DateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
       	self.selectionStyle = UITableViewCellSelectionStyleNone;
		
		MessageView *messageView = [MessageView getMessageView];
		
		UIEdgeInsets capInsets = UIEdgeInsetsMake(7,5,7,5);
		UIImageView *dateBg = [[UIImageView alloc] initWithImage:[messageView resizeImageWithCapInsets:capInsets andImage:[StringUtil getImageByResName:@"date_bg.png"]]];
		dateBg.tag = time_tag;
		
		UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectZero];
		timelabel.backgroundColor= [UIColor colorWithRed:204 green:204 blue:204 alpha:0];
		timelabel.font=[UIFont systemFontOfSize:time_font_size];
		timelabel.textColor = [UIColor whiteColor];
		timelabel.textAlignment = UITextAlignmentCenter;
		timelabel.tag = time_text_tag;
		[dateBg addSubview:timelabel];
		[timelabel release];
		
		[self.contentView addSubview:dateBg];
		[dateBg release];
    }
    return self;
}

-(void)configureCell:(ConvRecord*)_convRecord
{
	[talkSessionUtil configureTime:self convRecord:_convRecord];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
