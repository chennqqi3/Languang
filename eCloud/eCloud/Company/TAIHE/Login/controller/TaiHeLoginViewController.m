//
//  TaiHeLoginViewController.m
//  eCloud
//
//  Created by yanlei on 17/1/11.
//  Copyright (c) 2017年  lyan. All rights reserved.
//

#import "TaiHeLoginViewController.h"
#import "CycleScrollView.h"
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
#import "NewLoginViewController.h"

#import "TAIHEAgentLstViewController.h"
#import "ServerConfig.h"
#import "AFNetworking.h"
#import "UserTipsUtil.h"

#define kOANewsSaveData @"OANewsSaveData"

#define kAnimateDuration 0.3
#define ScreenWidth [UIScreen mainScreen].bounds.size.width


@interface TaiHeLoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    MBProgressHUD * _progressHUD;
    BOOL isFirstLoad;
    CycleScrollView *topNewsScroll;
    
    eCloudDAO *db;
    conn *_conn;
    NSString *accountStr;
    NSString *pwdStr;
}
@property (retain, nonatomic) IBOutlet UIView *topNewsView;
@property (retain, nonatomic) IBOutlet UIImageView *topNewsIcon;
@property (retain, nonatomic) IBOutlet UIImageView *topNewsIconBg;
@property (retain, nonatomic) IBOutlet UIImageView *topNewsShadow;
@property (retain, nonatomic) IBOutlet UIPageControl *topNewsPageView;
@property (retain, nonatomic) IBOutlet UILabel *topNewsIconTitle;


@property (retain, nonatomic) IBOutlet UIImageView *imageLoginBg;
@property (retain, nonatomic) IBOutlet UIImageView *imageLoginAccount;
@property (retain, nonatomic) IBOutlet UIImageView *imageLoginPwd;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *savePasswordBtn;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *rememberPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIView *userNameView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *savepwLabel;
@property (strong, nonatomic) IBOutlet UILabel *forgotPasswordlabel;
@property (strong, nonatomic) IBOutlet UILabel *loginHintLabel;

@property (strong, nonatomic) IBOutlet UIImageView *mobileOfficeLogo;
@property (strong, nonatomic) IBOutlet UIView *savePasswordView;


@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topViewTopVal;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightVal;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topView2UserInfoViewSpaceVal;

@property (strong, nonatomic) UITextField *currentTextField;
@property (assign, nonatomic) CGFloat topViewVal;
@property (assign, nonatomic) CGRect keyRect;
@end

