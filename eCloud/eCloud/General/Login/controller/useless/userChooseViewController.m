//
//  userChooseViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "userChooseViewController.h"
#import "LCLLoadingView.h"
#import "ASIFormDataRequest.h"
#import "loginViewController.h"
#import "eCloudDAO.h"
#import "StringUtil.h"
#import "Emp.h"

#import "eCloudDefine.h"

@interface userChooseViewController ()

@end

@implementation userChooseViewController
{
	eCloudDAO *_ecloud ;
}
@synthesize nameLabel;
@synthesize emp;
@synthesize backgoundLabel;
@synthesize iconImageView;
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
	
	if(iPhone5)
	{
		CGRect _infoFrame = self.infoButton.frame;
		_infoFrame.origin.y = _infoFrame.origin.y + i5_h_diff;
		[self.infoButton setFrame:_infoFrame];
	}
	_conn = [conn getConn];
	_ecloud = [eCloudDAO getDatabase];
	
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 30);

     //    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateHighlighted];
   
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
  

    backgoundLabel.backgroundColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
    [self part1Action:nil];//直接进入
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    // 没有连接通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(noConnect:) name:NO_CONNECT_NOTIFICATION object:nil];

	self.navigationController.navigationBarHidden = NO;
	isExit = false;
 	
    self.emp=[_ecloud getEmpInfo:_conn.userId];//获取人员详细信息
    
    nameLabel.text=self.emp.emp_name;
     
    if (self.emp.emp_logo == nil || self.emp.emp_logo.length == 0)
	{
    	[self setDefaultLogo];
    }
	else        
    {
		NSString* picpath = [StringUtil getLogoFilePathBy:_conn.userId andLogo:self.emp.emp_logo];
        UIImage *img = [UIImage imageWithContentsOfFile:picpath];
        if (img==nil) {
			[self setDefaultLogo];
			
              NSString *urlstr=[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getLogoFileDownloadUrl],self.emp.emp_logo];
            //初始下载路径
            NSURL *url = [NSURL URLWithString:urlstr];
            //设置下载路径
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];//[[ASIHTTPRequest alloc] initWithURL:url];
            //设置ASIHTTPRequest代理
            request.delegate = self;
            //初始化保存ZIP文件路径
            NSString *savePath =picpath;
            //初始化临时文件路径
            //  NSString *tempPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"temp/book_%d.zip.temp",[sender tag]]];
            //设置文件保存路径
            [request setDownloadDestinationPath:savePath];
            [request setDidFinishSelector:@selector(requestCommitDownloadDone:)];
            [request setDidFailSelector:@selector(requestCommitDownloadWrong:)];
            
            [request startAsynchronous];
        }
		else
		{
            iconImageView.image= [UIImage createRoundedRectImage:img size:CGSizeMake(small_user_logo_size, small_user_logo_size)];
        }
  
    }
    //下载大图
    NSString *bigLogoPath = [StringUtil getBigLogoFilePathBy:_conn.userId andLogo:self.emp.emp_logo];
    if(![[NSFileManager defaultManager]fileExistsAtPath:bigLogoPath])
    {
        dispatch_queue_t queue;
        queue = dispatch_queue_create("download.bigpic", NULL);
        dispatch_async(queue, ^{
            NSURL *bigurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[[[eCloudUser getDatabase]getServerConfig]getBigLogoFileDownloadUrl],self.emp.emp_logo]];
            NSData *BigImageData = [NSData dataWithContentsOfURL:bigurl];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (BigImageData!=nil) {
                    [BigImageData writeToFile:bigLogoPath atomically:YES];
                }
            });
            
            
        });
        
    }
}
-(void)setDefaultLogo
{
	if (self.emp.emp_sex==0)
	{//女
		iconImageView.image = [UIImage imageNamed:@"female.png"];
	}else
	{
		iconImageView.image=[UIImage imageNamed:@"male.png"];
	}
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:OFFLINE_NOTIFICATION object:nil];
      [[NSNotificationCenter defaultCenter]removeObserver:self name:NO_CONNECT_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
}
-(void)noConnect:(NSNotification *)notification
{
 	//[self performSelectorOnMainThread:@selector(stopLinking) withObject:nil waitUntilDone:YES];
}

- (void)notifyMessage:(NSDictionary *)message
{
	[self performSelectorOnMainThread:@selector(sendNotificationMessage:)  withObject:message waitUntilDone:YES];
}

- (void)sendNotificationMessage:(NSDictionary *)message
{
	[[NSNotificationCenter defaultCenter ]postNotificationName:notificationName object:notificationObject userInfo:message];
}

