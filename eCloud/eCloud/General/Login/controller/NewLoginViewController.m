//
//  NewLoginViewController.m
//  eCloud
//
//  Created by Richard on 13-11-23.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "NotificationUtil.h"
#import "ConnResult.h"
#import "UserDefaults.h"
#import "CheckBoxButton.h"


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
#import "CheckBoxButton.h"

#import "SafeKeyboard.h"
#ifdef _TAIHE_FLAG_
#import "TAIHEAgentLstViewController.h"
#endif

#define table_row_height (45)
#define table_header_height (10)
#define table_footer_height (60)


@interface NewLoginViewController ()<CheckBoxDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,SafeKeyboardDelegate,UITextFieldDelegate>
/** 安全键盘对象 */
@property (nonatomic, retain) SafeKeyboard *mySafeKeyboard;
/** 记录操作的是哪个文本框对象 */
@property (nonatomic, retain) UITextField *preTextField;
/** 是否要保存密码 */
@property (nonatomic, assign) BOOL isSavePassword;
/** 保存密码复选框UI组件 */
@property (nonatomic, retain) CheckBoxButton *_check2;

@end


/**
 结构体

 @param curVc 当前界面控制器
 */
static void _goToMainView(UIViewController *curVc)
{
//    mainViewController *mainView = [[mainViewController alloc]init];
//    if ([[curVc class] isEqual:[AppDelegate class]])
//    {
//        AppDelegate *Vc = (AppDelegate *)curVc;
//        [Vc.window.rootViewController.navigationController pushViewController:mainView animated:YES];
//    }
//    else
//    {
//        
//        [curVc.navigationController pushViewController:mainView animated:YES];
//    }
    AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];

    // 若服务器返回的应答为第一次登录则跳转至修改密码界面
    if ([UIAdapterUtil isTAIHEApp] && [conn getConn].isNeetModifyPwd) {
#ifdef _TAIHE_FLAG_
        TAIHEAgentLstViewController *agentListVC = [[TAIHEAgentLstViewController alloc]init];
        agentListVC.urlstr = [[[ServerConfig shareServerConfig] getFirstModifyPwdUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        agentListVC.isNeetHideLeftBtn = YES;
        UINavigationController *nc=[[UINavigationController alloc]initWithRootViewController:agentListVC];
        delegate.window.rootViewController=nc;
        [agentListVC release];
        [nc release];
#endif
    }else{
        // 将主界面的导航控制器设置为window的根控制器
        mainViewController *mainView = [[mainViewController alloc]init];
        UINavigationController *nc=[[UINavigationController alloc]initWithRootViewController:mainView];
        delegate.window.rootViewController=nc;
        [mainView release];
        [nc release];
    }
}

// 声明一个静态结构体对象
static NewLoginViewController_t * util = NULL;

@implementation NewLoginViewController
{
    /** 账号 */
	NSString *email;
    /** 密码 */
	NSString *password;
    /** 账号UI组件 */
    UITextField *emailTextField;
	/** 密码UI组件 */
	UITextField *passwordTextField;
    /** 登录按钮UI组件 */
    UIButton *loginBtn;
    
    UITableView *loginTable;
    eCloudDAO *db;
    /** 服务器连接对象 */
	conn *_conn;
}

+(NewLoginViewController_t *)sharedUtil
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 分配内存
        util = malloc(sizeof(NewLoginViewController_t));
        // 结构体成员指向实现的方法名指针
        util->goToMainView = _goToMainView;
    });
    return util;
}

