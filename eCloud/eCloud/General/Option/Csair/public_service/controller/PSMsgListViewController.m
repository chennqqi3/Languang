//
//  FLTGroupListViewController.m
//  eCloud
//
//  Created by Richard on 13-11-4.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "PSMsgListViewController.h"
#import "Conversation.h"
#import "PublicServiceDAO.h"
#import "FltGroupListViewUtil.h"
#import "PSMsgDtlViewController.h"
#import "PSBackButtonUtil.h"
#import "PSUtil.h"
#import "eCloudDefine.h"

#import "talkSessionViewController.h"

@interface PSMsgListViewController ()

@end
@implementation PSMsgListViewController
{
	UITableView *psTable;
	PublicServiceDAO *db;
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
	
	 db = [PublicServiceDAO getDatabase];
    
    [UIAdapterUtil processController:self];

	self.title = [StringUtil getLocalizableString:@"public_service"];
	//设置背景
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];

	CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height - 44);
	psTable = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
	psTable.delegate = self;
	psTable.dataSource = self;
	[self.view addSubview:psTable];
	[psTable release];
    
    [UIAdapterUtil setExtraCellLineHidden:psTable];
	
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
-(void)refreshData
{
	@autoreleasepool {
		
		self.itemArray = [db getAllPSMsgList];
	}
	[psTable reloadData];
	[self showNoReadNum];
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
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
}

#pragma mark tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return row_height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
	int serviceId = [conv.conv_id intValue];

    talkSessionViewController *talkSession = [talkSessionViewController getTalkSession];
    talkSession.serviceModel = [db getServiceByServiceId:serviceId];
    talkSession.needUpdateTag = 1;
    talkSession.talkType = publicServiceMsgDtlConvType;
    [self.navigationController pushViewController:talkSession animated:YES];
    
//	PSMsgDtlViewController *controller = [PSMsgDtlViewController getPSMsgDtlViewController];
//	controller.needRefresh = YES;
//	controller.serviceModel = [db getServiceByServiceId:serviceId];
//	
////	controller.hidesBottomBarWhenPushed = YES;
//	
//	[self.navigationController pushViewController:controller animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.itemArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
	{
		cell = [FltGroupListViewUtil initCell:cellIdentifier];
    }
	Conversation *conv = [self.itemArray objectAtIndex:indexPath.row];
	
	[FltGroupListViewUtil configCell:cell andConversation:conv];
	
	UIImageView *iconview=(UIImageView *)[cell.contentView viewWithTag:icon_view_tag];
	[iconview setImage:[PSUtil getServiceLogo:conv.serviceModel]];

	return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
