//
//  settingViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "settingViewController.h"
#import "OpenCtxManager.h"
#import "TabbarUtil.h"
#import "GXViewController.h"
#import "aboutViewController.h"
#import "SettingItem.h"

#import "eCloudUser.h"
#import "mainViewController.h"
#import "LCLLoadingView.h"
#import "eCloudNotification.h"
#import "AppDelegate.h"
#import "loginViewController.h"
#import "UIAdapterUtil.h"
#import "eCloudDAO.h"
#import "UsualSettingViewControlViewController.h"
#import "LanUtil.h"
#import "StringUtil.h"
#import "clearDataViewController.h"
#import "DirectoryWatcher.h"
#import "folderSizeAndList.h"
#import "NotificationsViewController.h"
#import "MessageView.h"
#import "UserInfo.h"
#import "broadcastListViewController.h"
#import "conn.h"
#import "DirectoryWatcher.h"
#import "LanUtil.h"
#import "UserDefaults.h"
#import "AgentListViewController.h"
#import "CollectionController.h"
#import "DownloadGuideImage.h"
#import "SettingManager.h"
//#import "CollectionViewController.h"
#define LG_SECRETARY_ID @"13774"
@interface settingViewController () <OpenCtxManagerDelegate>
{
    UITableView *settingTable;
	int newMsgRcvFlag;
    eCloudDAO *db;
    UIButton *modifySignatureButton;
    
    //    设置项数组
    NSMutableArray *settingItemArray;

}

@end

@implementation settingViewController
@synthesize userid;
@synthesize delegete;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    db = [eCloudDAO getDatabase];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    _conn = [conn getConn];
    settingTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44 - 48) style:UITableViewStyleGrouped];
    [settingTable setDelegate:self];
    [UIAdapterUtil setPropertyOfTableView:settingTable];
    settingTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [settingTable setDataSource:self];
    settingTable.showsHorizontalScrollIndicator = NO;
    settingTable.showsVerticalScrollIndicator = NO;
    settingTable.backgroundView = nil;
    settingTable.backgroundColor=[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1];
    settingTable.backgroundColor=[UIColor clearColor];
    settingTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:settingTable];
    [settingTable release];
    
    // Do any additional setup after loading the view.
    self.userid=_conn.userId;
    
#if defined(_LANGUANG_FLAG_) || defined(_XIANGYUAN_FLAG_) || defined(_BGY_FLAG_)
    
#else
    
    UIView *buttonview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 58)];
    
    modifySignatureButton=[UIAdapterUtil setNewButton:@"settings_log_out" andBackgroundImage:[StringUtil getImageByResName:@"exit_button"]];
    modifySignatureButton.frame=CGRectMake(10, 15, self.view.frame.size.width-2*10, 45);
    [modifySignatureButton addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
    [buttonview addSubview:modifySignatureButton];
    
    modifySignatureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    if ([UIAdapterUtil isGOMEApp])
    {
        modifySignatureButton.layer.cornerRadius = 5;
        modifySignatureButton.clipsToBounds = YES;
        
        [modifySignatureButton setBackgroundColor:[UIColor colorWithRed:2/255.0 green:139/255.0 blue:230/255.0 alpha:1]];
        [modifySignatureButton setBackgroundImage:nil forState:UIControlStateNormal];
    }
    if (![UIAdapterUtil isTAIHEApp]) {
       settingTable.tableFooterView=buttonview;
    }
    
    [buttonview release];
    
#endif

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    allSize = nil;
    self.title = [StringUtil getLocalizableString:@"main_settings"];
    if (![UIAdapterUtil isTAIHEApp]) {
        [modifySignatureButton setTitle:[StringUtil getLocalizableString:@"settings_log_out"] forState:UIControlStateNormal];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    if ([UIAdapterUtil isHongHuApp]) {
        
        [self hideTabBar];
    }else{
        [self displayTabBar];
    }
  
    [self reCalculateFrame];
	
//    如果有新版本，那么在设置标签上显示new
    if(_conn.hasNewVersion)
    {
//        如果是龙湖和国美或者泰和，不做任何设置，其它则要在设置这里
        if ([UIAdapterUtil isHongHuApp] || [UIAdapterUtil isGOMEApp] || [UIAdapterUtil isTAIHEApp]) {
        }else{
            [TabbarUtil setTabbarBage:@"new" andTabbarIndex:[eCloudConfig getConfig].settingIndex];
        }
        
    }
    else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].settingIndex];
    }

    
    [self prepareSettingItems];
    [settingTable reloadData];
    
    if ([self needDisplayBackButton]) {
        [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
    }
}

