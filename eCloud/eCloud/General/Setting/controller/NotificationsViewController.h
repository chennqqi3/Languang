//
//  NotificationsViewController.h
//  eCloud
//
//  Created by SH on 14-9-3.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *notification;
}

//应用是否关闭了消息提醒
+ (BOOL)needAlertWhenRcvMsg;

//检查本地通知是否需要声音提醒
+ (BOOL)isNotificationNeedSound;
@end
