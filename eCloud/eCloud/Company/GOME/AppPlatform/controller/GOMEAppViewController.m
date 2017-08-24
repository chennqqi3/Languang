//
//  ViewController.m
//  GOME_DEMO
//
//  Created by Alex L on 16/11/29.
//  Copyright © 2016年 Alex L. All rights reserved.
//

#import "GOMEAppViewController.h"
#import "UserTipsUtil.h"
#import "CubeRootViewController.h"

//#import "GSAMyShopMainViewController1.h"

#import "NewMsgNumberUtil.h"
#import "APPUtil.h"
#import "GOMEAPPCell.h"
#import "SDCycleScrollView.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "UserDefaults.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "conn.h"
#import "TabbarUtil.h"
//#import "GSAGSMHeader.h"
#import "mainViewController.h"
#import "AppDelegate.h"

#import "GOMEAddAppViewController.h"

#ifdef _GOME_FLAG_
#import "GMShoppingDayGo.h"
#endif

#import "AgentListViewController.h"
//#import "GSAWeekReportViewController1.h"
//#import "GSAMeetingMainViewController.h"
//#import "GSAEmolumentMainViewController.h"
//#import "GSASpecialMainViewController.h"
//#import "GSAPunishmentMainViewController.h"
//#import "GSAStoreMainViewController.h"
//#import "GSABusinessMainViewController.h"
//#import "GSAAwardMainViewController.h"
//#import "GSAExamineMainViewController.h"
//#import "GSAPersonalReportMainViewController1.h"
//#import "GSAMyShopMainViewController.h"
//#import "GSAEvaluationMainViewController.h"
//#import "GSAShareMainViewController.h"

#define IPHONE_5S (SCREEN_HEIGHT == 568)
#define IPHONE_6  (SCREEN_HEIGHT == 667)
#define IPHONE_6P (SCREEN_HEIGHT == 736)

#define SYCLEVIEW_Y IOS8_OR_LATER ? 0 : 64

#define ITEM_WIDTH ((COLLECTION_W)/LINE_MAX_COUNT)
#define ITEM_HEIGHT (ITEM_WIDTH + (IPHONE_5S ? -6:(IPHONE_6 ? -4:0)))

/** 一行最多显示多少个图标 */
#define LINE_MAX_COUNT (IPHONE_6P ? 4.0 : (IPHONE_6 ?  4.0 : 3.0))
/** 显示多少列 */
#define INTERITEM_COUNT (IPHONE_6P ? 4 : (IPHONE_6 ?  4 : 3))

#define COLLECTION_X (IPHONE_6 ?  0 : 10)
#define COLLECTION_Y IOS8_OR_LATER ? (SCREEN_WIDTH/2+20) : ((SCREEN_WIDTH/2+20)+64)
#define COLLECTION_W (SCREEN_WIDTH-(2*COLLECTION_X))
#define COLLECTION_H (SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT - ((SCREEN_WIDTH/2+30))) //(INTERITEM_COUNT*ITEM_HEIGHT)

#define AUTO_SCROLL_TIME 5

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *AppCellIdentifier = @"AppCellIdentifier";
@interface GOMEAppViewController ()<SDCycleScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _isEditing;
}
@property (nonatomic, strong) NSMutableArray *appDataArray;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SDCycleScrollView *sycleView;

@end

@implementation GOMEAppViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
}

