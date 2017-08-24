//
//  LGWorkViewControllerArc.m
//  eCloud
//
//  Created by Ji on 17/7/20.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LGWorkViewControllerArc.h"
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
#import "LANGUANGAgentViewControllerARC.h"
#import "LGMettingUtilARC.h"
#import "LGWorkCollectionHeaderViewArc.h"
#import "LGWorkCollectionFooterViewArc.h"
#import "LANGUANGWorkModelARC.h"
#import "LGWorkCellArc.h"

#define IPHONE_5S (SCREEN_HEIGHT == 568)
#define IPHONE_6  (SCREEN_HEIGHT == 667)
#define IPHONE_6P (SCREEN_HEIGHT == 736)

#define SYCLEVIEW_Y (IOS8_OR_LATER ? 0 : 64)

#define ITEM_WIDTH ((COLLECTION_W)/LINE_MAX_COUNT)
#define ITEM_HEIGHT (ITEM_WIDTH + (IPHONE_5S ? -6:(IPHONE_6 ? 1:0)))

/** 一行最多显示多少个图标 */
//#define LINE_MAX_COUNT (IPHONE_6P ? 4.0 : (IPHONE_6 ?  4.0 : 3.0))
#define LINE_MAX_COUNT  4

/** 显示多少列 */
//#define INTERITEM_COUNT (IPHONE_6P ? 4 : (IPHONE_6 ?  4 : 3))
#define INTERITEM_COUNT 4

#define COLLECTION_X (IPHONE_6 ?  0 : 0)
#define COLLECTION_W (SCREEN_WIDTH-(2*COLLECTION_X))

#define AUTO_SCROLL_TIME 5

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *AppCellIdentifier = @"AppCellIdentifier";
static NSString *LGWorkCollectionHeaderViewArcID = @"LGWorkCollectionHeaderViewArcID";
static NSString *LGWorkCollectionFooterViewArcID = @"LGWorkCollectionFooterViewArcID";

@interface LGWorkViewControllerArc ()<SDCycleScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *appDataArray;
@property(nonatomic,retain) NSMutableArray *guideImageArr;
@property(nonatomic,retain)UIScrollView *imageScrollView;
@property(nonatomic,retain)SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSArray *titleArray;
@property(nonatomic,retain) NSMutableArray *userDataTextArray;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) SDCycleScrollView *sycleView;


@end

@implementation LGWorkViewControllerArc

- (void)dealloc
{

}

#pragma mark - 懒加载
- (NSArray *)titleArray
{
    if (_titleArray == nil)
    {
        _titleArray = @[@"常用应用"];
    }
    
    return _titleArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    
    self.guideImageArr = [[NSMutableArray alloc]init];
    //[self loadHttpData];
    [self getAppListInfo];
    [self setupUI];
}

- (void)getAppListInfo
{
    // 保存完同步的轻应用发出的通知，刷新整个页面
    if (_appDataArray != nil && [_appDataArray count]) {
        [_appDataArray removeAllObjects];
    }
    self.userDataTextArray = [NSMutableArray array];
    NSMutableArray *array = [NSMutableArray array];
    _appDataArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    for (int i = 0 ; i < _appDataArray.count; i++) {
        
        NSArray *arr = _appDataArray[i];
        for (APPListModel *model in arr) {
            
            [array addObject:model];
            
        }
        
    }
    [self.userDataTextArray addObject:array];
    [self.collectionView reloadData];
}

#pragma mark - 请求登录界面广告信息接口
- (void)loadHttpData{
    
    id dict = [UserDefaults getTaiHeAppGuideImageUrl];
    
    if (dict == nil) {
        
        [self requestHttpData];
        
    }else{
        
        if (self.guideImageArr) {
            
            [self.guideImageArr removeAllObjects];
            
        }
        NSMutableArray *adInfoArr = dict[@"data"];
        for (NSDictionary *adInfoDic in adInfoArr) {
            
            LANGUANGWorkModelARC * entity = [[LANGUANGWorkModelARC alloc]init];
            [entity setValuesForKeysWithDictionary:adInfoDic];
            [self.guideImageArr addObject:entity];
        }
        
        [self initGuideImage];
        
        [self requestHttpData];
        
    }
    
}

- (void)requestHttpData{
    
    
    dispatch_queue_t queue = dispatch_queue_create("request Http Data", NULL);
    
    dispatch_async(queue, ^{
        
        //NSString *loginAdInfoUrl = [[ServerConfig shareServerConfig]getLoginADInfoUrl:1];
        NSString *loginAdInfoUrl = [NSString stringWithFormat:@"%@:8086/FilesService/getAdsInfo?type=1",[LGMettingUtilARC getInterfaceUrl]];
        
        NSDictionary *dict = [StringUtil getHtmlText:loginAdInfoUrl];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取首页广告信息 == %@",__FUNCTION__,dict]];
        if (dict) {
            
            NSString *status = [NSString stringWithFormat:@"%@",dict[@"status"]];
            if ([status isEqualToString:@"0"]) {
                
                id tempDict = [UserDefaults getTaiHeAppGuideImageUrl];
                if ([dict isEqualToDictionary:tempDict]) {
                    
                    return ;
                }
                
                NSMutableArray *adInfoArr = dict[@"data"];
                if (self.guideImageArr) {
                    
                    [self.guideImageArr removeAllObjects];
                    
                }
                for (NSDictionary *adInfoDic in adInfoArr) {
                    
                    LANGUANGWorkModelARC * entity = [[LANGUANGWorkModelARC alloc]init];
                    [entity setValuesForKeysWithDictionary:adInfoDic];
                    [self.guideImageArr addObject:entity];
                }
                
                [UserDefaults saveTaiHeAppGuideImageUrl:dict];
                
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self initGuideImage];
            
        });
        
    });
    
}

