//
//  BGYSettingViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/6/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYSettingViewControllerArc.h"
#import "MessageView.h"
#import "settingViewController.h"
#import "FileAssistantViewController.h"
#import "ImageUtil.h"
#import "conn.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "eCloudDefine.h"
#import "IOSSystemDefine.h"
#import "SettingItem.h"
#import "TabbarUtil.h"
#import "myCutomCell.h"
#import "NewOrgViewController.h"
#import "UserDefaults.h"
#import "GXViewController.h"
#import "mainViewController.h"
#import "ServerConfig.h"
#import "BGYAgentViewControllerARC.h"

#define ACTIVATE_LABEL_TAG 2309

@interface BGYSettingViewControllerArc ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation BGYSettingViewControllerArc
{
    UITableView *settingTable;
    //    设置项数组
    NSMutableArray *settingItemArray;
    UIButton *modifySignatureButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    settingTable= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT) style:UITableViewStyleGrouped];
    [settingTable setDelegate:self];
    [settingTable setDataSource:self];
    
    [UIAdapterUtil setPropertyOfTableView:settingTable];
    [UIAdapterUtil setExtraCellLineHidden:settingTable];
    
    settingTable.showsHorizontalScrollIndicator = NO;
    settingTable.showsVerticalScrollIndicator = NO;
    
    settingTable.backgroundView = nil;
    settingTable.backgroundColor=[UIColor clearColor];
    
    settingTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:settingTable];
    
    UIView *buttonview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 58)];
    buttonview.backgroundColor = [UIColor whiteColor];
    
    modifySignatureButton=[UIAdapterUtil setNewButton:[StringUtil getLocalizableString:@"settings_log_out"] andBackgroundImage:[StringUtil getImageByResName:@""]];
    modifySignatureButton.frame=CGRectMake(0, 0, self.view.frame.size.width, 58);
    [modifySignatureButton addTarget:self action:@selector(exitAction:) forControlEvents:UIControlEventTouchUpInside];
    [modifySignatureButton setTitleColor:GOME_NAME_COLOR forState:UIControlStateNormal];
    [buttonview addSubview:modifySignatureButton];
    modifySignatureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    settingTable.tableFooterView=buttonview;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self displayTabBar];
    
    self.title = [StringUtil getAppLocalizableString:@"main_settings"];
    
    [self prepareSettingItems];
    [settingTable reloadData];
}

- (void)Picture{
    
    [settingTable reloadData];
}

#pragma mark ====准备要显示的条目======

//打开用户资料界面
- (void)openUserInfo
{
    [NewOrgViewController openUserInfoById:[conn getConn].userId andCurController:self];
}
//打开文件助手界面
- (void)openFileAssistant
{
    FileAssistantViewController *fileVC = [[FileAssistantViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}
//打开设置界面
- (void)openSetting
{
    settingViewController *settingVc = [[settingViewController alloc]init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

- (void)changePassword
{
    BGYAgentViewControllerARC *agent = [[BGYAgentViewControllerARC alloc]init];
    agent.urlstr = @"http://im.tahoecn.com:9010/TaiheServer/DataService1?username=ROE3i7rlvV0cairuibinQNVivIn/Jse12XqZFU/eNsje5Q4xEi8=&url=http://oa.tahoecn.com/ekp/taihe/app/changePwd.jsp";
    [self.navigationController pushViewController:agent animated:YES];
    
}
//如果有新版本 那么需要在设置 旁边 显示 一个new 标志
- (void)customCellOfSetting:(UITableViewCell *)cell
{
    if([conn getConn].hasNewVersion)
    {
        CGSize _size = [cell.textLabel.text sizeWithFont:cell.textLabel.font];
        
        UIButton *newButton=[[UIButton alloc]initWithFrame:CGRectMake(_size.width + (DEFAULT_ROW_HEIGHT + 10),(DEFAULT_ROW_HEIGHT - 20) / 2, 34, 20)];
        
        [newButton addTarget:self action:@selector(openSetting) forControlEvents:UIControlEventTouchUpInside];
        
        UIEdgeInsets capInsets = UIEdgeInsetsMake(9,9,9,9);
        MessageView *messageView = [MessageView getMessageView];
        UIImage *newMsgImage = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"app_new_push" andType:@"png"]];
        newMsgImage = [messageView resizeImageWithCapInsets:capInsets andImage:newMsgImage];
        
        [newButton setBackgroundImage:newMsgImage forState:UIControlStateNormal];
        newButton.backgroundColor=[UIColor clearColor];
        [newButton setTitle:@"new" forState:UIControlStateNormal];
        newButton.font=[UIFont boldSystemFontOfSize:12];
        [cell addSubview:newButton];
        
        [TabbarUtil setTabbarBage:@"new" andTabbarIndex:[eCloudConfig getConfig].settingIndex];
        
    }else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].settingIndex];
    }
}
- (void)prepareSettingItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
    NSMutableArray *arr1 = [NSMutableArray array];
    //    登录用户资料
    _item = [[SettingItem alloc]init];
    _item.clickSelector = @selector(openUserInfo);
    [arr1 addObject:_item];
    
    
    NSMutableArray *arr2 = [NSMutableArray array];
    //    我的文件
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"me_file_assistant"];
    _item.imageName = @"wenjian.png";
    _item.clickSelector = @selector(openFileAssistant);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [arr2 addObject:_item];
    
    
    //    设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"settings_settings"];
    _item.imageName = @"shezhi.png";
    _item.clickSelector = @selector(openSetting);
    _item.customCellSelector = @selector(customCellOfSetting:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [arr2 addObject:_item];
    
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"settings_change_password"];
    _item.imageName = @"xiugaimima.png";
    _item.clickSelector = @selector(changePassword);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [arr2 addObject:_item];
    
    [settingItemArray addObject:arr1];
    [settingItemArray addObject:arr2];
    
}
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
    if (indexPath.section == 0) {
        return 120;
    }
    return DEFAULT_ROW_HEIGHT;
}