#pragma mark - 懒加载
- (NSMutableArray *)appDataArray
{
    if (_appDataArray == nil)
    {
        NSMutableArray *mArr = [NSMutableArray array];
        NSArray *array = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
        for (NSArray *arr1 in array)
        {
            for (APPListModel *model in arr1)
            {
                // .a文件里有才显示
                UIViewController *ctl = [[NSClassFromString(model.apppage1) alloc] init];
                if (ctl)
                {
                    // 只有显示在工作界面的才加到数组里
                    if (model.appShowFlag == app_show_flag_show)
                    {
                        [mArr addObject:model];
                        [LogUtil debug:[NSString stringWithFormat:@"%s %@ 显示 updatetime is %d sort is %d",__FUNCTION__,model.appname,model.update_time,model.sort]];
                    }
                    else
                    {
                        [LogUtil debug:[NSString stringWithFormat:@"%s %@ 不显示",__FUNCTION__,model.appname]];
                    }
                }
                else
                {
                    [LogUtil debug:[NSString stringWithFormat:@".a里不存在  不显示 : %@",model.appname]];
                }
            }
        }
        
        [mArr sortUsingComparator:^NSComparisonResult(APPListModel *obj1, APPListModel *obj2) {
            return [@(obj1.update_time) compare:@(obj2.update_time)];
        }];

        _appDataArray = [mArr copy];
        /*
        // 添加分割线
        // 添加横行
        NSInteger lineCount = (_appDataArray.count+(LINE_MAX_COUNT-1))/LINE_MAX_COUNT;
        for (int i = 1; i < lineCount; i++)
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, ITEM_HEIGHT*i+COLLECTION_Y, COLLECTION_W-20, 1)];
            lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            [self.view addSubview:lineView];
        }
        // 添加竖行
        for (int i = 1; i < LINE_MAX_COUNT; i++)
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10+ITEM_WIDTH*i, COLLECTION_Y+20, 1, lineCount*ITEM_HEIGHT-30)];
            lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            [self.view addSubview:lineView];
        }
         */
    }
    
    return _appDataArray;
}

#ifdef _GOME_FLAG_
- (instancetype)init
{
    if (self = [super init])
    {
        [self getAppUnread];
        
//        [GMShoppingDayGo getUnReadInternalPurchaseNum:[UserDefaults getGOMEEmpId] complete:^(NSString *str){
//            NSLog(@"goTestgoTestgoTestgoTest");
//            NSLog(@"unread--%@",str);
//            [TabbarUtil setTabbarBage:str andTabbarIndex:2];
//        }];
    }
    
    return self;
}
#endif

- (void)getAppBanner
{
    self.sycleView.autoScrollTimeInterval = [[UserDefaults getGomeAppBannerInterval] integerValue];
    self.sycleView.imageURLStringsGroup = [UserDefaults getGomeAppBanner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [StringUtil getAppLocalizableString:@"main_my"];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"6e5ec1e4e87649df92105e2fc633386c" forKey:@"accesstoken"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"10151365" forKey:@"employeeId"];
//    [[NSUserDefaults standardUserDefaults] setObject:@"123" forKey:@"employeeName"];
    
    
    self.sycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, SCREEN_WIDTH/2) delegate:self placeholderImage:[StringUtil getImageByResName:@"banner_placeholder"]];// [StringUtil getImageByResName:@"banner_placeholder"]
//    NSArray *imgNameArr = @[@"app_banner_0.jpg",@"app_banner_1.jpg"];
//    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:imgNameArr.count];
//    for (NSString *imgName in imgNameArr) {
//        NSString *imgPath = [[StringUtil getBundle] pathForResource:imgName ofType:@""];
//        if (imgPath) {
//            [arr addObject:imgPath];
//        }
//    }
//    sycleView.localizationImageNamesGroup = arr;
    [self getAppBanner];
    [self.view addSubview:self.sycleView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    flowLayout.minimumLineSpacing = 0;       // 行间距
    flowLayout.minimumInteritemSpacing = 0;  // 列间距
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(COLLECTION_X, COLLECTION_Y, COLLECTION_W, COLLECTION_H) collectionViewLayout:flowLayout];
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    // 注册cell
    [self.collectionView registerClass:[GOMEAPPCell class] forCellWithReuseIdentifier:AppCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    // 注册轻应用同步完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    
    // 注册轮播图片同步完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAppBanner) name:GOME_APP_BANNER_UPDATE_NOTIFICATION object:nil];
    
    [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"edit"] andTarget:self andSelector:@selector(test)];
}

