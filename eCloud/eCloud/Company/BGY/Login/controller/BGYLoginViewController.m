//
//  BGYLoginViewController.m
//  eCloud
//
//  Created by Alex-L on 17/7/12.
//  Copyright (c) 2017年  Alex-L. All rights reserved.
//

#import "BGYLoginViewController.h"
#import "TopNewsView.h"

#import "MBProgressHUD.h"
#import "SDKTools.h"
#import "IOSSystemDefine.h"

#import "StringUtil.h"
#import "eCloudDAO.h"
#import "LogUtil.h"
#import "conn.h"
#import "AccessConn.h"
#import "ConnResult.h"
#import "ApplicationManager.h"
#import "LCLLoadingView.h"
#import "UserDefaults.h"
#import "mainViewController.h"
#import "AppDelegate.h"
#import "NewLoginViewController.h"#import "ServerConfig.h"
#import "UserTipsUtil.h"

#define kAnimateDuration 0.3
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define BOTTOM_NORMAL_CONSTANT (IS_IPHONE_6P? 65 : 45)
#define BOTTOM_ACCOUNT_CONSTANT 110
#define BOTTOM_PASSWORD_CONSTANT 96

#define IS_SAVE_PASSWORD_KEY @"IS_SAVE_PASSWORD_KEY"

#define HEIGHT_LOGINVIEW_CONSTANT (IS_IPHONE_6P? 347 : 337)

#define HEIGHT_NORMAL_CONSTAN

@interface BGYLoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSString *accountStr;
    NSString *pwdStr;
    conn *_conn;
}

- (IBAction)loginBtnClick:(id)sender;
- (IBAction)savePasswordBtnClick:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *userNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backShadowImageView;
@property (retain, nonatomic) IBOutlet UIImageView *logoImageView;
@property (retain, nonatomic) IBOutlet UIImageView *accountIcon;
@property (retain, nonatomic) IBOutlet UIImageView *passwordIcon;

@property (strong, nonatomic) IBOutlet UIButton *savePasswordBtn;

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *loginViewBottomConstraint;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *loginViewHeightConstraint;

@property (strong, nonatomic) UIImageView *backgroundView;

@end

@implementation BGYLoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    [self setupUI];
    
    _conn = [conn getConn];
}

