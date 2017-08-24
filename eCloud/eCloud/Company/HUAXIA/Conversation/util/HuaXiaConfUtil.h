//
//  HuaXiaConfUtil.h
//  OpenCtx2017
//
//  Created by shisuping on 17/6/7.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HuaXiaConfUtil : NSObject

/** 获取单例 */
+ (HuaXiaConfUtil *)getUtil;

/**
 创建华夏网络会议接口

 @param createUser 创建人账号
 @param participants 参与人账号列表
 @param openVC 发起网络会议的界面
 */
- (void)createConfWithCreateUser:(NSString *)createUser andParticipants:(NSArray *)participants andOpenVC:(UIViewController *)openVC;

@end
