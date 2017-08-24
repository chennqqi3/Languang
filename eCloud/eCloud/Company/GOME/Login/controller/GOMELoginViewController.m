//
//  GOMELoginViewController.m
//  eCloud
//
//  Created by Alex L on 16/12/24.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "GOMELoginViewController.h"
#import "StringUtil.h"
#import "ApplicationManager.h"
#import "NotificationUtil.h"
#import "ConnResult.h"
#import "UserDefaults.h"
#import "CheckBoxButton.h"

#import "AppDelegate.h"
#import "NewLoginViewController.h"
#import "ServerConfigViewController.h"
#import "StringUtil.h"
#import "MessageView.h"
#import "eCloudDAO.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "LogUtil.h"
#import "protocol.h"

#import "mainViewController.h"
#import "AccessConn.h"

#define IPHONE_5S_OR_LESS (SCREEN_HEIGHT <= 568)
#define IPHONE_6  (SCREEN_HEIGHT == 667)
#define IPHONE_6P (SCREEN_HEIGHT == 736)

#define SCREEN_WIRTH [UIScreen mainScreen].bounds.size.width

#define ICON_WIDTH 60

@interface GOMELoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSString *email;
    NSString *password;
}

@property (retain, nonatomic) IBOutlet UIImageView *loginLogo;
@property (retain, nonatomic) IBOutlet UIImageView *userIcon;
@property (retain, nonatomic) IBOutlet UIImageView *secretIcon;

@property (retain, nonatomic) IBOutlet UITextField *emailTextfield;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextfield;

@property (retain, nonatomic) IBOutlet UIButton *loginButoon;
@property (retain, nonatomic) IBOutlet UIButton *visibleButton;

@property (retain, nonatomic) IBOutlet UILabel *versionLabel;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *emailtextFieldTopContraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *loginBtnTopContraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iconTopContraint;


- (IBAction)clickLogin;

@end

@implementation GOMELoginViewController

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本: %@",app_Version];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    
    [self setupUI];
}

- (void)resignFirstResponder
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

- (void)setupUI
{
    if (IPHONE_6P)
    {
        // do nothing
    }
    else if (IPHONE_6)
    {
        self.logoTopConstraint.constant -= 15;
        self.emailtextFieldTopContraint.constant -= 10;
        self.iconTopContraint.constant -= 10;
        self.loginBtnTopContraint.constant -= 5;
    }
    else
    {
        self.logoTopConstraint.constant -= 25;
        self.emailtextFieldTopContraint.constant -= 25;
        self.loginBtnTopContraint.constant -= 25;
        self.iconTopContraint.constant -= 25;
    }
    
    
    self.loginLogo.image = [StringUtil getImageByResName:@"login_logo"];
    self.userIcon.image = [StringUtil getImageByResName:@"userlogo"];
    self.secretIcon.image = [StringUtil getImageByResName:@"login_secret"];
    [self.visibleButton setImage:[StringUtil getImageByResName:@"invisible"] forState:UIControlStateNormal];
    [self.visibleButton setImage:[StringUtil getImageByResName:@"visible"] forState:UIControlStateSelected];
    [self.visibleButton addTarget:self action:@selector(tapVisiber:) forControlEvents:UIControlEventTouchUpInside];
    
    self.emailTextfield.borderStyle = UITextBorderStyleNone;
    self.emailTextfield.delegate = self;
    self.emailTextfield.returnKeyType = UIReturnKeyNext;
    [self.emailTextfield setFont:[UIFont systemFontOfSize:18]];
    self.emailTextfield.placeholder = @"请输入用户名";
    self.emailTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.passwordTextfield.borderStyle = UITextBorderStyleNone;
    self.passwordTextfield.delegate = self;
    self.passwordTextfield.returnKeyType = UIReturnKeyGo;
    [self.passwordTextfield setFont:[UIFont systemFontOfSize:18]];
    self.passwordTextfield.secureTextEntry = YES;
    self.passwordTextfield.placeholder = @"请输入密码";
    self.passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.loginButoon setTitle:@"登录" forState:UIControlStateNormal];
    self.loginButoon.layer.cornerRadius = 5;
    [self.loginButoon.titleLabel setFont:[UIFont systemFontOfSize:21]];
    self.loginButoon.clipsToBounds = YES;
    
    //给用户名和密码赋值
    self.emailTextfield.text = [UserDefaults getUserAccount];
