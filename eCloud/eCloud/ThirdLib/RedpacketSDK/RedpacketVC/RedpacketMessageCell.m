//
//  RedpacketMessageCell.m
//  LeanChat
//
//  Created by YANG HONGBO on 2016-5-7.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessageCell.h"
#import "RedpacketUser.h"
#import "RedpacketView.h"
#import "RedPacketLuckView.h"
#import "NormalTextMsgCell.h"
#import "RedpacketConfig.h"


#define HeaderImageWith     40.0f
#define RedpacketMargin     12.0f
#define UserNameSize        14.0f
#define LabelHeight         20.0f

@interface RedpacketMessageCell ()

@property (nonatomic, strong) RedpacketView     *redpacketView;
@property (nonatomic, strong) RedPacketLuckView *redpacketLuckView;
@property (nonatomic, strong) RedpacketMessageModel *redpacketMessageModel;

@end

@implementation RedpacketMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [super addCommonView:self];

        _redpacketView = [RedpacketView new];
        _redpacketView.tag = red_pecket_view_tag;
        _redpacketView.userInteractionEnabled = YES;
        
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        [contentView addSubview:_redpacketView];
        NSLog(@"%s 添加到消息体里",__FUNCTION__);

    }
    
    return self;
}

- (void)configWithRedpacketMessageModel:(RedpacketMessageModel *)model
                        andRedpacketDic:(NSDictionary *)redpacketDic
{
    NSLog(@"%s 红包类型 is %d",__FUNCTION__,model.redpacketType);

    if (model.redpacketType == RedpacketTypeAmount) {
        
        [_redpacketView removeFromSuperview];
        if (!_redpacketLuckView) {
            _redpacketLuckView = [RedPacketLuckView new];
        }
        [self.contentView addSubview:_redpacketLuckView];
        
        [_redpacketLuckView configWithRedpacketMessageModel:model];
        
    }else {
        
        [_redpacketLuckView removeFromSuperview];
        if (!_redpacketView) {
            _redpacketView = [RedpacketView new];
            UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
            
            _redpacketView.tag = red_pecket_view_tag;
            [contentView addSubview:_redpacketView];
            NSLog(@"%s 添加到消息体里",__FUNCTION__);

        }
        
        //[self.contentView addSubview:_redpacketView];
        [_redpacketView configWithRedpacketMessageModel:model
                                        andRedpacketDic:redpacketDic];
        
    }
    
//    redPacketUserInfo *currentUser = [RedpacketUser currentUser].userInfo;
//    
//    if (model.isRedacketSender) {
//        
//        [_headerImageView setImage:[UIImage imageNamed:currentUser.userAvatar]];
//        _userNickNameLabel.text = [RedpacketUser currentUser].userInfo.userNickName;
//        
//    }else {
//     
//        [_headerImageView setImage:[UIImage imageNamed:[RedpacketUser currentUser].talkingUserInfo.userAvatar]];
//        _userNickNameLabel.text = [RedpacketUser currentUser].talkingUserInfo.userNickName;
//        
//    }
//    
    [self swapSide:model.isRedacketSender withRedpacketModel:model];
    
}

- (void)swapSide:(BOOL)isSender withRedpacketModel:(RedpacketMessageModel *)model
{
    UIView *adjustView = _redpacketView;
    
    if (model.redpacketType == RedpacketTypeAmount) {
        adjustView = _redpacketLuckView;
    }
    
    if (isSender) {
        
        CGRect windowFrame = [UIScreen mainScreen].bounds;
        CGFloat windowWith = CGRectGetWidth(windowFrame);
        
        CGRect frame = _headerImageView.frame;
        frame.origin.x = windowWith - RedpacketMargin - HeaderImageWith;
        frame.origin.y = RedpacketMargin;
        _headerImageView.frame = frame;
        
        [_userNickNameLabel sizeToFit];
        frame = _userNickNameLabel.frame;
        frame.origin.x = windowWith - RedpacketMargin * 2 - CGRectGetWidth(frame) - HeaderImageWith;
        frame.origin.y = RedpacketMargin;
        frame.size.height = LabelHeight;
        _userNickNameLabel.frame = frame;
        
        frame = adjustView.frame;
        frame.origin.x = 20;//windowWith - RedpacketMargin * 2 - CGRectGetWidth(frame) - HeaderImageWith;
        frame.origin.y = 0;//RedpacketMargin * 3;
//        frame.size.width = SCREEN_WIDTH - 150;
//        frame.size.height = 124;
        adjustView.frame = frame;

    }else {
        
        CGRect frame = _headerImageView.frame;
        frame.origin.x = RedpacketMargin;
        frame.origin.y = RedpacketMargin;
        _headerImageView.frame = frame;
        
        [_userNickNameLabel sizeToFit];
        frame = _userNickNameLabel.frame;
        frame.origin.x = RedpacketMargin * 2 + HeaderImageWith;
        frame.origin.y = RedpacketMargin;
        frame.size.height = LabelHeight;
        _userNickNameLabel.frame = frame;
        
        frame = adjustView.frame;
        frame.origin.x = 5;//RedpacketMargin * 2 + HeaderImageWith;
        frame.origin.y = 0;// RedpacketMargin * 3;
        adjustView.frame = frame;
    }
}

+ (CGFloat)heightForRedpacketMessageCell:(RedpacketMessageModel *)model
{
    if (model.redpacketType == RedpacketTypeAmount) {
        return [RedPacketLuckView heightForRedpacketMessageCell] + 50;
    }
    
    return [RedpacketView redpacketViewHeight];
}

//显示红包消息
+ (void)showRedpacketMsgView:(RedpacketMessageCell *)cell andConvRecord:(ConvRecord *)_convRecord{
    RedpacketView *_redpacketView = [cell.contentView viewWithTag:red_pecket_view_tag];
    CGRect _frame = _redpacketView.frame;
    _frame.origin.x = 0;
    _redpacketView.frame = _frame;
    
    [[RedpacketConfig sharedConfig] showView:_redpacketView];
    
    _convRecord.msgSize = _redpacketView.frame.size;
    
    UIView *contentView = (UIView *)[cell.contentView viewWithTag:body_tag];
    contentView.hidden = NO;
    
    float contentWidth = _convRecord.msgSize.width;
    float contentHeight = _convRecord.msgSize.height;
    
    UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:head_tag];
    
    //    收到的消息
    float contentX = 0;
    float contentY = 0;
    
    contentView.backgroundColor = [UIColor clearColor];
    //    发送出去的消息
    if (_convRecord.msg_flag == send_msg) {
        contentX = headImageView.frame.origin.x - logo_horizontal_space - contentWidth;
        contentY = headImageView.frame.origin.y + send_msg_body_to_header_top;
    }else{
        contentX = headImageView.frame.origin.x + headImageView.frame.size.width + logo_horizontal_space;
        contentY = headImageView.frame.origin.y + rcv_msg_body_to_header_top;
    }
    
    contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
    [ParentMsgCell configureStatusView:cell andRecord:_convRecord];
}

@end
