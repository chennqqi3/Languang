//
//  NewFileMsgCell.h
//  eCloud
//
//  Created by Pain on 14-11-24.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "ParentMsgCell.h"

// 文件消息体的宽、高
#define FILE_MSG_WIDTH (msg_content_max_width)
#define FILE_MSG_HEIGHT (74.0)
#define FILE_MSG_SENDING_OR_DOWNING_HEIGHT (85.0)

// 发送或下载过程中，高度增加的大小
#define FILE_MSG_SENDING_OR_DOWNING (11.0)

// 文件名称上、左、下、右边距
#define FILE_MSG_IMAGE_SPACE (8.0)
#define FILE_MSG_IMAGE_MAX_WIDTH (58.0)
#define FILE_MSG_IMAGE_MAX_HEIGHT (58.0)

// 文件名称上、左、下、右边距
#define FILE_MSG_FILENAME_SPACE (8.0)
#define FILE_MSG_FILENAME_MAX_WIDTH (msg_content_max_width - (FILE_MSG_IMAGE_SPACE * 3 + FILE_MSG_IMAGE_MAX_WIDTH))
#define FILE_MSG_FILENAME_MAX_HEIGHT (42.0)

#define FILE_MSG_FILENAME_FONTCOLOR @"#000000"
#define FILE_MSG_FILENAME_FONTSIZE (17.0)

// 文件大小
#define FILE_MSG_FILESIZE_SPACE (8.0)
#define FILE_MSG_FILESIZE_SPACE_TOP (52.0)

#define FILE_MSG_FILESIZE_FONTCOLOR @"#A3A3A3"
#define FILE_MSG_FILESIZE_FONTSIZE (12.0)

// 文件状态
#define FILE_MSG_FILESTATUS_SPACE (8.0)
#define FILE_MSG_FILESTATUS_SPACE_TOP (52.0)

#define FILE_MSG_FILESTATUS_FONTCOLOR @"#A3A3A3"
#define FILE_MSG_FILESIZE_FONTSIZE (12.0)

// 下载进度
#define FILE_MSG_PROGRESS_SPACE (8.0)
#define FILE_MSG_PROGRESS_SPACE_TOP (74.0)

@interface NewFileMsgCell : ParentMsgCell

//显示文件消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通文件消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

+ (void)activeCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord;

/** 文件消息回复正常状态 */
+ (void)deactiveCell:(UITableViewCell *)cell andConvRecord:(ConvRecord *)_convRecord;

@end