- (void)test
{
    _isEditing = !_isEditing;
    
    if (_isEditing)
    {
        [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"cancel"] andTarget:self andSelector:@selector(test)];
        NSLog(@"正在编辑");
        /*
        //    隐藏默认应用外的其它应用
        NSArray *array = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
        for (NSArray *array1 in array) {
            for (APPListModel *model in array1) {
                if ([APPUtil isDefaultApp:model]) {
                    continue;
                }else{
                    if (model.appShowFlag == app_show_flag_hide){
                        [[APPPlatformDOA getDatabase]updateApp:model withShowFlag:app_show_flag_show];
                    }else{
                        [[APPPlatformDOA getDatabase]updateApp:model withShowFlag:app_show_flag_hide];
                    }
                }
            }
        }
         */
    }
    else
    {
        [UIAdapterUtil setRightButtonItemWithTitle:[StringUtil getLocalizableString:@"edit"] andTarget:self andSelector:@selector(test)];
        NSLog(@"取消编辑");
    }
    
    // 进入或取消 编辑状态
    [self.collectionView reloadData];
}

- (void)reloadCollectionView
{
    _appDataArray = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.collectionView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [UIAdapterUtil showTabar:self];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *naviVc = delegate.window.rootViewController;
    mainViewController *vc = [naviVc.viewControllers firstObject];
    if ([vc isKindOfClass:[mainViewController class]])
    {
        [vc showWaterMark];
    }

    [self getAppUnread];
}

