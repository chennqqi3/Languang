//
//  BGYHomePageViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/7/5.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYHomePageViewController.h"

#import "BGYMoreViewControllerARC.h"
#import "BGYNEWSViewControllerARC.h"
#import "BGYWebViewControllerARC.h"

#import "StringUtil.h"
#import "ImageUtil.h"
#import "UIAdapterUtil.h"

#import "conn.h"

#import "SDCycleScrollView.h"
#import "eCloudDefine.h"
#import "YYTableView.h"

#import "AppDelegate.h"

#define SYCLEVIEW_Y (IOS8_OR_LATER ? 0 : 64)

#define SCROLLVIEW_H 95
#define INDEX_WIDTH 30

#define BASE_TAG 100
#define APPNAME_TAG 2060
#define ICON_TAG 2061

#define ITEM_WIDTH 52

static BGYHomePageViewController *homepageVC;

@interface BGYHomePageViewController ()<SDCycleScrollViewDelegate, UIScrollViewDelegate>
{
    NSInteger _preSelectedIndex;
}
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *indexView;

@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;

@property (nonatomic, strong) NSArray *iconArray;

@end

@implementation BGYHomePageViewController

- (NSArray *)iconArray
{
    if (_iconArray == nil)
    {
        _iconArray = @[@"icon_schedule", @"icon_email", @"icon_report", @"icon_notice"];
    }
    
    return _iconArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BGY_HIDE_HEADVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BGY_SHOW_HEADVIEW_NOTIFICATION object:nil];
    
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置标题
    self.title = @"首页";
    
    // 展示左边侧边栏
    [UIAdapterUtil setupLeftIconItem:self];
    
    // 从左侧滑出“更多”界面的手势
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *VC = delegate.window.rootViewController;
    [StringUtil addEdgePanGestureRecognizer:VC];
    
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT+[self getSycleViewHeight]-64)];
    [self.view addSubview:self.contentView];
    
    // 添加轮播图
    [self addBannerView];
    
    // 轻应用快捷入口
    [self addAppEntrance];
    
    // 添加轻应用界面
    [self addAppView];
    
    // 添加“更多“界面
    [self addMoreViewController];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHeaderView) name:BGY_HIDE_HEADVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHeaderView) name:BGY_SHOW_HEADVIEW_NOTIFICATION object:nil];
}

- (void)addMoreViewController
{
    BGYMoreViewControllerARC *moreVC = [BGYMoreViewControllerARC getMoreViewController];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:moreVC];
    navi.view.frame = CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    
    [window.rootViewController.view addSubview:navi.view];
    [window.rootViewController addChildViewController:navi];
}

// 轻应用快捷入口
- (void)addAppEntrance
{
    self.titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [self getSycleViewHeight]+(SYCLEVIEW_Y), SCREEN_WIDTH, SCROLLVIEW_H)];
    self.titleScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 0);
    self.titleScrollView.showsVerticalScrollIndicator = NO;
    
    [self.contentView addSubview:self.titleScrollView];
    
    NSArray *arr = @[@"待办", @"邮箱", @"报表", @"公告"];
    NSInteger count = arr.count;
    CGFloat width = SCREEN_WIDTH/count;
    for (int i = 0; i < count; i++)
    {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0+i*width, 0, width, SCROLLVIEW_H)];
        contentView.tag = BASE_TAG + i;
        contentView.backgroundColor = [UIColor whiteColor];
        [self.titleScrollView addSubview:contentView];
        
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AppEntranceClick:)];
        [contentView addGestureRecognizer:tap];
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((width-ITEM_WIDTH)/2.0, 10, ITEM_WIDTH, ITEM_WIDTH)];
        icon.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        icon.tag = ICON_TAG;
        if (i == 0)
        {
            NSString *imageName = [NSString stringWithFormat:@"%@_click",self.iconArray[0]];
            icon.image = [StringUtil getImageByResName:imageName];
        }
        else
        {
            icon.image = [StringUtil getImageByResName:self.iconArray[i]];
        }
        icon.layer.cornerRadius = ITEM_WIDTH/2.0;
        icon.clipsToBounds = YES;
        [contentView addSubview:icon];
        
        UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, SCROLLVIEW_H-20-7, width, 20)];
        appName.text = arr[i];
        appName.tag = APPNAME_TAG;
        appName.textAlignment = NSTextAlignmentCenter;
        if (i == 0)
        {
            [appName setTextColor:[UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1]];
        }
        else
        {
            [appName setTextColor:[UIColor lightGrayColor]];
        }
        [contentView addSubview:appName];
    }
    
    
    // 蓝色的下标
    CGFloat indexH = 3;
    CGFloat indexY = SCROLLVIEW_H-indexH;
    self.indexView = [[UIView alloc] initWithFrame:CGRectMake((width-INDEX_WIDTH)/2, indexY, INDEX_WIDTH, indexH)];
    self.indexView.backgroundColor = [UIAdapterUtil getDominantColor];
    [self.titleScrollView addSubview:_indexView];
}

