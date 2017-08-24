//
//  VirtualGroupDAO.h
//  eCloud
//
//  Created by yanlei on 15/12/3.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VirtualGroupMemberModel.h"
#import "VirtualGroupInfoModel.h"
#import "eCloud.h"

@interface VirtualGroupDAO :eCloud

// 创建单例
+ (VirtualGroupDAO *)getDatabase;

// 创建虚拟组相关表
- (void)createTable;

// 处理同步下来的虚拟组信息
- (void)saveSynVirtualGroupInfo:(NSArray *)info;

// 查询虚拟组
- (BOOL)isVirtualGroupUser:(int)userId;

// 插入提示语或修改提示语的时间为最近的时间
- (void)initGreetingsWithUserId:(int)userId andTitle:(NSString *)title;

// 获取虚拟组时间戳
- (NSString *)getUpdate_time;
@end
