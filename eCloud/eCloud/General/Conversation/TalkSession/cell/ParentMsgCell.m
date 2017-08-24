
#import "ParentMsgCell.h"
#import "talkSessionUtil.h"
#import "BgImageUtil.h"
#import "NormalTextMsgCell.h"

#define TALKSESSION_NAME_COLOR ([UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:0])
@implementation ParentMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)addCommonView:(UITableViewCell *)cell
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.opaque = YES;
    
//	MessageView *messageView = [MessageView getMessageView];
	
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
	
	[cell.contentView addSubview:dateBg];
	[dateBg release];
	
#pragma mark --头像--
	//	用户头像
    UIImageView *headImageView =  [UserDisplayUtil getUserLogoViewWithLogoHeight:logo_height];// [UserDisplayUtil getUserChatLogoView];//[[UIImageView alloc]initWithFrame:CGRectZero];
	headImageView.userInteractionEnabled = YES;
	headImageView.tag = head_tag;
	
//	UILabel *namelabel=[[UILabel alloc]initWithFrame:CGRectMake(0, chat_user_logo_size, chat_user_logo_size, 20)];
    UILabel *namelabel=[[UILabel alloc]initWithFrame:CGRectMake(headImageView.frame.size.width + logo_horizontal_space,0, 200.0, sender_name_height)];
	namelabel.hidden = YES;
	namelabel.tag = head_empName_tag;
    namelabel.textColor = sender_name_color;
    namelabel.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:0];
	namelabel.font=[UIFont systemFontOfSize:sender_name_font_size];
	namelabel.textAlignment=NSTextAlignmentLeft;
	[headImageView addSubview:namelabel];
	[namelabel release];
    
//    把编辑按钮放到头像view里，作为头像view的子view
    if (CAN_EDIT_CONVRECORD) {
        UIButton *editButton = [[[UIButton alloc]initWithFrame:CGRectMake(0, (headImageView.frame.size.height - edit_button_size) * 0.5, edit_button_size, edit_button_size)]autorelease];
        editButton.tag = head_edit_button_tag;
        editButton.userInteractionEnabled = NO;
        [headImageView addSubview:editButton];
    }
	
	[cell.contentView addSubview:headImageView];
		
#pragma mark --发送消息气泡--
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	bubbleImageView.tag=bubble_send_tag;
	bubbleImageView.userInteractionEnabled = YES;
//	//	自己和联系人采用不同的气泡图片
	bubbleImageView.image = [BgImageUtil getSndBubbleImage]; 
	bubbleImageView.highlightedImage = [BgImageUtil getSndHighlightBubbleImage];	
	[cell.contentView addSubview:bubbleImageView];
	
	[bubbleImageView release];
	
#pragma mark --接收消息气泡--
	bubbleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
	bubbleImageView.tag=bubble_rcv_tag;
	bubbleImageView.userInteractionEnabled = YES;

	bubbleImageView.image = [BgImageUtil getRcvBubbleImage];
	bubbleImageView.highlightedImage = [BgImageUtil getRcvHighlightBubbleImage];	
	[cell.contentView addSubview:bubbleImageView];
	
	[bubbleImageView release];
	
#pragma mark --消息内容--
	UIView *contentView = [[UIView alloc]initWithFrame:CGRectZero];
	contentView.userInteractionEnabled = YES;
    contentView.layer.cornerRadius = msg_body_bg_arc;
    contentView.clipsToBounds = YES;
    
	contentView.tag = body_tag;
    [cell.contentView addSubview:contentView];
    [contentView release];
    
//    contentView.backgroundColor = [UIColor redColor];
    
    // update by shisp 最后添加状态view 图片消息显示时 body会覆盖大部分的状态view 导致状态view

#pragma mark --状态--
    UIView *statusView = [[UIView alloc]initWithFrame:CGRectZero];
    statusView.tag = status_tag;
