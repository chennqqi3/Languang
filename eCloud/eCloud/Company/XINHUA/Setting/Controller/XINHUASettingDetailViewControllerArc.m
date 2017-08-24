//
//  XINHUASettingDetailViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUASettingDetailViewControllerArc.h"
#import "XINHUASettingNormalViewControllerArc.h"
#import "aboutViewController.h"

#import "mainViewController.h"
#import "GXViewController.h"

#import "SettingItem.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "UserDefaults.h"
#import "TabbarUtil.h"

#import "UserInfo.h"

#import "eCloudUser.h"

#import "conn.h"

#define SWITCH_TAG 1002
#define LOGOUT_TAG 1005

static NSString *settingDetailSwitchCellArcID = @"settingDetailSwitchCellArcID";
static NSString *settingDetaillogoutCellArcID = @"settingDetaillogoutCellArcID";
static NSString *settingDetailCellArcID = @"settingDetailCellArcID";
@interface XINHUASettingDetailViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>
{
    conn *_conn;
}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic,retain) UserInfo *userinfo;

@end

@implementation XINHUASettingDetailViewControllerArc

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        SettingItem *item = nil;
        
        
        NSMutableArray *arr1 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"sound"];
        [arr1 addObject:item];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"shake"];
        [arr1 addObject:item];
        
        
        NSMutableArray *arr2 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"common"];
        item.clickSelector = @selector(openSettingNormal);
        [arr2 addObject:item];
        
        NSMutableArray *arr3 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"about"];
        item.clickSelector = @selector(openSettingAbout);
        [arr3 addObject:item];
        
        
        NSMutableArray *arr4 = [NSMutableArray array];
        item = [[SettingItem alloc] init];
        item.itemName = [StringUtil getAppLocalizableString:@"logout"];
        item.clickSelector = @selector(logout);
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

- (void)openSettingNormal
{
    XINHUASettingNormalViewControllerArc *normalVC = [[XINHUASettingNormalViewControllerArc alloc] init];
    [self.navigationController pushViewController:normalVC animated:YES];
}

- (void)openSettingAbout
{
    aboutViewController *aboutController=[[aboutViewController alloc]init];
    [self.navigationController pushViewController:aboutController animated:YES];
}

- (void)logout
{
    UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
    
    [tipAlert show];
}

#pragma mark - <UIAlertViewDelegate>
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSLog(@"退出登录");
        
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [StringUtil getAppLocalizableString:@"setting"];
    
    
    _conn = [conn getConn];
    self.userinfo= [[eCloudUser getDatabase] searchUserObjectByUserid:_conn.userId];
    

    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:(UITableViewStyleGrouped)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:settingDetailCellArcID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
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
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:settingDetailSwitchCellArcID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:settingDetailSwitchCellArcID];
            
            UISwitch *switch1 = [[UISwitch alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 10, 50, 30)];
            switch1.tag = SWITCH_TAG;
            [cell addSubview:switch1];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        
        UISwitch *mySwitch = [cell viewWithTag:SWITCH_TAG];
        
        if (indexPath.row==0)
        {
            [mySwitch addTarget:self action:@selector(switchVoice:) forControlEvents:(UIControlEventValueChanged)];
            
            if (self.userinfo.voiceFlag==1) {
                [mySwitch setOn:YES];
            }else
            {
                [mySwitch setOn:NO];
            }
        }
        else
        {
            [mySwitch addTarget:self action:@selector(switchVibrate:) forControlEvents:(UIControlEventValueChanged)];
            
            if (self.userinfo.vibrateFlag==1) {
                [mySwitch setOn:YES];
            }
            else
            {
                [mySwitch setOn:NO];
            }
        }
        
        
        cell.textLabel.text = item.itemName;
        
        return cell;
    }
    
    
    if (indexPath.section == 3)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:settingDetaillogoutCellArcID];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:settingDetaillogoutCellArcID];
            
            UILabel *logout = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-100)/2.0, 10, 100, 30)];
            logout.textAlignment = NSTextAlignmentCenter;
            logout.tag = LOGOUT_TAG;
            [cell addSubview:logout];
        }
        
        UILabel *label = [cell viewWithTag:LOGOUT_TAG];
        label.text = item.itemName;
        
        return cell;
    }
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:settingDetailCellArcID];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = item.itemName;
    
    return cell;
}

- (void)switchVoice:(UISwitch *)sender
{
    if (((UISwitch *)sender).on) {
        [((UISwitch *)sender) setOn:YES];
        // [setting setBool:YES forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateVoiceRemindState:1 :[_conn.userId intValue]];//打开
        
    }else
    {
        [((UISwitch *)sender) setOn:NO];
        //[setting setBool:NO forKey:@"soundSet"];
        [[eCloudUser getDatabase] updateVoiceRemindState:0 :[_conn.userId intValue]];//关闭
        
    }
}

- (void)switchVibrate:(UISwitch *)sender
{
    if (((UISwitch *)sender).on)
    {
        [((UISwitch *)sender) setOn:YES];
        [[eCloudUser getDatabase] updateVibrateRemindState:1 :[_conn.userId intValue]];//打开
    }
    else
    {
        [((UISwitch *)sender) setOn:NO];
        [[eCloudUser getDatabase] updateVibrateRemindState:0 :[_conn.userId intValue]];//关闭
    }
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
    if (item.clickSelector) {
        
        [self performSelector:item.clickSelector withObject:nil];
    }
}

@end
