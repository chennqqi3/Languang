//
//  PSListViewController.m
//  eCloud
// 服务号列表
//  Created by Shisp on 13-10-28.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "APPListViewController.h"
#import "APPListDetailViewController.h"
#import "APPListTableViewCell.h"
#import "APPBackButtonUtil.h"
#import "APPListModel.h"
#import "APPJsonParser.h"
#import "APPPlatformDOA.h"
#import "UIAdapterUtil.h"
#import "eCloudDefine.h"

#import "APPPushListTableViewCell.h"

#import "APPIntroViewController.h"

@interface APPListViewController ()

@end


@implementation APPListViewController
{
	//PublicServiceDAO *db;
}
@synthesize appsList;
@synthesize appsAddList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
	self.appsList = nil;
    self.appsAddList = nil;
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	//db = [PublicServiceDAO getDatabase];

    [UIAdapterUtil processController:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setExtraCellLineHidden:self.tableView];
    
	self.title = [StringUtil getLocalizableString:@"application_plaform"];
	[self setLeftBtn];
    
    NSLog(@"----------------%@",[[NSUserDefaults standardUserDefaults] objectForKey:APP_TOKEN]);
}

- (void)setExtraCellLineHidden: (UITableView *)tableView

{
    
    UIView *view =[ [UIView alloc]init];
    
    view.backgroundColor = [UIColor clearColor];
    
    [tableView setTableFooterView:view];
    
    [view release];
    
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
}
-(void)backButtonPressed:(id)sender
{
    //返回时设置所有应用为已读    
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];

	[self getPsList];
}

//查询所有服务号
-(void)getPsList
{
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
//	self.psList = [db getAllService];
//	[pool release];
    
    
    if (self.appsList == nil) {
        self.appsList =  [[NSMutableArray alloc] init];
    }
    else{
        [self.appsList removeAllObjects];
    }
    
    if (self.appsAddList == nil) {
        self.appsAddList =  [[NSMutableArray alloc] init];
    }
    else{
        [self.appsAddList removeAllObjects];
    }
    
    self.appsList = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:0];
    self.appsAddList = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    
    NSLog(@"self.appsAddList.count----------%i",[self.appsAddList count]);
    NSLog(@"self.appsList.count----------%i",[self.appsList count]);
    
    /*
    
    if (self.appsAddList == nil) {
        self.appsAddList =  [[NSMutableArray alloc] init];
    }
    else{
        [self.appsAddList removeAllObjects];
    }
    
    if (self.appsAddList == nil) {
        self.appsAddList =  [[NSMutableArray alloc] init];
    }
    else{
        [self.appsAddList removeAllObjects];
    }
    
    self.appsList = [[APPPlatformDOA getDatabase] getAPPPushNotificationWithAppid:@"11111"];
    //self.appsAddList = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    
    NSLog(@"self.appsAddList.count----------%i",[self.appsAddList count]);
    NSLog(@"self.appsList.count----------%i",[self.appsList count]);
    */
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1 && ([self.appsAddList count] && [self.appsList count])) {
        return 28.0;
    }
    else{
        return 0.0;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 && ([self.appsAddList count] && [self.appsList count])) {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0,320.0,2.0)];
        sectionView.backgroundColor = [UIColor clearColor];
        UILabel *lineBreak = [[UILabel alloc]initWithFrame:CGRectMake(4.0,27.0,312.0,1.0)];
        lineBreak.backgroundColor = [UIColor colorWithRed:193.0/255 green:193.0/255 blue:193.0/255 alpha:1.0];
        [sectionView addSubview:lineBreak];
        [lineBreak release];
        
        return [sectionView autorelease];
    }
    else{
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.appsList count];
    }
    else{
        return [self.appsAddList count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    APPListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
	{
		cell = [[[APPListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	  
    switch ([indexPath section]) {
        case 0:
        {
            //未添加到我的页面的应用
            APPListModel *appModel = (APPListModel *)[self.appsList objectAtIndex:indexPath.row];
            [cell configureCellWith:appModel];
            cell.detailButton.tag = [indexPath row];
            [cell.detailButton removeTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.detailButton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 1:
        {
            //已添加到我的页面的应用列表
            APPListModel *appModel = (APPListModel *)[self.appsAddList objectAtIndex:indexPath.row];
            [cell configureCellWith:appModel];
            cell.detailButton.tag = [indexPath row];
            [cell.detailButton removeTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.detailButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        default:
            break;
    }
    
    /*
    
    APPPushListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
	{
		cell = [[[APPPushListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    */
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    APPListModel *appModel;
    switch ([indexPath section]) {
        case 0:
        {
            appModel = (APPListModel *)[self.appsList objectAtIndex:[indexPath row]];
        }
            break;
        case 1:
        {
            appModel = (APPListModel *)[self.appsAddList objectAtIndex:[indexPath row]];
        }
            break;
        default:
            break;
    }
    
    if (appModel.isnew > 0) {
        //设置为已打开过一次的应用
        [[APPPlatformDOA getDatabase] setAPPModelRead:appModel.appid];
    }
    
    //将对应应用推送消息设置为已读
    [[APPPlatformDOA getDatabase] updateReadFlagOfAPPNoti:appModel.appid];
    
    if (1 == appModel.downloadFlag) {
        //应用已经下载，直接进入到应用页面
        if (appModel.apptype == 1) {
            //HTML5 应用
            NSString *url_str=[NSString stringWithFormat:@"%@",appModel.serverurl];
            NSLog(@"url_str------%@",url_str);
            
            APPListDetailViewController *ctr = [[APPListDetailViewController alloc] initWithAppID:appModel.appid];
            ctr.customTitle = appModel.appname;
            ctr.urlstr=url_str;
            [self.navigationController pushViewController:ctr animated:YES];
            [ctr release];
        }
        else{
            //原生应用,打开下载地址
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appModel.serverurl]];
        }
    }
    else{
        //进入应用简介
        APPIntroViewController *ctr = [[APPIntroViewController alloc] initWithAppID:appModel.appid];
        [self.navigationController pushViewController:ctr animated:YES];
        [ctr release];
    }
}

#pragma mark - 添加，删除我的页面应用
-(void)addAction:(UIButton *)sender{
    //添加应用到我的主页
    if ([self.appsList count] < sender.tag + 1 ) {
        return;
    }
    APPListModel *appModel = (APPListModel *)[self.appsList objectAtIndex:sender.tag];
    [[APPPlatformDOA getDatabase] updateHasAddedOfAPPModel:appModel.appid withAppShowflag:1];
    if (appModel.isnew > 0) {
        //设置已读
        [[APPPlatformDOA getDatabase] setAPPModelRead:appModel.appid];
    }
    
    [self getPsList];
}

-(void)deleteAction:(UIButton *)sender{
    //删除我的主页对应的应用
    if ([self.appsAddList count] < sender.tag + 1 ) {
        return;
    }
    
    APPListModel *appModel = (APPListModel *)[self.appsAddList objectAtIndex:sender.tag];
    [[APPPlatformDOA getDatabase] updateHasAddedOfAPPModel:appModel.appid withAppShowflag:0];
    if (appModel.isnew > 0) {
        //设置已读
        [[APPPlatformDOA getDatabase] setAPPModelRead:appModel.appid];
    }
    
    [self getPsList];
}



@end
