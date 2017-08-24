//
//  LANGUANGMyViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGMyViewControllerARC.h"
#import "SettingItem.h"

#import "StringUtil.h"
#import "ImageUtil.h"
#import "TabbarUtil.h"

#ifdef _LANGUANG_FLAG_
#import "RedpacketViewControl.h"
#import "LANGUANGMeetingListViewControllerARC.h"
#endif

#import "UserDefaults.h"
#import "ServerConfig.h"

#import "LGSettingCellArc.h"

#import "mainViewController.h"
#import "FileAssistantViewController.h"
#import "NewOrgViewController.h"
#import "GXViewController.h"
#import "LGMSGSettingViewControllerArc.h"
#import "CollectionController.h"
#import "settingViewController.h"
#import "LGInvoiceControllerARC.h"

#import "conn.h"

@interface LANGUANGMyViewControllerARC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    CGFloat _tableViewLineX;

}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation LANGUANGMyViewControllerARC

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        
        SettingItem *_item = nil;
        
        
         NSMutableArray *arr1 = [NSMutableArray array];
        //    登录用户资料
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@""];
        _item.clickSelector = @selector(openUserInfo);
        [arr1 addObject:_item];
        
        
        NSMutableArray *arr2 = [NSMutableArray array];
        //    红包
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"chats_talksession_message_red_packet"];
        _item.imageName = @"hongbao.png";
        _item.clickSelector = @selector(openRedpaket);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr2 addObject:_item];
        
        
        NSMutableArray *arr3 = [NSMutableArray array];
        //    我的文件
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"me_file_assistant"];
        _item.imageName = @"wenjian.png";
        _item.clickSelector = @selector(openFileAssistant);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr3 addObject:_item];
        
        
        //    收藏
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"collect"];
        _item.imageName = @"shouchang.png";
        _item.clickSelector = @selector(openCollection);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr3 addObject:_item];
        
        //    常用信息
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"me_common"];
        _item.imageName = @"changyong.png";
        _item.clickSelector = @selector(openCommon);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr3 addObject:_item];
        
        
        NSMutableArray *arr4 = [NSMutableArray array];
        //    设置
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"settings_settings"];
        _item.imageName = @"shezhi.png";
        _item.clickSelector = @selector(openSetting);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr4 addObject:_item];
        
        
        //    修改密码
//        _item = [[SettingItem alloc]init];
//        _item.itemName = [StringUtil getLocalizableString:@"修改密码"];
//        _item.imageName = @"suo.png";
//        _item.clickSelector = @selector(changePassword);
//        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        _item.selectionStyle = UITableViewCellSelectionStyleGray;
//        [arr4 addObject:_item];
        
        
        NSMutableArray *arr5 = [NSMutableArray array];
        //    退出登录
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"settings_log_out"];
        _item.clickSelector = @selector(logoutIfPermission);
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        [arr5 addObject:_item];
        
        
        [mArr addObject:arr1];
        [mArr addObject:arr2];
        [mArr addObject:arr3];
        [mArr addObject:arr4];
        [mArr addObject:arr5];
        
        
        _dataArray = [mArr copy];
    }
    
    return _dataArray;
}

- (void)openUserInfo
{
    [NewOrgViewController openUserInfoById:[conn getConn].userId andCurController:self];
}

- (void)openRedpaket
{
#ifdef _LANGUANG_FLAG_
    
    [RedpacketViewControl presentChangePocketViewControllerFromeController:self];

#endif
}

- (void)openFileAssistant
{
    FileAssistantViewController *fileVC=[[FileAssistantViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (void)openCollection
{
    CollectionController *collectCtl = [[CollectionController alloc] init];
    [self.navigationController pushViewController:collectCtl animated:YES];
    [UIAdapterUtil hideTabBar:self];
}

- (void)openSetting
{
    settingViewController *settingVC = [[settingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
    [UIAdapterUtil hideTabBar:self];
}

- (void)changePassword
{
    
    
}

- (void)openCommon
{
    LGInvoiceControllerARC *invoice = [[LGInvoiceControllerARC alloc]init];
    [self.navigationController pushViewController:invoice animated:YES];
    [UIAdapterUtil hideTabBar:self];
}
- (void)logoutIfPermission
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
        
        [StringUtil cleanCacheAndCookie];
        
        /** 蓝光退出登录 */
        [[NSNotificationCenter defaultCenter]postNotificationName:LG_LOG_OUT object:nil userInfo:nil];
        
    }
}

-(void)exit
{
    [UserDefaults saveUserIsExit:YES];
    [UserDefaults saveExistStatus:YES];
    
    id tabbarVC = [TabbarUtil getTabbarController];
    if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
        id mainVC = ((GXViewController *)tabbarVC).delegate;
        [((mainViewController*)mainVC) backRoot];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TABBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
     self.tableView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    [self.view addSubview:self.tableView];
   
    [UIAdapterUtil removeLeftSpaceOfTableViewCellSeperateLine:self.tableView];
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    //刷新通讯录语言
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLanguage) name:REFREASH_CONACTS_LANGUAGE object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil showTabar:self];
    self.title = [StringUtil getAppLocalizableString:@"main_settings"];
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
    LGSettingCellArc *cell = [[LGSettingCellArc alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    if (indexPath.section == 0)
    {
        Emp *emp = [conn getConn].curUser;
        cell.logoView.image = [ImageUtil getEmpLogo:emp];
        cell.nameLabel.text = emp.emp_name;
        //CGRect _frame = cell.arrowImage.frame;
        //_frame.origin.y = 28;
        //cell.arrowImage.frame = _frame;
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    else if (indexPath.section == (self.dataArray.count-1))
    {
        cell.logoutLabel.text = item.itemName ? item.itemName : @"";
        //cell.arrowImage.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.titleLabel.text = item.itemName ? item.itemName : @"";
        cell.icon.image = [StringUtil getImageByResName:item.imageName];
        _tableViewLineX = cell.titleLabel.frame.origin.x;

    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, _tableViewLineX, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}


#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataArray[indexPath.section];
    SettingItem *item = arr[indexPath.row];
    
    [self performSelector:item.clickSelector withObject:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 68;
    
    return 51;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 0.01;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == (self.dataArray.count-2))
    {
        return 32;
    }
    
    return 1;
}

- (void)Picture{
    
    [self.tableView reloadData];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFREASH_CONACTS_LANGUAGE object:nil];
    _dataArray = nil;
    //    [_settingArray removeAllObjects];
    
}

- (void)refreshLanguage
{
    _dataArray = nil;
    [_tableView reloadData];
}

@end
