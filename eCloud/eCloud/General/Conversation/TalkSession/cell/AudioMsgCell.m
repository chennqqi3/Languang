
#import "AudioMsgCell.h"
#import "FontSizeUtil.h"
#import "ConvRecord.h"
#import "ImageUtil.h"

@implementation AudioMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        
#pragma mark --录音消息--
        UIButton *clickbutton=[[UIButton alloc]initWithFrame:CGRectZero];
        clickbutton.tag=audio_tag;
        
        UIImageView *buttonimage=[[UIImageView alloc]initWithFrame:CGRectZero];
        buttonimage.tag=audio_playImageView_tag;
        
        UILabel *timeSecond = [[UILabel alloc]initWithFrame:CGRectZero];
        timeSecond.backgroundColor=[UIColor colorWithRed:178 green:225 blue:69 alpha:0];
        timeSecond.font=[UIFont systemFontOfSize:msg_audio_sec_font_size];
        timeSecond.tag = audio_second_tag;
        [clickbutton addSubview:buttonimage];
        [buttonimage release];
        
        [clickbutton addSubview:timeSecond];
        [timeSecond release];
        
        [contentView addSubview:clickbutton];
        [clickbutton release];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    float contentWidth = _convRecord.msgSize.width;
    float contentHeight = _convRecord.msgSize.height;
    
    // 设置背景按钮的布局
    UIButton *clickbutton= (UIButton*)[cell.contentView viewWithTag:audio_tag];
    clickbutton.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    clickbutton.hidden = NO;
    
    if(_convRecord.msg_flag == send_msg)
    {
        [clickbutton setBackgroundImage:[ImageUtil imageWithColor:[StringUtil colorWithHexString:msg_btn_send_color_nomal]] forState:UIControlStateNormal];
        [clickbutton setBackgroundImage:[ImageUtil imageWithColor:[StringUtil colorWithHexString:msg_btn_send_color_highlight]] forState:UIControlStateHighlighted];
    }
    else
    {
        [clickbutton setBackgroundImage:[ImageUtil imageWithColor:[StringUtil colorWithHexString:msg_btn_rcv_color_nomal]] forState:UIControlStateNormal];
        [clickbutton setBackgroundImage:[ImageUtil imageWithColor:[StringUtil colorWithHexString:msg_btn_rcv_color_highlight]] forState:UIControlStateHighlighted];
    }
    
    // 设置播放图标的布局
    UIImage *image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
//    CGSize imageSize = image.size;
//    CGSize imageSize = CGSizeMake(12.55, 18);
    CGSize imageSize = CGSizeMake(18, 18);
    CGFloat buttonImageX = msg_playimage_horizontal_space;
    CGFloat buttomImageY = msg_playimage_vertical_space;
    
    UIImageView *buttonimage=(UIImageView*)[cell.contentView viewWithTag:audio_playImageView_tag];
    
    if(_convRecord.msg_flag == send_msg)
    {
        buttonImageX = contentWidth - imageSize.width - msg_playimage_horizontal_space;
        buttonimage.image = [StringUtil getImageByResName:@"voice_send_default.png"];
    }
    else
    {
        buttonimage.image = [StringUtil getImageByResName:@"voice_rcv_default.png"];
    }
    buttonimage.frame = CGRectMake(buttonImageX, buttomImageY, imageSize.width , imageSize.height);
    buttonimage.hidden = NO;
    
    //	录音秒数
    UILabel *timeSecond = (UILabel*)[cell.contentView viewWithTag:audio_second_tag];
    timeSecond.font = [UIFont systemFontOfSize:msg_audio_sec_font_size];
    NSString *audioSec = [NSString stringWithFormat:@"%@\"",_convRecord.file_size];
    CGSize audioSecSize = [audioSec sizeWithFont:[UIFont systemFontOfSize:msg_audio_sec_font_size]];
    CGFloat timeLabelX = msg_seclabel_horizontal_space;
    CGFloat timeLabelY = msg_seclabel_vertical_space;
    
    if(_convRecord.msg_flag == rcv_msg)
    {
        timeLabelX = contentWidth - audioSecSize.width - msg_seclabel_horizontal_space;
    }
    timeSecond.frame = CGRectMake(timeLabelX, timeLabelY, audioSecSize.width , audioSecSize.height);
    timeSecond.text = audioSec;
    if (_convRecord.msg_flag == send_msg) {
        timeSecond.textColor = send_msg_text_color;
    }else{
        timeSecond.textColor = [StringUtil colorWithHexString:msg_seclabel_fontcolor];
    }
    timeSecond.hidden = NO;
    
    // 设置消息体的位置
    [self configureCommonView:cell andRecord:_convRecord];
}

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord
{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    contentView.hidden = NO;
    
    float contentWidth = _convRecord.msgSize.width;
    float contentHeight = _convRecord.msgSize.height;
    
    UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:head_tag];
    
    //    收到的消息
    float contentX = 0;
    float contentY = 0;
    
    //    发送出去的消息
    if (_convRecord.msg_flag == send_msg) {
        contentView.backgroundColor = send_msg_bg_color;
        contentX = headImageView.frame.origin.x - logo_horizontal_space - contentWidth;
        contentY = headImageView.frame.origin.y + send_msg_body_to_header_top;
    }else{
        contentX = headImageView.frame.origin.x + headImageView.frame.size.width + logo_horizontal_space;
        contentY = headImageView.frame.origin.y + rcv_msg_body_to_header_top;
        contentView.backgroundColor = rcv_msg_bg_color;
    }
    
    contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
    
//    [[super class] setbubbleImageViewFrameByCell:cell andRecord:_convRecord];
    
    [ParentMsgCell configureStatusView:cell andRecord:_convRecord];
    
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord
{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    int timeint = [_convRecord.file_size intValue];
    float cwidth = MIN_AUDIO_WIDTH + PER_SECOND_WIDTH * timeint;
    
    if(cwidth > MAX_AUDIO_WIDTH)
    {
        cwidth = MAX_AUDIO_WIDTH;
    }
    CGSize _size = CGSizeMake(cwidth, AUDIO_HEIGHT);
    _convRecord.msgSize = _size;
    
    //   头像和内容一起的高度
    float tempH;
    
    if (_convRecord.msg_flag == send_msg) {
        // 头像与消息体顶端对齐
        tempH = _convRecord.msgSize.height + send_msg_body_to_header_top;
    }else{
        // 多了一个头像的差值
        tempH =_convRecord.msgSize.height + rcv_msg_body_to_header_top;
    }
    
    return dateBgHeight + tempH;
}

/** 激活录音消息 */
+ (void)activeCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord{
    UIButton *clickButton = [cell.contentView viewWithTag:audio_tag];
    clickButton.highlighted = YES;

}
/** 录音消息回复正常状态 */
+ (void)deactiveCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord{
    UIButton *clickButton = [cell.contentView viewWithTag:audio_tag];
    clickButton.highlighted = NO;
}

@end
