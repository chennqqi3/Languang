//
//  WXReplyToOneMsgCellTableViewCell.m
//  eCloud
//
//  Created by shisuping on 17/5/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "WXReplyToOneMsgCellTableViewCellArc.h"
#import "TalkSessionDefine.h"
#import "MLEmojiLabel.h"
#import "ConvRecord.h"
#import "MessageView.h"
#import "talkSessionUtil.h"
#import "FontSizeUtil.h"
#import "ReplyOneMsgModelArc.h"
#import "openWebViewController.h"
#import "talkSessionViewController.h"
#import "NormalTextMsgCell.h"

/** 左右侧空白 */
#define left_space (8)

/** 上下空白 */
#define top_space (10)

/** 分割线上下空白 */
#define seperate_line_space (5)

/** label最小高度高度 */
#define label_min_height (25)

/** 双引号图片 size */
#define quote_view_size (0)

/** 发送人 发送时间 显示的最大宽度 */
#define sender_name_max_width (MAX_WIDTH - (quote_view_size + 10) * 2 )

/** 发送人 发送时间 字体大小 */
#define sender_name_font (14)

/** 发送人 发送内容显示的最大宽度 */
#define sender_msg_max_width (MAX_WIDTH - (quote_view_size + 10) * 2 )

/** 发送人 发送内容 字体大小 */
#define sender_msg_font (14)

/** 回复人回复内容的宽度 */
#define reply_msg_max_width (MAX_WIDTH - 10 * 2)

#define REPLY_MSG_WIDTH (247.0)

/** 回复人回复内容 字体大小 和 普通文本字体大小一致 */

@interface WXReplyToOneMsgCellTableViewCellArc () <TTTAttributedLabelDelegate>

@end

@implementation WXReplyToOneMsgCellTableViewCellArc


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [super addCommonView:self];
        
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        
        
        
        /** 父view */
        UIView *parentView = [[UIView alloc]initWithFrame:CGRectMake(0,0,REPLY_MSG_WIDTH,0)];
        parentView.tag = reply_one_msg_parent_view_tag;
//        parentView.backgroundColor = [UIColor redColor];
        [contentView addSubview:parentView];
        
        /** 原始消息父view */
        UIView *originMsgParentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, REPLY_MSG_WIDTH, 0)];
        originMsgParentView.tag = reply_one_msg_send_parent_view_tag;
        [parentView addSubview:originMsgParentView];
        
        
        
        /** 双引号view */
        UILabel *quotoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top_space, quote_view_size, quote_view_size)];
        quotoLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
//        quotoLabel.tag = reply_one_msg_quote_view_tag;
//        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"“"];
//        [attrStr addAttribute:NSFontAttributeName
//                        value:[UIFont systemFontOfSize:27.0f]
//                        range:NSMakeRange(0, 1)];
//        [attrStr addAttribute:NSBaselineOffsetAttributeName
//                        value:@(-5)   // 正值上偏 负值下偏
//                        range:NSMakeRange(0, 1)];
//        quotoLabel.attributedText = attrStr;
        quotoLabel.text = @"";
        quotoLabel.font = [UIFont systemFontOfSize:sender_name_font];
        [originMsgParentView addSubview:quotoLabel];
        
        
//        UIImageView *quotoView = [[UIImageView alloc]initWithFrame:CGRectMake(left_space, top_space, quote_view_size, quote_view_size)];
//        quotoView.tag = reply_one_msg_quote_view_tag;
////        quotoView.backgroundColor = [UIColor yellowColor];
//        [originMsgParentView addSubview:quotoView];
        
        /** 发送人名字、发送人时间 不用支持表情和链接*/
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0 + quote_view_size, top_space, REPLY_MSG_WIDTH, 0)];
        nameLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
        nameLabel.tag = reply_one_msg_sender_name_and_time_label_tag;
        nameLabel.numberOfLines = 0;
        nameLabel.font = [UIFont systemFontOfSize:sender_name_font];
        [originMsgParentView addSubview:nameLabel];
        
        /** 发送人发送内容label 支持表情 可以不用支持超链接，因为点击时会跳转到原来的内容 */
        MLEmojiLabel *senderMsgLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, REPLY_MSG_WIDTH, 0)];
        [originMsgParentView addSubview:senderMsgLabel];
        senderMsgLabel.tag = reply_one_msg_sender_msg_label_tag;
        senderMsgLabel.bundle = [StringUtil getBundle];
        senderMsgLabel.font = [UIFont systemFontOfSize:sender_msg_font];
