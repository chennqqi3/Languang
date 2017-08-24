//图片类型消息

#import "ParentMsgCell.h"

@class ConvRecord;

//	最大宽度
#define MAX_PIC_WIDTH 247
//	最大高度
#define MAX_PIC_HEIGHT 247

@interface PicMsgCell : ParentMsgCell

/*
 功能描述
 
 显示机器人的图片消息
 如果图片不存在，那么开始下载图片，并且显示正在下载图标
 如果图片不存在，那么显示下载图标
 如果图片存在，那么直接显示图片即可
 
 */
- (void)configureRobotPicCell:(ConvRecord *)_convRecord;

//显示图片文本消息，包括布局
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//调整共用的view的布局
+ (void)configureCommonView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

//普通图片消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

@end
