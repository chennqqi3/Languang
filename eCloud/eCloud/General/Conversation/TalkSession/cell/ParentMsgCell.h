//聊天界面各类消息的父cell 包括 时间、头像、气泡图片、消息体父view、回执消息view、状态view

#import <UIKit/UIKit.h>
#import "MessageView.h"
#import "eCloudDAO.h"
#import "eCloudDefine.h"
#import "ReceiptDAO.h"
#import "UserDisplayUtil.h"
#import "talkSessionUtil.h"

@interface ParentMsgCell : UITableViewCell


/**
 初始化各类消息共用的View

 @param cell:消息cell
 */
- (void)addCommonView:(UITableViewCell *)cell;

// 设置气泡的frame
+ (void)setbubbleImageViewFrameByCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

//设置状态view的显示
+ (void)configureStatusView:(UITableViewCell *)cell andRecord:(ConvRecord *)_convRecord;

@end
