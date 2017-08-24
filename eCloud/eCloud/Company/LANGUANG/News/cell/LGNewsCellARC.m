//
//  LGNewsCellARC.m
//  eCloud
//
//  Created by Ji on 17/6/17.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGNewsCellARC.h"
#import "NormalTextMsgCell.h"

@implementation LGNewsCellARC

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
//    LGNewsCellARC *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (cell) {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 12, news_view_width-24, 20)];
//        self.titleLabel.text = @"的撒多爱的阿萨德阿萨德阿萨德撒打阿萨德撒多打算打算";
        self.titleLabel.tag = news_title_tag;
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:self.titleLabel];
        
        self.urlLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 44, news_view_width-24, 20)];
//        self.urlLabel.text = @"的撒多爱的阿萨德阿萨德阿萨德撒打阿萨德撒多打算打算";
        self.urlLabel.tag = news_url_tag;
        self.urlLabel.font = [UIFont systemFontOfSize:16];
        [contentView addSubview:self.urlLabel];
        
    }
    return self;
    //}
    //return cell;
}

+ (void)configCellWithDataModel:(LGNewsMdelARC*)model andCell:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord
{
    UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:news_title_tag];
    UILabel *urlLabel = (UILabel*)[cell.contentView viewWithTag:news_url_tag];
    titleLabel.text = model.title;
    urlLabel.text = model.url;
    titleLabel.hidden = NO;
    urlLabel.hidden = NO;
    if (_convRecord.msg_flag == send_msg) {
        
        titleLabel.textColor = [UIColor whiteColor];
        urlLabel.textColor = [UIColor whiteColor];
    }else{
        
        titleLabel.textColor = [UIColor blackColor];
        urlLabel.textColor = [UIColor blackColor];
        
    }
//    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
//    bubble_sendPicView.hidden = NO;
//
//    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
//    bubble_rcvPicView.hidden = NO;
    
    [NormalTextMsgCell configureCommonView:cell andRecord:_convRecord];
    
//    [self configureCommonView:cell andRecord:_convRecord];
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
        contentX = headImageView.frame.origin.x - logo_horizontal_space - contentWidth;
        contentY = headImageView.frame.origin.y + send_msg_body_to_header_top;
    }else{
        contentX = headImageView.frame.origin.x + headImageView.frame.size.width + logo_horizontal_space;
        contentY = headImageView.frame.origin.y + rcv_msg_body_to_header_top;
    }
    
    contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
    [[super class] setbubbleImageViewFrameByCell:cell andRecord:_convRecord];
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord
{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    _convRecord.msgSize = CGSizeMake(news_view_width, news_view_height);
    
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

-(void)showView:(UIView *)parentView convRecord:(ConvRecord*)_convRecord
{
    parentView.hidden = NO;
    for(UIView *view in parentView.subviews)
    {
        view.hidden = NO;
        [self showView:view convRecord:_convRecord];
        
    }
    self.titleLabel.hidden = NO;
    self.urlLabel.hidden = NO;
    if (_convRecord.msg_flag == rcv_msg) {
        
        CGRect _frame;
        _frame = self.titleLabel.frame;
        _frame.origin.x = 12;
        self.titleLabel.frame = _frame;
        _frame = self.urlLabel.frame;
        _frame.origin.x = 12;
        self.urlLabel.frame = _frame;
    }
}
@end
