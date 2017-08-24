//
//  loginViewController.h
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "aboutViewController.h"
#import "userChooseViewController.h"
#import "Reachability.h"
#import "LCLLoadingView.h"
#import "AppDelegate.h"
#import "ServerConfigViewController.h"
#import "ASIFormDataRequest.h"

@class conn;
@interface loginViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    UITableView *loginTable;
    UIScrollView *scrollview;
    UITextField *emailTextField;
    UITextField *passwordTextField;
    UIButton *backgroundButton;
    aboutViewController* aboutController;
    userChooseViewController*userChoose;
	ServerConfigViewController *serverConfig;
	conn *_conn;
	
	NSString *_email;
	NSString *_passwd;
    UIImageView *loginImageview;
    bool initConnBool;
    
    ASIHTTPRequest *ssorequest;

}
@property(nonatomic,retain)IBOutlet UIScrollView *scrollview;
@property(nonatomic,retain)IBOutlet UITextField *emailTextField;
@property(nonatomic,retain)IBOutlet UITextField *passwordTextField;
@property(nonatomic,retain)IBOutlet UIButton *backgroundButton;

@property(nonatomic,retain)IBOutlet UIButton *loginButton;

-(IBAction)loginAction:(id)sender;
-(IBAction)helpAction:(id)sender;

@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) NSString *passwd;
//显示手动登录界面
-(void)handleLogin;
@end