//        senderMsgLabel.numberOfLines = 2;
        senderMsgLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        // 不支持话题和@用户、超链接和号码
        senderMsgLabel.isNeedAtAndPoundSign = NO;
        senderMsgLabel.disableThreeCommon = YES;
        
        senderMsgLabel.customEmojiRegex = EMOJI_LABEL_CUSTOM_EMOJI_REGEX;
        senderMsgLabel.customEmojiPlistName = EMOJI_LABEL_CUSTOM_EMOJI_PLISTNAME;

        /** 分割线 可以是一个label */
        UILabel *seperatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(left_space, 0, text_msg_max_width, 1)];
        seperatorLabel.tag = reply_one_msg_seperate_line_tag;
        seperatorLabel.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1/1.0];
        [originMsgParentView addSubview:seperatorLabel];
        
        /** 回复人的内容 */
        MLEmojiLabel *msgLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, REPLY_MSG_WIDTH, 0)];
        msgLabel.delegate = self;
        [parentView addSubview:msgLabel];
        msgLabel.tag = reply_one_msg_reply_msg_label_tag;
        msgLabel.bundle = [StringUtil getBundle];
        msgLabel.font = [UIFont systemFontOfSize:[FontSizeUtil getFontSize]];
        msgLabel.numberOfLines = 0;
        msgLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        // 不支持话题和@用户, 支持超链接和号码
        msgLabel.isNeedAtAndPoundSign = NO;
        msgLabel.disableThreeCommon = NO;
        
        msgLabel.customEmojiRegex = EMOJI_LABEL_CUSTOM_EMOJI_REGEX;
        msgLabel.customEmojiPlistName = EMOJI_LABEL_CUSTOM_EMOJI_PLISTNAME;
        
        
    }
    
    return self;
}

+ (void)getReplyToOneMsgSize:(ConvRecord *)_convRecord
{
    float msgTotalHeight = 0;
    
    ReplyOneMsgModelArc *_model = _convRecord.replyOneMsgModel;
    NSString *str = [NSString stringWithFormat:@"%@ %@",_model.senderName,_model.sendTimeDsp];
    
    CGSize _size = [talkSessionUtil getSizeOfTextMsg:str withFont:[UIFont systemFontOfSize:sender_name_font] withMaxWidth:REPLY_MSG_WIDTH];
    
    /** 如果小于最小高度，那么设置为最新高度，否则就是2个最小高度 */
    if (_size.height < label_min_height) {
        _size.height = label_min_height;
    }else{
        _size.height = 2 * label_min_height;
    }
    
    msgTotalHeight += _size.height;
    _model.senderNameHeight = _size.height;
    
    _size = [talkSessionUtil getSizeOfTextMsg:_model.sendMsgBody withFont:[UIFont systemFontOfSize:sender_msg_font] withMaxWidth:sender_msg_max_width];
    
    if (_size.height < label_min_height) {
        _size.height = label_min_height;
    }else{
        _size.height = 2 * label_min_height;
    }

    msgTotalHeight += _size.height;
    _model.sendMsgHeight = _size.height;

//        再加上分割线的高度
    msgTotalHeight += seperate_line_space * 2 + 1;
    
//    加上消息内容
    _size = [talkSessionUtil getSizeOfTextMsg:_convRecord.msg_body withFont:[UIFont systemFontOfSize:[FontSizeUtil getFontSize]] withMaxWidth:REPLY_MSG_WIDTH];
    
    msgTotalHeight += _size.height;
    _model.replayMsgHeight = _size.height;
    
    _convRecord.msgSize = CGSizeMake(REPLY_MSG_WIDTH, msgTotalHeight);
}

+ (void)configureReplyToOneMsgCell:(WXReplyToOneMsgCellTableViewCellArc *)cell andConvRecord:(ConvRecord *)_convRecord{
    
    ReplyOneMsgModelArc *_model = _convRecord.replyOneMsgModel;
    
    /** 双引号图标 */
    UILabel *quoteView = (UILabel *)[cell.contentView viewWithTag:reply_one_msg_quote_view_tag];
    quoteView.hidden = NO;
    
    /** 发送人名字和时间 */
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:reply_one_msg_sender_name_and_time_label_tag];
    nameLabel.hidden = NO;
    CGRect _frame = nameLabel.frame;
