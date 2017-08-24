//
//  XINHUALoginViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/4/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUALoginViewControllerArc.h"
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


@interface XINHUALoginViewControllerArc ()<UITextFieldDelegate>
{
    NSString *email;
    NSString *password;
    
    BOOL _isSavePassword;
}

@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (retain, nonatomic) IBOutlet UIImageView *logo;

@property (retain, nonatomic) IBOutlet UIImageView *accountLogo;
@property (retain, nonatomic) IBOutlet UIImageView *passwordLogo;


@property (retain, nonatomic) IBOutlet UITextField *emailTextfield;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextfield;

@property (retain, nonatomic) IBOutlet UILabel *phoneNumberWarning;
@property (retain, nonatomic) IBOutlet UILabel *passwordWarning;

@property (retain, nonatomic) IBOutlet UIButton *savePassword;

@property (retain, nonatomic) IBOutlet UIImageView *saveImageView;


- (IBAction)cancelTap:(UITapGestureRecognizer *)sender;

- (IBAction)savePasswordClick;

- (IBAction)loginClick;

@end

@implementation XINHUALoginViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)insertImageWithAttributeString:(NSMutableAttributedString *)attributeString WithImageName:(NSString *)imageName
{
    UIImage *errorImage = [StringUtil getImageByResName:imageName];
    NSTextAttachment* textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = errorImage;
    textAttachment.bounds = CGRectMake(0, -2, 13, 13);  // 微调图片位置
    NSAttributedString* imageAttachment = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributeString insertAttributedString:imageAttachment atIndex:0]; // 插入图片
}

- (void)setupUI
{
    if (IS_IPHONE_6) {
        self.topConstraint.constant = 86;
    }
    else if (IPHONE_5S_OR_LESS)
    {
        self.topConstraint.constant = 76;
    }
    
    
    _isSavePassword = [UserDefaults getIsSavePassword];
    
    NSString *imageName = _isSavePassword ? @"login_save_pw_s" : @"login_save_pw_no";
    self.saveImageView.image = [StringUtil getImageByResName:imageName];
    
    
    self.logo.image = [StringUtil getImageByResName:@"xinhua_logo"];
    self.logo.layer.cornerRadius = 5;
    self.logo.clipsToBounds = YES;
    
    NSMutableAttributedString *attributeString1 = [[NSMutableAttributedString alloc] initWithString:[StringUtil getAppLocalizableString:@"the_phone_number_is_wrong"]];
    [self insertImageWithAttributeString:attributeString1 WithImageName:@"xinhua_error"];
    NSMutableAttributedString *attributeString2 = [[NSMutableAttributedString alloc] initWithString:[StringUtil getAppLocalizableString:@"the_password_is_wrong"]];
    [self insertImageWithAttributeString:attributeString2 WithImageName:@"xinhua_error"];
    self.phoneNumberWarning.attributedText = attributeString1;
    self.passwordWarning.attributedText = attributeString2;
    
    self.phoneNumberWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
    self.emailTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    self.emailTextfield.text = [[NSUserDefaults standardUserDefaults] objectForKey:ACCOUNT_KEY];
    self.emailTextfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    self.emailTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailTextfield.returnKeyType = UIReturnKeyNext;
    
    self.passwordTextfield.text = _isSavePassword ? [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_KEY] : @"";
    self.passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordTextfield.returnKeyType = UIReturnKeyDone;
    self.passwordTextfield.secureTextEntry = YES;
    
    self.accountLogo.image = [StringUtil getImageByResName:@"yonghu"];
    self.passwordLogo.image = [StringUtil getImageByResName:@"suo"];
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

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.phoneNumberWarning.hidden = YES;
    self.passwordWarning.hidden = YES;
    
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextfield])
    {
        [self.emailTextfield resignFirstResponder];
        [self.passwordTextfield becomeFirstResponder];
    }
    else
    {
        [self.passwordTextfield resignFirstResponder];
        
        // 登录
        [self loginClick];
    }
    
    return YES;
}

- (IBAction)cancelTap:(UITapGestureRecognizer *)sender
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
}

- (IBAction)savePasswordClick
{
    _isSavePassword = !_isSavePassword;
    [UserDefaults saveIsSavePassword:_isSavePassword];
    
    NSString *imageName = _isSavePassword ? @"login_save_pw_s" : @"login_save_pw_no";
    self.saveImageView.image = [StringUtil getImageByResName:imageName];
}

// 判断手机号是否符合格式
-(BOOL)checkTelNumber:(NSString*)telNumber{
    
    
//    if (telNumber.length == 11)
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
    
    
    NSString *new = @"^1[0-9]{10}$";
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", new];
    BOOL res = [regextestcm evaluateWithObject:telNumber];
    if (res)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
    /* 17876456527
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    
     
     
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    BOOL res1 = [regextestmobile evaluateWithObject:telNumber];
    BOOL res2 = [regextestcm evaluateWithObject:telNumber];
    BOOL res3 = [regextestcu evaluateWithObject:telNumber];
    BOOL res4 = [regextestct evaluateWithObject:telNumber];
    
    if (res1 || res2 || res3 || res4)
    {
        return YES;
    }
    else
    {
        return NO;
    }
     */
}

- (IBAction)loginClick
{
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    
    BOOL isTelphone = [self checkTelNumber:self.emailTextfield.text];
    if (!isTelphone)
    {
        NSMutableAttributedString *attributeString1 = [[NSMutableAttributedString alloc] initWithString:[StringUtil getAppLocalizableString:@"the_phonenumber's_format_is_wrong"]];
        [self insertImageWithAttributeString:attributeString1 WithImageName:@"xinhua_error"];
        self.phoneNumberWarning.attributedText = attributeString1;
        
        self.phoneNumberWarning.hidden = NO;
        
        NSLog(@"手机号码格式错误");
        
        return;
    }
    
    email = self.emailTextfield.text;
    password = self.passwordTextfield.text;
    
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:ACCOUNT_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:PASSWORD_KEY];
    
    // MD5加密
    password = [StringUtil getUpperMD5Str:password];
    
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
                
                NSMutableAttributedString *attributeString1 = [[NSMutableAttributedString alloc] initWithString:[StringUtil getAppLocalizableString:@"the_phone_number_is_wrong"]];
                [self insertImageWithAttributeString:attributeString1 WithImageName:@"xinhua_error"];
                self.phoneNumberWarning.attributedText = attributeString1;
                
                self.phoneNumberWarning.hidden = NO;
                
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:errMsg delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//                [alert show];
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
        self.passwordWarning.hidden = NO;
        
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login_fail"] message:[result getResultMsg] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//        [alert show];
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