//    statusView.backgroundColor = [UIColor blueColor];
    
    // 消息发送失败的按钮
    //    update by shisp 发送失败按钮不能够正常显示，修改成UIImageView试试
    //	UIButton *failView=[[UIButton alloc]init];
    //	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail.gif"] forState:UIControlStateNormal];
    //	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateSelected];
    //	[failView setImage:[StringUtil getImageByResName:@"send_msg_fail_down.gif"] forState:UIControlStateHighlighted];
    UIImageView *failView = [[UIImageView alloc]initWithImage:[StringUtil getImageByResName:@"send_fail.png"]];
    failView.frame = CGRectMake(0, 0, FAIL_BTN_SIZE, FAIL_BTN_SIZE);
    failView.tag = status_failBtn_tag;
    failView.hidden = YES;
    [statusView addSubview:failView];
    [failView release];
    
    // 发送录音时需要一个view，提示用户正在上传录音
    //		现在是发送图片，录音和文字都需要上传提示
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.tag = status_spinner_tag;
    [statusView addSubview:spinner];
    [spinner release];

    UIImageView *downloadCancelBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, FAIL_BTN_SIZE, FAIL_BTN_SIZE)];
    downloadCancelBtn.userInteractionEnabled = YES;
    downloadCancelBtn.tag = file_download_cancel_tag;
    [downloadCancelBtn setImage:[StringUtil getImageByResName:@"file_stop.png"]];
    [statusView addSubview:downloadCancelBtn];
    [downloadCancelBtn release];
    
    //		在这里需要判断，如果是收到的录音消息，那么需要判断，是否显示未读标志
    UIImageView *redimage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 6, 6)];
    redimage.hidden=YES;
    redimage.tag=status_audio_tag;
    redimage.image=[StringUtil getImageByResName:@"new_msg_icon.png"];
    [statusView addSubview:redimage];
    [redimage release];
    
    /** 增加一个密聊消息能够显示的秒数 */
    UILabel *_label = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, [UIFont systemFontOfSize:11].lineHeight)]autorelease];
    _label.tag = status_miliaomsg_lefttime;
    _label.font = [UIFont systemFontOfSize:11];
    _label.textColor = [UIColor blueColor];
    _label.backgroundColor = [UIColor clearColor];
    [statusView addSubview:_label];
    
#if defined(_HUAXIA_FLAG_) || defined(_ZHENGRONG_FLAG_)
    //增加钉消息标志 图片
    UIImageView *dingxiaoxiImage=[[UIImageView alloc]initWithFrame:CGRectZero];
    dingxiaoxiImage.hidden=YES;
    dingxiaoxiImage.tag=status_dingxiaoxi_flag_tag;
    [statusView addSubview:dingxiaoxiImage];
    [dingxiaoxiImage release];
#endif
    
#pragma mark --一呼百应消息--
    UIImageView *receiptBg = [[UIImageView alloc]init];// [[UIImageView alloc] initWithImage:[BgImageUtil getDateBgImage]];
    receiptBg.tag = receipt_tag;
    
    UILabel *receiptLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    receiptLabel.textAlignment = NSTextAlignmentCenter;
    receiptLabel.backgroundColor = [UIColor clearColor];
    receiptLabel.font=[UIFont systemFontOfSize:MSG_RECEIPT_FONTSIZE] ;//time_font_size];
    //	receiptLabel.textColor = [UIColor whiteColor];
    receiptLabel.textColor = [StringUtil colorWithHexString:MSG_RECEIPT_OTHER_COLOR];
    receiptLabel.tag = receipt_text_tag;
    [receiptBg addSubview:receiptLabel];
    [receiptLabel release];
    
    [statusView addSubview:receiptBg];
    
    [receiptBg release];
    

    [cell.contentView addSubview:statusView];
    [statusView release];
    
}

// 设置气泡的frame
+ (void)setbubbleImageViewFrameByCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    
    // 获取气泡view
    UIImageView *bubbleImageView = (UIImageView *)[cell.contentView viewWithTag:bubble_send_tag];
    
    if (_convRecord.msg_flag == rcv_msg) {
        bubbleImageView = (UIImageView *)[cell.contentView viewWithTag:bubble_rcv_tag];
    }
    
    bubbleImageView.frame = contentView.frame;
    bubbleImageView.hidden = YES;
}

