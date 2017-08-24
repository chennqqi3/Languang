//
//  loginViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-21.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "loginViewController.h"
#import "eCloudDAO.h"
#import "ApplicationManager.h"
#import "ConnResult.h"
@interface loginViewController ()

@end

@implementation loginViewController
{
	eCloudDAO *db;
}
@synthesize scrollview;
@synthesize emailTextField;
@synthesize passwordTextField;
@synthesize backgroundButton;
@synthesize email = _email;
@synthesize passwd = _passwd;
@synthesize loginButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_conn = [conn getConn];
	db = [eCloudDAO getDatabase];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 30, 30);
	[button setBackgroundImage:[UIImage imageNamed:@"server_config.png"] forState:UIControlStateNormal];
	[button setBackgroundImage:[UIImage imageNamed:@"server_config_click.png"] forState:UIControlStateHighlighted];
	[button setBackgroundImage:[UIImage imageNamed:@"server_config_click.png"] forState:UIControlStateSelected];
	
	[button addTarget:self action:@selector(goToServerConfig:) forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:button]autorelease];
	
	self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];

	loginTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 120) style:UITableViewStyleGrouped];
   
//    loginTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 320, 120) style:UITableViewStyleGrouped];
    [loginTable setDelegate:self];
    [loginTable setDataSource:self];
    loginTable.scrollEnabled=NO;
    loginTable.backgroundView = nil;
    loginTable.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:loginTable];
   
    

    
	int imageH = 480;
	if(iPhone5)
	{
		imageH = imageH + i5_h_diff;
	}
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0&&imageH>480) {
        loginTable.frame=CGRectMake(0, 60, 320, 120);
        self.loginButton.frame=CGRectMake(self.loginButton.frame.origin.x, 200, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
    }
    
//    loginImageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, -20, 320, imageH)];
//	
//	if(iPhone5)
//	{
//		loginImageview.image=[UIImage imageNamed:@"Default-568h@2x.png"];		
//	}
//	else
//	{
//		loginImageview.image=[UIImage imageNamed:@"Default@2x.png"];		
//	}
//    
//    [self.navigationController setNavigationBarHidden:YES];
//    [self.view addSubview:loginImageview];
//    [self autoLogin];
    
}
-(void)handleLogin
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];
	[self.navigationController setNavigationBarHidden:NO];
	loginImageview.hidden=YES;
//	[self.emailTextField becomeFirstResponder];
}

