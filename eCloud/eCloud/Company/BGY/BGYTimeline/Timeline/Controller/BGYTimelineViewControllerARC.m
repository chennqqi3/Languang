//
//  BGYTimelineViewController.m
//  weiboDemo
//
//  Created by Alex-L on 2017/7/5.
//  Copyright © 2017年 Alex-L. All rights reserved.
//

#import "BGYTimelineViewControllerARC.h"
#import "YYKit.h"
#import "WBModel.h"
#import "WBStatusLayout.h"
#import "WBStatusCell.h"
#import "YYTableView.h"
#import "YYSimpleWebViewController.h"
#import "WBStatusComposeViewController.h"
#import "YYPhotoGroupView.h"
#import "YYFPSLabel.h"

#import "BGYWebViewControllerARC.h"
#import "BGYMyTimelineViewControllerARC.h"

#import "eCloudDefine.h"
#import "UIAdapterUtil.h"

#import "BGYTimelineHeadViewARC.h"
#import "AppDelegate.h"

#import "BGYMJRefreshHeaderARC.h"
#import "MJRefresh.h"

#define TABLEVIEW_Y (IOS8_OR_LATER ? 0 : 64)
static NSString *headCellId = @"BGYHeadCellId";

@interface BGYTimelineViewControllerARC () <UITableViewDelegate, UITableViewDataSource, WBStatusCellDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *layouts;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@property (nonatomic, strong) UIWindow *coverWindow;

@end

@implementation BGYTimelineViewControllerARC

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (instancetype)init {
    self = [super init];
    _tableView = [YYTableView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _layouts = [NSMutableArray new];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector( setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    [self setupUI];
}

- (void)updateData
{
    NSLog(@"updateData");
    [self performSelector:@selector(hideHeader) withObject:nil afterDelay:1];
}

- (void)hideHeader
{
    [_tableView.mj_header endRefreshing];
    
    _tableView.mj_header.state = MJRefreshStateIdle;
}

- (void)hideFooter
{
    [_tableView.mj_footer endRefreshing];
    
    _tableView.mj_footer.state = MJRefreshStateNoMoreData;
}

- (void)loadMoreData
{
    NSLog(@"loadMoreData");
    [self performSelector:@selector(hideFooter) withObject:nil afterDelay:1];
}

- (void)setupUI
{
    // 展示左边侧边栏
    [UIAdapterUtil setupLeftIconItem:self];
    
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"全部",@"我的公司",nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    segmentedControl.frame = CGRectMake(0, 0, 128, 28);
    segmentedControl.tintColor = [UIAdapterUtil getDominantColor];
    segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segmentedControl;
    
    
    
    // 设置导航栏右边按钮
    CGFloat itemWidth = 42;
    UIButton *editingBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    editingBtn.frame = CGRectMake(0, 0, itemWidth, itemWidth);
    [editingBtn setImage:[StringUtil getImageByResName:@"timeline_userinfo"] forState:(UIControlStateNormal)];
    [editingBtn addTarget:self action:@selector(openMyStatus) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *infoBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    infoBtn.frame = CGRectMake(itemWidth, 0, itemWidth, itemWidth);
    [infoBtn setImage:[StringUtil getImageByResName:@"timeline_editing"] forState:(UIControlStateNormal)];
    [infoBtn addTarget:self action:@selector(sendStatus) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth*2, itemWidth)];
    [rightView addSubview:editingBtn];
    [rightView addSubview:infoBtn];
    
    UIBarButtonItem *rightItem1 = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    
    
    UIBarButtonItem *fixedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedButton.width = -15;
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:fixedButton, rightItem1, nil];
    
    _tableView.frame = CGRectMake(0, TABLEVIEW_Y, YYScreenSize().width, YYScreenSize().height-64-47);
//        _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
//        _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    self.view.backgroundColor = kWBCellBackgroundColor;
    
    
    [_tableView setScrollsToTop:YES];
    
    // 设置下拉刷新的头部和上拉加载的底部
    _tableView.mj_header = [BGYMJRefreshHeaderARC headerWithRefreshingTarget:self refreshingAction:@selector(updateData)];
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    
    _fpsLabel = [YYFPSLabel new];
    [_fpsLabel sizeToFit];
    _fpsLabel.bottom = self.view.height - kWBCellPadding;
    _fpsLabel.left = kWBCellPadding;
    _fpsLabel.alpha = 0;
    [self.view addSubview:_fpsLabel];
    
    if (kSystemVersion < 7) {
        _fpsLabel.top -= 44;
        _tableView.top -= 64;
        _tableView.height += 20;
    }
    
    // 添加headview
    BGYTimelineHeadViewARC *headview = [[BGYTimelineHeadViewARC alloc] initWithFrame:CGRectMake(0, 0, YYScreenSize().width, HEAD_HEIGHT)];
    _tableView.tableHeaderView = headview;
    
    
    self.navigationController.view.userInteractionEnabled = NO;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.size = CGSizeMake(80, 80);
    indicator.center = CGPointMake(self.view.width / 2, self.view.height / 2);
    indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    indicator.clipsToBounds = YES;
    indicator.layer.cornerRadius = 6;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataNamed:[NSString stringWithFormat:@"weibo_%d.json",8]];
        WBTimelineItem *item = [WBTimelineItem modelWithJSON:data];
        for (WBStatus *status in item.statuses) {
            WBStatusLayout *layout = [[WBStatusLayout alloc] initWithStatus:status style:WBLayoutStyleTimeline];
             [layout layout];
            [_layouts addObject:layout];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = @"工作圈";
            [indicator removeFromSuperview];
            self.navigationController.view.userInteractionEnabled = YES;
            [_tableView reloadData];
        });
    });
}