+ (void)destroy
{
    // 释放结构体对象
    util ? free(util): 0;
    util = NULL;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark SafeKeyboardDelegate
- (void)setPasswordTextField:(NSString *)text
{
    passwordTextField.text = text;
}


/**
 安全键盘的代理方法，点击安全键盘的完成触发的方法
 */
- (void)clickLoginButton
{
    [self loginAction:nil];
}

#pragma mark - textfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow) {
        [textField.window makeKeyAndVisible];
    }
    
    self.preTextField = textField;
    
    if ([eCloudConfig getConfig].needFixSecurityGap && textField == passwordTextField)
    {
        if (self.mySafeKeyboard == nil)
        {
            self.mySafeKeyboard = [[[SafeKeyboard alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.frame.size.width, 225)]autorelease];
            // 设置代理
            self.mySafeKeyboard.safeKeyBoardDelegate = self;
            
            self.mySafeKeyboard.windowLevel = UIWindowLevelStatusBar;
            [self.mySafeKeyboard makeKeyAndVisible];
            
            NSLog(@"%s 生成安全键盘",__FUNCTION__);
        }
        
        CGRect rect = self.mySafeKeyboard.frame;
        rect.origin.y = [UIScreen mainScreen].bounds.size.height - 60;
        self.mySafeKeyboard.frame = rect;
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect rect = self.mySafeKeyboard.frame;
            rect.origin.y = [UIScreen mainScreen].bounds.size.height - 225;
            self.mySafeKeyboard.frame = rect;
            
           
            
            NSLog(@"%s 显示安全键盘，并设置尺寸%@",__FUNCTION__, NSStringFromCGRect(rect));
        }];
    }
}


/**
 隐藏系统键盘
 */
- (void)hideSystemKeyboard
{
    if (self.preTextField == passwordTextField)
    {
        NSLog(@"%s 密码输入框，隐藏系统键盘",__FUNCTION__);
        NSArray *windows = [[UIApplication sharedApplication] windows];
        UIWindow *keyboard = [windows lastObject];
        keyboard.hidden = YES;
    }else{
        NSLog(@"%s 不是密码输入框 不用隐藏",__FUNCTION__);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        if (textField == passwordTextField)
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                CGRect rect = self.mySafeKeyboard.frame;
                rect.origin.y += 225;
                self.mySafeKeyboard.frame = rect;
            }];
        }
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        if (textField == passwordTextField)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"clearPasswordTextNotification"object:nil];
        }else if(textField == emailTextField){
            passwordTextField.text = @"";
            self.isSavePassword = NO;
            self._check2.checked = NO;
        }
    }
    if(textField == emailTextField){
        passwordTextField.text = @"";
        self.isSavePassword = NO;
        self._check2.checked = NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger strLength = textField.text.length - range.length + string.length;
    NSString *textStr = textField.text;
    if (textField==emailTextField)
    {
        // 首先判断是否支持保存密码
        if ([eCloudConfig getConfig].supportSavePassword) {
            BOOL isExitAccount = NO;
            NSString *accountStr = textStr;
            if ([string isEqualToString:@""] && ![textStr isEqualToString:@""]) {
                accountStr = [textStr substringToIndex:textStr.length-1];
            }else if([string isEqualToString:@""] && [textStr isEqualToString:@""]) {
                accountStr = @"";
            }else{
                accountStr = [NSString stringWithFormat:@"%@%@",emailTextField.text,string];
            }
            NSMutableDictionary *accountInfoDic = [UserDefaults getAccountInfo];
            // 拿出账号密码内容，进行比对
            if (accountInfoDic) {
                for (NSString *accountItemStr in accountInfoDic) {
                    if ([accountItemStr isEqualToString:accountStr]) {
                        passwordTextField.text = [accountInfoDic valueForKey:accountStr];
                        isExitAccount = YES;
                    }
                }
            }else{
                passwordTextField.text = @"";
            }
            
//            UIView *footerView = [loginTable footerViewForSection:0];
//            CheckBoxButton *checkBoxBtn = (CheckBoxButton *)[footerView viewWithTag:1111];
            // 若该账号有对应的密码，则填充密码，否则将密码框清空
            if (isExitAccount) {
                // 将记住密码打上勾
                self.isSavePassword = YES;
                self._check2.checked = YES;
            }else{
                passwordTextField.text = @"";
                self.isSavePassword = NO;
                self._check2.checked = NO;
            }
        }
       return (strLength <= EMAIL_MAXLEN);
    }
    else if(textField==passwordTextField)
    {
        if ([[eCloudConfig getConfig] needFixSecurityGap])
        {
            return NO;
        }
      return (strLength <= PASSWD_MAXLEN);
    }
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_conn = [conn getConn];
	db = [eCloudDAO getDatabase];
    
    UIColor *_color = [UIColor colorWithRed:27/255.0 green:73/255.0 blue:138/255.0 alpha:1];
    [self.navigationController.navigationBar setTintColor:_color];
    // 功能配置项中是否需要显示服务器设置按钮
    if ([[eCloudConfig getConfig]displayServerConfigButton]) {
        // 导航栏右侧显示服务器设置按钮
        [UIAdapterUtil setRightButtonItemWithImageName:@"server_config.png" andTarget:self andSelector:@selector(goToServerConfig:)];        
    }
	
	loginTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:loginTable];
    [loginTable setDelegate:self];
    [loginTable setDataSource:self];
    loginTable.scrollEnabled=NO;
    loginTable.backgroundView = nil;
    loginTable.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:loginTable];
    
    // 点击空白的地方隐藏键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTextField)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)showSeftKeyboard
{
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        if ([passwordTextField isFirstResponder])
        {
            NSLog(@"%s 准备显示安全键盘",__FUNCTION__);
            NSArray *windows = [UIApplication sharedApplication].windows;
            
            for (UIWindow *window in windows)
            {
                NSString *className = [NSString stringWithFormat:@"%@",[window class]];
                if ([className isEqual:@"UIRemoteKeyboardWindow"] && window.hidden == NO)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        window.hidden = YES;
                        NSLog(@"%s 显示安全键盘",__FUNCTION__);
                    });
                    return;
                }
            }
        }
    }
}