- (void)getAppUnread
{
    //    内购会app
    APPListModel *purchaseApp = [[APPPlatformDOA getDatabase]getAPPModelByAppid:GOME_PURCHASE_APP_ID];
    if (purchaseApp.appid && purchaseApp.appShowFlag == app_show_flag_show) {
        
//        测试代码
//        int unread = 0;
//        for (APPListModel *_model in self.appDataArray) {
//            if (_model.appid == GOME_PURCHASE_APP_ID) {
//                _model.unread = unread;
//                break;
//            }
//        }
//        [_collectionView reloadData];
//        
//        if (unread) {
//            [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
//        }else{
//            [TabbarUtil setTabbarBage:@"0" andTabbarIndex:[eCloudConfig getConfig].myIndex];
//        }
//
//
#ifdef _GOME_FLAG_
        [GMShoppingDayGo getUnReadInternalPurchaseNum:[UserDefaults getGOMEEmpId] complete:^(NSString *str){
            NSLog(@"goTestgoTestgoTestgoTest");
            NSLog(@"unread--%@",str);
            if ([str compare:@"fail" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [LogUtil debug:[NSString stringWithFormat:@"%s 获取内购未读数失败",__FUNCTION__]];
            }else{
                [LogUtil debug:[NSString stringWithFormat:@"%s 获取内购未读数成功 未读数 %@",__FUNCTION__,str]];
                int unread = str.intValue;
                for (APPListModel *_model in self.appDataArray) {
                    if (_model.appid == GOME_PURCHASE_APP_ID) {
                        _model.unread = unread;
                        break;
                    }
                }
                [_collectionView reloadData];
                
                if (unread) {
                    [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }else{
                    [TabbarUtil setTabbarBage:@"0" andTabbarIndex:[eCloudConfig getConfig].myIndex];
                }
            }
        }];
#endif
    }else{
        [TabbarUtil setTabbarBage:@"0" andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.navigationController.viewControllers.count > 1)
    {
        [UIAdapterUtil hideTabBar:self];
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.appDataArray.count+1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if (indexPath.row < self.appDataArray.count)
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:AppCellIdentifier forIndexPath:indexPath];
        GOMEAPPCell *appCell = (GOMEAPPCell *)cell;
        
        appCell.isEditing = _isEditing;
        
        appCell.model = self.appDataArray[indexPath.row];
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:AppCellIdentifier forIndexPath:indexPath];
        GOMEAPPCell *appCell = (GOMEAPPCell *)cell;
        
        appCell.isEditing = NO;
        
        APPListModel *model = [[APPListModel alloc] init];
        model.appname = [StringUtil getLocalizableString:@"add"];
        model.appicon = @"add_app_ios";
        appCell.model = model;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - <UICollectionViewDataSource>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row %ld", (long)indexPath.row);
    
    
    if (_isEditing)
    {
        if (self.appDataArray.count > indexPath.row)
        {
            APPListModel *appModel = self.appDataArray[indexPath.row];
            if ([APPUtil isDefaultApp:appModel])
            {
                return;
            }
            
            [[APPPlatformDOA getDatabase] updateApp:appModel withShowFlag:app_show_flag_hide];
        }
    }
    else
    {
        NSString *token = [UserDefaults getGOMEToken];
        NSString *ID = [UserDefaults getGOMEEmpId];
        NSLog(@"token %@ \n ID %@",token, ID);
        
        conn *_conn = [conn getConn];
        if(_conn.userStatus == status_online)
        {
            if (indexPath.row < self.appDataArray.count)
            {
                APPListModel *appModel = self.appDataArray[indexPath.row];
                [[self class]openGomeApp:appModel andCurVC:self];
            }
            else
            {
                /*
                 NSString *testId = @"00000002";
                [GMShoppingDayGo goShoppingDayWithUserID:self userID:testId];
                [GMShoppingDayGo getUnReadInternalPurchaseNum:testId complete:^(NSString *str){
                    NSLog(@"goTestgoTestgoTestgoTest");
                    NSLog(@"unread--%@",str);
                }];
                
                GMShoppingDayGo *ctl = [[GMShoppingDayGo alloc] init];
                [self.navigationController pushViewController:ctl animated:YES];
                
                return;
                 */
                GOMEAddAppViewController *addAppCtl = [[GOMEAddAppViewController alloc] init];
                [self.navigationController pushViewController:addAppCtl animated:YES];
                
                NSLog(@"添加");
            }
        }
        else
        {
            [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"please_login_first"]];
        }
    }
}

- (void)openAgent:(APPListModel *)appModel
{
    NSString *agentUrl = nil;
    if ([appModel.apphomepage rangeOfString:@"?"].length > 0) {
        agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",appModel.apphomepage,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }else{
        agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",appModel.apphomepage,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
    }
    AgentListViewController *agentListVC = [[AgentListViewController alloc]init];
    
    // 测试用的token：8633bfe9-792a-4eb1-b4a3-5a9d0261ab05
    // 外网域名：http://moapproval.longfor.com:8080/moapproval/list.html
    
    agentListVC.urlstr = agentUrl;
    
    [self.navigationController pushViewController:agentListVC animated:YES];
}

+ (BOOL)openGomeApp:(APPListModel *)appModel andCurVC:(UIViewController *)curVC{
    if ([conn getConn].userStatus == status_online) {
        UIViewController *ctl = [[NSClassFromString(appModel.apppage1) alloc] init];
        
#ifdef _GOME_FLAG_
        //                国美内购会应用 使用接口提供的方法直接打开
        if ([ctl isKindOfClass:[GMShoppingDayGo class]]) {
            [GMShoppingDayGo goShoppingDayWithUserID:self userID:[UserDefaults getGOMEEmpId]];
            return YES;
        }
#endif
        //                        ctl = [[GSAMyShopMainViewController1 alloc]init];
        //        GSAWeekReportViewController1 *ctl = [[GSAWeekReportViewController1 alloc]init];
        //        GSAPersonalReportMainViewController1 *ctl = [[GSAPersonalReportMainViewController1 alloc]init];
        
        if (ctl)
        {
            //                    因为应用 小店 里有个设置头像的功能因为加了水印不能正常进行，所以打开小店时隐藏水印
            if ([ctl isKindOfClass:[CubeRootViewController class]] || appModel.appid == 121)
            {
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                UINavigationController *naviVc = delegate.window.rootViewController;
                mainViewController *vc = [naviVc.viewControllers firstObject];
                if ([vc isKindOfClass:[mainViewController class]])
                {
                    [vc hideWaterMark];
                }
            }
            //            NSLog(@"%@-%@" kGSAEmpNum ,kGSAAccessToken);
            [curVC.navigationController pushViewController:ctl animated:YES];
            return YES;
        }

    }else{
        [UserTipsUtil showAlert:[StringUtil getLocalizableString:@"please_login_first"]];
    }
    return NO;
}
@end
