//
//  BGYSettingViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/7/6.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYMoreViewControllerARC.h"

#import "NewOrgViewController.h"
#import "FileAssistantViewController.h"
#import "settingViewController.h"
#import "CollectionController.h"
#import "BGYUserInfoViewControllerARC.h"

#import "eCloudDefine.h"
#import "SettingItem.h"

#import "AppDelegate.h"

#import "UserDefaults.h"
#import "TabbarUtil.h"
#import "GXViewController.h"

#define ICON_X 15
#define ICON_Y 70
#define ICON_WIDTH 90
#define ICON_HEIGHT 90

#define HEADVIEW_HEIGHT 200

#define LOGOUT_BTN_X 20
#define LOGOUT_BTN_HEIGHT 50

#define CELL_HEIGHT 50

static BGYMoreViewControllerARC *moreViewController;

static NSString *moreViewID = @"moreViewID";
@interface BGYMoreViewControllerARC ()<UITableViewDataSource, UITableViewDelegate>
{
    CGPoint _point;
    CGFloat _x;
}

@property (nonatomic, strong) NSArray *itemArray;

@end

@implementation BGYMoreViewControllerARC

+ (BGYMoreViewControllerARC *)getMoreViewController
{
    if (moreViewController == nil)
    {
        moreViewController = [[BGYMoreViewControllerARC alloc] init];
    }
    
    return moreViewController;
}

- (NSArray *)itemArray
{
    if (_itemArray == nil) {
        
        NSMutableArray * array = [NSMutableArray array];
        SettingItem *item = nil;
        
        item = [[SettingItem alloc] init];
        item.clickSelector = @selector(openFileAssistant);
        item.imageName = @"more_file_assistant";
        item.itemName = @"我的文件";
        [array addObject:item];
        
        item = [[SettingItem alloc] init];
        item.clickSelector = @selector(openCollection);
        item.imageName = @"my_collections";
        item.itemName = @"收藏";
        [array addObject:item];
        
        item = [[SettingItem alloc] init];
        item.clickSelector = @selector(openSetting);
        item.imageName = @"more_setting";
        item.itemName = @"设置";
        [array addObject:item];
        
        item = [[SettingItem alloc] init];
//        item.clickSelector = @selector(openSetting);
        item.imageName = @"help_and_feedback";
        item.itemName = @"帮助与反馈";
        [array addObject:item];
        
        item = [[SettingItem alloc] init];
//        item.clickSelector = @selector(openSetting);
        item.imageName = @"more_version_infomation";
        item.itemName = @"版本信息";
        [array addObject:item];
        
        _itemArray = [array copy];
    }
    return _itemArray;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 添加灰色背景
    [self addBackgrounpView];
    
    // 添加“更多按钮”
    [self addMoreView];
    
    // 添加左滑隐藏的手势
    [self panToHideMoreView];
}

- (void)panToHideMoreView
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTohide:)];
    [self.moreView addGestureRecognizer:pan];
}

