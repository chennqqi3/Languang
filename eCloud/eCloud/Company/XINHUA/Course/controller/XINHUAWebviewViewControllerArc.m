//
//  XINHUAWebviewViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAWebviewViewControllerArc.h"
#import <WebKit/WebKit.h>
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "LogUtil.h"
#ifdef _XINHUA_FLAG_
#import "XINHUALoginViewControllerArc.h"
#endif

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface XINHUAWebviewViewControllerArc ()<WKUIDelegate,WKNavigationDelegate>
{
    BOOL _isHideLoading;
}
@property (nonatomic, strong) WKWebView *webview;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIView *loadingView;

@end

@implementation XINHUAWebviewViewControllerArc

- (void)dealloc
{
    [self.webview removeObserver:self forKeyPath:@"estimatedProgress"];
    
    NSLog(@"%s", __func__);
}
- (void)backButtonPressed{
    if (self.urlIsFromScanResult) {
        NSArray *_array = self.navigationController.viewControllers;
        
        int vcCount = (int)_array.count;
        
        if (vcCount >= 3) {
            id target = _array[vcCount - 3];
            [self.navigationController popToViewController:target animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)share
{
    NSString *textToShare = self.urlstr;
    
//    UIImage *imageToShare = [UIImage imageNamed:@"iosshare.jpg"];
    
    NSURL *urlToShare = [NSURL URLWithString:self.urlstr];
    
    NSArray *activityItems = @[textToShare,urlToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    if (self.viewHeight > 0)
//    {
//        self.webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.viewHeight)];
//    }
//    else
//    {
        self.webview = [[WKWebView alloc] initWithFrame:self.view.frame];
//    }
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    [self.view addSubview:self.webview];
    
    self.webview.allowsBackForwardNavigationGestures = true;
    
    NSURL *url = [NSURL URLWithString:self.urlstr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
    
    self.progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 3)];
    self.progressView.backgroundColor = [UIColor greenColor];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];
    
    
    if (self.urlIsFromScanResult) {
        [UIAdapterUtil setRightButtonItemWithImageName:@"ios_share" andTarget:self andSelector:@selector(share)];
        [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed)];
    }
    
    
    if (self.isAutoLogin)
    {
        self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
        self.loadingView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        
        UIImageView *loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-80)/2.0, (SCREEN_HEIGHT-64-80)/2.0 - 15, 80, 80)];
        
        NSMutableArray *images = [NSMutableArray array];
        for (int i = 1; i < 18; i++) {
            [images addObject:[StringUtil getImageByResName:[NSString stringWithFormat:@"loading_%d",i]]];
        }
        loadingImageView.animationImages = [images copy];
        
        [self.loadingView addSubview:loadingImageView];
        
        [loadingImageView startAnimating];
        
        [self.view addSubview:self.loadingView];
    }
    
    
    // 监听加载进度
    [self.webview addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
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
    
    [UIAdapterUtil hideTabBar:self];
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
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
#ifdef _XINHUA_FLAG_
    
    if (_isHideLoading)
    {
        [self.loadingView removeFromSuperview];
    }
    
    
    if (self.isAutoLogin)
    {
        NSString *account = [[NSUserDefaults standardUserDefaults] objectForKey:ACCOUNT_KEY];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD_KEY];
        
        // 自动登录
        NSString *textJS = [NSString stringWithFormat:@"document.getElementById(\"login_username\").value = \"%@\";document.getElementById(\"login_password\").value = \"%@\";document.getElementById(\"login-form\").submit();", account, password];
        [webView evaluateJavaScript:textJS completionHandler:nil];
        
        _isHideLoading = YES;

        
        self.isAutoLogin = NO;
    }
#endif

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

@end