-(void) backButtonPressed:(id) sender{

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==tipAlert)
	{
        if (buttonIndex==1)
		{
           	if(_conn.connStatus == normal_type)
            {
                isExit = true;
                
                [_conn logout:1];
//                if (![eCloudConfig getConfig].supportShareExtension)
//                {
                    NSString *str =  [[ServerConfig shareServerConfig]getShareName];
                    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
                    [sharedDefaults removeObjectForKey:@"isLogin"];
               // }
                
                [self exit];
			}
			else if(_conn.connStatus == not_connect_type)
            {
				[self exit];
            }
        }
    }
    //    int tag = alertView.tag;
    //
    //	if(tag == 1 && buttonIndex == 0)
    //	{
    //        //		清除所有聊天记录
    //		[db deleteAllConversation];
    //
    //		return;
    //	}
}

-(void)exit
{
//    DownloadGuideImage *downloadImage = [DownloadGuideImage shareDownloadGuideImageSingle];
//    if ([downloadImage picNameArray]) {
//        [downloadImage.picNameArray removeAllObjects];
//        downloadImage.picNameArray = nil;
//    }
    [UserDefaults saveUserIsExit:YES];
    
    if (self.delegete && [self.delegete isKindOfClass:[mainViewController class]]) {
        [( (mainViewController*)self.delegete)backRoot];
    }else{
        id tabbarVC = [TabbarUtil getTabbarController];
        if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
            id mainVC = ((GXViewController *)tabbarVC).delegate;
            [((mainViewController*)mainVC) backRoot];
        }
    }
}

-(IBAction)exitAction:(id)sender
{
    [OpenCtxManager getManager].delegate = self;
    [[OpenCtxManager getManager]onClickExitButton];
    
//    NSString *temp = @"";
//    if(_conn.connStatus == linking_type)
//    {
//        temp = [StringUtil getLocalizableString:@"settings_connecting_server"];
//    }
//    else if(_conn.connStatus == rcv_type)
//    {
//        temp = [StringUtil getLocalizableString:@"settings_receiving_messages"];
//    }
//    else if(_conn.connStatus == download_org)
//    {
//        temp = [StringUtil getLocalizableString:@"settings_loading_organizational_structure"];
//    }
//    else if(_conn.downLoadImageStatus == download_guide)
//    {
//        temp = [StringUtil getLocalizableString:@"settings_download_guide"];
//    }
//    
//    if(temp.length > 0)
//    {
//        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
//        [tipAlert show];
//        [tipAlert release];
//        tipAlert = nil;
//        return;
//    }
//    
//    else {
//        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
//        
//            [tipAlert show];
//            [tipAlert release];
//    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//add by lyong  2012-6-19
#pragma  table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingItemArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *_array = [settingItemArray objectAtIndex:section];
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    return [UIAdapterUtil isLANGUANGApp]?40:DEFAULT_ROW_HEIGHT;
    return kGetCurrentValue(51);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
 
//    CGRect textLabelRect = CGRectMake(0, 12, 375, 22);
//    cell.textLabel.frame = [GYFrame myRect:textLabelRect];
//    cell.textLabel.font = [UIFont systemFontOfSize:17];
    //cell.textLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 375, 51)];
    label.font = [UIFont systemFontOfSize:17];
    [cell addSubview:label];
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    label.text = _item.itemName;
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:settingTable withOriginX:label.frame.origin.x];
    cell.selectionStyle = _item.selectionStyle;
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        [UIAdapterUtil customSelectBackgroundOfCell:cell];
    }
    cell.accessoryType = _item.accessoryType;
    
    
    if (_item.customCellSelector) {
        [self performSelector:_item.customCellSelector withObject:cell];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    int section = (int)[indexPath section];
//    int row = (int)indexPath.row;
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];

    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kGetCurrentValue(32);
        
    }
    
    SettingItem *_item = [self getSettingItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];

    if (_item && _item.headerHight) {
        return _item.headerHight;
    }
    return kGetCurrentValue(32);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return [UIAdapterUtil isLANGUANGApp]?6:DEFAULT_SECTION_FOOTER_HEIGHT;
    
}

-(void)displayTabBar
{
    if ([self.navigationController.viewControllers[0] isKindOfClass:[self class]]) {
        [UIAdapterUtil showTabar:self];
    }
	self.navigationController.navigationBarHidden = NO;
}

-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}


-(void)dealloc
{
    [settingItemArray release];
    settingItemArray = nil;

    settingTable = nil;
//    allSize = nil;
    userinfo = nil;
    userid =nil;
    broadcastList = nil;
    tipAlert=nil;
    modifySignatureButton =nil;
    
    [super dealloc];
}

