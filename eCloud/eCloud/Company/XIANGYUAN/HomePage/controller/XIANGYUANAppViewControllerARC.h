//
//  XIANGYUANAppViewControllerARC.h
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XIANGYUANAppViewControllerARC : UIViewController

/** 用户点击轻应用通知启动应用，这里记录通知所带的userInfo */
@property (nonatomic,retain) NSDictionary *appInfo;

//+(XIANGYUANAppViewControllerARC *)getXIANGYUANAppViewControllerARC;


- (void)openAppUrl:(NSString *)appUrl;

/**
 *  自动打开待办界面 如果用户还没有登录 那么需要用户登录成功后 再打开
 */
- (void)autoOpenAgentList;


@end