/**
 隐藏键盘
 */
- (void)hideTextField
{
    [emailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = self.mySafeKeyboard.frame;
        rect.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.mySafeKeyboard.frame = rect;
        NSLog(@"%s 隐藏安全键盘 现在的frame是%@",__FUNCTION__,NSStringFromCGRect(rect));
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];

    // 根据InfoPlist.strings文件中的CFBundleDisplayName的value值作为title值(南航和泰禾有区别)
	self.title = [StringUtil getAppName];
    
    [loginTable reloadData];
    
    // 根据配置项若为YES 则启用安全键盘
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        // 监听键盘弹出
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSeftKeyboard) name:UIKeyboardWillShowNotification object:nil];
        NSLog(@"%s 接收系统键盘将要显示通知",__FUNCTION__);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(showSeftKeyboard)
                                                     name:UIKeyboardDidShowNotification object:nil];
        NSLog(@"%s 接收系统键盘显示通知",__FUNCTION__);
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
    
    if ([eCloudConfig getConfig].needFixSecurityGap)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        NSLog(@"%s 不再收取 系统键盘 将要显示通知",__FUNCTION__);
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        NSLog(@"%s 不再接收系统键盘弹出通知",__FUNCTION__);
        
        NSLog(@"%d",[self.mySafeKeyboard retainCount]);
        self.mySafeKeyboard.safeKeyBoardDelegate = nil;
        self.mySafeKeyboard = nil;
    }
}


/**
 跳转到服务器连接界面(没有用到)

 @param sender 被点击的按钮对象
 */
