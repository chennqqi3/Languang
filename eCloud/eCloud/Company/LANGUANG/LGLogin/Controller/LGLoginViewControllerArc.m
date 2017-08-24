//
//  LGLoginViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/5/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGLoginViewControllerArc.h"
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

@interface LGLoginViewControllerArc ()<UITextFieldDelegate,UIAlertViewDelegate>
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

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *emailtextFieldTopContraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *loginBtnTopContraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *iconTopContraint;

@property (nonatomic ,strong)UIButton *delButton;
@property (nonatomic ,strong)UIButton *visibleBtn;

- (IBAction)clickLogin;


@end

@implementation LGLoginViewControllerArc

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tap];
    
    [self setupUI];
    
    //监听当键盘将要出现时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    float viewY = self.view.frame.origin.y;
    if (viewY == 0) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        CGRect _frame = self.view.frame;
        _frame.origin.y = self.view.frame.origin.y - 46;
        self.view.frame = _frame;
        
        [UIView commitAnimations];
        
    }
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    float viewY = self.view.frame.origin.y;
    if (viewY < 0) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        CGRect _frame = self.view.frame;
        _frame.origin.y = self.view.frame.origin.y + 46;
        self.view.frame = _frame;
        
        [UIView commitAnimations];
    }
}

- (void)resignFirstResponder
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

- (void)setupUI
{
/*
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
*/
    
    self.loginLogo.image = [StringUtil getImageByResName:@"login_logo"];
//    self.userIcon.image = [StringUtil getImageByResName:@"userlogo"];
//    self.secretIcon.image = [StringUtil getImageByResName:@"login_secret"];
    [self.visibleButton setImage:[StringUtil getImageByResName:@"invisible"] forState:UIControlStateNormal];
    [self.visibleButton setImage:[StringUtil getImageByResName:@"visible"] forState:UIControlStateSelected];
    [self.visibleButton addTarget:self action:@selector(tapVisiber:) forControlEvents:UIControlEventTouchUpInside];
 
    self.emailTextfield.borderStyle = UITextBorderStyleNone;
    self.emailTextfield.delegate = self;
    self.emailTextfield.returnKeyType = UIReturnKeyNext;
    [self.emailTextfield setFont:[UIFont systemFontOfSize:17]];
    self.emailTextfield.placeholder = @"请输入蓝光用户名";
//    self.emailTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.passwordTextfield.borderStyle = UITextBorderStyleNone;
    self.passwordTextfield.delegate = self;
    self.passwordTextfield.returnKeyType = UIReturnKeyGo;
    [self.passwordTextfield setFont:[UIFont systemFontOfSize:17]];
    self.passwordTextfield.secureTextEntry = YES;
    self.passwordTextfield.placeholder = @"请输入密码";
//    self.passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.passwordTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.loginButoon setTitle:@"登录" forState:UIControlStateNormal];
    self.loginButoon.layer.cornerRadius = 5;
    [self.loginButoon.titleLabel setFont:[UIFont systemFontOfSize:19]];
    self.loginButoon.clipsToBounds = YES;
    self.loginButoon.userInteractionEnabled=NO;//交互关闭
    self.loginButoon.alpha=0.4;//透明度
    
    //给用户名和密码赋值
    self.emailTextfield.text = [UserDefaults getUserAccount];
    //    self.passwordTextfield.text = [UserDefaults getUserPassword]; // 不自动填充密码
    
    // 添加水印
    [self addWaterMark];
    
    self.delButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.delButton.frame = CGRectMake(self.view.frame.size.width-24-15, self.passwordTextfield.frame.origin.y + 12.5, 15, 15);
//    self.delButton.frame = CGRectMake(self.passwordTextfield.frame.origin.x + self.passwordTextfield.frame.size.width + 23 + 38, self.passwordTextfield.frame.origin.y+12.5, 15, 15);
    [self.delButton setImage:[StringUtil getImageByResName:@"ic_signin_delete.png"] forState:UIControlStateNormal];
//    self.delButton.backgroundColor = [UIColor redColor];
    [self.delButton addTarget:self action:@selector(delSender) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.delButton];
    self.delButton.hidden = YES;
    
    
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.delButton.frame = CGRectMake(self.visibleButton.frame.origin.x + 20, self.visibleButton.frame.origin.y, self.visibleButton.frame.size.width, self.visibleButton.frame.size.height);
    
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
    NSString *str = [NSString stringWithFormat:@"蓝光BRC\n持有人:\n%@",time];
    
    UILabel *waterMarkkLabel = [[UILabel alloc] initWithFrame:CGRectMake(-15, 120, 200, 100)];
    waterMarkkLabel.numberOfLines = 0;
    waterMarkkLabel.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel.text = str;
    waterMarkkLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:waterMarkkLabel];
    
    UILabel *waterMarkkLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, 120, 200, 100)];
    waterMarkkLabel1.numberOfLines = 0;
    waterMarkkLabel1.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel1.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel1 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel1.text = str;
    waterMarkkLabel1.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];

    
    [delegate.window addSubview:waterMarkkLabel1];
    
    UILabel *waterMarkkLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(-15, SCREEN_HEIGHT-170, 200, 100)];
    waterMarkkLabel2.numberOfLines = 0;
    waterMarkkLabel2.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel2.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel2 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel2.text = str;
    waterMarkkLabel2.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];

    
    [delegate.window addSubview:waterMarkkLabel2];
    
    UILabel *waterMarkkLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, SCREEN_HEIGHT-170, 200, 100)];
    waterMarkkLabel3.numberOfLines = 0;
    waterMarkkLabel3.textAlignment = NSTextAlignmentCenter;
    waterMarkkLabel3.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [waterMarkkLabel3 setFont:[UIFont systemFontOfSize:18]];
    waterMarkkLabel3.text = str;
    waterMarkkLabel3.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];

    
    [delegate.window addSubview:waterMarkkLabel3];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length >=6) {
        
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
    }
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.passwordTextfield) {
        if (textField.text.length >= 6) {
            
            self.loginButoon.userInteractionEnabled=YES;
            self.loginButoon.alpha=1;
        }else{
            
            self.loginButoon.userInteractionEnabled=NO;
            self.loginButoon.alpha=0.4;
        }
        
        if (textField.text.length >0) {
            
            self.delButton.hidden = NO;
        }else{
            
            self.delButton.hidden = YES;
            
        }
    }
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
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)clickLogin
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    
    email = self.emailTextfield.text;
    password = self.passwordTextfield.text;
    
    NSString	*errorMessage	=	nil;
    //判断注册帐号是否合法
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
        //提示框
        [self showIndicator];
        [self performSelector:@selector(login:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[UserDefaults getUserAccount],@"user_account",password,@"user_password",nil] afterDelay:0.1];
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

- (void)delSender{
    
    self.passwordTextfield.text = @"";
    self.delButton.hidden = YES;
}

@end
