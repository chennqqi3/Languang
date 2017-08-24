//
//  VideoMsgCell.h
//  eCloud
//
//  Created by yanlei on 15/9/30.
//  Copyright © 2015年  lyong. All rights reserved.
//  视频处理cell

#import "ParentMsgCell.h"

// 横向video展示宽高
#define video_display_horizontal_width (160)
#define video_display_horizontal_height (90)
// 竖向video展示宽高
#define video_display_vertical_width (90)
#define video_display_vertical_height (160)

// video展示中秒数的宽和高
#define video_sec_width (60)
#define video_sec_height (20)

#define VIDEO_MSG_PIC_ANGLE_WIDTH (3)

// 播放按钮宽与高
#define VIDEO_MSG_PLAY_WIDTH (40.0)
#define VIDEO_MSG_PLAY_HEIGHT (40.0)

// 秒数距离右侧的边距  字体大小
#define VIDEO_MSG_SEC_TO_RIGHT (6.0)
#define VIDEO_MSG_SEC_TO_BUTTOM (4.0)

#define VIDEO_MSG_SEC_FONTSIZE (12.0)

@interface VideoMsgCell : ParentMsgCell

//显示视频文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通视频消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

@end
