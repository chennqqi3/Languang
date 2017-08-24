//
//  NotificationUtil.m
//  eCloud
//
//  Created by shisuping on 14-12-4.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "NotificationUtil.h"
#import "eCloudNotification.h"

#import "LogUtil.h"

static NotificationUtil *notificationUtil;
@implementation NotificationUtil

+ (NotificationUtil *)getUtil
{
    if (notificationUtil == nil) {
        notificationUtil = [[NotificationUtil alloc]init];
    }
    return notificationUtil;
}

- (void)sendNotification:(NSDictionary *)dic
{
    NSString *notiName = [dic valueForKey:notification_name];
    eCloudNotification *_object = [dic valueForKey:notification_object];
    NSDictionary *_userinfo = [dic valueForKey:notification_userinfo];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:notiName object:_object userInfo:_userinfo];
}

- (void)sendNotificationOnMainThread:(NSDictionary *)dic
{
    [self performSelectorOnMainThread:@selector(sendNotification:) withObject:dic waitUntilDone:YES];
}

//增加一个方法 根据 通知名字 通知object 通知userinfo 来发送通知
- (void)sendNotificationWithName:(NSString *)_name andObject:(eCloudNotification *)_object andUserInfo:(NSDictionary *)_userInfo
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    if (_name) {
        [mDic setValue:_name forKey:notification_name];
//        [LogUtil debug:[NSString stringWithFormat:@"notification name is %@",_name]];
    }
    if (_object) {
        [mDic setValue:_object forKey:notification_object];
//        [LogUtil debug:[NSString stringWithFormat:@"notification object:%@",[_object description]]];
    }
    if (_userInfo) {
        [mDic setValue:_userInfo forKey:notification_userinfo];
//        [LogUtil debug:[NSString stringWithFormat:@"notification user info is %@",[_userInfo description]]];
    }
    if (mDic.count > 0) {
        [self sendNotificationOnMainThread:mDic];
    }
}

@end
