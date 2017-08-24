//
//  userChooseViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mainViewController.h"
#import "userInfoViewController.h"
#import "aboutViewController.h"
#import "conn.h"
#import "UIRoundedRectImage.h"
@interface userChooseViewController : UIViewController<UIAlertViewDelegate>
{
    mainViewController *mainview;
    userInfoViewController *userInfo;
    aboutViewController* aboutController;
    UILabel *nameLabel;
    Emp *emp;
    UILabel *backgoundLabel;
    UIImageView *iconImageView;
	
	conn *_conn;
   
	bool isExit;
    
    UIAlertView *tipAlert;
    //	手动连接选择在一个新的线程里进行，这样不会阻塞主线程，所以从连接线程里发出通知，需要通知在主线程上执行
	NSString *notificationName;//通知名称
	eCloudNotification *notificationObject;//通知带的对象
  
}
@property(nonatomic,retain)IBOutlet UIImageView *iconImageView;
@property(nonatomic,retain)IBOutlet  UILabel *backgoundLabel;
@property(nonatomic,retain)Emp *emp;
@property(nonatomic,retain)IBOutlet  UILabel *nameLabel;
-(IBAction)exitAction:(id)sender;
-(IBAction)infoAction:(id)sender;
-(IBAction)part1Action:(id)sender;
-(IBAction)part2Action:(id)sender;
-(IBAction)helpAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *infoButton;
@end
