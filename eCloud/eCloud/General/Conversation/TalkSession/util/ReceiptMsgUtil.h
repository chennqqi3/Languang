//
//  ReceiptMsgUtil.h
//  eCloud
//  重要消息提醒 回执消息 @消息
//  Created by shisuping on 15/11/23.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConvRecord;

@interface ReceiptMsgUtil : NSObject
@property (nonatomic,retain) NSMutableArray *pinMsgArray;
@property (nonatomic,assign) int unreadMsgNumber;

+ (ReceiptMsgUtil *)getUtil;

/** 在talksession中增加一个view 用来显示重要的消息 */
- (void)addPinMsgButton;

/** 读取新消息的数目 和 未读的@消息和回执消息 */
- (void)getNewPinMsgs;

/** 显示最近的pin消息 */
- (void)displayRecentPinMsg;

/** 从数组里删除一个 已经显示的 pin消息 */
- (void)deletePinMsg:(ConvRecord *)convRecord;

/** 隐藏pinMsgButton */
- (void)hidePinMsgButton;

@end


#pragma mark =======显示 回执消息 @消息 的 按钮=========
@interface CustomReceiptMsgButton : UIButton

@property (nonatomic,assign) BOOL isDingMsg;

@end
