//
//  BGYWebViewController.m
//  eCloud
//
//  Created by Alex-L on 2017/7/14.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYWebViewControllerARC.h"
#import <WebKit/WebKit.h>
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "LogUtil.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface BGYWebViewControllerARC ()<WKUIDelegate,WKNavigationDelegate, UIScrollViewDelegate>
{
    BOOL _isHideLoading;
    
    BOOL _isHideHeadView;
    
    BOOL _isFirstTime;
    
    NSInteger _backListCount;
    BOOL _isCommit;
    
    NSInteger _preContentY; // 用来判断滚动的方向
}
@property (nonatomic, strong) WKWebView *webview;

@property (nonatomic, strong) UIView *progressView;

@end

@implementation BGYWebViewControllerARC

- (void)dealloc
{
    [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BGY_HIDE_HEADVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BGY_SHOW_HEADVIEW_NOTIFICATION object:nil];
    
    
    self.webview.scrollView.delegate = nil;
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self addWKWebView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHeadView) name:BGY_HIDE_HEADVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHeadView) name:BGY_SHOW_HEADVIEW_NOTIFICATION object:nil];
}

- (void)addWKWebView
{
    self.webview = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    self.webview.scrollView.delegate = self;
    
    [self.view addSubview:self.webview];
    
    self.webview.allowsBackForwardNavigationGestures = true;
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 3)];
    self.progressView.backgroundColor = [UIColor greenColor];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];
    
    
    // 监听加载进度
    [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    
}

- (void)hideHeadView
{
    _isHideHeadView = YES;
}

- (void)showHeadView
{
    _isHideHeadView = NO;
}

- (void)setViewHeight:(CGFloat)viewHeight
{
    _viewHeight = viewHeight;
    
    CGRect rect = self.view.frame;
    rect.size.height = _viewHeight;
    self.webview.frame = rect;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        NSLog(@"%f", self.webview.estimatedProgress);
        
        CGFloat progress = self.webview.estimatedProgress;
        
        CGRect rect = self.progressView.frame;
        rect.size.width = SCREEN_WIDTH*progress;
        self.progressView.frame = rect;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isHideTabar)
    {
        [UIAdapterUtil hideTabBar:self];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 只加载一次
    if (!_isFirstTime)
    {
        
        NSURL *url = [NSURL URLWithString:self.urlstr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webview loadRequest:request];
        
        _isFirstTime = YES;
    }
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"createWebViewWithConfiguration");
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"didStartProvisionalNavigation");
    self.progressView.hidden = NO;
    
    
    _isCommit = NO;
}

// 当main frame的web内容开始到达时，会回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSArray *arr = self.webview.backForwardList.backList;
    
    _backListCount = arr.count;
    _isCommit = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    self.title = self.webview.title;
    
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    self.progressView.hidden = YES;
    NSLog(@"加载出错 %@", error);
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _preContentY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isHideHeaderWhenScroll)
    {
        if (scrollView.contentOffset.y > 10)
        {
            if (!_isHideHeadView)
            {
                if (scrollView.contentOffset.y < 3 && scrollView.contentOffset.y >= 0) // 避免点击到二级网页时自动调用
                    return;
                
                if (_isCommit && _backListCount == 0)
                {
                    if (scrollView.contentOffset.y > _preContentY) // 说明在向上滚动
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:BGY_HIDE_HEADVIEW_NOTIFICATION object:nil];
                    }
                }
            }
        }
        else if (scrollView.contentOffset.y < 10)
        {
            if (_isHideHeadView)
            {
                if (scrollView.contentOffset.y < 3 && scrollView.contentOffset.y >= 0) // 避免点击到二级网页时自动调用
                    return;
                
                if (_isCommit && _backListCount == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:BGY_SHOW_HEADVIEW_NOTIFICATION object:nil];
                }
            }
        }
    }
}

@end