#pragma mark - 创建广告页和webview
- (void)initGuideImage{
    
        if (!self.imageScrollView) {
    
            self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, 150)];
            self.imageScrollView.pagingEnabled=YES;
            self.imageScrollView.showsVerticalScrollIndicator = NO;
            self.imageScrollView.showsHorizontalScrollIndicator = NO;
            self.imageScrollView.delegate = self;
            self.imageScrollView.userInteractionEnabled = YES;
            self.imageScrollView.bounces = NO;
            self.imageScrollView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:self.imageScrollView];
    
            NSMutableArray *imagesURLStrings;
            imagesURLStrings = [NSMutableArray array];
            for (int i = 0 ; i < self.guideImageArr.count; i++) {
    
                LANGUANGWorkModelARC * model = [[LANGUANGWorkModelARC alloc]init];
                model = self.guideImageArr[i];
    
                [imagesURLStrings addObject:model.thumb];
            }
    
            if (_cycleScrollView) {
    
                _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
    
            }else{
                _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height) delegate:self placeholderImage:nil];
                _cycleScrollView.backgroundColor = [UIColor whiteColor];
                _cycleScrollView.delegate = self;
                _cycleScrollView.currentPageDotColor = [UIColor grayColor];
                //暂时写死
//                _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
                
                //         --- 轮播时间间隔，默认1.0秒，可自定义
                _cycleScrollView.autoScrollTimeInterval = 8.0;
    
                [self.imageScrollView addSubview:_cycleScrollView];
            }
            //block监听点击方式
            __weak typeof(self) weakSelf = self;
            _cycleScrollView.clickItemOperationBlock = ^(NSInteger index) {
    
                //[weakSelf OpenImageLinks:index];
            };
        }
   
    
}

- (void)handleCmd:(NSNotification *)notif{
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1];
    self.title = [StringUtil getAppLocalizableString:@"工作"];
    
     //展示左边侧边栏
    //[UIAdapterUtil setupLeftIconItem:self];
    
    UIImage *image = [StringUtil getImageByResName:@"img_work_banner.png"];
    CGFloat height = 0;
    if(image)
    {
        height = SCREEN_WIDTH*(image.size.height/image.size.width);
    }
    
//    
//    self.sycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, height) delegate:self placeholderImage:image];
//    [self.view addSubview:self.sycleView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, height)];
    imageView.image = image;
    [self.view addSubview:imageView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_WIDTH, ITEM_HEIGHT);
    flowLayout.minimumLineSpacing = 0;       // 行间距
    flowLayout.minimumInteritemSpacing = 0;  // 列间距
    
    
    CGFloat COLLECTION_Y = (height)+SYCLEVIEW_Y + 12;
    CGFloat COLLECTION_H = (SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT - TABBAR_HEIGHT - 12-((height)));
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(COLLECTION_X, COLLECTION_Y, COLLECTION_W, COLLECTION_H) collectionViewLayout:flowLayout];
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    // 注册cell
    [self.collectionView registerClass:[LGWorkCellArc class] forCellWithReuseIdentifier:AppCellIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.collectionView registerClass:[LGWorkCollectionHeaderViewArc class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LGWorkCollectionHeaderViewArcID];
    [self.collectionView registerClass:[LGWorkCollectionFooterViewArc class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:LGWorkCollectionFooterViewArcID];

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
    return self.userDataTextArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.userDataTextArray[section];
    return array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGWorkCellArc *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AppCellIdentifier forIndexPath:indexPath];
    NSArray *array = self.userDataTextArray[indexPath.section];
    APPListModel *model = array[indexPath.row];
    cell.model = model;
    
    return cell;
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.userDataTextArray[indexPath.section];
    APPListModel *model = array[indexPath.row];
    LANGUANGAgentViewControllerARC *webCtl = [[LANGUANGAgentViewControllerARC alloc] init];
    webCtl.urlstr = model.apphomepage;
    if (model.appid == 10003) {
        
        webCtl.isNews = YES;
    }
    [self.navigationController pushViewController:webCtl animated:YES];
}

// 这个方法是返回Header的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(120, 50);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(120, 0.05);
}

//获取Header或Footer的方法。
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        LGWorkCollectionHeaderViewArc *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LGWorkCollectionHeaderViewArcID forIndexPath:indexPath];
        headView.headerLabel.text = self.titleArray[indexPath.section];
        
        return headView;
    }
    else
    {
        LGWorkCollectionFooterViewArc *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:LGWorkCollectionFooterViewArcID forIndexPath:indexPath];
        return view;
    }
}


@end