-(void)goToServerConfig:(id)sender
{
	ServerConfigViewController	*serverConfig = [[ServerConfigViewController alloc]init];
    [self.navigationController pushViewController:serverConfig animated:YES];
	[serverConfig release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return table_row_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
	cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    
	float labelX = 10;
	float labelY = 0;
	float labelW = 77;
	float labelH = table_row_height;
	
	CGRect _frame = CGRectMake(labelX, labelY, labelW, labelH);
	
	UILabel *titlelabel=[[UILabel alloc]initWithFrame:_frame];
	titlelabel.backgroundColor=[UIColor clearColor];
	[cell.contentView addSubview:titlelabel];
	[titlelabel release];
    
//    passwordTitlelabel=[[UILabel alloc]initWithFrame:_frame];
//	passwordTitlelabel.backgroundColor=[UIColor clearColor];
//	[cell.contentView addSubview:passwordTitlelabel];
//	[passwordTitlelabel release];

    float textX = labelX + labelW + 5;
	float textY = 0;
	float textW = [UIAdapterUtil getTableCellContentWidth] - 25 - textX;
	float textH = table_row_height;
	
	_frame = CGRectMake(textX, textY, textW, textH);
	
	int row = indexPath.row;
	if(row == 0)
	{
		titlelabel.text = [StringUtil getLocalizableString:@"account"];
		
		emailTextField = [[UITextField alloc]initWithFrame:_frame];
		emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        emailTextField.delegate=self;
        emailTextField.keyboardType=UIKeyboardTypeEmailAddress;
        emailTextField.placeholder=[StringUtil getAppLocalizableString:@"input_account"];
        
        emailTextField.text = [UserDefaults getUserAccount];
        [cell.contentView addSubview:emailTextField];
		[emailTextField release];
        
        if ([eCloudConfig getConfig].supportSavePassword) {
            // 获取账号
            BOOL *isSavePwd = NO;
            NSString *accountStr = emailTextField.text;
            NSMutableDictionary *accountInfoDic = [UserDefaults getAccountInfo];
            // 查询
            if (accountInfoDic) {
                for (NSString *accountName in accountInfoDic) {
                    if ([accountName isEqualToString:accountStr]) {
                        isSavePwd = YES;
                    }
                }
            }
            if (isSavePwd) {
                self.isSavePassword = YES;
            }else{
                self.isSavePassword = NO;
            }
        }
	}
	else if(row == 1)
	{
		titlelabel.text = [StringUtil getLocalizableString:@"password"];
        passwordTextField = [[UITextField alloc]initWithFrame:_frame];
		passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		passwordTextField.placeholder=[StringUtil getAppLocalizableString:@"input_password"];
        passwordTextField.delegate=self;
        passwordTextField.secureTextEntry=YES;
        
        if (![eCloudConfig getConfig].needFixSecurityGap) {
            passwordTextField.text = [UserDefaults getUserPassword];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"clearPasswordTextNotification"object:nil];
        }
        
        [cell.contentView addSubview:passwordTextField];
		[passwordTextField release];
	}
	
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return table_header_height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([eCloudConfig getConfig].supportSavePassword) {
        return table_footer_height + 40;
    }
	return table_footer_height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	CGRect viewFrame = CGRectMake(0, 0, tableView.frame.size.width, table_footer_height);
	UIView *_view = [[[UIView alloc]initWithFrame:viewFrame]autorelease];
    
	float btnX = 20;
	float btnY = 10;
	float btnW = viewFrame.size.width - btnX * 2;
	float btnH = 40;
    
    if ([eCloudConfig getConfig].supportSavePassword) {
        self._check2 = [[CheckBoxButton alloc] initWithDelegate:self];
        self._check2.frame = CGRectMake(SCREEN_WIDTH-100, 0, 80, 40);
        [self._check2 setTitle:@"记住密码" forState:UIControlStateNormal];
        [self._check2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self._check2.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        
        if (self.isSavePassword) {
            self._check2.checked = YES;
        }
        [_view addSubview:self._check2];
        self._check2.tag = 1111;
        [self._check2 release];
        btnY += 40;
    }
	
	UIImage *normalImg = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"login_button_new" andType:@"png"]];
//	UIImage *highlightedImg = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"login_button_click" andType:@"png"]];
	
	//	拉伸login图片
	MessageView *messageView = [MessageView getMessageView];
	UIEdgeInsets capInsets = UIEdgeInsetsMake(20,12,18,12);
	normalImg = [messageView resizeImageWithCapInsets:capInsets andImage:normalImg];
