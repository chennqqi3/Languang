
#import "GroupInfoMsgCell.h"
#import "MessageView.h"
#import "BgImageUtil.h"
#import "ConvRecord.h"
#import "FontSizeUtil.h"
#import "UITableViewCell+getCellContentWidth.h"

@implementation GroupInfoMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.opaque = YES;
        
#pragma mark --消息时间--
        
        UIImageView *dateBg = [[UIImageView alloc]init];// [[UIImageView alloc] initWithImage:[BgImageUtil getDateBgImage]];
        dateBg.backgroundColor = msg_time_bg_color;
        dateBg.layer.cornerRadius = msg_time_bg_arc;
        dateBg.clipsToBounds = YES;
        
        dateBg.tag = time_tag;
        
        UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectZero];
        timelabel.backgroundColor= [UIColor clearColor];// [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:0];
        timelabel.font=[UIFont systemFontOfSize:msg_time_font_size];
        timelabel.textAlignment = NSTextAlignmentCenter;
        timelabel.textColor = msg_time_font_color;
        timelabel.tag = time_text_tag;
        
        [dateBg addSubview:timelabel];
        [timelabel release];
        
        [self.contentView addSubview:dateBg];
        [dateBg release];
        
#pragma mark --群组变化通知--
		UIImageView *groupInfoBg =  [[UIImageView alloc]init];//[[UIImageView alloc] initWithImage:[BgImageUtil getDateBgImage]];
        groupInfoBg.backgroundColor = msg_time_bg_color;
        groupInfoBg.layer.cornerRadius = msg_time_bg_arc;
        groupInfoBg.clipsToBounds = YES;

		groupInfoBg.tag = groupinfo_tag;
		
		UILabel *groupInfolabel=[[UILabel alloc]initWithFrame:CGRectZero];
		groupInfolabel.numberOfLines =  0;
		groupInfolabel.lineBreakMode = NSLineBreakByCharWrapping;
        groupInfolabel.backgroundColor = [UIColor clearColor];//  [UIColor colorWithRed:204 green:204 blue:204 alpha:0];
        groupInfolabel.font=[UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]];
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

#pragma mark --群组通知消息--
+(void)configureGroupInfo:(UITableViewCell *)cell convRecord:(ConvRecord*)_convRecord
{
    //    NSLog(@"%s,cell.contentView is %@",__FUNCTION__,cell.contentView);
    
    BOOL isSingleLine = YES;
    UILabel *grpInfoText=(UILabel*)[cell.contentView viewWithTag:groupinfo_text_tag];
    grpInfoText.font = [UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]];
    
    if((_convRecord.msgSize.height / grpInfoText.font.lineHeight) > 1)
    {
        //        NSLog(@"多行消息");
        isSingleLine = NO;
    }
    
    if(isSingleLine)
    {
        //        背景的宽度，x值，y值，高度都需要计算
        //	时间的宽度和高度
        float labelWidth = _convRecord.msgSize.width;
        float labelHeight = _convRecord.msgSize.height;

        //	背景的宽度和高度
        float bgWidth = _convRecord.msgSize.width + 2 * group_info_horizontal_space;
        float bgHeight = _convRecord.msgSize.height + 2 * group_info_vertical_space;
        
        //	背景的起始位置
        float bgX = ([cell getCellContentWidth] - bgWidth) / 2;
        
        float bgY = [talkSessionUtil getTimeHeight:_convRecord];;
        UIImageView *groupInfoBg = (UIImageView*)[cell.contentView viewWithTag:groupinfo_tag];
        groupInfoBg.frame = CGRectMake(bgX, bgY, bgWidth, bgHeight );
        groupInfoBg.hidden = NO;
        
        
        //增加消息时间
        NSString *msgBody = _convRecord.msg_body;
        
        UILabel *grpInfoText=(UILabel*)[cell.contentView viewWithTag:groupinfo_text_tag];
        grpInfoText.frame = CGRectMake(group_info_horizontal_space, group_info_vertical_space,labelWidth, labelHeight);
        grpInfoText.text = msgBody;
        grpInfoText.hidden = NO;
        grpInfoText.textAlignment = NSTextAlignmentCenter;
        
        //        NSLog(@"%s,groupInfoBg is %@,grpInfoText is %@",__FUNCTION__,groupInfoBg,grpInfoText);
    }
    else
    {
        //        背景的宽度 背景的x值都是固定的，背景的高度，背景的y值是变化的
        //        label的宽度 label相对于背景的x值，y值都是固定的，label的高度是变化的
        
        NSString *msgBody = _convRecord.msg_body;
        //	时间的宽度和高度
        float labelWidth = max_group_info_width - group_info_horizontal_space * 2;
        
        float labelHeight = _convRecord.msgSize.height;
        
        //	背景的宽度和高度
        float bgWidth = max_group_info_width;
        
        float bgHeight = labelHeight + group_info_vertical_space * 2;
        
        //	背景的起始位置
        float bgX = group_info_bg_horizontal_space;
        
        float bgY = [talkSessionUtil getTimeHeight:_convRecord];
        
        if (_convRecord.isMiLiaoMsg)
        {
            bgWidth = _convRecord.msgSize.width + group_info_horizontal_space * 2;
            bgX = (SCREEN_WIDTH - bgWidth)/2.0;
        }
        
        UIImageView *groupInfoBg = (UIImageView*)[cell.contentView viewWithTag:groupinfo_tag];
        groupInfoBg.frame = CGRectMake(bgX, bgY, bgWidth, bgHeight );
        groupInfoBg.hidden = NO;
        
        UILabel *grpInfoText=(UILabel*)[cell.contentView viewWithTag:groupinfo_text_tag];
        grpInfoText.frame = CGRectMake(group_info_horizontal_space, group_info_vertical_space,labelWidth, labelHeight);
        grpInfoText.text = msgBody;
        grpInfoText.hidden = NO;
        grpInfoText.textAlignment = UITextAlignmentLeft;
        
        //        NSLog(@"%s,groupInfoBg is %@,grpInfoText is %@",__FUNCTION__,groupInfoBg,grpInfoText);
    }
    
    //	时间相对背景的起始位置
    
}

+(CGFloat)getGroupInfoSize:(ConvRecord*)_convRecord
{
    //	时间相对背景的起始位置
    float labelX = 7;
    
    //	如果信息较多，则需要显示多行，一行的最大宽度是320 - 20*2 - labeX * 2
    int maxWidth = SCREEN_WIDTH - group_info_bg_horizontal_space * 2 - labelX * 2;
    
    NSString *msgBody = _convRecord.msg_body;
    _convRecord.msgSize = [talkSessionUtil getSizeOfTextMsg:msgBody withFont:[UIFont systemFontOfSize:[FontSizeUtil getGroupInfoFontSize]] withMaxWidth:maxWidth];
    
    if (_convRecord.isMiLiaoMsg) {
        NSLog(@"%s %@",__FUNCTION__,NSStringFromCGSize(_convRecord.msgSize));
    }

    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    return (_convRecord.msgSize.height + 2 * group_info_vertical_space + dateBgHeight);

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    if (IOS7_OR_LATER)
//    {
//        self.contentView.frame = CGRectMake(
//                                            10,
//                                            self.contentView.frame.origin.y,
//                                            self.frame.size.width - 20,
//                                            self.contentView.frame.size.height
//                                            );
//    }
}

@end
