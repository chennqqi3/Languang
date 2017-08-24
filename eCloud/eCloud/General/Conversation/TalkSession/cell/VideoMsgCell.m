//
//  VideoMsgCell.m
//  eCloud
//
//  Created by yanlei on 15/9/30.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "VideoMsgCell.h"
#import "IrregularView.h"
#import <AVFoundation/AVFoundation.h>

@implementation VideoMsgCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [super addCommonView:self];
        UIView *contentView = (UIView *)[self.contentView viewWithTag:body_tag];
        
        UIImageView *showPicView=[[UIImageView alloc]initWithFrame:CGRectZero];
        showPicView.tag = video_tag;
        showPicView.userInteractionEnabled = YES;
        showPicView.contentMode=UIViewContentModeScaleAspectFit;
        
        // 秒数、进度等一些控件放在此次展示不出来，暂放入(void)configureVideoMsg:(UITableViewCell *)cell convRecord:(ConvRecord *)_convRecord中
        
        [contentView addSubview:showPicView];
        
        [showPicView release];
        
        
        //        增加播放按钮
        UIImageView *video_play = [[[UIImageView alloc]init]autorelease];
        video_play.contentMode = UIViewContentModeScaleAspectFit;
        video_play.tag = video_play_tag;
        video_play.image = [StringUtil getImageByResName:@"btn_play"];
        [showPicView addSubview:video_play];
        
        UILabel *secLab = [[[UILabel alloc]init]autorelease];
        secLab.tag = video_sec_tag;
        secLab.textColor = [UIColor whiteColor];
        secLab.textAlignment = NSTextAlignmentCenter;
        secLab.font = [UIFont systemFontOfSize:14.0];
        [showPicView addSubview:secLab];
        
        UIProgressView *progressCell = [[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar]autorelease];
        progressCell.progress = 0.0;
        [showPicView addSubview:progressCell];
        progressCell.tag = video_progress_tag;
        progressCell.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark --显示视频消息--
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord
{
    //	展示给用户看的收到的图片，没下载前显示为默认图片bubble_send_tag
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:_convRecord.file_name];
    
    UIImageView *showPicView=(UIImageView*)[cell.contentView viewWithTag:video_tag];
    showPicView.backgroundColor=[UIColor whiteColor];
    //添加四个边阴影
//    showPicView.layer.shadowColor = [UIColor blackColor].CGColor;
//    showPicView.layer.shadowOffset = CGSizeMake(0, 0);
//    showPicView.layer.shadowOpacity = 1;
    
    UIImage *_image = nil;
    if (_convRecord.imageDisplay) {
        _image = _convRecord.imageDisplay;
    }else{
        _image = [talkSessionUtil getVideoPreViewImage:[NSURL fileURLWithPath:videopath]];
        if (!_image) {
            //        如果第一帧没有取到，那么显示默认的图片
            _image = [StringUtil getImageByResName:@"default_video.png"];//默认图片
        }else{
            _convRecord.imageDisplay = _image;
        }
    }
    
    showPicView.image=_image;
    
    showPicView.frame = CGRectMake(0, 0, _convRecord.msgSize.width, _convRecord.msgSize.height);
    showPicView.contentMode = UIViewContentModeScaleAspectFill;
    showPicView.hidden = NO;
    