//	highlightedImg = [messageView resizeImageWithCapInsets:capInsets andImage:highlightedImg];
	
	CGRect btnFrame = CGRectMake(btnX, btnY, btnW, btnH);
	loginBtn = [[UIButton alloc]initWithFrame:btnFrame];
	
	[loginBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
//	[loginBtn setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
//	[loginBtn setBackgroundImage:highlightedImg forState:UIControlStateSelected];
	[loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[loginBtn setTitle:[StringUtil getLocalizableString:@"login"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
	[_view addSubview:loginBtn];
	[loginBtn release];
	
	return _view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 登录按钮点击事件

 @param sender 被点击按钮对象
 */
-(void)loginAction:(id)sender
{
    // 隐藏键盘
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
	email = emailTextField.text;
	password = passwordTextField.text;
	
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
		[alert release];
		return;
	}
    // 账号内容转小写
	email = [email lowercaseString];
	
    // 获取最后一次登录成功保存的用户账号信息
    NSString *lastUserAccount = [UserDefaults getLastUserAccount];
    if (lastUserAccount.length > 0) {
        // 保存的最后一次登录成功的账号信息与此次登录的账号是否一致
        if (![lastUserAccount isEqualToString:email]) {
            AccessConn *conn = [AccessConn getConn];
            // 若最后一次登录成功的账号信息与此次登录账号信息不一致，代表切换了登录账号
            // 此时要将保存在本地的服务器连接ip、端口、时间进行清空，不允许通过上次的连接信息进行自动连接
            [conn removeLastConnectData];
        }
    }
    // 先将账号、密码信息保存在本地，方便在其他类或通知方法中使用
    [UserDefaults setPassword:password forAccount:email];
    
	if(![ApplicationManager getManager].isNetworkOk)
	{
        // 网络异常
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
        [self performSelector:@selector(login:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:email,@"user_account",password,@"user_password",nil] afterDelay:0.1];
	}
}
//登录采用异步方式 update by shisp

/**
 登录方法

 @param userInfo 存放账号、密码的字典
 */
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
        // 初始化与服务器的连接
        if([_conn initConn])
        {
            // 连接应答的信息中是否有新版本需要升级
            if(_conn.forceUpdate || ([[eCloudConfig getConfig]needShowAlertWhenOptionUpdate] && _conn.hasNewVersion))
            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                     // 根据新版本升级的类别，显示新版本的升级提示框
                     [[ApplicationManager getManager] showVersionAlert:self];
                 });
                return;
            }
            else
            {
                // 通过conn对象调用与服务器通讯的登录接口
                if(![_conn login:email andPasswd:password])
                {
                    // 回到主线程弹出登录失败的提示框
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
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"GSAPassword"];
                    NSLog(@"登录成功");
                }
            }
        }
        else
        {
            // 回到主线程，弹出与服务器连接初始化失败的提示
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [LogUtil debug:@"初始化连接失败"];
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                // 获取服务器连接响应的错误信息
                NSString *errMsg = [AccessConn getConn].errMsg;
//                if ([_errMsg isEqualToString:@"没有找到该账号"] ) {
//                    errMsg = _errMsg;
//                }
                // 若错误信息为nil，为错误信息赋初始值
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

/**
 设置加载框内容
 */
-(void)showIndicator
{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"logining"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];

}
// 无用方法
-(void)goOnLogin
{
    [self showIndicator];
    if(![_conn login:email andPasswd:password])
    {
        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        //				直接提示错误
        NSLog(@"登录命令发送失败");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"login_cmd_send_error"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

/**
 处理登录应答的通知

 @param notification 通知对象
 */
- (void)handleCmd:(NSNotification *)notification
{    
  	eCloudNotification	*cmd = (eCloudNotification *)[notification object];
    
    // 获取通知对象命令类型
	if(cmd.cmdId == login_timeout)  // 登录超时
	{
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];

 		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login"] message:[StringUtil getLocalizableString:@"login_timeout"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:Nil, nil];
		[alert show];
		[alert release];
	}
	else if(cmd.cmdId == login_failure) // 登录失败
	{
        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];

        // 获取通知对象字典内容
		NSDictionary * dic = cmd.info;
        // 获取连接实体对象
		ConnResult *result = [dic objectForKey:@"RESULT"];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"login_fail"] message:[result getResultMsg] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else if(cmd.cmdId == login_success) // 登录成功
	{
        // 根据配置项，判断是否支持保存密码(龙湖不支持保存密码)
        if ([eCloudConfig getConfig].supportSavePassword){
            // 获取账号、密码
            NSString *accountStr = emailTextField.text;
            NSString *passwordStr = passwordTextField.text;
            
            NSMutableDictionary *accountInfoDic = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAccountInfo]];
            if (!accountInfoDic || [accountInfoDic allKeys].count == 0) {
                accountInfoDic = [[NSMutableDictionary alloc]init];
            }
            if (self.isSavePassword) {
                [accountInfoDic setObject:passwordStr forKey:accountStr];
            }else{
                [accountInfoDic removeObjectForKey:accountStr];
            }
            // 保存账号、密码信息
            [UserDefaults saveAccountInfo:accountInfoDic];
        }

        _NewLoginViewController->goToMainView(self);

        [[LCLLoadingView currentIndicator]hiddenForcibly:YES];

	}
}