@implementation TaiHeLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [StringUtil cleanCacheAndCookie];

    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboradWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(isFirstLoad) {
//        [self createCycleView];
        if (IS_IPHONE_4_OR_LESS) {
            if(!IOS7_OR_LATER) {
                self.topNewsView.top = 5;
            } else {
                self.topNewsView.top = 20;
            }
            topNewsScroll.width = 210;
            topNewsScroll.height = 251;
            topNewsScroll.centerX = self.view.centerX;
            topNewsScroll.scrollView.frame = CGRectMake(0, 0, topNewsScroll.width, topNewsScroll.height);
            topNewsScroll.scrollView.contentSize = CGSizeMake(topNewsScroll.scrollView.contentSize.width, topNewsScroll.height);
            self.topNewsIcon.left = topNewsScroll.left - 5;
            self.topNewsIconBg.left = self.topNewsIcon.left;
            self.topNewsShadow.top = topNewsScroll.bottom - 8;
            self.topNewsPageView.top = topNewsScroll.bottom;
            _userNameView.top += 10;
            _savePasswordView.top += 10;
            _loginView.top -= 2;
            self.topNewsIconTitle.left += 18;
        }
        self.topNewsIconTitle.transform = CGAffineTransformMakeRotation(-M_PI_4);
        
        [self loadHttpData];
    }
    [topNewsScroll resumeTimer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:@"applicationWillResignActive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:@"applicationDidBecomeActive" object:nil];
    
    // 初始化数据
    [self loadLoginData];
    
    [self loadLoginUI];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
//    [_userNameTextField setValue:[UIColor colorWithRed:((0x5c7585>>16)&0xFF)/255.0 green:((0x5c7585>>8)&0xFF)/255.0 blue:(0x5c7585&0xFF)/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
//    [_passwordTextField setValue:[UIColor colorWithRed:((0x5c7585>>16)&0xFF)/255.0 green:((0x5c7585>>8)&0xFF)/255.0 blue:(0x5c7585&0xFF)/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_userNameTextField setValue:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextField setValue:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    
    isFirstLoad = YES;
    //    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // 增大记住密码的触摸范围
    UIView *savePasswordBackgroundView = [[UIView alloc] initWithFrame:self.savePasswordView.bounds];
    savePasswordBackgroundView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *savePassTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(savePass)];
    [savePasswordBackgroundView addGestureRecognizer:savePassTap];
    [self.savePasswordView addSubview:savePasswordBackgroundView];
}
- (void)loadLoginData{
    _conn = [conn getConn];
    db = [eCloudDAO getDatabase];
}
- (void)loadLoginUI{
    [self createCycleView];
    // 设置登陆页面显示图片资源
    self.imageLoginBg.image = [StringUtil getImageByResName:@"login_bg"];
    self.imageLoginAccount.image = [StringUtil getImageByResName:@"login_icon_account"];
    self.imageLoginPwd.image = [StringUtil getImageByResName:@"login_icon_pwd"];
    self.topNewsIconBg.image = [StringUtil getImageByResName:@"login_icon_top_news_bg"];
    self.topNewsIcon.image = [StringUtil getImageByResName:@"login_icon_top_news"];
    self.topNewsShadow.image = [StringUtil getImageByResName:@"login_top_news_shadow"];
    [self.loginBtn setBackgroundImage:[StringUtil getImageByResName:@"login_btn_bg"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[StringUtil getImageByResName:@"login_btn_bg_ac"] forState:UIControlStateHighlighted];
    [self.savePasswordBtn setBackgroundImage:[StringUtil getImageByResName:@"login_save_pw_no"] forState:UIControlStateNormal];
    [self.savePasswordBtn setBackgroundImage:[StringUtil getImageByResName:@"login_save_pw_no"] forState:UIControlStateSelected];
    [self.savePasswordBtn setImage:[StringUtil getImageByResName:@"login_save_pw_sel"] forState:UIControlStateSelected];
    
    self.forgotPasswordlabel.textColor = [UIColor lightGrayColor];//kHintLabelColorLogin;
    self.loginHintLabel.textColor = [UIColor lightGrayColor];//kHintLabelColorLogin;
    
    [self.userNameTextField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.userNameTextField.text = [UserDefaults getUserAccount];
    int accountSaveState = [[UserDefaults getSaveState] intValue];
    if (accountSaveState == 1) {
        self.savePasswordBtn.selected = YES;
        self.passwordTextField.text = [UserDefaults getUserPassword];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [topNewsScroll pauseTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [topNewsScroll resumeTimer];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.view.top = 0;
    }];
}

- (BOOL)needAddLog
{
    return NO;
}

- (void)createCycleView
{
    if(!topNewsScroll) {
        // 根据手机型号重新计算加载登录界面布局
//        self.topViewVal = 60;
        // 48  56   62
        self.topViewVal = 35;
        CGFloat topsNewScrollHeight = 290;
        if (IS_IPHONE_5) {
            self.topViewTopVal.constant = self.topViewVal;
            self.topViewHeightVal.constant = 330;
            self.topView2UserInfoViewSpaceVal.constant = 10;
        }else if (IS_IPHONE_6){
            self.topViewVal = 40;
            self.topViewTopVal.constant = self.topViewVal;
            self.topViewHeightVal.constant = 390;
            self.topView2UserInfoViewSpaceVal.constant = 20;
            topsNewScrollHeight = 350;
        }else if (IS_IPHONE_6P){
            self.topViewVal = 40;
            self.topViewTopVal.constant = self.topViewVal;
            self.topViewHeightVal.constant = 460;
            self.topView2UserInfoViewSpaceVal.constant = 20;
            topsNewScrollHeight = 415;
        }
        else if (IS_IPAD)
        {
            self.topViewVal = 60;
            self.topViewTopVal.constant = self.topViewVal;
            self.topViewHeightVal.constant = 560;
            self.topView2UserInfoViewSpaceVal.constant = 80;
            topsNewScrollHeight = 500;
        }
        
        int topsNewScrollWidth = topsNewScrollHeight*(6/8.0); // ScreenWidth - (2 * self.topViewVal);
        // ScreenWidth-38*2
        int topsNewScrollX = topsNewScrollWidth*(1/16.0);
        topNewsScroll = [[CycleScrollView alloc] initWithFrame:CGRectMake(topsNewScrollX, 0, topsNewScrollWidth, topsNewScrollHeight) animationDuration:4.f];
        topNewsScroll.backgroundColor = [UIColor clearColor];
        topNewsScroll.scrollView.layer.cornerRadius = 25.f;
        topNewsScroll.scrollView.clipsToBounds = YES;
        [self.topNewsView insertSubview:topNewsScroll aboveSubview:self.topNewsIconBg];
    }
    
}

- (void)reloadCycleWithData:(NSArray *)newsList
{
    NSMutableArray *itemList = [NSMutableArray array];
    for (OANewsEntity *entity in newsList) {
        TopNewsView *item = [TopNewsView loadFromXib];
        item.frame = CGRectMake(0, 0, topNewsScroll.scrollView.width, topNewsScroll.scrollView.height);
        [item displayWithModel:entity];
        [itemList addObject:item];
        self.topNewsIconTitle.text = entity.newstype;
    }
    topNewsScroll.scrollView.backgroundColor = [UIColor clearColor];
    self.topNewsPageView.numberOfPages = newsList.count;
    
    __weak typeof(self) weakself = self;
    
    topNewsScroll.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        if(pageIndex >= 0 && pageIndex < itemList.count) {
            return itemList[pageIndex];
        } else {
            return nil;
        }
    };
    
    topNewsScroll.totalPagesCount = ^NSInteger(void){
        return newsList.count;
    };
    
    topNewsScroll.TapActionBlock = ^(NSInteger pageIndex){
        if(pageIndex >= 0 && pageIndex < newsList.count) {
            OANewsEntity *entity = newsList[pageIndex];
//            [weakself.navigator openString:entity.url];
            [weakself openString:entity.url];
        }
    };
    
    __weak typeof(self.topNewsPageView) pageControl = self.topNewsPageView;
    topNewsScroll.ScrollBlock = ^(NSInteger currentIndex,CGFloat contentOffsetX){
        pageControl.currentPage = currentIndex;
    };
}
- (void)openString:(NSString *)str
{
    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    openweb.urlstr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.navigationController pushViewController:openweb animated:YES];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        [_passwordTextField becomeFirstResponder];
        [self changeViewFrameByKeyboard:self.keyRect];
    }else if(textField.returnKeyType == UIReturnKeyGo){
        [self loginBtnClick:nil];
        [UIView animateWithDuration:kAnimateDuration animations:^{
            self.view.top = 0;
        }];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.currentTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
}