- (void)AppEntranceClick:(UITapGestureRecognizer *)tap
{
    UIView *view = tap.view;
    NSInteger index = view.tag - BASE_TAG;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.contentScrollView.contentOffset = CGPointMake(index*SCREEN_WIDTH, 0);
    }];
    
    
    
    NSInteger page = index;
    if (page == _preSelectedIndex)
        return;
    
    UIView *view1 = [self.titleScrollView viewWithTag:BASE_TAG+page];
    UILabel *appName1 = [view1 viewWithTag:APPNAME_TAG];
    appName1.textColor = [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1];
    
    UIImageView *icon1 = [view1 viewWithTag:ICON_TAG];
    NSString *imageName = [NSString stringWithFormat:@"%@_click", self.iconArray[page]];
    icon1.image = [StringUtil getImageByResName:imageName];
    
    
    // 将上一次选中的还原
    UIView *view2 = [self.titleScrollView viewWithTag:BASE_TAG+_preSelectedIndex];
    UILabel *appName2 = [view2 viewWithTag:APPNAME_TAG];
    appName2.textColor = [UIColor lightGrayColor];
    
    UIImageView *icon2 = [view2 viewWithTag:ICON_TAG];
    icon2.image = [StringUtil getImageByResName:self.iconArray[_preSelectedIndex]];
    
    
    _preSelectedIndex = page;
}

- (CGFloat)getSycleViewHeight
{
    UIImage *image = [StringUtil getImageByResName:@"banner_placeholder"];
    CGFloat height = SCREEN_WIDTH*(image.size.height/image.size.width);
    
    return height;
}

- (void)addAppView
{
    CGFloat lineY = self.titleScrollView.frame.origin.y + SCROLLVIEW_H;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, lineY, SCREEN_WIDTH, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.contentView addSubview:line];
    
    CGFloat scrollViewHeight = SCREEN_HEIGHT-[self getSycleViewHeight]-52;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, lineY+1, SCREEN_WIDTH, scrollViewHeight)];
    self.contentScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*4, 0);
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.contentView addSubview:self.contentScrollView];
    
    
    BGYWebViewControllerARC *webCtl1 = [[BGYWebViewControllerARC alloc] init];
    webCtl1.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, scrollViewHeight);
    webCtl1.isHideHeaderWhenScroll = YES;
    webCtl1.urlstr = @"http://www.bgy.com.cn/mobile/?from=singlemessage";
    [self.contentScrollView addSubview:webCtl1.view];
    [self addChildViewController:webCtl1];
