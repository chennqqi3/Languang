//
//  LocationMsgCell.m
//  eCloud
//
//  Created by Alex L on 16/5/20.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "LocationMsgCell.h"
#import "LocationMsgUtil.h"
#import "ConvRecord.h"
#import "LocationModel.h"
#import "CustomLabel.h"

#import "AppDelegate.h"
#import "StringUtil.h"

#import "IrregularView.h"

@implementation LocationMsgCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [super addCommonView:self];
        
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        UIView *parentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MSG_MAX_LOCATION_WIDTH, MSG_MAX_LOCATION_HEIGHT)];
        parentView.tag = location_parent_view_tag;
        
        [contentView addSubview:parentView];
        
        CustomLabel *addressLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 0, MSG_MAX_LOCATION_WIDTH, MSG_MAX_LOCATION_HEIGHT - LOCATION_PIC_HEIGHT)];
        
        addressLabel.font = [UIFont systemFontOfSize:MSG_ADDRESS_FONTSIZE];
        //        addressLabel.backgroundColor = [UIColor colorWithRed:0x0 green:0x0 blue:0x0 alpha:0.5];
        addressLabel.backgroundColor = [UIColor whiteColor];
        addressLabel.textColor = [StringUtil colorWithHexString:MSG_ADDRESS_FONTCOLOR];
        addressLabel.textInsets = UIEdgeInsetsMake(MSG_ADDRESS_SPACE, MSG_ADDRESS_SPACE, MSG_ADDRESS_SPACE, MSG_ADDRESS_SPACE);
        

        addressLabel.tag = location_address_tag;
        [parentView addSubview:addressLabel];
        

        
        UIImageView *showPicView=[[UIImageView alloc]initWithFrame:CGRectMake(0, MSG_MAX_LOCATION_HEIGHT - LOCATION_PIC_HEIGHT, MSG_MAX_LOCATION_WIDTH, LOCATION_PIC_HEIGHT)];
        showPicView.backgroundColor = [UIColor whiteColor];
        
        showPicView.tag = location_pic_view_tag;
        showPicView.contentMode=UIViewContentModeScaleAspectFit;
        [parentView addSubview:showPicView];
        
       //        进度提示
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        indicatorView.tag = location_load_indicator_view_tag;;
        indicatorView.center = CGPointMake(MSG_MAX_LOCATION_WIDTH * 0.5 , LOCATION_PIC_HEIGHT * 0.5);
        [showPicView addSubview:indicatorView];
        
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark --显示图片消息--
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    // 通过位置实体生成图片
    if (_convRecord.imageDisplay == nil) {
        UIImage *image = [LocationMsgUtil getLocationImage:_convRecord.locationModel];
        if (image) {
            _convRecord.imageDisplay = image;
        }
    }
    
    //	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
//    UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:location_pic_view_tag];
//    showPicView.backgroundColor=[UIColor whiteColor];
//    //添加四个边阴影
//    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
//    showPicView.layer.shadowOffset = CGSizeMake(0, 0);
//    showPicView.layer.shadowOpacity = 1;
//    
//
//    showPicView.image=_convRecord.imageDisplay;
//    showPicView.frame = CGRectMake(0, MSG_MAX_LOCATION_HEIGHT - LOCATION_PIC_HEIGHT, LOCATION_PIC_WIDTH, LOCATION_PIC_HEIGHT);
//    showPicView.image=_convRecord.imageDisplay;
    
//    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
//    bubble_sendPicView.image=nil;
//    bubble_sendPicView.highlightedImage=nil;
//    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
//    bubble_rcvPicView.image=nil;
//    bubble_rcvPicView.highlightedImage=nil;

//   	BOOL fromSelf=YES;
//    if (_convRecord.msg_flag == rcv_msg) {//别人发送的信息
//        fromSelf=NO;
//    }
//    if (fromSelf) {
//        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
//                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
//                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
//                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
//                                   nil];
//    }else{
//        showPicView.trackPoints = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(0, 0)],
//                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, 0)],
//                                   [NSValue valueWithCGPoint:CGPointMake(_convRecord.msgSize.width, _convRecord.msgSize.height)],
//                                   [NSValue valueWithCGPoint:CGPointMake(0, _convRecord.msgSize.height)],
//                                   nil];
//    }
//    
//    
//    showPicView.contentMode = UIViewContentModeScaleToFill;
    //    地址
    UIView *parentView = [cell.contentView viewWithTag:location_parent_view_tag];
    parentView.hidden = NO;
    
    CustomLabel *addressLabel = (CustomLabel *)[cell.contentView viewWithTag:location_address_tag];
//    addressLabel.frame = CGRectMake(0, -(MSG_MAX_LOCATION_HEIGHT - LOCATION_PIC_HEIGHT), LOCATION_PIC_WIDTH, MSG_ADDRESS_HEIGHT);
    addressLabel.text = _convRecord.locationModel.address;
    // 设置文字的内边距
    addressLabel.hidden = NO;
    
    UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:location_pic_view_tag];
    showPicView.image=_convRecord.imageDisplay;
    showPicView.userInteractionEnabled = YES;
    showPicView.hidden = NO;

//    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[showPicView viewWithTag:location_load_indicator_view_tag];
////    CGRect _frame =  indicatorView.frame;
////    _frame.origin = CGPointMake((_convRecord.msgSize.width - _frame.size.width) * 0.5, ((_convRecord.msgSize.height - location_address_height) - _frame.size.height) * 0.5);
////    indicatorView.frame = _frame;
//    
//    indicatorView.center = CGPointMake(LOCATION_PIC_WIDTH * 0.5, LOCATION_PIC_HEIGHT * 0.5);
//    
//    [showPicView setMask];
    
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
        contentX = headImageView.frame.origin.x - logo_horizontal_space - contentWidth;
        contentY = headImageView.frame.origin.y + send_msg_body_to_header_top;
    }else{
        contentX = headImageView.frame.origin.x + headImageView.frame.size.width + logo_horizontal_space;
        contentY = headImageView.frame.origin.y + rcv_msg_body_to_header_top;
    }
    
    contentView.frame = CGRectMake(contentX, contentY, contentWidth, contentHeight);
    
    [ParentMsgCell configureStatusView:cell andRecord:_convRecord];
//    [[super class] setbubbleImageViewFrameByCell:cell andRecord:_convRecord];
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord
{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    _convRecord.msgSize = CGSizeMake(MSG_MAX_LOCATION_WIDTH, MSG_MAX_LOCATION_HEIGHT);
    
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

@end
