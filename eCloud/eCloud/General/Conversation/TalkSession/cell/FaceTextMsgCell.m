
#import "FaceTextMsgCell.h"
#import "NormalTextMsgCell.h"
#import "MessageView.h"
#import "ConvRecord.h"

@implementation FaceTextMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
#pragma mark --不带超链接图文混合消息--
        TextMessageView *textPicView = [[TextMessageView alloc]initWithFrame:CGRectZero];
        textPicView.maxWidth = MAX_WIDTH;
        textPicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textPicView.tag = nolink_text_pic_tag;
        [contentView addSubview:textPicView];
        [textPicView release];
    }
    return self;
}


+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord{
    TextMessageView* textMessageView = (TextMessageView*)[cell.contentView viewWithTag:nolink_text_pic_tag];
    textMessageView.frame = CGRectMake(msg_horizontal_space,msg_horizontal_space,_convRecord.msgSize.width,_convRecord.msgSize.height);
    textMessageView.hidden = NO;
    if (_convRecord.msg_flag == send_msg) {
        textMessageView.textColor = send_msg_text_color;
    }else{
        textMessageView.textColor = rcv_msg_text_color;
    }
    
    [textMessageView setMessage:_convRecord.textMsgArray];
    
    [NormalTextMsgCell configureCommonView:cell andRecord:_convRecord];
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord{
    CGSize messageViewSize = [[MessageView getMessageView] getTextMessageViewSize:_convRecord.textMsgArray andMaxWidth:text_msg_max_width];
    _convRecord.msgSize = messageViewSize;
    
    return [NormalTextMsgCell calculateTotalTextMsgHeight:_convRecord];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
