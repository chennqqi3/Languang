
#import "LinkTextMsgCell.h"
#import "TextLinkView.h"
#import "ConvRecord.h"
#import "NormalTextMsgCell.h"

@implementation LinkTextMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
#pragma mark --带超链接的文本消息--
        TextLinkView *linkView=[[TextLinkView alloc]initWithFrame:CGRectZero];
        linkView.tag = link_text_tag;
        [contentView addSubview:linkView];
        [linkView release];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//显示文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord{
    TextLinkView *linkView = (TextLinkView*)[cell.contentView viewWithTag:link_text_tag];
    linkView.textWidth = text_msg_max_width;
    linkView.textstr = _convRecord.msg_body;
    
    if (_convRecord.msg_flag == send_msg) {
        linkView.textColor = send_msg_text_color;
        linkView.linkTextColor = send_link_text_color;
    }else{
        linkView.textColor = rcv_msg_text_color;
        linkView.linkTextColor = rcv_link_text_color;
    }
    [linkView getViewSize];
    [linkView updateShowContent];
    linkView.hidden = NO;
    
    CGRect _frame = linkView.frame;
    _frame.origin = CGPointMake(msg_horizontal_space, msg_vertical_space);
    linkView.frame = _frame;
    
    [NormalTextMsgCell configureCommonView:cell andRecord:_convRecord];
}

//文本消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord{
    TextLinkView *linkView = [[TextLinkView alloc]initWithFrame:CGRectZero];
    linkView.textWidth = text_msg_max_width;
    linkView.textstr = _convRecord.msg_body;
    _convRecord.msgSize=[linkView getViewSize];
    [linkView release];
    
    return [NormalTextMsgCell calculateTotalTextMsgHeight:_convRecord];
}



@end