//-(void)goToMainView
//{
//	mainViewController *mainView = [[mainViewController alloc]init];
//	[self.navigationController pushViewController:mainView animated:YES];
//	[mainView release];
//}

#pragma mark - UIAlertViewDelegate的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 如果有强制升级或者可选升级，进行如下处理
    if (alertView.tag == FORCE_UPDATE_ALERT_TAG || (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 1 ))
    {
        _conn.connStatus = not_connect_type;
        
        [LogUtil debug:[NSString stringWithFormat:@"强制升级 或者 可选升级，打开升级页面"]];
        // 获取新版本的下载url，进行下载操作
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_conn.updateUrl]];
        if ([_conn.updateUrl hasPrefix:@"itms-services://"]) {
            //            ios8下 用户选择安装新版本后，系统不会自动退出，所以进行以下处理
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 0)   // 可选升级，用户选择了"以后再说"按钮
    {
        [LogUtil debug:[NSString stringWithFormat:@"可选升级，用户选择了以后再说，那么继续登录"]];
        
        [self showIndicator];
        
        // 连接状态变为  链接中
        _conn.connStatus = linking_type;
        // 进行登录操作
        if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
        {
            // 登录失败，连接状态改为  未连接
            _conn.connStatus = not_connect_type;
        }
    }
    [ApplicationManager getManager].versionAlert = nil;
}
#pragma mark - 复选框代理方法
- (void)didSelectedCheckBox:(CheckBoxButton *)checkbox checked:(BOOL)checked {
    NSLog(@"did tap on CheckBox:%@ checked:%d", checkbox.titleLabel.text, checked);
    if (checked) {
        self.isSavePassword = YES;
    }else{
        self.isSavePassword = NO;
    }
}

#pragma mark ====横屏===
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
//    如果是ipad才支持横屏
    if (IS_IPAD) {
        //    重新设置table frame
        CGRect _frame = loginTable.frame;
        _frame.size.width = SCREEN_WIDTH;
        _frame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
        loginTable.frame = _frame;
        
        //    重新设置loginBtn frame
        _frame = loginBtn.frame;
        _frame.size.width = [UIScreen mainScreen].bounds.size.width - 2 * _frame.origin.x;
        loginBtn.frame = _frame;
        
        //    重新设置textfiled frame
        _frame = emailTextField.frame;
        _frame.size.width = [UIAdapterUtil getTableCellContentWidth] - 25 - _frame.origin.x;
        
        emailTextField.frame = _frame;
        passwordTextField.frame = _frame;
    }
}

// New Autorotation support.
//- (BOOL)shouldAutorotate
//{
//    if (IS_IPAD) {
//        return YES;
//    }
//    return NO;
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    if (IS_IPAD) {
//        return UIInterfaceOrientationMaskAll;
//    }
//    return UIInterfaceOrientationMaskPortrait;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    if (IS_IPAD) {
//        return UIInterfaceOrientationLandscapeLeft;
//    }
//    return UIInterfaceOrientationPortrait;
//}

@end
