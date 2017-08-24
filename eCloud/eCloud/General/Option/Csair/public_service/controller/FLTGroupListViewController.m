//
//  FLTGroupListViewController.m
//  eCloud
//
//  Created by Richard on 13-11-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "FLTGroupListViewController.h"
#import "Conversation.h"
#import "eCloudDAO.h"
//#import "FltGroupListViewUtil.h"
#import "talkSessionViewController.h"
#import "PSBackButtonUtil.h"
#import "QueryResultCell.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "eCloudNotification.h"
#import "NotificationDefine.h"
#import "eCloudDefine.h"

@interface FLTGroupListViewController ()

@end
@implementation FLTGroupListViewController
{
	UITableView *fltTable;
	eCloudDAO *db;
	UIButton *backButton;
}
@synthesize itemArray;

-(void)dealloc
{
	self.itemArray = nil;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    db = [eCloudDAO getDatabase];
    
	self.title = [StringUtil getLocalizableString:@"flt_group"];
	
	CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height - 44);
	fltTable = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
	fltTable.delegate = self;
	fltTable.dataSource = self;
	[self.view addSubview:fltTable];
	[fltTable release];
	
	[self setLeftBtn];
    
}
#pragma mark 处理会话通知
-(void)handleCmd:(NSNotification*)notification
{
	eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
	switch (cmd.cmdId)
	{
		case rev_msg:
		{
			[self refreshData];
		}
			break;
	}
}
-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:CONVERSATION_NOTIFICATION object:nil];
	[self refreshData];
}
#pragma mark 获取并显示未读记录数
-(void)showNoReadNum
{
	[PSBackButtonUtil showNoReadNum:nil andButton:backButton];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    backButton = [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}
-(void)backButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)refreshData
{
	@autoreleasepool {
		self.itemArray = [NSMutableArray arrayWithArray:[db getRecentConversation:flt_group_type]];
	}
	[fltTable reloadData];
	[self showNoReadNum];
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
}

#pragma mark tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return conv_row_height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	Conversation *conv = [itemArray objectAtIndex:indexPath.row];
	
	talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
	talkSession.talkType = mutiableType;
	talkSession.titleStr = (conv.conv_remark==nil)?conv.conv_title:conv.conv_remark;
	talkSession.convId = conv.conv_id;
	talkSession.needUpdateTag=1;
	talkSession.convEmps =[db getAllConvEmpBy:conv.conv_id];
	talkSession.last_msg_id=conv.last_msg_id;
    //	talkSession.hidesBottomBarWhenPushed = YES;
	
	[self.navigationController pushViewController:talkSession animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.itemArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell1";
    QueryResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[QueryResultCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID]autorelease];
        cell.cellWidth = [UIAdapterUtil getTableCellContentWidth];
        [cell initSubView];
    }
    Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
    conv.displayTime = YES;
    conv.displayRcvMsgFlag = YES;
    [cell configCell:conv];
    
    return cell;
    //    update by shisp 采用和会话列表同样地cell定义
    //	static NSString *cellIdentifier = @"Cell";
    //
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //
    //    if (cell == nil)
    //	{
    //		cell = [FltGroupListViewUtil initCell:cellIdentifier];
    //    }
    //
    //	[FltGroupListViewUtil configCell:cell andConversation:conv];
    //	return cell;
}

#pragma mark 增加滑动删除机组群功能
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Conversation *conv=[self.itemArray objectAtIndex:indexPath.row];
        [db deleteConvAndConvRecordsBy:conv.conv_id];
        [self.itemArray removeObjectAtIndex:indexPath.row];
		[tableView reloadData];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