- (void)panTohide:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _point = [pan translationInView:self.moreView];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point1 = [pan translationInView:self.moreView];
            
            _x = (point1.x - _point.x);
            if (_x>0) {
                return;
            }
            CGRect rect = self.moreView.frame;
            rect.origin.x = _x;
            self.moreView.frame = rect;
            
            
            self.backgrounpView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3+_x/MORE_VIEW_WIDTH];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"%f",_x);
            if (-_x > (MORE_VIEW_WIDTH/4))
            {
                [self hideMoreVC];
            }
            else
            {
                [self showMoreViewController];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)addMoreView
{
    self.moreView = [[UIView alloc] initWithFrame:CGRectMake(-MORE_VIEW_WIDTH, 0, MORE_VIEW_WIDTH, SCREEN_HEIGHT)];
    self.moreView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.moreView];
    
    // 头部view
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MORE_VIEW_WIDTH, HEADVIEW_HEIGHT)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewUserInfo)];
    [headview addGestureRecognizer:tap];
    headview.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
    [self.moreView addSubview:headview];
    
    // 背景
    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MORE_VIEW_WIDTH, HEADVIEW_HEIGHT)];
    headImageView.image = [StringUtil getImageByResName:@"info_background"];
    [headview addSubview:headImageView];
    
    // 箭头
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.image = [StringUtil getImageByResName:@"view_info_detail"];
    arrow.frame = CGRectMake(MORE_VIEW_WIDTH-20-15, 102, 16, 25);
    [headview addSubview:arrow];
    
    // 头像
    UIImageView *icon = [[UIImageView alloc] init];
    icon.frame = CGRectMake(ICON_X, ICON_Y, ICON_WIDTH, ICON_HEIGHT);
    icon.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1];
    icon.image = [StringUtil getImageByResName:@"more_big_logo"];
    [headview addSubview:icon];
    // 圆角
    icon.layer.cornerRadius = ICON_WIDTH/2;
    icon.clipsToBounds = YES;
    
    // 用户名
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(115, 93, 160, 25);
    nameLabel.textColor = [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1];
    nameLabel.text = @"小张";
    [nameLabel setFont:[UIFont systemFontOfSize:28]];
    [headview addSubview:nameLabel];
    
    // 所在部门
    UILabel *deptLabel = [[UILabel alloc] initWithFrame:CGRectMake(115, 122, 200, 25)];
    deptLabel.text = @"碧桂园集团/行政部";
    deptLabel.textColor = [UIColor colorWithWhite:0.36 alpha:1];
    [deptLabel setFont:[UIFont systemFontOfSize:15]];
    [headview addSubview:deptLabel];
    
    // 设置列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADVIEW_HEIGHT+45, MORE_VIEW_WIDTH, CELL_HEIGHT*self.itemArray.count)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.moreView addSubview:tableView];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // 注册cell
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:moreViewID];
    
    // 退出登录按钮
    UIButton *logoutBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    logoutBtn.frame = CGRectMake(LOGOUT_BTN_X, SCREEN_HEIGHT-90, MORE_VIEW_WIDTH-LOGOUT_BTN_X*2, LOGOUT_BTN_HEIGHT);
    [logoutBtn setTitle:@"退出登录" forState:(UIControlStateNormal)];
    [logoutBtn addTarget:self action:@selector(exitAction) forControlEvents:(UIControlEventTouchUpInside)];
    logoutBtn.backgroundColor = [UIAdapterUtil getDominantColor];
    // 设置圆角
    logoutBtn.layer.cornerRadius = 5;
    logoutBtn.clipsToBounds = YES;
    [self.moreView addSubview:logoutBtn];
}

- (void)viewUserInfo
{
    BGYUserInfoViewControllerARC *userInfoCtl = [[BGYUserInfoViewControllerARC alloc] init];
    [self.navigationController pushViewController:userInfoCtl animated:YES];
}

- (void)showMoreViewController
{
    self.navigationController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.23f animations:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.backgrounpView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        strongSelf.moreView.frame = CGRectMake(0, 0, MORE_VIEW_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [UIAdapterUtil showTabar:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)addBackgrounpView
{
    self.backgrounpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.backgrounpView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMoreVC)];
    [self.backgrounpView addGestureRecognizer:tap];
}

- (void)hideMoreVC
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.2f animations:^{
        
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.backgrounpView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        strongSelf.moreView.frame = CGRectMake(-MORE_VIEW_WIDTH, 0, MORE_VIEW_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.navigationController.view.frame = CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    
}

- (void)openFileAssistant
{
    NSLog(@"我的文件");
    
    FileAssistantViewController *fileVC = [[FileAssistantViewController alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (void)openCollection
{
    NSLog(@"收藏");
    CollectionController *collectionVC = [[CollectionController alloc] init];
    [self.navigationController pushViewController:collectionVC animated:YES];
}

- (void)openSetting
{
    NSLog(@"设置");
    settingViewController *settingVc = [[settingViewController alloc]init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

//打开用户资料界面
- (void)openUserInfo
{
    [NewOrgViewController openUserInfoById:[conn getConn].userId andCurController:self];
}

#pragma mark 添加左边按钮
-(void)setLeftBtn
{
    [UIAdapterUtil setLeftButtonItemWithTitle:[StringUtil getLocalizableString:@"back"] andTarget:self andSelector:@selector(backButtonPressed:)];
}

-(void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreViewID];
    
    SettingItem *item = self.itemArray[indexPath.row];
    cell.textLabel.text = item.itemName;
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    cell.imageView.image = [StringUtil getImageByResName:item.imageName];
    
    return cell;
}

-(void)exitAction
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
    
    if(temp.length > 0)
    {
        UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:[StringUtil getAppName] ] message:temp delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [tipAlert dismissWithClickedButtonIndex:0 animated:YES];
        tipAlert.delegate = self;
        [tipAlert show];
    }
    else
    {
        UIAlertView *tipAlert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"settings_log_out?"] message:nil delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
        tipAlert.delegate = self;
        [tipAlert show];
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (buttonIndex==1)
        {
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

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingItem *item = self.itemArray[indexPath.row];
    if ([self respondsToSelector:item.clickSelector])
    {
        [self performSelector:item.clickSelector withObject:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

@end