- (UITableViewCell *)getUserInfoCell
{
    myCutomCell *mCell = [[myCutomCell alloc] init];
    
    mCell.nameLable.text = [conn getConn].curUser.emp_name;
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:[conn getConn].curUser];
    mCell.newButton.hidden = YES;
    
    return mCell;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self getUserInfoCell];
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = GOME_NAME_COLOR;
    
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    cell.textLabel.text = _item.itemName;
    cell.imageView.image = [StringUtil getImageByResName:_item.imageName];
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
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    if (_item.clickSelector) {
        [self performSelector:(_item.clickSelector)];
    }
    [self hideTabBar];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    SettingItem *_item = [self getSettingItemByIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    if (_item && _item.headerHight) {
        return _item.headerHight;
    }
    
    return DEFAULT_SECTION_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return FIRST_SECTION_FOOTER_HEIGHT;
    }
    
    return 50;
}

-(void)displayTabBar
{
    [UIAdapterUtil showTabar:self];
    self.navigationController.navigationBarHidden = NO;
}

-(void)hideTabBar
{
    [UIAdapterUtil hideTabBar:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (SettingItem *)getSettingItemByIndexPath:(NSIndexPath *)indexPath
{
    int section=[indexPath section];
    int row = [indexPath row];
    
    NSArray *_array = [settingItemArray objectAtIndex:section];
    SettingItem *_item = [_array objectAtIndex:row];
    return _item;
}

-(IBAction)exitAction:(id)sender
{
    conn *_conn = [conn getConn];
    
    NSString *temp = @"";
    if(_conn.connStatus == linking_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_connecting_server"];
    }
    else if(_conn.connStatus == rcv_type)
    {
        temp = [StringUtil getLocalizableString:@"settings_receiving_messages"];
    }
    else if(_conn.connStatus == download_org)
    {
        temp = [StringUtil getLocalizableString:@"settings_loading_organizational_structure"];
    }
    else if(_conn.downLoadImageStatus == download_guide)
    {
        temp = [StringUtil getLocalizableString:@"settings_download_guide"];
    }
    
    UIAlertView *tipAlert;
    if(temp.length > 0)
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        [tipAlert show];
        tipAlert = nil;
        return;
    }
    else
    {
        tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        
        [tipAlert show];
    }
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"退出登录");
        conn *_conn = [conn getConn];
        
        if(_conn.connStatus == normal_type)
        {
            [_conn logout:1];
            
            NSString *str =  [[ServerConfig shareServerConfig]getShareName];
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
            [sharedDefaults removeObjectForKey:@"isLogin"];
            
            [self exit];
        }
        else if(_conn.connStatus == not_connect_type)
        {
            [self exit];
        }
    }
}

-(void)exit
{
    [UserDefaults saveUserIsExit:YES];
    
    id tabbarVC = [TabbarUtil getTabbarController];
    if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
        id mainVC = ((GXViewController *)tabbarVC).delegate;
        [((mainViewController*)mainVC) backRoot];
    }
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
