//
//  RobotConn.h
//  eCloud
//
//  Created by shisuping on 15-3-9.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"

@interface RobotConn : NSObject

@property (nonatomic,retain) NSMutableArray *robotMenuArray;

+ (RobotConn *)getConn;

//发起同步机器人资料请求
- (void)syncRobotInfo;

//处理机器人同步应答
- (void)processSyncRobotAck:(ROBOTSYNCRSP *)info;

//同步小万菜单
- (void)syncRobotMenu;

//同步小万每日主题
- (void)syncRobotTopic;

@end