-(void)autoLogin
{
    NSLog(@"%s",__FUNCTION__);
    
	if(![ApplicationManager getManager].isNetworkOk)
	{
        [self.navigationController setNavigationBarHidden:NO];
       
        loginImageview.hidden=YES;
        [self.emailTextField becomeFirstResponder];
        
        return;
	}
	else
	{

        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        NSString* username=[accountDefaults objectForKey:@"username"];
        NSString* userpw=[accountDefaults objectForKey:@"password"];
        self.email=username;
        self.passwd=userpw;
		
        NSLog(@"email is %@ ,passwd is %@",username,userpw);

        
        NSString	*errorMessage	=	nil;
        /****判断注册帐号是否合法*****/
        if(nil == self.email
           || [self.email length] <= 0)
        {
            errorMessage	=	@"账号为空";
        }
        // add by shisp
        //	else if([self.email length] > 50)
        //	{
        //		errorMessage	=	@"账号最大长度50位";
        //	}
        
        /****判断是否输入验证码*****/
        else if(nil == self.passwd
                || [self.passwd length] <= 0)
        {
            
            //		email = @"liuyong@sxit.com.cn";
            
            errorMessage	=	@"密码不能为空";
        }
        //add by shisp
        //	else if([self.passwd length] > 20)
        //	{
        //		errorMessage	=	@"密码长度最大20位";
        //
        //	}
        
        if(errorMessage)
        {
            
            [self.navigationController setNavigationBarHidden:NO];
            
            loginImageview.hidden=YES;
           [self.emailTextField becomeFirstResponder];
            return;
        }
        
        self.email = [self.email lowercaseString];
        /**提示框**/
        [[LCLLoadingView currentIndicator]setCenterMessage:@"正在登录..."];
        [[LCLLoadingView currentIndicator]showSpinner];
        [[LCLLoadingView currentIndicator]show];

    // [self performSelector:@selector(ssoLoginAction) withObject:nil afterDelay:0.1];
      [self performSelector:@selector(login) withObject:nil afterDelay:0.1];//公司帐户使用
        
		
	}


}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}
NSString* urlEncode(NSString* unencodeString) {
    NSString * encodedString = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)unencodeString,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
    return encodedString;
}
-(void)ssoLoginAction
{
    
    self.email = self.emailTextField.text;
	self.passwd = self.passwordTextField.text;
    
   NSString *urlString = @"http://ssoii.csair.com/siteminderagent/forms/login/login.fcc?TYPE=33554433&REALMOID=06-483cc0ef-e5ff-447e-ba80-c3cee3b38c4e&GUID=&SMAUTHREASON=0&METHOD=GET&SMAGENTNAME=-SM-pzaN%2bJfnBs8RBKGiQjcuBeuvFM4D0Em8R%2bfrtBNCX4lLRfY0ui%2fdx39lKZWzGtxt&TARGET=-SM-http%3a%2f%2fqysso%2ecsair%2ecom%2flogin%2easpx";
    

   ssorequest=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
   // ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
   // NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
  //  [request setURL:[NSURL URLWithString:urlString]];
    
    [ssorequest setDelegate:self];
    [ssorequest setRequestMethod:@"POST"];
    [ssorequest addRequestHeader:@"Accept-Language" value:@"zh-CN"];
    [ssorequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [ssorequest addRequestHeader:@"Accept" value:@"text/html, application/xhtml+xml, */*"];
    [ssorequest addRequestHeader:@"Connection" value:@"keep-alive"];
    [ssorequest addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    [ssorequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"];
    [ssorequest addRequestHeader:@"Referer" value:urlString];
    [ssorequest addRequestHeader:@"Host" value:@"ssoii.csair.com" ];
    [ssorequest addRequestHeader:@"Cache-Control" value:@"no-cache"];
  //  [request addRequestHeader:@"Set-Cookie" value:@""];
    //--传参数--
   
    NSString * post = [[NSString alloc] initWithFormat:@"SMENC=%@&SMLOCALE=%@&USER=%@&PASSWORD=%@&smauthreason=0&smagentname=%@&postpreservationdata=&target=%@", @"ISO-8859-1", @"US-EN", urlEncode(self.email),urlEncode(self.passwd),urlEncode(@"pzaN+JfnBs8RBKGiQjcuBeuvFM4D0Em8R+frtBNCX4lLRfY0ui/dx39lKZWzGtxt"),urlEncode(@"http://qysso.csair.com/login.aspx")];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSLog(@"----email--%@-----passwd---%@",self.email,self.passwd);
    [ssorequest setPostBody:(NSMutableData*)postData];
    [ssorequest setUseSessionPersistence:NO];
    [ssorequest setDidFinishSelector:@selector(startGetCookieFromSSO:)];
   // [ssorequest setDidReceiveResponseHeadersSelector:@selector(startGetCookieFromSSO:)];
    [ssorequest setDidFailSelector:@selector(failGetCookieFromSSO:)];
    [ssorequest setTimeOutSeconds:30];
    [ssorequest startAsynchronous];
    [post release];
    [ssorequest release];
    NSLog(@"--0000000---startSynchronous");
 //   if (!initConnBool) {
   initConnBool=[_conn initConn];
 //   }
    
}

-(void)startGetCookieFromSSO:(ASIHTTPRequest*)request
{
    [request clearDelegatesAndCancel];
    NSError *error = [request error];
    NSString* cookieValue;
    if (!error)
    {
        NSDictionary *dictionary = [request responseHeaders];
        int statuscode=[request responseStatusCode];NSLog(@"--21111111--statuscode----%d",statuscode);
        if (statuscode==200||statuscode==302){
            cookieValue=[dictionary objectForKey:@"Set-Cookie"]; 
            NSLog(@"-----cookieValue----%@",cookieValue);
            if (cookieValue!=nil&&cookieValue.length>0) {
                [self login];
                NSRange range=[cookieValue rangeOfString:@"SMSESSION"];
                cookieValue=[cookieValue substringFromIndex:range.location];
                NSLog(@"--2222222---cookieValue----%@",cookieValue);
                
                NSString*  urlString = @"http://qysso.csair.com/login.aspx";
                
                ASIHTTPRequest *requestOther=[[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
                [requestOther setDelegate:self];
                [requestOther setRequestMethod:@"POST"];
                [requestOther addRequestHeader:@"Accept-Language" value:@"zh-CN"];
                [requestOther addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
                [requestOther addRequestHeader:@"Accept" value:@"text/html, application/xhtml+xml, */*"];
                [requestOther addRequestHeader:@"Accept-Encoding" value:@"gzip, deflate"];
                [requestOther addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"];
                [requestOther addRequestHeader:@"Host" value:@"qysso.csair.com" ];
                [requestOther addRequestHeader:@"Cache-Control" value:@"no-cache"];
                [requestOther addRequestHeader:@"Cookie" value:cookieValue];
                [requestOther setDidFinishSelector:@selector(saveCookieFromSSO:)];
                [requestOther setDidFailSelector:@selector(failCookieFromSSO:)];
                [requestOther setTimeOutSeconds:30];
                [requestOther setUseSessionPersistence:NO];
                [requestOther startAsynchronous];
                [requestOther release];
                //[requestOther startSynchronous];
            }else
            {
                [[LCLLoadingView currentIndicator]hiddenForcibly:true];
                [self.navigationController setNavigationBarHidden:NO];
                loginImageview.hidden=YES;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"SSO认证失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }

            
        }else
        {
            [[LCLLoadingView currentIndicator]hiddenForcibly:true];
            [self.navigationController setNavigationBarHidden:NO];
            loginImageview.hidden=YES;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"SSO认证失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
    }
      
}
-(void)failGetCookieFromSSO:(ASIHTTPRequest*)request
{
    NSError *error = [request error];
    NSLog(@"-error-failGetCookieFromSSO---%@",error.localizedDescription);
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
    [self.navigationController setNavigationBarHidden:NO];
    
    loginImageview.hidden=YES;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"SSO认证失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
-(void)saveCookieFromSSO:(ASIHTTPRequest*)request
{  
     NSError *error = [request error];
    if (!error)
    {
        NSDictionary *dictionary = [request responseHeaders];
        int statuscode=[request responseStatusCode];
        
        NSLog(@"-－33333-----------second----%d",statuscode);
        if (statuscode==200) {
            // NSLog(@"--requestOther---dictionary----%@",[dictionary description]);
            NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
            NSString* SM_USER=[dictionary objectForKey:@"SM_USER"];
            NSString* SM_KEY=[dictionary objectForKey:@"SM_KEY"];
            
            if (SM_USER!=nil) {
                [accountDefaults setObject:SM_USER forKey:@"SM_USER"];
            }
            if (SM_KEY!=nil) {
                [accountDefaults setObject:SM_KEY forKey:@"SM_KEY"];
            }
            
            NSLog(@"-－444444444－qysso.csair.com--statuscode--%d --SM_USER-%@---SM_KEY-%@",statuscode,SM_USER,SM_KEY);
        }
        
    }
   
}

-(void)failCookieFromSSO:(ASIHTTPRequest*)request
{
    NSError *error = [request error];
    NSLog(@"-error-failCookieFromSSO---%@",error.localizedDescription);
}
-(IBAction)loginAction:(id)sender
{
    
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];

	self.email = emailTextField.text;
	self.passwd = passwordTextField.text;
	
//	NSLog(@"email is %@ ,passwd is %@",email,passwd);

	NSString	*errorMessage	=	nil;
	/****判断注册帐号是否合法*****/
	if(nil == self.email
	   || [self.email length] <= 0)
	{
		errorMessage	=	@"账号为空";
	}
	// add by shisp
//	else if([self.email length] > 50)
//	{
//		errorMessage	=	@"账号最大长度50位";
//	}
	
	/****判断是否输入验证码*****/
	else if(nil == self.passwd
			|| [self.passwd length] <= 0)
	{

//		email = @"liuyong@sxit.com.cn";

		errorMessage	=	@"密码不能为空";
	}	
	//add by shisp
//	else if([self.passwd length] > 20)
//	{
//		errorMessage	=	@"密码长度最大20位";
//
//	}
	
	if(errorMessage)
	{
		UIAlertView	*alert	=	[[UIAlertView alloc]initWithTitle:@"登录" 
													   message:errorMessage
													  delegate:nil 
											 cancelButtonTitle:@"确定" 
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	self.email = [self.email lowercaseString];
	
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
 //   NSString* username=[accountDefaults objectForKey:@"username"];
 //   NSString* userpw=[accountDefaults objectForKey:@"password"];
    [accountDefaults setObject:self.email forKey:@"username"];
    [accountDefaults setObject:self.passwd forKey:@"password"];
	//				登录提示框
	/**提示框**/
	[[LCLLoadingView currentIndicator]setCenterMessage:@"正在登录..."];
	[[LCLLoadingView currentIndicator]showSpinner];
	[[LCLLoadingView currentIndicator]show];

	if(![ApplicationManager getManager].isNetworkOk)
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];	
	}
	else 
	{      NSLog(@"-----------------------------------------------ssoLoginAction--begin");
       
      //[self performSelector:@selector(ssoLoginAction) withObject:nil afterDelay:1];
     [self performSelector:@selector(login) withObject:nil afterDelay:0.1];//公司帐户使用
		
	}
}

- (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    return destDate;
    
}
-(BOOL)compareDateWithNow
{
    NSDate *nowdate=[[NSDate alloc]init];
    NSString *outdateStr=@"2013-05-15 12:00:00";
    NSDate *outdate=[self dateFromString:outdateStr];
    NSDate *returndate=[nowdate earlierDate:outdate];
    BOOL late=[nowdate isEqualToDate:returndate];
    
    return late;
}
-(void)login
{
//     BOOL isCanGo=[self ssoLoginAction];
//   //  isCanGo=[self compareDateWithNow];//设置期限范围内可用
//    if (!isCanGo) {
//        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
//        [self.navigationController setNavigationBarHidden:NO];
//        
//        loginImageview.hidden=YES;
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"SSO认证失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
//        return;
//    }
    initConnBool=[_conn initConn];//公司帐户使用
    //[self ssoLoginAction];
	if(initConnBool)
	{
		eCloudUser *_eCloudUser = [eCloudUser getDatabase];
		NSString *localVersion = [_eCloudUser getVersion:app_version_type];
		if([localVersion compare:_conn.updateVersion] == NSOrderedAscending)
		{
			NSLog(@"--_conn.updateVersion-: %@ ---localVersion :%@",_conn.updateVersion,localVersion);
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
			NSLog(@"需要升级");
			if(_conn.updateFlag == 0)
			{
				[self.navigationController setNavigationBarHidden:NO];
                
                loginImageview.hidden=YES;
				NSLog(@"可选升级");	
				UIAlertView *alertVersion	=	[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"飞信有新版本了" delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"现在更新", nil];
				alertVersion.tag = 0;
				[alertVersion show];
				
				[alertVersion release];
				
				return;
			}
			else 
			{
				NSLog(@"强制升级");
                [self.navigationController setNavigationBarHidden:NO];
                
                loginImageview.hidden=YES;
				UIAlertView *alertVersion	=	[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"飞信有新版本了" delegate:self cancelButtonTitle:nil otherButtonTitles:@"现在更新", nil];
				alertVersion.tag = 1;
				[alertVersion show];
				[alertVersion release];
				return;
			}
		}
		else
		{
			NSLog(@"不用升级");
			
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
			
			if(![_conn login:self.email andPasswd:self.passwd])
			{
				[[NSNotificationCenter defaultCenter]removeObserver:self name:LOGIN_NOTIFICATION object:nil];
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				//				直接提示错误
				NSLog(@"登录命令发送失败");
                [self.navigationController setNavigationBarHidden:NO];
               
                loginImageview.hidden=YES;
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录命令发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
			
		}
	}
	else 
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
		
		//			直接提示错误
		NSLog(@"链接错误");
        [self.navigationController setNavigationBarHidden:NO];
        
        loginImageview.hidden=YES;
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录失败,请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _conn.isclickedUpdate=false;
  //  NSString *updatestr=@"itms-services://?action=download-manifest&url=http://qyfile.csair.com/eCloud.plist";
	if(alertView.tag == 0)
	{
		if(buttonIndex == 0)
		{
			NSLog(@"以后再说，那么继续登录");
			
			[[LCLLoadingView currentIndicator]setCenterMessage:@"正在登录..."];
			[[LCLLoadingView currentIndicator]show];
			
			//				登录命令执行成功后，可以增加接收通知
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];

			if(![_conn login:self.email andPasswd:self.passwd])
			{
				[[NSNotificationCenter defaultCenter]removeObserver:self name:LOGIN_NOTIFICATION object:nil];

				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				//				直接提示错误
				NSLog(@"登录命令发送失败");
				UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录命令发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
			}
		}
		else 
		{
			NSLog(@"打开升级页面");
            _conn.isclickedUpdate=true;
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:_conn.updateUrl]];
           // 	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:updatestr]];
          
           

		}
	}
	else if(alertView.tag == 1)
	{
		if(buttonIndex == 0)
		{
			NSLog(@"强制升级，打开页面");
            _conn.isclickedUpdate=true;
			[[UIApplication sharedApplication]openURL:[NSURL URLWithString:_conn.updateUrl]];
            //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:updatestr]];
                       
		}
	}
}
-(IBAction)helpAction:(id)sender
{
    if (aboutController==nil) {
        aboutController=[[aboutViewController alloc]init];
        
    }
    self.navigationController.navigationBar.hidden=NO;
    
    
    [self.navigationController pushViewController:aboutController animated:YES];
    aboutController.navigationController.navigationBar.topItem.title=@"关于飞信";
     
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
        return 2;    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 45;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        UITextField *inputField=[[UITextField alloc]initWithFrame:CGRectMake(10+50, 10, 280-50, 40)];
//        inputField.backgroundColor=[UIColor clearColor];
//        inputField.tag=1;
//        inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
//        [cell.contentView addSubview:inputField];
//        [inputField release];
        
        UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 50, 40)];
        titlelabel.backgroundColor=[UIColor clearColor];
        titlelabel.tag=2;
        [cell.contentView addSubview:titlelabel];
        [titlelabel release];

        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    if (indexPath.row==0) {
        if (self.emailTextField==nil) {
           self.emailTextField=[[UITextField alloc]initWithFrame:CGRectMake(10+50, 10, 280-50, 40)];  
        }
        self.emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.emailTextField.keyboardType=UIKeyboardTypeEmailAddress;
        self.emailTextField.placeholder=@"请输入工号";//@"请输入邮箱";
        [cell.contentView addSubview:self.emailTextField];
      // [self.emailTextField becomeFirstResponder];
        
        UILabel *userlabel=(UILabel *)[cell viewWithTag:2];
        userlabel.text=@"帐号:";
    }else
    {
        if (self.passwordTextField==nil) {
            self.passwordTextField=[[UITextField alloc]initWithFrame:CGRectMake(10+50, 10, 280-50, 40)];
        }
         self.passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //self.passwordTextField=( UITextField *)[cell viewWithTag:1];
       self.passwordTextField.placeholder=@"请输入密码";
        self.passwordTextField.secureTextEntry=YES;
        [cell.contentView addSubview:self.passwordTextField];
		//[passwordTextField setText:@"111111"];
         UILabel *passwordlabel=(UILabel *)[cell viewWithTag:2];
         passwordlabel.text=@"密码:";
    }
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    NSString* username=[accountDefaults objectForKey:@"username"];
    NSString* userpw=[accountDefaults objectForKey:@"password"];
    self.emailTextField.text=username;
    self.passwordTextField.text=userpw;
   

    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 18;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
 
}
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//
//    return 60;
//
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    if (section==0) {
//        UIView *tempview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
//        UILabel *titilelabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 80)];
//        titilelabel.numberOfLines=0;
//        titilelabel.backgroundColor=[UIColor clearColor];
//        titilelabel.text=@"如果你要关闭或开启微信的新消息通知，请在iPhone的“设置”－“通知”功能中，找到应用程序“微信”进行更改";
//        titilelabel.textAlignment=UITextAlignmentCenter;
//        titilelabel.textColor=[UIColor grayColor];
//        titilelabel.font=[UIFont systemFontOfSize:14];
//        [tempview addSubview:titilelabel];
//        return tempview;
//    }else
//    {
//        return nil;
//    }
//    
//}


-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
   //  initConnBool=[_conn initConn];
	//监听
	
}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)handleCmd:(NSNotification *)notification
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:YES];

  	eCloudNotification	*cmd	 =	(eCloudNotification *)[notification object];
	if(cmd.cmdId == login_timeout)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];

        [self.navigationController setNavigationBarHidden:NO];
        _conn.userStatus = status_offline;
        [db updateUserStatus:_conn.userId andStatus:status_offline];
        loginImageview.hidden=YES;
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:Nil, nil];
		[alert show];
		[alert release];
	}
	else if(cmd.cmdId == login_failure)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];

		[self.navigationController setNavigationBarHidden:NO];
        _conn.userStatus = status_offline;
        [db updateUserStatus:_conn.userId andStatus:status_offline];
        loginImageview.hidden=YES;
		NSDictionary * dic = cmd.info;
		ConnResult *result = [dic objectForKey:@"RESULT"];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:[result getResultMsg] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else if(cmd.cmdId == login_success)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];

		if (userChoose==nil) {
			userChoose=[[userChooseViewController alloc]initWithNibName:@"userChooseViewController" bundle:nil];
		}
    
		self.navigationController.navigationBar.hidden=YES;
		[self.navigationController pushViewController:userChoose animated:YES];
         //
        [self performSelector:@selector(hiddenImage) withObject:nil afterDelay:1];
		
		[[eCloudDAO getDatabase]updateSendFlagToUploadFailIfUploading];
	}
}
-(void)hiddenImage
{
   [self.navigationController setNavigationBarHidden:NO];
   self.navigationController.navigationBar.hidden=YES;
    loginImageview.hidden=YES;
}
-(void)goToServerConfig:(id)sender
{
	if(serverConfig == nil)
		serverConfig = [[ServerConfigViewController alloc]init];
//	serverConfig.navigationController.navigationBar.topItem.title=@"服务器设置";

	[self.navigationController pushViewController:serverConfig animated:YES];
}
@end
