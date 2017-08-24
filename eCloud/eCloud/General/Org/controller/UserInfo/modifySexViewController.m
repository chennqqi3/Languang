//
//  modifySexViewController.m
//  eCloud
//
//  Created by  lyong on 12-11-3.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "modifySexViewController.h"
#import "conn.h"
#import "LCLLoadingView.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "eCloudNotification.h"


@interface modifySexViewController ()

@end

@implementation modifySexViewController
{
	eCloudDAO *_ecloud;
}
@synthesize emp_id = _emp_id;
@synthesize sextype;
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
	_ecloud = [eCloudDAO getDatabase];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
	self.title=[StringUtil getLocalizableString:@"sex_modify_sex"];
    [UIAdapterUtil processController:self];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"save"] andTarget:self andSelector:@selector(addButtonPressed:)];
 
    UITableView* backgroudTable= [[UITableView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 240) style:UITableViewStyleGrouped];
    [backgroudTable setDelegate:self];
    [backgroudTable setDataSource:self];
    backgroudTable.scrollEnabled=NO;
    backgroudTable.backgroundView = nil;
    backgroudTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:backgroudTable];
    
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}

#pragma mark 修改备注或群组名
-(void) addButtonPressed:(id) sender{
    if(self.sextype == oldSexType){
		[self.navigationController popViewControllerAnimated:YES];
//		[self dismissModalViewControllerAnimated:YES];        
        return;
    }
    NSString *sexStr=[StringUtil getStringValue:sextype];
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
    if(![[conn getConn]modifyUserInfo:0 andNewValue:sexStr]) //修改性别
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		
	}
    
}

-(void)viewWillAppear:(BOOL)animated
{

	oldSexType = self.sextype;

//    if (self.sextype==0) {//女
//        [boyButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
//        [girlButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
//    }else if(self.sextype==1)//男
//    {
//        [girlButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
//        [boyButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
//    }

    //监听输入框消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
 	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
   
}
#pragma mark 接收消息处理
- (void)handleCmd:(NSNotification *)notification
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
  	eCloudNotification	*cmd					=	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
            
        case modify_userinfo_success:
        {
            /*		NSDictionary *dic = cmd.info;
             NSString *msgId = [dic objectForKey:@"msg_id"];*/
            
//            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alertView show];
//            [alertView release];
           
            conn* _conn = [conn getConn];
            NSString* userid=_conn.userId;
            [_ecloud updateUserSex:self.sextype :[userid intValue]];
			[self.navigationController popViewControllerAnimated:YES];
//            [self dismissModalViewControllerAnimated:YES];
            
        }break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"通讯超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
		}
			break;            
		default:
			break;
	}
	
}

-(IBAction)boyAction:(id)sender
{
	if(self.sextype == 0)
	{//0是女生
		[boyButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
		[girlButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
		self.sextype = 1;
	}
}

-(IBAction)girlAction:(id)sender
{
	if(sextype == 1)
	{
        [girlButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
        [boyButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
     	sextype = 0;
    }
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
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 18;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 18;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
               
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    if (indexPath.row==0) {
		cell.textLabel.text=[StringUtil getLocalizableString:@"sex_male"];
        boyButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [boyButton addTarget:self action:@selector(boyAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView=boyButton;
    }else
    {
       cell.textLabel.text=[StringUtil getLocalizableString:@"sex_female"];
        girlButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [girlButton addTarget:self action:@selector(girlAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView=girlButton;
    }
    
    if (self.sextype==0) {//女
        [boyButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
        [girlButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
    }else if(self.sextype==1)//男
    {
        [girlButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
        [boyButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(sextype == 0)
	{//女生
		if(indexPath.row == 0)
		{
			[girlButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
			[boyButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
			sextype = 1;
		}
	}
	else
	{
		if(indexPath.row == 1)
		{
			[boyButton setImage:[StringUtil getImageByResName:@"Selection_01.png"] forState:UIControlStateNormal];
			[girlButton setImage:[StringUtil getImageByResName:@"Selection_01_ok.png"] forState:UIControlStateNormal];
			sextype = 0;
		}
		
	}
}
@end
