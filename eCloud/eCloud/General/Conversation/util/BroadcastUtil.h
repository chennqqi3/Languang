//
//  BroadcastUtil.h
//  eCloud
//  通过广播协议收到的消息 相关 的 方法
//普通广播消息 来自第三方应用的消息
//普通的广播会话 来自第三方应用消息对应的会话
//  Created by shisuping on 16/12/14.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BroadcastUtil : NSObject

/*
 功能描述
 根据广播消息类型，返回广播会话类型
 
 参数
 广播消息类型
 
 返回 对应的会话类型

 */
+ (int)getBroadcastConvTypeWithBroadcastType:(int)broadcastType;


/*
 功能描述
 根据广播会话类型返回广播消息类型
 
 参数是广播会话类型
 
 返回 对应的广播消息类型
 */
+ (int)getBroadcastTypeWithBroadcastConvType:(int)broadcastConvType;

@end
