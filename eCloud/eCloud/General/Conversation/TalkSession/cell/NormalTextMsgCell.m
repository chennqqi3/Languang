

#import "NormalTextMsgCell.h"
#import "FontSizeUtil.h"
#import "MLEmojiLabel.h"
#import "EncryptFileManege.h"

@implementation NormalTextMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        
#pragma mark --不带超链接一般文本消息--
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        UILabel *normalTextView = [[UILabel alloc]initWithFrame:CGRectZero];
        normalTextView.font = [UIFont systemFontOfSize:message_font];
        normalTextView.numberOfLines = 0;
        normalTextView.backgroundColor = [UIColor clearColor];
        normalTextView.tag = normal_text_tag;
        normalTextView.textColor = [UIColor colorWithRed:53/255 green:53/255 blue:53/255 alpha:1.0];
        [contentView addSubview:normalTextView];
        [normalTextView release];
    }
    return self;
}

//设置文本消息的背景颜色
+ (void)setTextMsgBgColor:(ConvRecord *)_convRecord{
    
}


+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    UILabel *normalTextView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
    
    if (_convRecord.msgSize.width == text_msg_min_width) {
        normalTextView.textAlignment = NSTextAlignmentCenter;
    }else{
        normalTextView.textAlignment = NSTextAlignmentLeft;
    }
    
    normalTextView.font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
    normalTextView.frame =  CGRectMake(msg_horizontal_space,msg_vertical_space,_convRecord.msgSize.width,_convRecord.msgSize.height);
    normalTextView.text = _convRecord.msg_body;
    normalTextView.hidden = NO;
    
    
    
    [talkSessionUtil setTextMsgColor:normalTextView andConvRecord:_convRecord];

    [[self class]configureCommonView:cell andRecord:_convRecord];
}

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    contentView.hidden = NO;
    
    float contentWidth = _convRecord.msgSize.width + 2 * msg_horizontal_space;
    float contentHeight = _convRecord.msgSize.height + 2 * msg_vertical_space;
    
    if (_convRecord.newsModel) {
        
        contentWidth = _convRecord.msgSize.width;
        contentHeight = _convRecord.msgSize.height;
    }
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
+ (float)getMsgHeight:(ConvRecord *)_convRecord{
    _convRecord.msgSize = [talkSessionUtil getSizeOfTextMsg:_convRecord.msg_body withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:text_msg_max_width];
    
    NSLog(@"%s msgHeight is %.0f fontLineHeight %.0f",__FUNCTION__, _convRecord.msgSize.height,[UIFont systemFontOfSize:[FontSizeUtil getFontSize]].lineHeight);
    if (_convRecord.msgSize.height > [UIFont systemFontOfSize:[FontSizeUtil getFontSize]].lineHeight) {
//        超过一行
        CGSize _size = _convRecord.msgSize;
        _size.width = text_msg_max_width;
        _convRecord.msgSize = _size;
    }
    
    return [[self class]calculateTotalTextMsgHeight:_convRecord];
}

//获取文本消息cell的总高度
+ (float)calculateTotalTextMsgHeight:(ConvRecord *)_convRecord{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    CGSize _size = _convRecord.msgSize;
    if (_size.width < text_msg_min_width) {
        _size.width = text_msg_min_width;
    }
    if (_size.height < text_msg_min_height) {
        _size.height = text_msg_min_height;
    }
    _convRecord.msgSize = _size;
    
    //   头像和内容一起的高度
    float tempH;
    
    if (_convRecord.msg_flag == send_msg) {
        tempH = _convRecord.msgSize.height + 2 * msg_vertical_space + send_msg_body_to_header_top;
    }else{
        tempH =_convRecord.msgSize.height + 2 * msg_vertical_space + rcv_msg_body_to_header_top;
    }
    
    return dateBgHeight + tempH;
}

//长消息使用了相同的cell，获取长消息cell的高度
+ (float)getLongMsgHeight:(ConvRecord *)_convRecord{
    NSString *filePath = [talkSessionUtil getLongMsgPath:_convRecord];
    NSData *longMsgData = [EncryptFileManege getDataWithPath:filePath];
    NSString *longMsg = [[[NSString alloc] initWithData:longMsgData encoding:NSUTF8StringEncoding]autorelease];
    //	NSString *longMsg = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if(longMsg == nil || longMsg.length == 0)
    {
        longMsg = _convRecord.file_name;
    }
    
    _convRecord.msgSize = [talkSessionUtil getSizeOfTextMsg:longMsg withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:text_msg_max_width];
    
    return [[self class]calculateTotalTextMsgHeight:_convRecord];
}

//显示长消息
+ (void)configureLongMsg:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord{
    //		检查长消息是否下载，如果没有下载，那么就先去下载，然后展示
    //		如果已经下载，那么就直接展示
    NSString *filePath = [talkSessionUtil getLongMsgPath:_convRecord];
    NSData *longMsgData = [EncryptFileManege getDataWithPath:filePath];
    NSString *longMsg = [[[NSString alloc] initWithData:longMsgData encoding:NSUTF8StringEncoding]autorelease];
    if(longMsg == nil || longMsg.length == 0)
    {
        longMsg = _convRecord.file_name;
    }
    
    UILabel *textView = (UILabel*)[cell.contentView viewWithTag:normal_text_tag];
    textView.font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
    textView.frame = CGRectMake(msg_horizontal_space,msg_vertical_space,_convRecord.msgSize.width,_convRecord.msgSize.height);
    textView.text = [NSString stringWithFormat:@"%@", longMsg];
    textView.hidden = NO;

    [talkSessionUtil setTextMsgColor:textView andConvRecord:_convRecord];
    
    [[self class]configureCommonView:cell andRecord:_convRecord];
}


@end