//设置状态view的显示
+ (void)configureStatusView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord{
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    
    float contentX = contentView.frame.origin.x;
    float contentY = contentView.frame.origin.y;
    float contentWidth = contentView.frame.size.width;
    float contentHeight = contentView.frame.size.height;
    
    //    状态view 的y值 与 消息内容相同 高度也相同 宽度为固定宽度 x值需要计算
    float statusX;
    float statusY = contentY;
    float statusHeight = contentHeight;
    float statusWidth = msg_status_width;
    
    if (_convRecord.msg_flag == send_msg) {
        statusX = contentX - msg_status_horizontal_space - statusWidth;
    }else{
        statusX = contentX + contentWidth + msg_status_horizontal_space;
    }
    
    UIView *statusView = (UIView*)[cell.contentView viewWithTag:status_tag];
    statusView.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight);
    statusView.hidden = NO;
    statusView.backgroundColor = [UIColor clearColor];// [UIColor colorWithWhite:125/255.0 alpha:0.5];
    
    //    配置回执消息的提示
    if (_convRecord.isHuizhiMsg) {
        /** 已经打开的密聊消息就不再显示发送回执或者回执已发送的提示了 */
        if (_convRecord.isMiLiaoMsg && _convRecord.isMiLiaoMsgOpen) {
            
        }else{
            
            NSString *receiptTips = _convRecord.receiptTips;
            
            UIFont *_font = [UIFont systemFontOfSize:MSG_RECEIPT_FONTSIZE];
            
            CGSize size = [receiptTips sizeWithFont:_font];
            
            UIImageView *receiptBGView = (UIImageView *)[cell.contentView viewWithTag:receipt_tag];
            receiptBGView.frame = CGRectMake(0 , 0,size.width, size.height);
            receiptBGView.hidden = NO;
            
            //		增加显示提示信息
            UILabel *receiptLabel= (UILabel*)[cell.contentView viewWithTag:receipt_text_tag];
            receiptLabel.text = receiptTips;
            receiptLabel.frame = CGRectMake(0, 0, size.width, size.height);
            receiptLabel.hidden = NO;
            
            receiptLabel.textColor = [talkSessionUtil getReceiptTipsColorOfActive];
            
            //    增加判断 如果是发送的消息 显示激活的颜色 如果是收到的消息，那么还未发送回执，显示激活；已经发送了回执，则使用非激活颜色
            if (_convRecord.msg_flag == rcv_msg && _convRecord.readNoticeFlag == 1) {
                receiptLabel.textColor = [talkSessionUtil getReceiptTipsColorOfInActive];
            }
//            如果是发送的消息 并且是单人回执消息 那么收到回执后，颜色也要显示为灰色
            if (_convRecord.msg_flag == send_msg && _convRecord.conv_type == singleType) {
                int readCount = [[ReceiptDAO getDataBase] getReadUserCountOfMsg:_convRecord.msgId];
                if (readCount == 1) {
                    receiptLabel.textColor = [talkSessionUtil getReceiptTipsColorOfInActive];
                }
            }
        }
    }
    
    UIImageView *receiptBGView = (UIImageView *)[cell.contentView viewWithTag:receipt_tag];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView*)[cell.contentView viewWithTag:status_spinner_tag];
    UIImageView *failView=(UIImageView*)[cell.contentView viewWithTag:status_failBtn_tag];
    UIImageView *downloadCancelBtn=(UIImageView*)[cell.contentView viewWithTag:file_download_cancel_tag];
 
    UIImageView *redimage=(UIImageView*)[cell.contentView viewWithTag:status_audio_tag];
    
    UILabel *miLiaoMsgLeftTimeLabel = (UILabel *)[cell.contentView viewWithTag:status_miliaomsg_lefttime];

    CGRect _frame = redimage.frame;
    _frame.origin.x = 0;
    _frame.origin.y = 0;
    redimage.frame = _frame;
    
    float receiptBGViewX = 0;
    float receiptBGViewY = 0;
    
    float spinnerX = 0;
    float spinnerY = 0;
    
    float failViewX = 0;
    float failViewY = 0;
    
