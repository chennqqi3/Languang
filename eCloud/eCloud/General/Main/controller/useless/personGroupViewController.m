//
//  personGroupViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-25.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "personGroupViewController.h"
#import "Emp.h"
#import "eCloudDAO.h"
#import "LCLLoadingView.h"
#import "personInfoViewController.h"
#import "talkSessionViewController.h"
#import "conn.h"
#import "userInfoViewController.h"
#import "eCloudDefine.h"

@interface personGroupViewController ()

@end

@implementation personGroupViewController
{
	eCloudDAO *db;

}
@synthesize titleStr;
@synthesize dataArray;
@synthesize conv_id;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)handleCmd:(NSNotification *)notification
{
	eCloudNotification *cmd = [notification object];
	if(cmd != nil)
	{
		int cmdId = cmd.cmdId;
		switch (cmdId) {
			case get_user_info_success:
			{
				NSLog(@"get user info success");
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				NSString* empId = [cmd.info objectForKey:@"EMP_ID"];
				Emp *emp = [db getEmpInfo:empId];
				
				personInfo.titleStr=emp.emp_name;
				personInfo.sexType=emp.emp_sex;
				personInfo.emp=emp;
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}
				break;
			case get_user_info_timeout:
			{
				NSLog(@"get user info timeout ......");
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}
				break;
				
			case get_user_info_failure:
			{
				NSLog(@"get user info failure");
				
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
				//			[personInfo release];
				
			}
				break;	

		}
	}
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];

}
-(void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	_conn = [conn getConn];
	db = [eCloudDAO getDatabase];
	
    [UIAdapterUtil setBackGroundColorOfController:self];
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    self.title=[NSString stringWithFormat:@"%@(%d)",titleStr,[self.dataArray count]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 30);
    [backButton setBackgroundImage:[UIImage imageNamed:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[UIImage imageNamed:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem= leftItem;
    [leftItem release];
    // [backButton release];
    // Do any additional setup after loading the view from its nib.
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, 0, 50, 30);
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_ico.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_click_ico.png"] forState:UIControlStateHighlighted];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"Button_exit_click_ico.png"] forState:UIControlStateSelected];
    [sendButton setTitle:@"发消息" forState:UIControlStateNormal];
    sendButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    [sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem*rightItem = [[UIBarButtonItem alloc]initWithCustomView:sendButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    [rightItem release];
    
	int tableH = 460-45;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    personGroupTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [personGroupTable setDelegate:self];
    [personGroupTable setDataSource:self];
    personGroupTable.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:personGroupTable];
	// Do any additional setup after loading the view.
	
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:PERSON_INFO_DISMISS_NOTIFICATION object:nil];

	personInfo=[[personInfoViewController alloc]init];
	
}


-(void)dismissSelf:(NSNotification *)notification
{
	
	[self dismissModalViewControllerAnimated:NO];
	[[NSNotificationCenter defaultCenter]postNotificationName:PERSON_GROUP_DISMISS_NOTIFICATION object:nil userInfo:nil];
}

//返回 按钮
-(void) backButtonPressed:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}

-(void) sendButtonPressed:(id) sender{
    

    
    talkSessionViewController *session = [[talkSessionViewController alloc]init];
    session.talkType = mutiableType;
    session.titleStr = self.titleStr;
    session.convId = self.conv_id;
    session.convEmps =self.dataArray;
	session.needUpdateTag = 1;
	[self.navigationController pushViewController:session animated:YES];
//    [self presentModalViewController:session animated:YES];
    [session release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	if(personInfo)
		[personInfo release];
	
    // Release any retained subviews of the main view.
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:PERSON_INFO_DISMISS_NOTIFICATION object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//--------------------------------------------
//add by lyong  2012-6-19
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return [self.dataArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        //cell.backgroundColor=[UIColor colorWithRed:228/255.0 green:228/255.0 blue:230/255.0 alpha:1];
        UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, small_user_logo_size, small_user_logo_size)];
        iconview.tag=1;
        [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:iconview];
        [iconview release];
        
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(60, 20, 160, 20)];
        namelable.tag=2;
        namelable.font=[UIFont systemFontOfSize:14];
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        
        UILabel *signatureLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 35, 200, 30)];
        signatureLabel.backgroundColor=[UIColor clearColor];
        signatureLabel.tag=3;
        signatureLabel.hidden=YES;
        signatureLabel.textColor=[UIColor grayColor];
        signatureLabel.textAlignment=UITextAlignmentLeft;
        signatureLabel.font=[UIFont systemFontOfSize:12];
        [cell.contentView addSubview:signatureLabel];
        [signatureLabel release];
      }
    
    cell.backgroundColor=[UIColor clearColor];
    // int row=[indexPath row];
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
    //    UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:1];
    UIButton *iconview=(UIButton *)[cell.contentView viewWithTag:1];
    iconview.titleLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];
    UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
    Emp *emp=[self.dataArray objectAtIndex:indexPath.row];
    namelabel.text=emp.emp_name;
    if (emp.signature!=nil&&[emp.signature length]>0) {
        UILabel *signatureLabel=(UILabel *)[cell.contentView viewWithTag:3];
        signatureLabel.hidden=NO;
        signatureLabel.text=emp.signature;
    }else
    {
        UILabel *signatureLabel=(UILabel *)[cell.contentView viewWithTag:3];
        signatureLabel.hidden=YES;
    }
    if(_conn.userStatus == status_online)
    {
        if (emp.emp_status==status_online) {//在线
            if (emp.emp_sex==0) {//女
                cell.imageView.image=[UIImage imageNamed:@"Female_ios_40.png"];
            }else
            {
                cell.imageView.image=[UIImage imageNamed:@"Male_ios_40.png"];
            }
        }else if(emp.emp_status==status_leave)//离开
        {
            if (emp.emp_sex==0) {//女
                cell.imageView.image=[UIImage imageNamed:@"Female_ios_leave.png"];
            }else
            {
                cell.imageView.image=[UIImage imageNamed:@"Male_ios_leave.png"];
            }
        }else//离线，或离开
        {
            cell.imageView.image=[UIImage imageNamed:@"Offline_ios_35.png"];
        }
    }
    else {
        cell.imageView.image=[UIImage imageNamed:@"Offline_ios_35.png"];			
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	[self viewPersonInfo:indexPath.row];
	
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        [tableData removeObjectAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)iconAction:(id)sender
{
    UIButton *button=(UIButton *)sender;
    int index=[button.titleLabel.text intValue];
   
	[self viewPersonInfo:index];
}

-(void)viewPersonInfo:(int)index
{
	Emp *emp=[self.dataArray objectAtIndex:index];
	
	emp=[db getEmpInfo:[StringUtil getStringValue:emp.emp_id]];
	
	if(emp.emp_id == [_conn.userId intValue])
	{
		//		打开用户自己的资料
		userInfoViewController *userInfo = [[userInfoViewController alloc]init];
		userInfo.tagType=1;
		userInfo.emp=emp;
		userInfo.titleStr=emp.emp_name;
		[self.navigationController pushViewController:userInfo animated:YES];
		[userInfo release];
		return;
	}
	
	personInfo.emp = emp;
    [self.navigationController pushViewController:personInfo animated:YES];
}

@end
