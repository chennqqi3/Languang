//
//  GOMESettingViewController.m
//  eCloud
//
//  Created by shisuping on 16/12/14.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "GOMESettingViewController.h"
#import "MessageView.h"
#import "settingViewController.h"
#import "FileAssistantViewController.h"
#import "GOMERegisterMailViewControllerArc.h"
#import "ImageUtil.h"
#import "conn.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "IOSSystemDefine.h"
#import "SettingItem.h"
#import "TabbarUtil.h"
#import "myCutomCell.h"
#import "NewOrgViewController.h"
#import "GOMEQRCodeViewController.h"
#import "GOMEEmailUtilArc.h"
#import "UserDefaults.h"
#import "GOMEMailDefine.h"

#define ACTIVATE_LABEL_TAG 2309

@interface GOMESettingViewController ()<UITableViewDelegate,UITableViewDataSource>


@end

@implementation GOMESettingViewController{
    
    UITableView *settingTable;
    //    设置项数组
    NSMutableArray *settingItemArray;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    settingTable= [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT) style:UITableViewStyleGrouped]autorelease];
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
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displayTabBar];
    
    self.title = [StringUtil getAppLocalizableString:@"main_settings"];
    
    [self prepareSettingItems];
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
    FileAssistantViewController *fileVC=[[[FileAssistantViewController alloc]init]autorelease];
    [self.navigationController pushViewController:fileVC animated:YES];
}
//打开设置界面
- (void)openSetting
{
    settingViewController *settingVc = [[[settingViewController alloc]init]autorelease];
    [self.navigationController pushViewController:settingVc animated:YES];
}

//打开二维码界面
- (void)openQRCode
{
    GOMEQRCodeViewController *qrCodeVC = [[[GOMEQRCodeViewController alloc] initWithNibName:@"GOMEQRCodeViewController" bundle:nil]autorelease];
    [self.navigationController pushViewController:qrCodeVC animated:YES];
}

//邮件代收
- (void)mailServer
{
    GOMERegisterMailViewControllerArc *registerVc = [[[GOMERegisterMailViewControllerArc alloc] init]autorelease];
    [self.navigationController pushViewController:registerVc animated:YES];
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
        [newButton release];
        
        [TabbarUtil setTabbarBage:@"new" andTabbarIndex:[eCloudConfig getConfig].settingIndex];

    }else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].settingIndex];
    }
}
- (void)prepareSettingItems
{
    settingItemArray = [[NSMutableArray alloc]init];
    
    SettingItem *_item = nil;
    
//    登录用户资料
    _item = [[SettingItem alloc]init];
    _item.clickSelector = @selector(openUserInfo);
    [settingItemArray addObject:[NSArray arrayWithObject:_item]];
    
    [_item release];

    
    //    我的文件
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"me_file_assistant"];
    _item.imageName = [[StringUtil getBundle] pathForResource:@"setting_file.png" ofType:nil];
    _item.clickSelector = @selector(openFileAssistant);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [settingItemArray addObject:[NSArray arrayWithObject:_item]];
    [_item release];
    
    
    //    设置
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"settings_settings"];
    _item.imageName = [[StringUtil getBundle] pathForResource:@"setting_setting.png" ofType:nil];
    _item.clickSelector = @selector(openSetting);
    _item.customCellSelector = @selector(customCellOfSetting:);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [settingItemArray addObject:[NSArray arrayWithObject:_item]];
    [_item release];
    
    
    //    国美小虫下载地址
    _item = [[SettingItem alloc]init];
    _item.itemName = [StringUtil getLocalizableString:@"settings_download_website"];
    _item.imageName = [[StringUtil getBundle] pathForResource:@"setting_qrcode.png" ofType:nil];
    _item.clickSelector = @selector(openQRCode);
    
    _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _item.selectionStyle = UITableViewCellSelectionStyleGray;
    
    [settingItemArray addObject:[NSArray arrayWithObject:_item]];
    [_item release];
    
    if (START_GOME_MAIL) {
        //    邮件代收
        _item = [[SettingItem alloc]init];
        _item.itemName = [StringUtil getLocalizableString:@"邮件代收"];
        _item.imageName = [[StringUtil getBundle] pathForResource:@"email_service_icon.png" ofType:nil];
        _item.clickSelector = @selector(mailServer);
        
        _item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _item.selectionStyle = UITableViewCellSelectionStyleGray;
        
        [settingItemArray addObject:[NSArray arrayWithObject:_item]];
        [_item release];
    }
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
        return myCellHeight;
    }
    return DEFAULT_ROW_HEIGHT;
}

- (UITableViewCell *)getUserInfoCell
{
    myCutomCell *mCell = [[myCutomCell alloc] init];
    
    mCell.nameLable.text = [conn getConn].curUser.emp_name;
    mCell.iconView.image = [ImageUtil getOnlineEmpLogo:[conn getConn].curUser];
    mCell.newButton.hidden = YES;
    
    return [mCell autorelease];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self getUserInfoCell];
    }
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil]autorelease];
    
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textColor = GOME_NAME_COLOR;
    
    
    SettingItem *_item = [self getSettingItemByIndexPath:indexPath];
    
    cell.textLabel.text = _item.itemName;
    cell.imageView.image = [UIImage imageWithContentsOfFile:_item.imageName];
    cell.selectionStyle = _item.selectionStyle;
    
    if (cell.selectionStyle == UITableViewCellSelectionStyleGray) {
        [UIAdapterUtil customSelectBackgroundOfCell:cell];
    }
    
    cell.accessoryType = _item.accessoryType;
    
    
    if (_item.customCellSelector) {
        [self performSelector:_item.customCellSelector withObject:cell];
    }
    
    
    if (indexPath.section == 4)
    {
        UILabel *activateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 10, 80, 25)] autorelease];
        [activateLabel setFont:[UIFont systemFontOfSize:16]];
        
        NSString *status = [GOMEUserDefaults getGOMEEmailStatus];
        
        if ([status isEqualToString:@"success"])
        {
            activateLabel.text = [StringUtil getLocalizableString:@"activated"];
            activateLabel.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        }
        else
        {
            activateLabel.text = [StringUtil getLocalizableString:@"inactive"];
            activateLabel.textColor = [UIColor colorWithRed:0XFF/255.0 green:0X33/255.0  blue:0X33/255.0  alpha:1];
        }
        
        [cell addSubview:activateLabel];
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
        return FIRST_SECTION_HEADER_HEIGHT;
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
    
    return DEFAULT_SECTION_FOOTER_HEIGHT;
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

@end
