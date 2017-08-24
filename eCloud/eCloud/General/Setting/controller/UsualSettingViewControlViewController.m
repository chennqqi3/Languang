//
//  UsualSettingViewControlViewController.m
//  eCloud
//
//  Created by SH on 14-7-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "UsualSettingViewControlViewController.h"
#import "OpenCtxDefine.h"
#import "MsgSyncDefine.h"
#import "UserInfo.h"
#import "eCloudUser.h"

#import "talkSessionUtil.h"
#import "SettingItem.h"

#import "UIAdapterUtil.h"

#import "UIAdapterUtil.h"
#import "deleteAllChatRecord.h"
#import "FontSizeSettingViewController.h"
#import "chatBackgroudViewController.h"
#import "chooseLanguageViewController.h"
#import "StringUtil.h"
#import "clearDataViewController.h"
#import "MessageView.h"
#import "LanUtil.h"
#import "conn.h"
#import "folderSizeAndList.h"

#import "LCLLoadingView.h"

#import "UserDefaults.h"

#import "eCloudDAO.h"
#import "UserTipsUtil.h"
#import "talkRecordViewController.h"
#import "chatRecordViewController.h"
#import "GYFrame.h"
#define tips_font_size (14.0)

@interface UsualSettingViewControlViewController ()
{
    deleteAllChatRecord *delete;
    long long allSize;
    conn *_conn;
    int newMsgRcvFlag;
    //    刷新通讯录的提示的高度
    float refreshOrgTipsHeight;
    
//    设置项数组
    NSMutableArray *settingItemArray;
    
    UITableView *usualView;
}

@end

