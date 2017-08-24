//
//  BlackListConn.h
//  eCloud
// 获取黑名单请求
// 保存黑名单
//处理黑名单变更通知
//  Created by shisuping on 14-4-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "client.h"
@interface BlackListConn : NSObject

+ (BlackListConn *)getConn;

#pragma mark 获取黑名单
- (void)getBlacklist;

#pragma mark 保存黑名单
- (void)saveBlacklist:(GETSPECIALLISTACK*)info;

#pragma mark 保存黑名单
- (void)saveBlacklistNotice:(MODISPECIALLISTNOTICE*)info;

- (void)addTestData;

- (void)saveToDB:(NSMutableArray *)specialList andWhiteList:(NSMutableArray *)whiteList;
@end