- (void)openMyStatus
{
    BGYMyTimelineViewControllerARC *myTimelineCtl = [[BGYMyTimelineViewControllerARC alloc] init];
    [self.navigationController pushViewController:myTimelineCtl animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picDismissFinish) name:BGY_PIC_DISMISS_FINISH_NOTIFICATION object:nil];
}

- (void)picDismissFinish
{
    [UIAdapterUtil showTabar:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIAdapterUtil showTabar:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BGY_PIC_DISMISS_FINISH_NOTIFICATION object:nil];
}

- (void)sendStatus {
    WBStatusComposeViewController *vc = [WBStatusComposeViewController new];
    vc.type = WBStatusComposeViewTypeStatus;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    @weakify(nav);
    vc.dismiss = ^{
        @strongify(nav);
        [nav dismissViewControllerAnimated:YES completion:NULL];
    };
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:NULL];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (_fpsLabel.alpha != 0) {
            [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _fpsLabel.alpha = 0;
            } completion:NULL];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha != 0) {
        [UIView animateWithDuration:1 delay:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 0;
        } completion:NULL];
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if (_fpsLabel.alpha == 0) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _fpsLabel.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cell";
    WBStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[WBStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.delegate = self;
    }
    [cell setLayout:_layouts[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((WBStatusLayout *)_layouts[indexPath.row]).height;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - WBStatusCellDelegate
// 此处应该用 Router 之类的东西。。。这里只是个Demo，直接全跳网页吧～

/// 点击了 Cell
- (void)cellDidClick:(WBStatusCell *)cell {
    
}

/// 点击了 Card
- (void)cellDidClickCard:(WBStatusCell *)cell {
    WBPageInfo *pageInfo = cell.statusView.layout.status.pageInfo;
    NSString *url = pageInfo.pageURL; // sinaweibo://... 会跳到 Weibo.app 的。。
    YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    vc.title = pageInfo.pageTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 点击了转发内容
- (void)cellDidClickRetweet:(WBStatusCell *)cell {
    
}

/// 点击了 Cell 菜单
- (void)cellDidClickMenu:(WBStatusCell *)cell {
    
}

/// 点击了下方 Tag
- (void)cellDidClickTag:(WBStatusCell *)cell {
    WBTag *tag = cell.statusView.layout.status.tagStruct.firstObject;
    NSString *url = tag.tagScheme; // sinaweibo://... 会跳到 Weibo.app 的。。
    YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    vc.title = tag.tagName;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 点击了关注
- (void)cellDidClickFollow:(WBStatusCell *)cell {
    
}

/// 点击了转发
- (void)cellDidClickRepost:(WBStatusCell *)cell {
    WBStatusComposeViewController *vc = [WBStatusComposeViewController new];
    vc.type = WBStatusComposeViewTypeRetweet;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    @weakify(nav);
    vc.dismiss = ^{
        @strongify(nav);
        [nav dismissViewControllerAnimated:YES completion:NULL];
    };
    [self presentViewController:nav animated:YES completion:NULL];
}

/// 点击了评论
- (void)cellDidClickComment:(WBStatusCell *)cell {
    WBStatusComposeViewController *vc = [WBStatusComposeViewController new];
    vc.type = WBStatusComposeViewTypeComment;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    @weakify(nav);
    vc.dismiss = ^{
        @strongify(nav);
        [nav dismissViewControllerAnimated:YES completion:NULL];
    };
    [self presentViewController:nav animated:YES completion:NULL];
}

/// 点击了赞
- (void)cellDidClickLike:(WBStatusCell *)cell {
    WBStatus *status = cell.statusView.layout.status;
    [cell.statusView.toolbarView setLiked:!status.attitudesStatus withAnimation:YES];
}

/// 点击了用户
- (void)cell:(WBStatusCell *)cell didClickUser:(WBUser *)user {
    if (user.userID == 0) return;
    NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/u/%lld",user.userID];
    YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
    [self.navigationController pushViewController:vc animated:YES];
}

/// 点击了图片
- (void)cell:(WBStatusCell *)cell didClickImageAtIndex:(NSUInteger)index {
    UIView *fromView = nil;
    NSMutableArray *items = [NSMutableArray new];
    WBStatus *status = cell.statusView.layout.status;
    NSArray<WBPicture *> *pics = status.retweetedStatus ? status.retweetedStatus.pics : status.pics;
    
    for (NSUInteger i = 0, max = pics.count; i < max; i++) {
        UIView *imgView = cell.statusView.picViews[i];
        WBPicture *pic = pics[i];
        WBPictureMetadata *meta = pic.largest.badgeType == WBPictureBadgeTypeGIF ? pic.largest : pic.large;
        YYPhotoGroupItem *item = [YYPhotoGroupItem new];
        item.thumbView = imgView;
        item.largeImageURL = meta.url;
        item.largeImageSize = CGSizeMake(meta.width, meta.height);
        [items addObject:item];
        if (i == index) {
            fromView = imgView;
        }
    }
    
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromView toContainer:self.navigationController.view animated:YES completion:nil];
    
    [UIAdapterUtil hideTabBar:self];
}

/// 点击了 Label 的链接
- (void)cell:(WBStatusCell *)cell didClickInLabel:(YYLabel *)label textRange:(NSRange)textRange {
    NSAttributedString *text = label.textLayout.text;
    if (textRange.location >= text.length) return;
    YYTextHighlight *highlight = [text attribute:YYTextHighlightAttributeName atIndex:textRange.location];
    NSDictionary *info = highlight.userInfo;
    if (info.count == 0) return;
    
    if (info[kWBLinkHrefName]) {
        NSString *url = info[kWBLinkHrefName];
        YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    /*
    if (info[kWBLinkURLName]) {
        WBURL *url = info[kWBLinkURLName];
        WBPicture *pic = url.pics.firstObject;
        if (pic) {
            // 点击了文本中的 "图片链接"
            YYTextAttachment *attachment = [label.textLayout.text attribute:YYTextAttachmentAttributeName atIndex:textRange.location];
            if ([attachment.content isKindOfClass:[UIView class]]) {
                YYPhotoGroupItem *info = [YYPhotoGroupItem new];
                info.largeImageURL = pic.large.url;
                info.largeImageSize = CGSizeMake(pic.large.width, pic.large.height);
                
                YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:@[info]];
                [v presentFromImageView:attachment.content toContainer:self.navigationController.view animated:YES completion:nil];
            }
            
        } else if (url.oriURL.length){
            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url.oriURL]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        return;
    }
    
    if (info[kWBLinkTagName]) {
        WBTag *tag = info[kWBLinkTagName];
        NSLog(@"tag:%@",tag.tagScheme);
        return;
    }
    
    if (info[kWBLinkTopicName]) {
        WBTopic *topic = info[kWBLinkTopicName];
        NSString *topicStr = topic.topicTitle;
        topicStr = [topicStr stringByURLEncode];
        if (topicStr.length) {
            NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/k/%@",topicStr];
            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        return;
    }
     */
    
    if (info[kWBLinkAtName]) {
        NSString *name = info[kWBLinkAtName];
        name = [name stringByURLEncode];
        if (name.length) {
            NSString *url = [NSString stringWithFormat:@"http://m.weibo.cn/n/%@",name];
            YYSimpleWebViewController *vc = [[YYSimpleWebViewController alloc] initWithURL:[NSURL URLWithString:url]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        return;
    }
}

@end