- (void)textFieldTextDidChange:(UITextField *)textField
{
    if (textField.text.length > 20) {
        textField.text = [textField.text substringToIndex:20];
    }
}

#pragma mark - Button Action
- (IBAction)loginBtnClick:(id)sender {
    [UIView animateWithDuration:kAnimateDuration animations:^{
        self.view.top = 0;
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
        [alert release];
        return;
    }
    accountStr = [accountStr lowercaseString];
    
    NSString *lastUserAccount = [UserDefaults getLastUserAccount];
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
        [alert release];
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
                        [alert release];
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
                [alert release];
            });
        }
    });
    dispatch_release(queue);
}
static void _goToMainView(UIViewController *curVc)
{
    mainViewController *mainView = [[mainViewController alloc]init];
    AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    UINavigationController *nc=[[UINavigationController alloc]initWithRootViewController:mainView];
    delegate.window.rootViewController=nc;
}
- (void)handleCmd:(NSNotification *)notification
{
    eCloudNotification	*cmd	 =	(eCloudNotification *)[notification object];
    if(cmd.cmdId == login_timeout)
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"login_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:Nil, nil];
        [alert show];
        [alert release];
    }
    else if(cmd.cmdId == login_failure)
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
        
        NSDictionary * dic = cmd.info;
        ConnResult *result = [dic objectForKey:@"RESULT"];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login_fail"] message:[result getResultMsg] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
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
//    UIButton * btn = (UIButton*)sender;
//    btn.selected = !btn.selected;
    self.savePasswordBtn.selected = !self.savePasswordBtn.selected;
}
#pragma mark - 请求登录界面广告信息接口
- (void)loadHttpData{
    
    id dict = [UserDefaults getTaiHeAppLoginJsonString];
    if (dict == nil) {
        
        [self requestHttpData];
        
    }else{
        
        NSArray *adInfoArr = dict[@"data"];
        NSMutableArray *tmpnewsList = [NSMutableArray array];
        NSString *typename = @"泰禾头条";
        
        for (NSDictionary *adInfoDic in adInfoArr) {
            OANewsEntity * entity = [[OANewsEntity alloc]init];
            
            [entity setValuesForKeysWithDictionary:adInfoDic];
            [tmpnewsList addObject:entity];
        }
        
        [self reloadCycleWithData:tmpnewsList];
        
        [self requestHttpData];
        
    }
}

