//
//  MsgSyncUtil.h
//  OpenCtx2017
//  和消息同步有关的util
//  Created by shisuping on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgSyncDefine.h"

@interface MsgSyncUtil : NSObject

/** 获取单例 */
+ (MsgSyncUtil *)getUtil;


/*
 功能描述：
 设置消息同步开关的接口
 
 参数说明：
 msgSyncFlag:同步消息开关
 rcv_msg_when_pc_leave_or_offline
 rcv_msg_all_the_time
 
 示例代码：
 [[OpenCtxManager getManager] setMsgSyncFlag:rcv_msg_all_the_time completionHandler:^(int resultCode,NSString *resultMsg)
 {
 NSLog(@"%d,%@",resultCode,resultMsg);
 }];
 
 */
- (void)setMsgSyncFlag:(int)msgSyncFlag completionHandler:(SetMsgSyncFlagResultBlock)completionHandler;

/** 获取当前登录用户的消息同步标志 */
- (int)getMsgSyncFlag;

@end
