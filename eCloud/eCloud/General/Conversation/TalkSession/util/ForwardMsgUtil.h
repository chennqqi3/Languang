//
//  ForwardMsgUtil.h
//  eCloud
//  转发多条消息的工具类
//  Created by shisuping on 15/12/2.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForwardMsgUtil : NSObject

+ (ForwardMsgUtil *)getUtil;

/**
 功能描述
 转发多条消息记录 首先是保存消息到本地，然后再发送出去，逐条处理
 
 参数
 records:要转发的消息记录数组
 */
- (void)saveAndSendForwardMsgArray:(NSArray *)records;

@end