- (void)requestHttpData{
    
    NSString *loginAdInfoUrl = [[ServerConfig shareServerConfig]getLoginADInfoUrl:0];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 30;
    [manager POST:loginAdInfoUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取登录页广告信息 == %@",__FUNCTION__,responseObject]];

        id dict = responseObject;
        id empDict = [UserDefaults getTaiHeAppLoginJsonString];
        
        if ([dict isEqualToDictionary:empDict]) {
            
            return ;
        }
       
        NSString *stateCode = [NSString stringWithFormat:@"%@",dict[@"status"]];
        if ([stateCode isEqualToString:@"0"]) {
            NSArray *adInfoArr = dict[@"data"];
            NSMutableArray *tmpnewsList = [NSMutableArray array];
            NSString *typename = @"泰禾头条";
            
            for (NSDictionary *adInfoDic in adInfoArr) {
                OANewsEntity * entity = [[OANewsEntity alloc]init];
                //                entity.title = adInfoDic[@"title"];
                //                entity.url = adInfoDic[@"url"];
                //                entity.thumb = adInfoDic[@"thumb"];
                //                entity.newsdescription = adInfoDic[@"description"];
                //                entity.inputtime = adInfoDic[@"update_time"];
                //                entity.newstype = typename;
                [entity setValuesForKeysWithDictionary:adInfoDic];
                [tmpnewsList addObject:entity];
            }
            
            [self reloadCycleWithData:tmpnewsList];
            
            [UserDefaults saveTaiHeAppLoginJsonString:responseObject];
            
            _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
            _progressHUD.labelText = @"kLoadingViewTextLogin";//kLoadingViewTextLogin;
            [self.view addSubview:_progressHUD];
            isFirstLoad = NO;
        }else{
            [UserTipsUtil showAlert:dict[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取登录页广告信息失败 == %@",__FUNCTION__,error]];
        //[UserTipsUtil showAlert:@"登录页广告信息获取失败"];
        
    }];
}
-(void)keyboradWillShow:(NSNotification *)noti{
    // 键盘的frame
    self.keyRect = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self changeViewFrameByKeyboard:self.keyRect];
}
- (void)changeViewFrameByKeyboard:(CGRect)keyRectTmp{
    CGFloat keyboardH = keyRectTmp.size.height;
    
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [[self.currentTextField superview] convertRect:self.currentTextField.frame toView:window];
    
    CGFloat textfieldYPlusH = CGRectGetMaxY(frame);
    CGFloat keyboardY = [UIApplication sharedApplication].keyWindow.frame.size.height - keyboardH;
    
    if (textfieldYPlusH > keyboardY){
        CGFloat delta = textfieldYPlusH - keyboardY;
        
        self.topViewTopVal.constant -= delta;
    }
}

-(void)keyboradWillHide:(NSNotification *)noti{
    // 回到初始状态
    self.topViewTopVal.constant = self.topViewVal;
    self.keyRect = CGRectZero;
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