#pragma mark ========准备设置项数组=========
- (void)prepareSettingItems
{
    [[SettingManager sharedManager] getSettingItemArray:^(NSArray *settingArray) {
        settingItemArray = [settingArray copy];
    }];
}
//打开通知设置界面
- (void)openNotificationSetting
{
    NotificationsViewController *notificationView = [[NotificationsViewController alloc] init];
    [self.navigationController pushViewController:notificationView animated:YES];
    [self hideTabBar];
    [notificationView release];
}

//打开通用设置界面
- (void)openUsualSetting
{
    UsualSettingViewControlViewController *usualSettingControl = [[UsualSettingViewControlViewController alloc]init];
    [self hideTabBar];
    [self.navigationController pushViewController:usualSettingControl animated:YES];
    [usualSettingControl release];
}

//打开关于界面
- (void)openAbout
{
    aboutViewController *aboutController=[[aboutViewController alloc]init];
    [self hideTabBar];
    [self.navigationController pushViewController:aboutController animated:YES];
    [aboutController release];
}
//打开意见反馈界面
- (void)openIdeaFeedback
{
    Emp *_emp = [[eCloudDAO getDatabase] getEmployeeById:LG_SECRETARY_ID];
    if(_emp)
    {
        [UIAdapterUtil openConversation:self andEmp:_emp];
    }
}
//清理缓存
- (void)clearDateView
{
    clearDataViewController *clearDataView = [[clearDataViewController alloc] init];
    [self.navigationController pushViewController:clearDataView animated:YES];
    [clearDataView release];
}
//打开收藏界面
- (void)openMyCollections
{
    CollectionController *collectionController = [[CollectionController alloc] init];
    [self hideTabBar];
    [self.navigationController pushViewController:collectionController animated:YES];
    [collectionController release];
}

// 如果 图片或文件的 大小合起来 超过200M，并且没有新版本， 那么需要 在 通用的旁边 显示一个红点
- (void)customCellOfUsual:(UITableViewCell *)cell
{
    long long temp = [UserDefaults getAllStorage];

    if (temp>(1024*1024*200))
    {
        if(_conn.hasNewVersion)
        {
            [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].settingIndex];
        }
        
        CGSize _size = [cell.textLabel.text sizeWithFont:cell.textLabel.font];
        UIImageView *clearView = [[UIImageView alloc]initWithFrame:CGRectMake(_size.width + 30, 18, 9, 9)];
        clearView.image =  [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        [cell addSubview:clearView];
        [clearView release];
    }
}

//如果有新版本 那么需要在关于 旁边 显示 一个new 标志
- (void)customCellOfAbout:(UITableViewCell *)cell
{
    if(_conn.hasNewVersion)
    {
        CGSize _size = [cell.textLabel.text sizeWithFont:cell.textLabel.font];

        UIButton *newButton=[[UIButton alloc]initWithFrame:CGRectMake(_size.width + 30,(DEFAULT_ROW_HEIGHT - 20) / 2, 34, 20)];
        
        [newButton addTarget:self action:@selector(openAbout) forControlEvents:UIControlEventTouchUpInside];
        
        UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
        MessageView *messageView = [MessageView getMessageView];
        UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
        
        [newButton setBackgroundImage:newMsgImage forState:UIControlStateNormal];
        newButton.backgroundColor=[UIColor clearColor];
        [newButton setTitle:@"new" forState:UIControlStateNormal];
        newButton.font=[UIFont boldSystemFontOfSize:12];
        [cell addSubview:newButton];
        [newButton release];
    }
}

- (void)reCalculateFrame
{
    settingTable.frame = CGRectMake(0, 0, self.view.frame.size.width , SCREEN_HEIGHT - 44 - [StringUtil getStatusBarHeight] - self.tabBarController.tabBar.frame.size.height);
}

- (SettingItem *)getSettingItemByIndexPath:(NSIndexPath *)indexPath
{
    int section = (int)[indexPath section];
    int row = (int)[indexPath row];
    
    NSArray *_array = [settingItemArray objectAtIndex:section];
    SettingItem *_item = [_array objectAtIndex:row];
    return _item;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect _frame = settingTable.frame;
    
    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect(_frame));
}

/**
 是否需要显示返回按钮
 
 @return 需要则返回YES 否则NO
 */
- (BOOL)needDisplayBackButton
{
    if ([UIAdapterUtil isHongHuApp] || [UIAdapterUtil isGOMEApp] || [UIAdapterUtil isTAIHEApp] ||[UIAdapterUtil isLANGUANGApp]) {
        return YES;
    }
    return NO;
}

#pragma mark openctxmanager delegate
- (void)didLogout{
    [self exit];
}

@end