//    self.passwordTextfield.text = [UserDefaults getUserPassword]; // 不自动填充密码
    
    
    if ([UIAdapterUtil isGOMEApp])
    {
        // 添加水印
        [self addWaterMark];
    }
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.emailTextfield isFirstResponder])
    {
        [self.emailTextfield resignFirstResponder];
        [self.passwordTextfield becomeFirstResponder];
    }
    else if ([self.passwordTextfield isFirstResponder])
    {
        [self.passwordTextfield resignFirstResponder];
        
        [self clickLogin];
    }
    
    return YES;
}

- (void)addWaterMark
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (IPHONE_5S_OR_LESS)
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm"];
    }
    else
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm:ss"];
    }
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSString *str = [NSString stringWithFormat:@"国美电器有限公司\n持有人:\n%@",time];
    
    UILabel *waterMarkkLabel = [[UILabel alloc] initWithFrame:CGRectMake(-15, 120, 200, 100)];
    waterMarkkLabel.numberOfLines = 0;
    waterMarkkLabel.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel.text = str;
    waterMarkkLabel.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:waterMarkkLabel];
    
    UILabel *waterMarkkLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, 120, 200, 100)];
    waterMarkkLabel1.numberOfLines = 0;
    waterMarkkLabel1.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel1.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel1 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel1.text = str;
    waterMarkkLabel1.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];;
    
    [delegate.window addSubview:waterMarkkLabel1];
    
    UILabel *waterMarkkLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(-15, SCREEN_HEIGHT-170, 200, 100)];
    waterMarkkLabel2.numberOfLines = 0;
    waterMarkkLabel2.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel2.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel2 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel2.text = str;
    waterMarkkLabel2.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];;
    
    [delegate.window addSubview:waterMarkkLabel2];
    
    UILabel *waterMarkkLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, SCREEN_HEIGHT-170, 200, 100)];
    waterMarkkLabel3.numberOfLines = 0;
    waterMarkkLabel3.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel3.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel3 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel3.text = str;
    waterMarkkLabel3.textColor = [UIColor colorWithWhite:0.78 alpha:0.3];;
    
    [delegate.window addSubview:waterMarkkLabel3];
}


- (void)tapVisiber:(UIButton *)button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        self.passwordTextfield.secureTextEntry = NO;
    }
    else
    {
        self.passwordTextfield.secureTextEntry = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
    
    self.navigationController.navigationBar.hidden = YES;
    
    // 设置状态栏颜色为黑色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
    
    self.navigationController.navigationBar.hidden = NO;
    
    // 设置状态栏颜色为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)clickLogin
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    
    email = self.emailTextfield.text;
    password = self.passwordTextfield.text;
    
    NSString	*errorMessage	=	nil;
    /****判断注册帐号是否合法*****/
    if(!email || email.length <= 0)
    {
        errorMessage	=	[StringUtil getLocalizableString:@"account_is_null"];
    }
    // add by shisp
    //	else if([self.email length] > 50)
    //	{
    //		errorMessage	=	@"账号最大长度50位";
    //	}
    else if(!password || password.length <= 0)
    {
        errorMessage	=	[StringUtil getLocalizableString:@"password_is_null"];
    }
    //add by shisp
    //	else if([self.passwd length] > 20)
    //	{
    //		errorMessage	=	@"密码长度最大20位";
    //
    //	}
    
    if(errorMessage)
    {
        UIAlertView	*alert	=	[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"]
                                                       message:errorMessage
                                                      delegate:nil
                                             cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"]
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    email = [email lowercaseString];
    
    NSString *lastUserAccount = [UserDefaults getLastUserAccount];
    if (lastUserAccount.length > 0) {
        if (![lastUserAccount isEqualToString:email]) {
            AccessConn *conn = [AccessConn getConn];
            [conn removeLastConnectData];
        }
    }
    
    [UserDefaults setPassword:password forAccount:email];
    
    if(![ApplicationManager getManager].isNetworkOk)
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"check_network"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        //				登录提示框
        /**提示框**/
        [self showIndicator];
        [self performSelector:@selector(login:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:email,@"user_account",password,@"user_password",nil] afterDelay:0.1];
    }
}
//登录采用异步方式 update by shisp
-(void)login:(NSDictionary *)userInfo
{
    NSString *account = userInfo[@"user_account"];
    NSString *psd = userInfo[@"user_password"];
    
    if (!account || ![account isEqualToString:[UserDefaults getUserAccount]]) {
        //        账号不一致
        return;
    }
    if (!psd || ![psd isEqualToString:[UserDefaults getUserPassword]]) {
        //        密码不一致
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("logging...", NULL);
    
    dispatch_async(queue, ^{
        
        email = [UserDefaults getUserAccount];
        password = [UserDefaults getUserPassword];
        
        conn *_conn = [conn getConn];
        
        if([_conn initConn])
        {
            if(_conn.forceUpdate || ([[eCloudConfig getConfig]needShowAlertWhenOptionUpdate] && _conn.hasNewVersion))
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                    
                    [[ApplicationManager getManager] showVersionAlert:self];
                });
                return;
            }
            else
            {
                if(![_conn login:email andPasswd:password])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [LogUtil debug:@"登录命令发送失败"];
                        
                        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                        
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"login_cmd_send_error"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                        [alert show];
                    });
                }
                else
                {
                    // 登录成功
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"GSAPassword"];
                    NSLog(@"登录成功");
                }
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [LogUtil debug:@"初始化连接失败"];
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                
                NSString *errMsg = [AccessConn getConn].errMsg;
                //                if ([_errMsg isEqualToString:@"没有找到该账号"] ) {
                //                    errMsg = _errMsg;
                //                }
                
                if(errMsg == nil)
                {
                    errMsg = [StringUtil getLocalizableString:@"Connection_failed"];
                }
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:errMsg delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                [alert show];
            });
        }
    });
}

