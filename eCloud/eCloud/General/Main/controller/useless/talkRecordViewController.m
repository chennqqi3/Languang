//
//  talkRecordViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "talkRecordViewController.h"
#import "eCloudDAO.h"
#import "eCloudNotification.h"
#import "Conversation.h"
#import "Emp.h"
#import "LCLLoadingView.h"
#import "eCloudDefine.h"

@interface talkRecordViewController ()

@end

@implementation talkRecordViewController
{
	eCloudDAO *db;
}
@synthesize itemArray = _itemArray;

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
	db = [eCloudDAO getDatabase];

	_conn = [conn getConn];
	
	// Do any additional setup after loading the view.
//    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    
    //适配ios7UIViewController的变化
    if ([self respondsToSelector:@selector(extendedLayoutIncludesOpaqueBars)]) {
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    }
    
    self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 50, 30);
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_botton.png"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateHighlighted];
    [backButton setBackgroundImage:[StringUtil getImageByResName:@"Return_Click_botton.png"] forState:UIControlStateSelected];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.titleLabel.font=[UIFont boldSystemFontOfSize:14];
    //    [backButton setBackgroundImage:[StringUtil getImageByResName:@"back.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem*leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem= leftItem;
    [leftItem release];

/*    UISearchBar *searchbar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 45, 320, 40)];
    searchbar.delegate=self;
    searchbar.placeholder=@"输入聊天内容进行查询";
    [self.view addSubview:searchbar];
    searchbar.backgroundColor=[UIColor colorWithRed:237/255.0 green:241/255.0 blue:245/255.0 alpha:1];
    for (UIView *subview in searchbar.subviews)
    {
		if([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
		{
			searchTextView = (UITextView*)subview;
		}
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
//            break;
        }
    }
	*/
	int tableH = 360;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	
    personTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, tableH) style:UITableViewStylePlain];
    [personTable setDelegate:self];
    [personTable setDataSource:self];
    personTable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:personTable];
    
	int foooterY = self.view.frame.size.height - 60;
//	if(iPhone5)
//		foooterY = foooterY + i5_h_diff;
	
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0,foooterY-44, 320, 60)];
    footerView.backgroundColor=[UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
    [self.view addSubview:footerView];
    UIButton *fastpreButton=[[UIButton alloc]initWithFrame:CGRectMake(20, 5, 40, 40)];
    [fastpreButton setImage:[StringUtil getImageByResName:@"fastpre.png"] forState:UIControlStateNormal];
    [fastpreButton addTarget:self action:@selector(fastpreAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:fastpreButton];
    
    UIButton *preButton=[[UIButton alloc]initWithFrame:CGRectMake(80, 5, 40, 40)];
    [preButton setImage:[StringUtil getImageByResName:@"pre.png"] forState:UIControlStateNormal];
    [preButton addTarget:self action:@selector(preAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:preButton];
    
    UIButton *nextButton=[[UIButton alloc]initWithFrame:CGRectMake(140, 5, 40, 40)];
    [nextButton setImage:[StringUtil getImageByResName:@"next.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:nextButton];
    
    
    UIButton *fastnextButton=[[UIButton alloc]initWithFrame:CGRectMake(200, 5, 40, 40)];
    [fastnextButton setImage:[StringUtil getImageByResName:@"fastnext.png"] forState:UIControlStateNormal];
    [fastnextButton addTarget:self action:@selector(fastnextAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:fastnextButton];
    
    UIButton *deleteButton=[[UIButton alloc]initWithFrame:CGRectMake(260, 5, 40, 40)];
    [deleteButton setImage:[StringUtil getImageByResName:@"delete.png"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:deleteButton];
    
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf:) name:PERSON_INFO_DISMISS_NOTIFICATION object:nil];

	personInfo=[[personInfoViewController alloc]init];
}

-(void)dismissSelf:(NSNotification *)notification
{
	NSLog(@"talk record dismiss");
	[self dismissModalViewControllerAnimated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if(curPage == 0) 
		curPage = 1;
	

	totalCount = [db getAllConvCount];
	if((totalCount % perpage_conv) == 0)
	{
		totalPage = totalCount/perpage_conv;
	}
	else
	{
		totalPage = (totalCount / perpage_conv) + 1;
	}
	
	if(curPage > totalPage)
		curPage = totalPage;
	
	self.itemArray = [[db getConvsOfPage:curPage]mutableCopy];
	
	
    self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];
	
	[personTable reloadData];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:GETUSERINFO_NOTIFICATION object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:GETUSERINFO_NOTIFICATION object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
	self.itemArray = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	if(personInfo)
		[personInfo release];
	
	[[NSNotificationCenter defaultCenter]removeObserver:self name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:PERSON_INFO_DISMISS_NOTIFICATION object:nil];

}

-(void)handleCmd:(NSNotification *)notification
{
	eCloudNotification *_notification = [notification object];
	if(_notification != nil)
	{
		int cmdId = _notification.cmdId;
		switch (cmdId) {
			case get_user_info_success:
			{
				
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				NSString* empId = [_notification.info objectForKey:@"EMP_ID"];
				Emp *emp = [db getEmpInfo:empId];
				
//				personInfo=[[personInfoViewController alloc]init];
				personInfo.titleStr=emp.emp_name;
				personInfo.sexType=emp.emp_sex;
				personInfo.emp=emp;
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
//				[personInfo release];
				
			}
				break;
			case get_user_info_timeout:
			{
				NSLog(@"get user info timeout ......");
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
//				[personInfo release];
				
			}
				break;
	
			case get_user_info_failure:
			{
				NSLog(@"get user info failure");
				
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
//				[self presentModalViewController:personInfo animated:YES];
//				[personInfo release];
				
			}
				break;				
			default:
				break;
		}
	}
}

-(void) fastpreAction:(id) sender{
	if(curPage == 1) return;
	curPage = 1;
	self.itemArray = [[db getConvsOfPage:curPage]mutableCopy];
	[personTable reloadData];
	self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];
}
-(void) preAction:(id) sender{
	if(curPage == 1)
		return;
	curPage--;
	self.itemArray = [[db getConvsOfPage:curPage]mutableCopy];
	[personTable reloadData];
	self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];
}
-(void) nextAction:(id) sender{
	if(curPage == totalPage)
		return;
	curPage++;
	self.itemArray = [[db getConvsOfPage:curPage]mutableCopy];
	[personTable reloadData];
	self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];
}
-(void) fastnextAction:(id) sender{
	if(curPage == totalPage) return;
	curPage = totalPage;
	self.itemArray = [[db getConvsOfPage:curPage]mutableCopy];
	[personTable reloadData];
	self.title=[NSString stringWithFormat:@"聊天记录[%d/%d]",curPage,totalPage];

}
#pragma mark alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	int tag = alertView.tag;
	
	if(tag == 1 && buttonIndex == 0)
	{
		[db deleteAllConversation];
//		清除所有聊天记录
		[self.navigationController popViewControllerAnimated:YES];// dismissModalViewControllerAnimated:YES];
		return;
	}
	if(tag == 2 && buttonIndex == 0)
	{
		[db deleteConvAndConvRecordsBy:deleteConvId];
		[self.itemArray removeObjectAtIndex:deleteRow];
		[personTable reloadData];
		return;
	}
}

