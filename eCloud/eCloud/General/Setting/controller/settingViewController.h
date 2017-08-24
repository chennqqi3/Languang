//
//  settingViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GYFrame.h"
@class UserInfo;
@class conn;
@class broadcastListViewController;
@class DirectoryWatcher;

@interface settingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UserInfo* userinfo;
    NSString *userid;
    broadcastListViewController *broadcastList;
    UIAlertView *tipAlert;
    conn *_conn;
    
    /** 是否退出登录 */
	bool isExit;
}
/** 用户id */
@property(nonatomic,retain)NSString *userid;
@property(assign)id delegete;

/** 从新计算settingTable的高度 */
- (void)reCalculateFrame;

@end