-(void)handleCmd:(NSNotification *)notification
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:true];
//    self.navigationController.navigationBar.hidden=NO;
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
			case get_user_info_success:
			{
				NSLog(@"get user info success");
				NSString* empId = [_notification.info objectForKey:@"EMP_ID"];
				Emp *newemp = [_ecloud getEmpInfo:empId];
                userInfo.titleStr=self.emp.emp_name;
                userInfo.emp=newemp;
                
                self.navigationController.navigationBar.hidden=NO;
                
                userInfo.navigationController.navigationBar.topItem.title=@"个人信息";
                                   
                    
                [self.navigationController pushViewController:userInfo animated:YES];
              				
			}
				break;
			case get_user_info_timeout:
			{
				NSLog(@"get user info timeout ......");
//                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"处理失败timeout" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
//                [alert release];
				//[self.navigationController pushViewController:userInfo animated:YES];
				
			}
				break;

			case get_user_info_failure:
			{
				NSLog(@"get user info failure");
//				UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"处理失败failure" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
//                [alert release];
				
				// [self.navigationController pushViewController:userInfo animated:YES];
				
			}
				break;
			case user_offline:
			{
				if(isExit)
				{
					_conn.userStatus = status_exit;
					//				设置用户状态为离线
					[_ecloud updateUserStatus:_conn.userId andStatus:status_exit];
					
					self.navigationController.navigationBar.hidden=NO;
					[self.navigationController popViewControllerAnimated:YES];
					
				}
				else
				{
					_conn.userStatus = status_offline;
					//				设置用户状态为离线
					[_ecloud updateUserStatus:_conn.userId andStatus:status_offline];
				}
				
			}
				break;
			default:
				break;
		}
		
	}
}

- (void)viewDidUnload
{
	[self setInfoButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==tipAlert) {
        if (buttonIndex==0) {
           	if(_conn.userStatus == status_online)
            {   
                isExit = true;
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setBool:YES  forKey:@"isExit"];
//                [[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
//                [[LCLLoadingView currentIndicator]show];
                [_conn logout:1];
                self.navigationController.navigationBar.hidden=NO;
//				for(UIViewController *_controller in self.navigationController.viewControllers)
//				{
//					NSLog(@"%@",_controller);
//				}
//				update by shisp 6.27 点击退出按钮，有时需要pop两次才能到登录界面
				[self.navigationController popToRootViewControllerAnimated:YES];
//                [self.navigationController popViewControllerAnimated:YES];
//                if(![_conn logout])
//                {
//                    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
//                   
//                    self.navigationController.navigationBar.hidden=NO;
//                   // [self.navigationController setNavigationBarHidden:NO];
//                    [self.navigationController popViewControllerAnimated:YES];
//                    
//                    //			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"企云" message:@"退出指令发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                    //			[alert show];
//                    //			[alert release];
//                }

            }else
            {  
                self.navigationController.navigationBar.hidden=NO;
                [self.navigationController popViewControllerAnimated:YES];
                

            }
        }
    }
}

-(IBAction)exitAction:(id)sender
{
    if (tipAlert==nil) {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:[StringUtil getLocalizableString:@"cancel"], nil];
        
    }
    [tipAlert show];
    
 }
-(IBAction)infoAction:(id)sender{
 
    if (userInfo==nil) {
        userInfo=[[userInfoViewController alloc]init];
    }

    userInfo.titleStr=self.emp.emp_name;
    userInfo.emp=self.emp;
     
     userInfo.navigationController.navigationBar.topItem.title=@"个人信息";
    if(self.emp.info_flag)
	{
        
        self.navigationController.navigationBar.hidden=NO;
        [self.navigationController pushViewController:userInfo animated:YES];
       
	}
	else
	{   
		NSLog(@"需要从服务器端取数据");
		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
		[[LCLLoadingView currentIndicator]showSpinner];
		[[LCLLoadingView currentIndicator]show];
		bool ret = [_conn getUserInfo:self.emp.emp_id];
		if(!ret)
		{
            self.navigationController.navigationBar.hidden=NO;
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
            [self.navigationController pushViewController:userInfo animated:YES];
		}
	}
    
}
-(IBAction)part1Action:(id)sender{
  
    mainview=[[mainViewController alloc]init];
   
   [self.navigationController pushViewController:mainview animated:YES];
	
	[mainview release];
}
-(IBAction)part2Action:(id)sender{
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    NSString* SM_USER=[accountDefaults objectForKey:@"SM_USER"];
    NSString* SM_KEY=[accountDefaults objectForKey:@"SM_KEY"];
     NSString *urlString=[NSString stringWithFormat:@"http://qysso.csair.com/sso.aspx?smuser=%@&key=%@&target=ipad",SM_USER,SM_KEY];
    NSLog(@"---urlString---%@",urlString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}
-(IBAction)helpAction:(id)sender
{
    if (aboutController==nil) {
        aboutController=[[aboutViewController alloc]init];
        
    }
    self.navigationController.navigationBar.hidden=NO;
    
    
    [self.navigationController pushViewController:aboutController animated:YES];
    aboutController.navigationController.navigationBar.topItem.title=[NSString stringWithFormat:@"关于%@",[StringUtil getAppName]];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//从网络返回数据成功
- (void)requestCommitDownloadDone:(ASIHTTPRequest *)request {
    
    UIImage *img = [UIImage imageWithContentsOfFile:[request downloadDestinationPath]];
    if (img==nil)
	{
    	[self setDefaultLogo];
    }
	else
	{
		iconImageView.image= [UIImage createRoundedRectImage:img size:CGSizeMake(small_user_logo_size,small_user_logo_size)];
	}
 }

//从网络返回数据失败
- (void)requestCommitDownloadWrong:(ASIHTTPRequest *)request {
    
    NSError *error = [request error];
	NSLog(@"%@" , error.localizedDescription);
//    UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"头像下载失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//    [alertView show];
//    [alertView release];
}
- (void)dealloc {
	[_infoButton release];
	[super dealloc];
}
@end