//    webCtl1.viewHeight = scrollViewHeight;
    
    BGYWebViewControllerARC *webCtl2 = [[BGYWebViewControllerARC alloc] init];
    webCtl2.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, scrollViewHeight);
    webCtl2.isHideHeaderWhenScroll = YES;
    webCtl2.urlstr = @"https://www.baidu.com";
    [self.contentScrollView addSubview:webCtl2.view];
    [self addChildViewController:webCtl2];
//    webCtl2.viewHeight = scrollViewHeight;
    
    BGYWebViewControllerARC *webCtl3 = [[BGYWebViewControllerARC alloc] init];
    webCtl3.view.frame = CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, scrollViewHeight);
    webCtl3.isHideHeaderWhenScroll = YES;
    webCtl3.urlstr = @"http://www.bgy.com.cn/mobile/?from=singlemessage";
    [self.contentScrollView addSubview:webCtl3.view];
    [self addChildViewController:webCtl3];
//    webCtl3.viewHeight = scrollViewHeight;
    
    BGYWebViewControllerARC *webCtl4 = [[BGYWebViewControllerARC alloc] init];
    webCtl4.view.frame = CGRectMake(SCREEN_WIDTH*3, 0, SCREEN_WIDTH, scrollViewHeight);
    webCtl4.isHideHeaderWhenScroll = YES;
    webCtl4.urlstr =  @"https://www.baidu.com";
    [self.contentScrollView addSubview:webCtl4.view];
    [self addChildViewController:webCtl4];
//    webCtl4.viewHeight = scrollViewHeight;
}

- (void)addBannerView
{
    UIImage *image = [StringUtil getImageByResName:@"banner_placeholder"];
    CGFloat height = SCREEN_WIDTH*(image.size.height/image.size.width);
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, SYCLEVIEW_Y, SCREEN_WIDTH, height) delegate:self placeholderImage:image];
    
    [self.contentView addSubview:self.cycleScrollView];
}

#pragma mark - BGYWebViewController Notification
- (void)hideHeaderView
{
    CGRect rect = self.contentView.frame;
    rect.origin.y = -[self getSycleViewHeight];
    
    [UIView animateWithDuration:.35 animations:^{
        
        self.contentView.frame = rect;
    }];
}

- (void)showHeaderView
{
    CGRect rect = self.contentView.frame;
    rect.origin.y = 0;
    
    [UIView animateWithDuration:.4 animations:^{
        
        self.contentView.frame = rect;
    }];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentScrollView)
    {
        CGRect rect = self.indexView.frame;
        CGFloat itemWidth = SCREEN_WIDTH/4;
        rect.origin.x = (itemWidth-INDEX_WIDTH)/2 + (itemWidth)*(scrollView.contentOffset.x/SCREEN_WIDTH);
        self.indexView.frame = rect;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.contentScrollView)
    {
        int page = (scrollView.contentOffset.x/SCREEN_WIDTH);
        
        if (page == _preSelectedIndex)
            return;
        
        UIView *view1 = [self.titleScrollView viewWithTag:BASE_TAG+page];
        UILabel *appName1 = [view1 viewWithTag:APPNAME_TAG];
        appName1.textColor = [UIColor colorWithRed:0x11/255.0 green:0x11/255.0 blue:0x11/255.0 alpha:1];
        
        UIImageView *icon1 = [view1 viewWithTag:ICON_TAG];
        NSString *imageName = [NSString stringWithFormat:@"%@_click", self.iconArray[page]];
        icon1.image = [StringUtil getImageByResName:imageName];
        
        
        // 将上一次选中的还原
        UIView *view2 = [self.titleScrollView viewWithTag:BASE_TAG+_preSelectedIndex];
        UILabel *appName2 = [view2 viewWithTag:APPNAME_TAG];
        appName2.textColor = [UIColor lightGrayColor];
        
        UIImageView *icon2 = [view2 viewWithTag:ICON_TAG];
        icon2.image = [StringUtil getImageByResName:self.iconArray[_preSelectedIndex]];
        
        
        _preSelectedIndex = page;
    }
}

@end
