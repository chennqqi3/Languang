//
//  BGYWorkViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/6/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYWorkViewControllerArc.h"
#import "NewMsgNumberUtil.h"
#import "APPUtil.h"
#import "SDCycleScrollView.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "UserDefaults.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "conn.h"
#import "TabbarUtil.h"
#import "AppDelegate.h"
#import "mainViewController.h"
#import "BGYWebViewControllerARC.h"

#import "BGYWorkCollectionHeaderViewArc.h"
#import "BGYWorkCollectionFooterViewArc.h"

#import "BGYWorkCellArc.h"

#define IPHONE_5S (SCREEN_HEIGHT == 568)
#define IPHONE_6  (SCREEN_HEIGHT == 667)
#define IPHONE_6P (SCREEN_HEIGHT == 736)

#define SYCLEVIEW_Y (IOS8_OR_LATER ? 0 : 64)

#define ITEM_WIDTH ((COLLECTION_W)/LINE_MAX_COUNT)
#define ITEM_HEIGHT (ITEM_WIDTH + (IPHONE_5S ? -6:(IPHONE_6 ? 1:0)))

/** 一行最多显示多少个图标 */
#define LINE_MAX_COUNT (IPHONE_6P ? 4.0 : (IPHONE_6 ?  4.0 : 3.0))
/** 显示多少列 */
#define INTERITEM_COUNT (IPHONE_6P ? 4 : (IPHONE_6 ?  4 : 3))

#define COLLECTION_X (IPHONE_6 ?  0 : 0)
#define COLLECTION_W (SCREEN_WIDTH-(2*COLLECTION_X))

#define AUTO_SCROLL_TIME 5

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *AppCellIdentifier = @"AppCellIdentifier";
static NSString *BGYWorkCollectionHeaderViewArcID = @"BGYWorkCollectionHeaderViewArcID";
static NSString *BGYWorkCollectionFooterViewArcID = @"BGYWorkCollectionFooterViewArcID";

@interface BGYWorkViewControllerArc ()<SDCycleScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *appDataArray;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SDCycleScrollView *sycleView;


@end

@implementation BGYWorkViewControllerArc

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
}

#pragma mark - 懒加载
- (NSArray *)titleArray
{
    if (_titleArray == nil)
    {
        _titleArray = @[@"常用应用", @"移动办公", @"流程系统"];
    }
    
    return _titleArray;
}

- (NSMutableArray *)appDataArray
{
    if (_appDataArray == nil)
    {
        /*
        NSMutableArray *mArr = [NSMutableArray array];
        NSArray *array = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
        
        for (NSArray *arr1 in array)
        {
            for (APPListModel *model in arr1)
            {
                [mArr addObject:model];
            }
        }
        
        if (mArr.count == 0) {
            
            
        }else{
            
            NSArray *arr1 = [mArr subarrayWithRange:NSMakeRange(0, 4)];
            NSArray *arr2 = [mArr subarrayWithRange:NSMakeRange(4, 4)];
            NSArray *arr3 = [mArr subarrayWithRange:NSMakeRange(8, 3)];
            NSMutableArray *mArr1 = [NSMutableArray array];
            [mArr1 addObject:arr1];
            [mArr1 addObject:arr2];
            [mArr1 addObject:arr3];
            
            
            _appDataArray = [mArr1 copy];
            
        }
        */
        
        NSArray *titleArr = @[@[@"待办事宜",@"邮箱"],@[@"管理桌面",@"日常管理",@"政策舆情",@"项目地图"],@[@"流程管理",@"NC主平台",@"明源ERP",@"H3"]];
        NSArray *iconArr  = @[@[@"组-72",@"组-73"],@[@"组-74",@"组-75",@"组-76",@"组-77"],@[@"组-78",@"组-79",@"组-80",@"组-81"]];
        
        NSMutableArray *mArr = [NSMutableArray array];
        for (int i = 0; i<titleArr.count; i++)
        {
            NSMutableArray *mArr1 = [NSMutableArray array];
            NSArray *arr1 = titleArr[i];
            NSArray *arr2 = iconArr[i];
            for (int j = 0; j<arr1.count; j++)
            {
                APPListModel *model = [[APPListModel alloc] init];
                model.appname = arr1[j];
                model.logopath = arr2[j];
                model.apphomepage = @"http://www.bgy.com.cn/mobile/?from=singlemessage";
                [mArr1 addObject:model];
            }
            [mArr addObject:mArr1];
        }
        
        
        _appDataArray = [mArr copy];
    }
    
    return _appDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [StringUtil getAppLocalizableString:@"工作"];
    
    // 展示左边侧边栏
    [UIAdapterUtil setupLeftIconItem:self];
    
    UIImage *image = [StringUtil getImageByResName:@"banner_placeholder"];
    CGFloat height = SCREEN_WIDTH*(image.size.height/image.size.width);
    
    self.sycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, height) delegate:self placeholderImage:image];
    
    [self.view addSubview:self.sycleView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    flowLayout.minimumLineSpacing = 0;       // 行间距
    flowLayout.minimumInteritemSpacing = 0;  // 列间距
    
    
    CGFloat COLLECTION_Y = (height)+SYCLEVIEW_Y;
    CGFloat COLLECTION_H = (SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT - ((height)));
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(COLLECTION_X, COLLECTION_Y, COLLECTION_W, COLLECTION_H) collectionViewLayout:flowLayout];
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    // 注册cell
    [self.collectionView registerClass:[BGYWorkCellArc class] forCellWithReuseIdentifier:AppCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[BGYWorkCollectionHeaderViewArc class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:BGYWorkCollectionHeaderViewArcID];
    [self.collectionView registerClass:[BGYWorkCollectionFooterViewArc class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:BGYWorkCollectionFooterViewArcID];
    
    // 注册轻应用同步完成通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCollectionView) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    
    // 注册轮播图片同步完成通知
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAppBanner) name:GOME_APP_BANNER_UPDATE_NOTIFICATION object:nil];
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
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.appDataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.appDataArray[section];
    return array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BGYWorkCellArc *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AppCellIdentifier forIndexPath:indexPath];
    NSArray *array = self.appDataArray[indexPath.section];
    APPListModel *model = array[indexPath.row];
    cell.model = model;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.appDataArray[indexPath.section];
    APPListModel *model = array[indexPath.row];
    BGYWebViewControllerARC *webCtl = [[BGYWebViewControllerARC alloc] init];
    webCtl.urlstr = model.apphomepage;
    [self.navigationController pushViewController:webCtl animated:YES];
}

// 这个方法是返回Header的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(120, 30);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(120, 1);
}

//获取Header或Footer的方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        BGYWorkCollectionHeaderViewArc *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:BGYWorkCollectionHeaderViewArcID forIndexPath:indexPath];
        headView.headerLabel.text = self.titleArray[indexPath.section];
        
        return headView;
    }
    else
    {
        BGYWorkCollectionFooterViewArc *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:BGYWorkCollectionFooterViewArcID forIndexPath:indexPath];
        return view;
    }
}

@end
