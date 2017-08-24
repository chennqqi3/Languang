//
//  WXReplyOneMsgUtil.h
//  eCloud
//  用来处理和定向回复消息有关的程序
//  Created by shisuping on 17/5/8.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConvRecord;

@interface WXReplyOneMsgUtil : NSObject

+ (WXReplyOneMsgUtil *)getUtil;

/** 回复的消息 */
@property (nonatomic,retain) ConvRecord *sendConvRecord;

/** 格式化定向回复消息 */
- (NSString *)formatReplyMsg:(NSString *)inputText;

/** 根据ConvRecord获取 */
- (NSString *)getMsgBodyWithConvRecord:(ConvRecord *)convRecord;

- (void)addJumpToViewGesture:(UITableViewCell *)cell;

- (void)addSearchJumpToViewGesture:(UITableViewCell *)cell;
@end