//    UIImageView *bubble_sendPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_send_tag];
//    bubble_sendPicView.image=nil;
//    bubble_sendPicView.highlightedImage=nil;
//    UIImageView *bubble_rcvPicView=(UIImageView*)[cell.contentView viewWithTag:bubble_rcv_tag];
//    bubble_rcvPicView.image=nil;
//    bubble_rcvPicView.highlightedImage=nil;
    
    BOOL fromSelf=YES;
    if (_convRecord.msg_flag==1) {//别人发送的信息
        fromSelf=NO;
    }
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
//    [showPicView setMask];
    //进度
    UIView *view = (UIView *)[cell.contentView viewWithTag:body_tag];
    
    UIProgressView *progressCell=(UIProgressView*)[view viewWithTag:video_progress_tag];
    
    float progressWidth = _convRecord.msgSize.width - VIDEO_MSG_PIC_ANGLE_WIDTH;
    
    //    update by shisp 如果是 钉消息类型的视频消息 那么已读和未读显示 特别靠下，因此把进度条 向上调整
    progressCell.frame=CGRectMake(VIDEO_MSG_PIC_ANGLE_WIDTH * 0.5, showPicView.frame.size.height - progressCell.frame.size.height, progressWidth, progressCell.frame.size.height);
    
    // 在视频第一帧图片上面加一个播放图标，这个UIImageView放在VideoMsgCell中，不会显示
    UIImageView *video_play = (UIImageView*)[showPicView viewWithTag:video_play_tag];
    video_play.hidden = NO;
    video_play.frame = CGRectMake(0, 0, VIDEO_MSG_PLAY_WIDTH, VIDEO_MSG_PLAY_WIDTH);
    video_play.center = showPicView.center;
    
    // 视频时长的调整
    UILabel *secLab = (UILabel *)[showPicView viewWithTag:video_sec_tag];
    
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videopath] options:nil]autorelease];
    NSInteger *sec = asset.duration.value / asset.duration.timescale;
    secLab.text = [talkSessionUtil lessSecondToDay:sec];
    // 计算视频时长的size
    CGSize secSize = [secLab.text sizeWithFont:[UIFont systemFontOfSize:VIDEO_MSG_SEC_FONTSIZE]];
    secLab.font = [UIFont systemFontOfSize:VIDEO_MSG_SEC_FONTSIZE];
    
    CGFloat secX = _convRecord.msgSize.width - VIDEO_MSG_SEC_TO_RIGHT - secSize.width;
    CGFloat secY = _convRecord.msgSize.height - VIDEO_MSG_SEC_TO_BUTTOM - secSize.height;
    
    secLab.frame = CGRectMake(secX, secY, secSize.width, secSize.height);
    secLab.hidden = NO;
    _convRecord.videoSeconds = (int)sec;
    
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
//    [[super class] setbubbleImageViewFrameByCell:cell andRecord:_convRecord];
    [ParentMsgCell configureStatusView:cell andRecord:_convRecord];
    
}

//返回高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord
{
    //	时间所占高度 已经增加了时间与消息直接的分隔
    float dateBgHeight = [talkSessionUtil getTimeHeight:_convRecord];
    
    // 判断视屏是横屏还是竖屏
    BOOL isHorizontal = [self isHorizontalFromVideo:_convRecord];
    
    if (isHorizontal) {
        _convRecord.msgSize = CGSizeMake(video_display_horizontal_width,video_display_horizontal_height);
    }else{
        _convRecord.msgSize = CGSizeMake(video_display_vertical_width,video_display_vertical_height);
    }
    
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

+ (BOOL)isHorizontalFromVideo:(ConvRecord *)_convRecord
{
    NSString *videoname = _convRecord.file_name;
    NSString *videopath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:videoname];
    
    // 判断视频是横向拍的还是竖向拍的，通过第一帧图片的横竖屏进行判断
    UIImage *_image = nil;
    if (_convRecord.imageDisplay) {
        _image = _convRecord.imageDisplay;
    }else{
        _image = [talkSessionUtil getVideoPreViewImage:[NSURL fileURLWithPath:videopath]];
        if (!_image) {
            //        如果第一帧没有取到，那么显示默认的图片
            _image = [StringUtil getImageByResName:@"default_video.png"];//默认图片
        }else{
            _convRecord.imageDisplay = _image;
        }
    }
    //	宽和高的比例
    float rate = _image.size.width/_image.size.height;
    
    float frameWidth = _image.size.width;
    float frameHeight = _image.size.height;
    
    if(rate < 1)
    {
        // 竖屏
        return NO;
    }
    return YES;
}
@end
