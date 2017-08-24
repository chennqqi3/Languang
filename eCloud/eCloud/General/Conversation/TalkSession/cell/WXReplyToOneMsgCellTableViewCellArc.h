//
//  WXReplyToOneMsgCellTableViewCell.h
//  eCloud
//  定向回复消息cell
//  Created by shisuping on 17/5/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentMsgCell.h"
@interface WXReplyToOneMsgCellTableViewCellArc : ParentMsgCell

/** 获取定向回复消息的显示高度 */
+ (void)getReplyToOneMsgSize:(ConvRecord *)_convRecord;

/** 显示定向回复消息 */
+ (void)configureReplyToOneMsgCell:(WXReplyToOneMsgCellTableViewCellArc *)cell andConvRecord:(ConvRecord *)_convRecord;


//定向回复消息的总高度
+ (float)getMsgHeight:(ConvRecord *)_convRecord;

//显示定向回复消息
+ (void)configureCell:(UITableViewCell *)cell andRecord:(ConvRecord*)_convRecord;

@end