-(void) deleteAction:(id) sender{
   
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"会话" message:@"确定要清除全部聊天记录吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
	alert.tag = 1;
	[alert dismissWithClickedButtonIndex:1 animated:YES];
	[alert show];
	[alert release];
}
//返回 按钮
-(void) backButtonPressed:(id) sender{
    
	[self.navigationController popViewControllerAnimated:YES];
//    [self dismissModalViewControllerAnimated:YES];
    //[( (mainViewController*)self.delegete).navigationController.view removeFromSuperview];
    //[self.view removeFromSuperview];
}


#pragma mark------UISearchBarDelegate-----
/*
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	if(NO == isSearch)
	{
		isSearch	=	YES;
		oldItemArray 	=	self.itemArray;
		self.itemArray	=	nil;
		[personTable reloadData];
		
		[searchBar setShowsCancelButton:YES animated:YES];
	}
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if(_searchText) 
		[_searchText release];
	_searchText = [searchText retain];
	
	if([searchText length] == 0)
	{
		[self.itemArray removeAllObjects];
		[personTable reloadData];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	self.itemArray = [[db getConversationBy:searchBar.text] mutableCopy];
	
	[personTable reloadData];
	[searchBar resignFirstResponder];
	
	for (UIView *possibleButton in searchBar.subviews)
	{
		if ([possibleButton isKindOfClass:[UIButton class]])
		{
			UIButton *cancelButton = (UIButton*)possibleButton;
			cancelButton.enabled = YES;
			break;
		}
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.itemArray removeAllObjects];
	
	[searchBar setShowsCancelButton:NO animated:YES];
	self.itemArray = oldItemArray;
	oldItemArray = nil;
	[personTable reloadData];
	[searchBar resignFirstResponder];
	searchBar.text = @"";
	
	isSearch	=	NO;
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//--------------------------------------------
//add by lyong  2012-6-19
#pragma  table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section
    
	return [self.itemArray count];
	
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
        UIButton *iconview=[[UIButton alloc]initWithFrame:CGRectMake(10, 10, user_logo_size, user_logo_size)];
        iconview.tag=1;
        [iconview addTarget:self action:@selector(iconAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:iconview];
        [iconview release];
        
        UILabel *namelable=[[UILabel alloc]initWithFrame:CGRectMake(60, 20, 105, 20)];
        namelable.tag=2;
        namelable.font=[UIFont systemFontOfSize:17];
        namelable.backgroundColor=[UIColor clearColor];
        namelable.textColor=[UIColor blackColor];
        [cell.contentView addSubview:namelable];
        [namelable release];
        
        UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(165, 20, 150, 20)];
        timelabel.tag=3;
        timelabel.font=[UIFont systemFontOfSize:11];
        timelabel.backgroundColor=[UIColor clearColor];
        timelabel.textColor=[UIColor grayColor];
        [cell.contentView addSubview:timelabel];
        [timelabel release];
    }
    cell.backgroundColor=[UIColor clearColor];
	
	Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
	//	头像
	UIButton *iconview=(UIButton *)[cell.contentView viewWithTag:1];
	iconview.titleLabel.text=[NSString stringWithFormat:@"%d",indexPath.row];

	if(conv.conv_type == 0)//单聊
	{
		if (conv.emp.emp_status==status_online) {//在线
			
			if (conv.emp.emp_sex==0) {//女
				[iconview setImage:[StringUtil getImageByResName:@"Female_ios_40.png"] forState:UIControlStateNormal];  
			}
			else
			{
				[iconview setImage:[StringUtil getImageByResName:@"Male_ios.png"] forState:UIControlStateNormal];
			}
			
		}else //离线，或离开
		{
			[iconview setImage:[StringUtil getImageByResName:@"Offline_ios.png"] forState:UIControlStateNormal];
			
		}		
	}
	else//群聊
	{
		[iconview setImage:[StringUtil getImageByResName:@"Group_ios.png"] forState:UIControlStateNormal];
	}
//	会话名称
	UILabel *namelabel=(UILabel *)[cell.contentView viewWithTag:2];
	namelabel.text=(conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
//	最后一条消息时间
	UILabel *timelabel=(UILabel *)[cell.contentView viewWithTag:3];
	timelabel.text=[StringUtil getDisplayTime:conv.last_record.msg_time];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [searchTextView resignFirstResponder];
	
	Conversation *_conv = (Conversation*)[self.itemArray objectAtIndex:indexPath.row];
 	talkRecordDetailViewController *talkRecordDetail=[[talkRecordDetailViewController alloc]init];
	talkRecordDetail.convId = _conv.conv_id;
	talkRecordDetail.convName =(_conv.conv_remark==nil)?_conv.conv_title:_conv.conv_remark;
	talkRecordDetail.convType = _conv.conv_type;
	talkRecordDetail.conv = _conv;
	
	[self.navigationController pushViewController:talkRecordDetail animated:YES];
//    [self presentModalViewController:talkRecordDetail animated:YES];
	[talkRecordDetail release];
    
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
		deleteConvId = conv.conv_id;
		deleteRow = indexPath.row;
		
		NSString *titleStr = @"";
		if(conv.conv_type == singleType)
		{
			titleStr = [NSString stringWithFormat:@"确定删除和%@的会话吗？",conv.emp.emp_name];
		}
		else
		{
			titleStr = @"确定删除该群聊吗？";
		}
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"会话" message:titleStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
		alert.tag = 2;
		[alert dismissWithClickedButtonIndex:1 animated:YES];
		[alert show];
		[alert release];
		
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
    
	
	Conversation *conv = [self.itemArray objectAtIndex:index];
	if(conv.conv_type == 0)
	{//单聊
		personInfo.titleStr=conv.emp.emp_name;
		personInfo.sexType=conv.emp.emp_sex;
		personInfo.emp= [db getEmpInfo:[StringUtil getStringValue:(conv.emp.emp_id)]];
		
		if(conv.emp.info_flag)
		{
			[self.navigationController pushViewController:personInfo animated:YES];
		}
		else
		{
			NSLog(@"需要从服务器端取数据");	
			[[LCLLoadingView currentIndicator]setCenterMessage:@"请稍候..."];
			[[LCLLoadingView currentIndicator]showSpinner];
			[[LCLLoadingView currentIndicator]show];
			bool ret = [_conn getUserInfo:conv.emp.emp_id];
			if(!ret)
			{
				[[LCLLoadingView currentIndicator]hiddenForcibly:true];
				[self.navigationController pushViewController:personInfo animated:YES];
			}
		}
	}
	else
	{
        personGroup=[[personGroupViewController alloc]init];
		
        personGroup.dataArray=[db getAllConvEmpBy:conv.conv_id];
        personGroup.titleStr=conv.conv_title;
        personGroup.conv_id=conv.conv_id;
		[self.navigationController pushViewController:personGroup animated:YES];
        [personGroup release];
	}
}

@end