//    if (_convRecord.msg_flag == send_msg) {
//        _frame.origin.x +=8;
//    }
    _frame.size.height = _model.senderNameHeight;
    nameLabel.text = [NSString stringWithFormat:@"\“%@ %@",_model.senderName,_model.sendTimeDsp];
    nameLabel.frame = _frame;
    if (_convRecord.msg_flag == send_msg) {
        
        nameLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];//[UIColor colorWithWhite:0.6 alpha:1];
        
    }
//    NSLog(@"name label:%@",NSStringFromCGRect(_frame));
    
/** 发送内容 */
    MLEmojiLabel *sendMsgLabel = (MLEmojiLabel *)[cell viewWithTag:reply_one_msg_sender_msg_label_tag];
    sendMsgLabel.hidden = NO;
    if (_convRecord.msg_flag == send_msg) {
        
        sendMsgLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        
    }else{
        
        sendMsgLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    }
    
    [sendMsgLabel setEmojiText:_model.sendMsgBody];
    _frame = sendMsgLabel.frame;
    _frame.size.height = _model.sendMsgHeight;
    _frame.origin.y = nameLabel.frame.origin.y + nameLabel.frame.size.height;
    sendMsgLabel.frame = _frame;
    
//    NSLog(@"sendMsgLabel:%@",NSStringFromCGRect(_frame));

    /** 分割线 */
    UILabel *seperateView = (UILabel *)[cell viewWithTag:reply_one_msg_seperate_line_tag];
    seperateView.hidden = NO;
    _frame = seperateView.frame;
    if (_convRecord.msg_flag == send_msg) {
        
        seperateView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];//[UIColor colorWithWhite:0.6 alpha:1];
        
    }
    _frame.origin.y = sendMsgLabel.frame.origin.y + sendMsgLabel.frame.size.height + seperate_line_space;
    seperateView.frame = _frame;
    
//    NSLog(@"seperateView:%@",NSStringFromCGRect(_frame));

    /** 发送消息的父view */
    UIView *sendParentView = [cell viewWithTag:reply_one_msg_send_parent_view_tag];
    sendParentView.hidden = NO;
    _frame = sendParentView.frame;
    _frame.size.height = seperateView.frame.origin.y + seperateView.frame.size.height + seperate_line_space;
    sendParentView.frame = _frame;
    
//    NSLog(@"sendParentView:%@",NSStringFromCGRect(_frame));

    
    /** 回复消息的内容 */
    MLEmojiLabel *replyMsgLabel = (MLEmojiLabel *)[cell viewWithTag:reply_one_msg_reply_msg_label_tag];
    replyMsgLabel.hidden = NO;
    _frame = replyMsgLabel.frame;
    _frame.origin.y = sendParentView.frame.size.height;
    _frame.size.height = _model.replayMsgHeight;
    replyMsgLabel.frame = _frame;
    if (_convRecord.msg_flag == send_msg) {
        
        replyMsgLabel.textColor = [UIColor whiteColor];
        
    }
    [replyMsgLabel setEmojiText:_convRecord.msg_body];
    
//    NSLog(@"replyMsgLabel:%@",NSStringFromCGRect(_frame));

    
    UIView *parentView = [cell viewWithTag:reply_one_msg_parent_view_tag];
    parentView.hidden = NO;
    _frame = parentView.frame;
    
//    if (_convRecord.msg_flag == rcv_msg) {
//        _frame.origin.x = left_space;
//    }
    _frame.origin.x = left_space;
    _frame.size.height = replyMsgLabel.frame.origin.y + replyMsgLabel.frame.size.height + top_space;
    parentView.frame = _frame;
    
    
//    NSLog(@"parentView:%@",NSStringFromCGRect(_frame));

}

//定向回复消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord{
    [[self class]getReplyToOneMsgSize:_convRecord];
    return [NormalTextMsgCell calculateTotalTextMsgHeight:_convRecord];
}

//显示定向回复消息
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord{
    [[self class]configureReplyToOneMsgCell:(WXReplyToOneMsgCellTableViewCellArc *)cell andConvRecord:_convRecord];
    [NormalTextMsgCell configureCommonView:cell andRecord:_convRecord];
}


#pragma mark - <TTTAttributedLabelDelegate>
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSLog(@"%@",url);
    
    openWebViewController *openweb=[[openWebViewController alloc]init];
    openweb.urlstr=[NSString stringWithFormat:@"%@",url];
    [[talkSessionViewController getTalkSession].navigationController pushViewController:openweb animated:YES];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    NSLog(@"%@",phoneNumber);
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithAddress:(NSDictionary *)addressComponents
{
    NSLog(@"alksnflanflan");
}

@end