- (void)setupUI
{
    self.loginViewBottomConstraint.constant = BOTTOM_NORMAL_CONSTANT;
    self.loginViewHeightConstraint.constant = HEIGHT_LOGINVIEW_CONSTANT;
    
    
    [self.savePasswordBtn setImage:[StringUtil getImageByResName:@"login_save_pw_no@2x"] forState:(UIControlStateNormal)];
    [self.savePasswordBtn setImage:[StringUtil getImageByResName:@"login_save_pw_s@2x"] forState:(UIControlStateSelected)];
    
    // 设置状态栏的颜色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    
    self.savePasswordBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    
    self.backgroundImageView.image = [StringUtil getImageByResName:@"backgroundImage"];
    // 伸缩后重新赋值
    UIImage *image =[StringUtil getImageByResName:@"backgroundShadow"];
    [self.backShadowImageView setImage:image];
    
    
    self.logoImageView.image = [StringUtil getImageByResName:@"logo_icon"];
    self.accountIcon.image = [StringUtil getImageByResName:@"userlogo"];
    self.passwordIcon.image = [StringUtil getImageByResName:@"login_secret"];
    
    
    // 自动填充账号、密码
    NSString *userAccount = [UserDefaults getUserAccount];
    self.userNameTextField.text = userAccount;
    BOOL isSavePassword = [[NSUserDefaults standardUserDefaults] boolForKey:IS_SAVE_PASSWORD_KEY];
    if (isSavePassword)
    {
        NSString *password = [UserDefaults getUserPassword];
        self.passwordTextField.text = password;
    }
    self.savePasswordBtn.selected = isSavePassword;
    
    self.userNameTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.returnKeyType = UIReturnKeyGo;
    
    self.userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.userNameTextField.placeholder = @"User's name";
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.secureTextEntry = YES;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [UIView animateWithDuration:kAnimateDuration animations:^{
        
        self.loginViewBottomConstraint.constant = BOTTOM_NORMAL_CONSTANT;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_passwordTextField becomeFirstResponder];
        
    }else if(textField.returnKeyType == UIReturnKeyGo){
        
        [self loginBtnClick:nil];
        
        [UIView animateWithDuration:kAnimateDuration animations:^{
            
            self.loginViewBottomConstraint.constant = BOTTOM_NORMAL_CONSTANT;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext)
    {
        [UIView animateWithDuration:kAnimateDuration animations:^{
            
            self.loginViewBottomConstraint.constant = BOTTOM_ACCOUNT_CONSTANT;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
        
    }
    else if(textField.returnKeyType == UIReturnKeyGo)
    {
        [UIView animateWithDuration:kAnimateDuration animations:^{
            
            self.loginViewBottomConstraint.constant = BOTTOM_PASSWORD_CONSTANT;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }];
    }
    
    return YES;
}

- (void)textFieldTextDidChange:(UITextField *)textField
{
    /** 密码长度限制为15位 */
    if (textField == self.passwordTextField) {
        
        if (textField.text.length > 15) {
            textField.text = [textField.text substringToIndex:15];
        }
    }
    
}

#pragma mark - Button Action
- (IBAction)loginBtnClick:(id)sender {
    [UIView animateWithDuration:kAnimateDuration animations:^{
        
        self.loginViewBottomConstraint.constant = BOTTOM_NORMAL_CONSTANT;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    accountStr = [StringUtil trimString:_userNameTextField.text];
    pwdStr = _passwordTextField.text;
    
    NSString	*errorMessage	=	nil;
    /****判断注册帐号是否合法*****/
    if(!accountStr || accountStr.length <= 0)
    {
        errorMessage	=	[StringUtil getLocalizableString:@"account_is_null"];
    }
    else if(!pwdStr || pwdStr.length <= 0)
    {
        errorMessage	=	[StringUtil getLocalizableString:@"password_is_null"];
    }
    
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
    accountStr = [accountStr lowercaseString];
    
    NSString *lastUserAccount = [UserDefaults getUserAccount];
    // 如果登录的是不同的用户
    if (lastUserAccount.length > 0) {
        if (![lastUserAccount isEqualToString:accountStr]) {
            AccessConn *conn = [AccessConn getConn];
            [conn removeLastConnectData];
        }
    }
    
    [UserDefaults setPassword:pwdStr forAccount:accountStr];
    
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
        [self performSelector:@selector(login:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:accountStr,@"user_account",pwdStr,@"user_password",nil] afterDelay:0.1];
    }
}

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
        
        accountStr = [UserDefaults getUserAccount];
        pwdStr = [UserDefaults getUserPassword];
        
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
                if(![_conn login:accountStr andPasswd:pwdStr])
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
                    [[NSUserDefaults standardUserDefaults] setObject:pwdStr forKey:@"GSAPassword"];
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
            NSString *accountStr = _userNameTextField.text;
            NSString *passwordStr = _passwordTextField.text;
            
            NSMutableDictionary *accountInfoDic = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAccountInfo]];
            if (!accountInfoDic || [accountInfoDic allKeys].count == 0) {
                accountInfoDic = [[NSMutableDictionary alloc]init];
            }
            int accountSaveState = 0;
            if(self.savePasswordBtn.isSelected){
                accountSaveState = 1;
                [accountInfoDic setObject:passwordStr forKey:accountStr];
            }else{
                [accountInfoDic removeObjectForKey:accountStr];
            }
            [UserDefaults saveAccountInfo:accountInfoDic];
            [UserDefaults saveSaveState:[NSNumber numberWithInt:accountSaveState]];
        }
        
        _NewLoginViewController->goToMainView(self);
        
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
    }
}

#pragma mark - 弹出提示框
-(void)showIndicator{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"logining"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
}

#pragma mark - 保存密码
- (void)savePass{
    [self savePasswordBtnClick:nil];
}
- (IBAction)savePasswordBtnClick:(id)sender {
    
    self.savePasswordBtn.selected = !self.savePasswordBtn.selected;
    
    [[NSUserDefaults standardUserDefaults] setBool:self.savePasswordBtn.selected forKey:IS_SAVE_PASSWORD_KEY];
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

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

@end