@implementation UsualSettingViewControlViewController

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
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"ChangeLanguage" object:nil];
    
    [super viewDidLoad];
    
    // 计算刷新组织架构注意事项的高度
    refreshOrgTipsHeight = [talkSessionUtil getSizeOfTextMsg:[StringUtil getLocalizableString:@"usual_refresh_org_by_hand_tips"] withFont:[UIFont systemFontOfSize:tips_font_size] withMaxWidth:([UIAdapterUtil getTableCellContentWidth] - 24)].height;
    refreshOrgTipsHeight += 12;
    _conn = [conn getConn];
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
	self.title = [StringUtil getLocalizableString:@"usual_usual"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"settings_settings"]andTarget:self andSelector:@selector(backButtonPressed:)];

    
    usualView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStyleGrouped];
    [UIAdapterUtil setPropertyOfTableView:usualView];
    usualView.delegate = self;
    usualView.dataSource = self;
    usualView.showsHorizontalScrollIndicator = NO;
    usualView.showsVerticalScrollIndicator = NO;
    usualView.backgroundView = nil;
    usualView.backgroundColor=[UIColor clearColor];

    usualView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:usualView];
    [usualView release];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    allSize = nil;

    [self prepareSettingItems];

    [usualView reloadData];
    self.title = [StringUtil getLocalizableString:@"usual_usual"];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"settings_settings"]andTarget:self andSelector:@selector(backButtonPressed:)];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:MODIFYUSER_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNoConnect:) name:NO_CONNECT_NOTIFICATION object:nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NO_CONNECT_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:MODIFYUSER_NOTIFICATION object:nil];
 	[[NSNotificationCenter defaultCenter]removeObserver:self name:TIMEOUT_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];

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
			_conn.userRcvMsgFlag = newMsgRcvFlag;
            
			//局部cell刷新
			NSIndexPath *reloadIndexPath=[NSIndexPath indexPathForRow:0 inSection:1];
			[usualView beginUpdates];
			[usualView reloadRowsAtIndexPaths:[NSArray arrayWithObject:reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[usualView endUpdates];
        }
			break;
        case modify_userinfo_failure:
        {
            UIAlertView *alertView	=	[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
			//局部cell刷新
			NSIndexPath *reloadIndexPath=[NSIndexPath indexPathForRow:0 inSection:1];
			[usualView beginUpdates];
			[usualView reloadRowsAtIndexPaths:[NSArray arrayWithObject:reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[usualView endUpdates];
            
        }
			break;
		case cmd_timeout:
		{
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"通讯超时" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			
			//局部cell刷新
			NSIndexPath *reloadIndexPath=[NSIndexPath indexPathForRow:0 inSection:1];
			[usualView beginUpdates];
			[usualView reloadRowsAtIndexPaths:[NSArray arrayWithObject:reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
			[usualView endUpdates];
            
		}
			break;
		default:
			break;
	}
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [UIAdapterUtil isLANGUANGApp]?40:DEFAULT_ROW_HEIGHT;
    return kGetCurrentValue(51);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kGetCurrentValue(32);
    }
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    SettingItem *_item = nil;
    
    id _id = [settingItemArray objectAtIndex:section];
    if ([_id isKindOfClass:[SettingItem class]]) {
        _item = (SettingItem *)_id;
    }
    else if ([_id isKindOfClass:[NSArray class]])
    {
        _item = [((NSArray *)_id) objectAtIndex:0];
    }
    if (_item && _item.headerHight) {
        return _item.headerHight + 30;
    }

    return 17;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return settingItemArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id _id = [settingItemArray objectAtIndex:section];
    if ([_id isKindOfClass:[SettingItem class]]) {
        return 1;
    }
    else if ([_id isKindOfClass:[NSArray class]])
    {
        return ((NSArray *)_id).count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SettingItem *_item = nil;
    
    id _id = [settingItemArray objectAtIndex:section];
    if ([_id isKindOfClass:[SettingItem class]]) {
        _item = (SettingItem *)_id;
    }
    else if ([_id isKindOfClass:[NSArray class]])
    {
        _item = [((NSArray *)_id) objectAtIndex:0];
    }
    if (_item && _item.headerView) {
        return _item.headerView;
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    
//    cell.textLabel.font = [UIFont systemFontOfSize:[UIAdapterUtil isLANGUANGApp]?16:17];
//    cell.textLabel.font = [UIFont systemFontOfSize:17];
    
//    cell.textLabel.textColor = [UIAdapterUtil isGOMEApp] ? GOME_NAME_COLOR : [UIColor blackColor];
//    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(12, 14.5, SCREEN_WIDTH-24, 22)];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = UIColorFromRGB(0x333333);
    [cell addSubview:label];
    
    SettingItem *_item = nil;
    
    int section=(int)[indexPath section];
    
    id _id = [settingItemArray objectAtIndex:section];
    
    if ([_id isKindOfClass:[SettingItem class]]) {
        _item = (SettingItem *)_id;
    }
    else
    {
        int row = [indexPath row];
        NSArray *_array = (NSArray *)_id;
        
        _item = [_array objectAtIndex:row];
    }
    label.text = _item.itemName;
    
    [UIAdapterUtil alignHeadIconAndCellSeperateLine:usualView withOriginX:label.frame.origin.x];
    
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

- (void)positionSwitch:(UISwitch *)_switch ofCell:(UITableViewCell *)cell
{
    [UIAdapterUtil positionSwitch:_switch ofCell:cell];
    CGRect _frame = _switch.frame;
    _frame.origin.y = 10;
    _switch.frame = _frame;
    
}
-(void)switchModeAction:(id)sender
{
    conn* _conn = [conn getConn];
    
    //    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    if (((UISwitch *)sender).on) {
        [((UISwitch *)sender) setOn:YES];
        // [setting setBool:YES forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateReceiverModeState:1 :[_conn.userId intValue]];//打开
        
    }else
    {
        [((UISwitch *)sender) setOn:NO];
        //[setting setBool:NO forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateReceiverModeState:0 :[_conn.userId intValue]];//关闭
    }
}

-(void)updateRcvMsgFlag:(id)sender
{
	
	UISwitch *_switch = (UISwitch*)sender;
	if(_switch.isOn)
	{
		newMsgRcvFlag = rcv_msg_all_the_time;
	}
	else
	{
		newMsgRcvFlag = rcv_msg_when_pc_leave_or_offline;
	}
	[[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"please_wait"]];
	[[LCLLoadingView currentIndicator]showSpinner];
	[[LCLLoadingView currentIndicator]show];
	
	if(![[conn getConn]modifyUserInfo:12 andNewValue:[StringUtil getStringValue:newMsgRcvFlag]]) //修改消息同步标志
	{
		[[LCLLoadingView currentIndicator]hiddenForcibly:true];
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"请求失败，请稍候再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingItem *_item = nil;
    
    int section = [indexPath section];
    
    id _id = [settingItemArray objectAtIndex:section];
    
    if ([_id isKindOfClass:[SettingItem class]]) {
        _item = (SettingItem *)_id;
    }
    else{
        int row = indexPath.row;
        NSArray *array = [settingItemArray objectAtIndex:section];
        _item = [array objectAtIndex:row];
    }
    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (long long) fileSizeAtPath:(NSString*) filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(void)dealloc
{
    [settingItemArray release];
    settingItemArray = nil;
    
    usualView = nil;
    allSize = nil;
    [delete release];
    [super dealloc];
}


#pragma mark ======手动刷新通讯录========

- (void)refreshOrgByHand
{
//    如果用户在线
    if (_conn.userId && _conn.userStatus == status_online)
    {
        [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
        //	add by shisp  注册组织架构信息变动通知
        [[eCloudDAO getDatabase]refreshOrgByHand];
    }
    else
    {
        [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"connResult_noLogin"]];
    }
}
#pragma mark 刷新组织架构
- (void)refreshOrg:(NSNotification *)notification
{
    eCloudNotification *cmd = notification.object;
    switch (cmd.cmdId) {
        case refresh_org_byhand_finish:
        {
            [UserTipsUtil hideLoadingView];
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"usual_refresh_org_by_hand_finish"] autoDimiss:YES];
        }
            break;
        default:
            break;
    }
}
//提示用户是否要刷新通讯录
- (void)showRefreshOrgAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"usual_confirm_refresh_org_by_hand"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    alert.tag = 100;
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self refreshOrgByHand];
    }
}

- (void)handleNoConnect:(NSNotification *)notification
{
    conn *_conn = [conn getConn];
    if (_conn.isRefreshOrgByHand) {
        [UserTipsUtil hideLoadingView];
        [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"user_is_offline"] autoDimiss:YES];
    }
}

#pragma mark ========准备设置项数组=========
- (void)prepareSettingItems
{
    settingItemArray = [[NSMutableArray alloc]init];

    SettingItem *_item = nil;
    
//    语言
    if ([[eCloudConfig getConfig]supportLanguageSetting]) {
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"usual_language"];
        _item.clickSelector = @selector(openLanuangeSettingVC);
        
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [settingItemArray addObject:_item];
        [_item release];
    }
    
//    同步消息
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_synchronous_message"];
    
    _item.customCellSelector = @selector(customCellOfMsgSync:);
    [settingItemArray addObject:_item];
    [_item release];
    
//    听筒模式
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_receiver_button"];
    
    _item.customCellSelector = @selector(customCellOfReceiverMode:);

    [settingItemArray addObject:_item];
    [_item release];

//    聊天界面的设置
    NSMutableArray *chatSettingArray = [NSMutableArray array];
    
//    字号设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_font_size"];
    
    _item.clickSelector = @selector(openFontSizeSettingVC);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;

    [chatSettingArray addObject:_item];
    [_item release];
    
//    字体设置
    if ([[eCloudConfig getConfig]supportFontStyleSetting]) {
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"usual_font"];
        [chatSettingArray addObject:_item];
        [_item release];
    }
    