//    float downloadCancelBtnX = 0;
//    float downloadCancelBtnY = 0;
    
    
    if (contentHeight <= msg_body_min_height) {
        spinnerY = (statusHeight - spinner.frame.size.height) * 0.5;
        failViewY = (statusHeight - failView.frame.size.height) * 0.5;
        
        if (!receiptBGView.hidden) {
            receiptBGViewY = (statusHeight - receiptBGView.frame.size.height) * 0.5;
        }
        
    }else{
        spinnerY = statusHeight - spinner.frame.size.height - msg_status_to_msg_vertical_space;
        failViewY = statusHeight - failView.frame.size.height - msg_status_to_msg_vertical_space;
        
        if (!receiptBGView.hidden) {
            receiptBGViewY = statusHeight - receiptBGView.frame.size.height - msg_status_to_msg_vertical_space;
        }
    }
    
    if (receiptBGView.hidden) {
        if (_convRecord.msg_flag == send_msg) {
            spinnerX = statusWidth - spinner.frame.size.width;
            failViewX = statusWidth - spinner.frame.size.width;
        }else{
            spinnerX = 0;
            failViewX = 0;
        }
    }else{
        if (_convRecord.msg_flag == send_msg) {
            spinnerX = statusWidth - receiptBGView.frame.size.width - msg_status_horizontal_space - spinner.frame.size.width;
            failViewX = statusWidth - receiptBGView.frame.size.width - msg_status_horizontal_space - failView.frame.size.width;
            
            receiptBGViewX = statusWidth - receiptBGView.frame.size.width;
            
        }else{
            spinnerX = receiptBGView.frame.size.width + msg_status_horizontal_space;
            failViewX = receiptBGView.frame.size.width + msg_status_horizontal_space;
            
            receiptBGViewX = 0;
        }
    }
    
    _frame = spinner.frame;
    _frame.origin = CGPointMake(spinnerX, spinnerY);
    spinner.frame = _frame;
    
    _frame = failView.frame;
    _frame.origin = CGPointMake(failViewX, failViewY);
    failView.frame = _frame;
    failView.hidden = NO;
    
//    文件上传下载的view和消息发送失败的view其实大小一样
    downloadCancelBtn.frame = failView.frame;
    
    if (!receiptBGView.hidden) {
        _frame = receiptBGView.frame;
        _frame.origin = CGPointMake(receiptBGViewX, receiptBGViewY);
        receiptBGView.frame = _frame;
        
        CGPoint _center = receiptBGView.center;
        _center.y = spinner.center.y;
        receiptBGView.center = _center;
    }
    
    
//    密聊消息 剩余时间
    if (_convRecord.isMiLiaoMsg) {
        
        if (_convRecord.miLiaoMsgLeftTime) {
//            CGRect _frame = miLiaoMsgLeftTimeLabel.frame;
//            _frame.origin.y = statusHeight - _frame.size.height - 5;
//            miLiaoMsgLeftTimeLabel.frame = _frame;
            
            CGPoint _center = miLiaoMsgLeftTimeLabel.center;
            _center.y = spinner.center.y;
            miLiaoMsgLeftTimeLabel.center = _center;
            
            miLiaoMsgLeftTimeLabel.text = [NSString stringWithFormat:@"%dS",_convRecord.miLiaoMsgLeftTime];
            miLiaoMsgLeftTimeLabel.hidden = NO;
            
            miLiaoMsgLeftTimeLabel.textAlignment = NSTextAlignmentCenter;
        }
    }

}


- (void)layoutSubviews
{
    [super layoutSubviews];
    return;
    
    if (IOS7_OR_LATER)
    {
        self.contentView.frame = CGRectMake(
                                            10,
                                            self.contentView.frame.origin.y,
                                            self.frame.size.width - 20,
                                            self.contentView.frame.size.height
                                            );
    }
    
}

@end
