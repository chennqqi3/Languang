//
//  XINHUASettingViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/4/26.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUASettingViewControllerArc.h"
#import "XINHUAUserInfoViewControllerArc.h"
#import "XINHUAgentLstViewControllerArc.h"

#import "XINHUAWebviewViewControllerArc.h"
#import "XINHUASettingDetailViewControllerArc.h"

#import "XINHUAGroupCellArc.h"
#import "eCloudDAO.h"

#import "UserDefaults.h"

#import "Emp.h"
#import "conn.h"
#import "StringUtil.h"
#import "ImageUtil.h"

@interface XINHUASettingViewControllerArc ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_labelArray;
    NSMutableArray *_imageArray;
}
- (IBAction)tapToUserInfo:(UITapGestureRecognizer *)sender;

@property (retain, nonatomic) IBOutlet UIView *headView;
@property (retain, nonatomic) IBOutlet UIImageView *userIcon;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UILabel *phoneNumberLabel;

@property (retain, nonatomic) IBOutlet UIImageView *settingImage;


- (IBAction)settingClick;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XINHUASettingViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    
    _labelArray = [[NSMutableArray alloc] initWithObjects:@"双创资讯", nil];
    _imageArray = [[NSMutableArray alloc] initWithObjects:@"chuangke", nil];
}

- (void)setupUI
{
    Emp *emp = [conn getConn].curUser;
    
    [self.settingImage setImage:[StringUtil getImageByResName:@"setting"]];
    
    self.headView.backgroundColor = [UIAdapterUtil getDominantColor];
    
    self.usernameLabel.text = emp.emp_name;
    self.phoneNumberLabel.text = emp.empCode;
    self.userIcon.image = [ImageUtil getEmpLogo:emp];
    self.userIcon.layer.cornerRadius = 5;
    self.userIcon.clipsToBounds = YES;
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 更改头像时可以实时更新到界面
    Emp *emp = [conn getConn].curUser;
    self.userIcon.image = [ImageUtil getEmpLogo:emp];
    
    self.usernameLabel.text = emp.emp_name;
    NSString *account = [UserDefaults getUserAccount];
    self.phoneNumberLabel.text = emp.empCode ?: account;
    
    self.navigationController.navigationBar.hidden = YES;
    
    [UIAdapterUtil showTabar:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"XINHUAsettingCell";
    
    XINHUAGroupCellArc *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[XINHUAGroupCellArc alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    cell.groupName.text = [_labelArray objectAtIndex:indexPath.row];
    cell.groupLogo.image = [StringUtil getImageByResName:[_imageArray objectAtIndex:indexPath.row]];
    
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XINHUAWebviewViewControllerArc *agent = [[XINHUAWebviewViewControllerArc alloc]init];
    agent.urlstr = @"http://cx.news.cn/index.htm";
    [self.navigationController pushViewController:agent animated:YES];
    
    [UIAdapterUtil hideTabBar:self];
}

- (IBAction)tapToUserInfo:(UITapGestureRecognizer *)sender
{
    XINHUAUserInfoViewControllerArc *userInfoCtl = [[XINHUAUserInfoViewControllerArc alloc] init];
    Emp *emp = [conn getConn].curUser;
    eCloudDAO *_ecloud = [eCloudDAO getDatabase];
    Emp *emp1 = [_ecloud getEmpInfo:[NSString stringWithFormat:@"%d",emp.emp_id]];
    userInfoCtl.emp = emp1;
    [self.navigationController pushViewController:userInfoCtl animated:YES];
}

- (IBAction)settingClick
{
    XINHUASettingDetailViewControllerArc *settingVC = [[XINHUASettingDetailViewControllerArc alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

@end
