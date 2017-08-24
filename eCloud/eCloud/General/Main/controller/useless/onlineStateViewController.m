#import "onlineStateViewController.h"
#import "eCloudDAO.h"
#import "ConnResult.h"
#import "eCloudUser.h"
#import "UserInfo.h"
#import "defineReplyViewController.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "eCloudDefine.h"

@interface onlineStateViewController ()

@end

@implementation onlineStateViewController
{
	eCloudDAO *db;

}
@synthesize userid;
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
	self.userid=_conn.userId;
    userinfo = [[eCloudUser getDatabase]searchUserObjectByUserid:self.userid];
	[onlineTable reloadData];

//	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:USERCHANGESTATUS_NOTIFICATION object:nil];
	//监听
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
	//监听离线通知
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:OFFLINE_NOTIFICATION object:nil];


}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LOGIN_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:OFFLINE_NOTIFICATION object:nil];
}

#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
	[[LCLLoadingView currentIndicator]hiddenForcibly:true];
	
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	
	switch (cmd.cmdId) {
		case login_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:Nil, nil];
			[alert show];
			[alert release];
		}
			break;
		case login_failure:
		{
			NSDictionary * dic = cmd.info;
			ConnResult *result = [dic objectForKey:@"RESULT"];
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:[result getResultMsg] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;
		case login_success:
		{
			NSDictionary *dic = cmd.info;
			//		登录成功后，创建数据库
			NSString *userId = [dic objectForKey:@"user_id"];
			
			[[eCloudDAO getDatabase]initDatabase:userId];
			
			//		登录成功后，保存用户信息
			[[eCloudUser getDatabase]addUser:dic];
			
			//同时保存到用户数据库的员工表中
//			[[eCloudDAO getDatabase]addEmp:[NSArray arrayWithObject:dic]];
			[db updateUserStatus:_conn.userId andStatus:status_online];
			userinfo = [[eCloudUser getDatabase]searchUserObjectByUserid:self.userid];
			
			[onlineTable reloadData];
		}
			break;
		case user_offline:
		{
			_conn.userStatus = status_offline;
			//				设置用户状态为离线
			[db updateUserStatus:_conn.userId andStatus:status_offline];

			userinfo = [[eCloudUser getDatabase]searchUserObjectByUserid:self.userid];
			
			[onlineTable reloadData];			
		}
			break;
		default:
			break;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	db = [eCloudDAO getDatabase];
	
    [UIAdapterUtil setBackGroundColorOfController:self];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    UINavigationBar *navibar=[[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    navibar.tintColor=[UIColor colorWithRed:32/255.0 green:132/255.0 blue:209/255.0 alpha:1];
    [self.view addSubview:navibar];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 10, 50, 30);
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navibar addSubview:backButton];
    
//	加上标题
	UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(85, 7.5, 150, 30)];
	title.font = [UIFont boldSystemFontOfSize:19];
	title.textAlignment = UITextAlignmentCenter;
	title.text = @"在线状态";
	title.textColor = [UIColor whiteColor];
	title.backgroundColor = [UIColor clearColor];
	[self.view addSubview:title];
	[title release];
	
    stateArray=[[NSArray alloc]initWithObjects:@"在线",@"离线", nil];
    
    onlineTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 45, 320, 460-45) style:UITableViewStyleGrouped];
    [onlineTable setDelegate:self];
    [onlineTable setDataSource:self];
    onlineTable.backgroundView = nil;
    onlineTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:onlineTable];
    
    _conn = [conn getConn];
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [stateArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 18;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell	=	[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
	}
    cell.backgroundColor=[UIColor clearColor];

	if((userinfo.status == status_online && indexPath.row == 0) || (userinfo.status == status_offline && indexPath.row == 1))
	{
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
	}
	cell.textLabel.text=[stateArray objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:17];
	
	
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if(indexPath.row == 0)//用户点击的是在线
	{
		if(userinfo.status == status_online){//已经是在线状态，状态不变
			return;
		}
		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
		[[LCLLoadingView currentIndicator]show];
		
		[self performSelector:@selector(login) withObject:nil afterDelay:0.1];
	}
	else//点击的是离线
	{
		
		if(userinfo.status == status_offline)//已经是离线，无响应
		{
			return;
		}
        [self performSelector:@selector(setOffline) withObject:nil afterDelay:0.5];
      //		[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
//		[[LCLLoadingView currentIndicator]show];
//		if(![_conn logout])
//		{
//			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
//		}
	}
}
-(void)setOffline
{
    [_conn logout];
    _conn.userStatus = status_offline;
    //				设置用户状态为离线
    [db updateUserStatus:_conn.userId andStatus:status_offline];
    
    userinfo = [[eCloudUser getDatabase]searchUserObjectByUserid:self.userid];
    
    [onlineTable reloadData];

}
-(void)login
{
	//		准备登录
	if([_conn initConn])
	{
		if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
		{
			[[LCLLoadingView currentIndicator]hiddenForcibly:true];
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"登录命令发送失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
	}
	else 
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录" message:@"连接失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void)iconAction:(id)sender
{

}

@end