-(void)showIndicator
{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"logining"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
}

- (void)handleCmd:(NSNotification *)notification
{
    eCloudNotification	*cmd	 =	(eCloudNotification *)[notification object];
    if(cmd.cmdId == login_timeout)
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"login_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:Nil, nil];
        [alert show];
    }
    else if(cmd.cmdId == login_failure)
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
        
        NSDictionary * dic = cmd.info;
        ConnResult *result = [dic objectForKey:@"RESULT"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login_fail"] message:[result getResultMsg] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
    }
    else if(cmd.cmdId == login_success)
    {
        // 判断是否支持保存密码
        if ([eCloudConfig getConfig].supportSavePassword){
            // 获取账号
            NSString *accountStr = self.emailTextfield.text;
            NSString *passwordStr = self.passwordTextfield.text;
            
            NSMutableDictionary *accountInfoDic = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAccountInfo]];
            if (!accountInfoDic || [accountInfoDic allKeys].count == 0) {
                accountInfoDic = [[NSMutableDictionary alloc]init];
            }
//            if (self.isSavePassword) {
                [accountInfoDic setObject:passwordStr forKey:accountStr];
//            }else{
//                [accountInfoDic removeObjectForKey:accountStr];
//            }
            [UserDefaults saveAccountInfo:accountInfoDic];
        }
        
        _NewLoginViewController->goToMainView(self);
        
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
        
    }
}

#pragma mark ====alertview=====
//如果有强制升级或者可选升级，进行如下处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == FORCE_UPDATE_ALERT_TAG || (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 1 ))
    {
        [conn getConn].connStatus = not_connect_type;
        
        [LogUtil debug:[NSString stringWithFormat:@"强制升级 或者 可选升级，打开升级页面"]];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[conn getConn].updateUrl]];
        if ([[conn getConn].updateUrl hasPrefix:@"itms-services://"]) {
            //            ios8下 用户选择安装新版本后，系统不会自动退出，所以
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 0)
    {
        [LogUtil debug:[NSString stringWithFormat:@"可选升级，用户选择了以后再说，那么继续登录"]];
        
        [self showIndicator];
        
        [conn getConn].connStatus = linking_type;
        
        if(![[conn getConn] login:[conn getConn].userEmail andPasswd:[conn getConn].userPasswd])
        {
            [conn getConn].connStatus = not_connect_type;
        }
    }
    [ApplicationManager getManager].versionAlert = nil;
}

@end
