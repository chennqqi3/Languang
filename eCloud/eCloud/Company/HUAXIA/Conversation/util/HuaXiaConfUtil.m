//
//  HuaXiaConfUtil.m
//  OpenCtx2017
//  华夏会议接口
//  Created by shisuping on 17/6/7.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "HuaXiaConfUtil.h"
//#import "LogUtil.h"
//#import "UserTipsUtil.h"

static HuaXiaConfUtil *_util;

@implementation HuaXiaConfUtil

+ (HuaXiaConfUtil *)getUtil{
    if (!_util) {
        _util = [[HuaXiaConfUtil alloc]init];
    }
    return _util;
}
/**
 创建华夏网络会议接口
 
 @param createUser 创建人账号
 @param participants 参与人账号列表
 @param openVC 发起网络会议的界面
 */
- (void)createConfWithCreateUser:(NSString *)createUser andParticipants:(NSArray *)participants andOpenVC:(UIViewController *)openVC{
//    [LogUtil debug:[NSString stringWithFormat:@"%s %@ %@",__FUNCTION__,createUser,participants]];
//    [UserTipsUtil showLoadingView:@"请稍候！"];
//    
//    dispatch_queue_t queue = dispatch_queue_create("search Conv", NULL);
//    
//    dispatch_async(queue, ^{
//        [NSThread sleepForTimeInterval:5.0];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UserTipsUtil hideLoadingView];
//        });
//    });
//    dispatch_release(queue);
}

@end
