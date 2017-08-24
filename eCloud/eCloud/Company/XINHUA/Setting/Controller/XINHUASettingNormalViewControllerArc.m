//
//  XINHUASettingNormalViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUASettingNormalViewControllerArc.h"

#import "chooseLanguageViewController.h"
#import "FontSizeSettingViewController.h"
#import "chatBackgroudViewController.h"

#import "SettingItem.h"

#import "UserTipsUtil.h"
#import "eCloudDAO.h"

#import "LCLLoadingView.h"

#import "MsgSyncDefine.h"

#import "conn.h"

#import "eCloudUser.h"
#import "UserInfo.h"

@interface XINHUASettingNormalViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>
{
    conn *_conn;
    int newMsgRcvFlag;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation XINHUASettingNormalViewControllerArc

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        SettingItem *item = nil;
        
        
        NSMutableArray *arr1 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"lanuange_settings"];
        item.clickSelector = @selector(openLanuangeSettingVC);
        [arr1 addObject:item];
        
        
        NSMutableArray *arr2 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"font_size"];
        item.clickSelector = @selector(openFontSizeSettingVC);
        [arr2 addObject:item];
        
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"chat_background"];
        item.clickSelector = @selector(openChatBackgroundSettingVC);
        [arr2 addObject:item];
        
        
        NSMutableArray *arr3 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"receiver_model"];
        item.clickSelector = @selector(switchModeAction:);
        [arr3 addObject:item];
        
        
        NSMutableArray *arr4 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"reload_address_book"];
        item.clickSelector = @selector(showRefreshOrgAlert);
        [arr4 addObject:item];
        
        
        NSMutableArray *mArr = [NSMutableArray array];
        [mArr addObject:arr1];
        [mArr addObject:arr2];
        [mArr addObject:arr3];
        [mArr addObject:arr4];
        
        
        _dataArray = [mArr copy];
    }
    
    return _dataArray;
}

//修改语言
- (void)openLanuangeSettingVC
{
    chooseLanguageViewController *_chooseLanguageController = [[chooseLanguageViewController alloc]init];
    [self.navigationController pushViewController:_chooseLanguageController animated:YES];
}

//打开字体设置界面
- (void)openFontSizeSettingVC
{
    FontSizeSettingViewController *_controller = [[FontSizeSettingViewController alloc]init];// [[FontSizeSettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:_controller animated:YES];
}

//打开聊天背景设置界面
- (void)openChatBackgroundSettingVC
{
    chatBackgroudViewController *_chatBackgroudController = [[chatBackgroudViewController alloc]init];
    [self.navigationController pushViewController:_chatBackgroudController animated:YES];
}

//提示用户是否要刷新通讯录
- (void)showRefreshOrgAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getAppLocalizableString:@"whether_reload_address_book"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self refreshOrgByHand];
    }
}

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

-(void)switchModeAction:(id)sender
{
    if (((UISwitch *)sender).on)
    {
        [((UISwitch *)sender) setOn:YES];
        // [setting setBool:YES forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateReceiverModeState:1 :[[conn getConn].userId intValue]];//打开
        
    }
    else
    {
        [((UISwitch *)sender) setOn:NO];
        //[setting setBool:NO forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateReceiverModeState:0 :[[conn getConn].userId intValue]];//关闭
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = [StringUtil getAppLocalizableString:@"common_setting"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _conn = [conn getConn];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStyleGrouped)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshOrg:) name:ORG_NOTIFICATION object:nil];
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:ORG_NOTIFICATION object:nil];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataArray[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    
    UITableViewCell *cell;
    
    if (indexPath.section == 2)
    {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
        
        UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 10, 50, 30)];
        [cell addSubview:switch1];
        
        [switch1 addTarget:self action:item.clickSelector forControlEvents:(UIControlEventValueChanged)];
        
        cell.textLabel.text = item.itemName;
        
        UserInfo *userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
        if (userinfo.receiver_model_Flag==1) {
            [switch1 setOn:YES];
        }else
        {
            [switch1 setOn:NO];
        }
        
        return cell;
    }
    
    
    cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = item.itemName;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 20;
    }
    
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    [self performSelector:item.clickSelector withObject:nil];
}

@end