//    聊天背景
    if (![UIAdapterUtil isGOMEApp])
    {
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"usual_chat_background"];
        _item.clickSelector = @selector(openChatBackgroundSettingVC);
        
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [chatSettingArray addObject:_item];
        [_item release];
    }
    
    [settingItemArray addObject:chatSettingArray];
    
    
    
//    查看聊天记录
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_view_chat_records"];
    _item.clickSelector = @selector(openChatRecordVC);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;

    [settingItemArray addObject:_item];
    [_item release];

//    刷新组织架构
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"usual_refresh_org_by_hand"];
    _item.clickSelector = @selector(showRefreshOrgAlert);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;

    _item.headerHight = refreshOrgTipsHeight;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIAdapterUtil getTableCellContentWidth], refreshOrgTipsHeight)];
    headerView.backgroundColor = self.view.backgroundColor;
    
    UILabel *titlelabel=[[UILabel alloc]initWithFrame:CGRectMake(12, 12, [UIAdapterUtil getTableCellContentWidth] - 24, refreshOrgTipsHeight)];
    titlelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titlelabel.numberOfLines = 0;
    titlelabel.backgroundColor = [UIColor clearColor];
    titlelabel.font=[UIFont systemFontOfSize:tips_font_size];
    titlelabel.textColor = [UIColor grayColor];
    titlelabel.text= [StringUtil getLocalizableString:@"usual_refresh_org_by_hand_tips"];
    [headerView addSubview:titlelabel];
    [titlelabel release];
    
    _item.headerView = headerView;
    
    [headerView release];
    
    [settingItemArray addObject:_item];
    [_item release];

//    清理存储空间
//    _item = [[SettingItem alloc]init];
//    _item.itemName = [StringUtil getLocalStringRelatedWithAppNameByKey:@"usual_clear_data"];
//    _item.clickSelector = @selector(openClearDataVC);
//    
//    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    _item.selectionStyle = UITableViewCellSelectionStyleGray;
//    _item.customCellSelector = @selector(customCellOfClearData:);
//    [settingItemArray addObject:_item];
//    [_item release];
  
}

//修改语言
- (void)openLanuangeSettingVC
{
    chooseLanguageViewController *_chooseLanguageController = [[chooseLanguageViewController alloc]init];
    [self.navigationController pushViewController:_chooseLanguageController animated:YES];
    [_chooseLanguageController release];
    
//    UINavigationController *navigationController = [[UINavigationController alloc]
//                                                    initWithRootViewController:_chooseLanguageController];
//    [self presentViewController:navigationController animated:YES completion:nil];
//    
//    [_chooseLanguageController release];
//    [navigationController release];
}

//打开字体设置界面
- (void)openFontSizeSettingVC
{
    FontSizeSettingViewController *_controller = [[FontSizeSettingViewController alloc]init];// [[FontSizeSettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:_controller animated:YES];
    [_controller release];
}

//打开聊天背景设置界面
- (void)openChatBackgroundSettingVC
{
    chatBackgroudViewController *_chatBackgroudController = [[chatBackgroudViewController alloc]init];
    [self.navigationController pushViewController:_chatBackgroudController animated:YES];
    [_chatBackgroudController release];
}

//打开查看聊天记录界面
- (void)openChatRecordVC
{
    chatRecordViewController *chatRecordView = [[chatRecordViewController alloc] init];
    [self.navigationController pushViewController:chatRecordView animated:YES];
    [chatRecordView release];
}

//打开清理缓存界面
- (void)openClearDataVC
{
    clearDataViewController *clearDataView = [[clearDataViewController alloc] init];
    [self.navigationController pushViewController:clearDataView animated:YES];
    [clearDataView release];
}

//清楚缓存功能需要定制的cell
- (void)customCellOfClearData:(UITableViewCell *)cell
{
    long long temp = [UserDefaults getAllStorage];
    if (temp > (1024*1024*200))
    {
        CGSize _size = [cell.textLabel.text sizeWithFont:cell.textLabel.font];
        UIImageView *clearView = [[UIImageView alloc]initWithFrame:CGRectMake(_size.width + 30, 18, 9, 9)];
        clearView.image =  [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        [cell addSubview:clearView];
        [clearView release];
    }
}

//消息同步需要定制的cell
- (void)customCellOfMsgSync:(UITableViewCell *)cell
{
    CGRect switchRect = CGRectMake(220,12,0,0);
    UISwitch *_switch = [[UISwitch alloc] initWithFrame:switchRect];
    _switch.onTintColor = UIColorFromRGB(0x2481FC);
    [self positionSwitch:_switch ofCell:cell];
    
    if (_conn.userRcvMsgFlag==rcv_msg_all_the_time)
    {
        [_switch setOn:YES];
    }
    else
    {
        [_switch setOn:NO];
    }
    
    [_switch addTarget:self action:@selector(updateRcvMsgFlag:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:_switch];
    [_switch release];
}

//听筒模式定制cell
- (void)customCellOfReceiverMode:(UITableViewCell *)cell
{
    CGRect switchRect = CGRectMake(220,12,0,0);
    UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:switchRect];
    mySwitch.onTintColor = UIColorFromRGB(0x2481FC);
    [self positionSwitch:mySwitch ofCell:cell];
    UserInfo *userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    if (userinfo.receiver_model_Flag==1) {
        [mySwitch setOn:YES];
    }else
    {
        [mySwitch setOn:NO];
    }
    [mySwitch addTarget:self action:@selector(switchModeAction:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:mySwitch];
    [mySwitch release];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"%s",__FUNCTION__);
    
    [usualView reloadData];
}

@end
