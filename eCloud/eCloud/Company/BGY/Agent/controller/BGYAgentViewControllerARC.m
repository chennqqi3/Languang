//
//  BGYAgentViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/6/6.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "BGYAgentViewControllerARC.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "WebViewJavascriptBridge.h"
#import "JSSDKObject.h"
#import "LogUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "JsObjectCViewController.h"
#import "UserDefaults.h"

@interface BGYAgentViewControllerARC ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) WebViewJavascriptBridge *bridge;

@end

@implementation BGYAgentViewControllerARC
{
    NSTimer *checkTimer;
    JSSDKObject *jssdk;
    BOOL isFirstLoad;
}
@synthesize customTitle;
@synthesize urlstr;
@synthesize curUrlStr;
@synthesize navigationType;

-(void)dealloc
{
    
    [self stopCheckTimer];
    
    if (webview.isLoading)
    {
        [webview stopLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    webview.delegate = nil;
    webview = nil;
    self.urlstr = nil;
    self.curUrlStr = nil;
    self.customTitle = nil;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
    if (self.navigationController.viewControllers.count == 1) {
        
        [UIAdapterUtil showTabar:self];
        [UIAdapterUtil setLeftButtonItemWithTitle:@" " andTarget:self andSelector:nil andDisplayLeftButtonImage:NO];
        
//        webview.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT);
//        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstLoad = YES;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    //webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH)];
    webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) usingUIWebView:YES];
    webview.scalesPageToFit = YES;
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.bounces = NO;
    //    webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webview];
    
    //self.urlstr = @"http://im.tahoecn.com/ExampleApp.html";
    
    NSString *strUrl = [self.urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    
    webview.delegate=self;
    
    [webview loadRequest:requestObj];
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    
    [self initInterface];
    
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    
    if ([webview canGoBack]) {   // 若当前页面不是首页进行页面回退操作
        [webview goBack];
        return ;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
        [self stopCheckTimer];
        self.bridge = nil;
        jssdk.bridge = nil;
        jssdk.curVC = nil;
        jssdk = nil;
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
    
}
#pragma mark ======和JS互相调用接口========

//接口初始化
- (void)initInterface
{
    
    [WebViewJavascriptBridge enableLogging];
    UIViewController *weakSelf =self;
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:webview webViewDelegate:weakSelf handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取_bridge----");
    }];
    
    jssdk = [[JSSDKObject alloc]init];
    jssdk.bridge = self.bridge;
    jssdk.curVC = self;
    
    [jssdk initSDK];
    
    //    [self initImage];
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
}

- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)_navigationType
{
    
    //    JsObjectCViewController *js = [[JsObjectCViewController alloc]init];
    //    [self.navigationController pushViewController:js animated:YES];
    //    return NO;
    
    self.curUrlStr = request.URL.absoluteString;
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s return YES current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
    
    return YES;
}

-(void) webViewDidStartLoad:(IMYWebView *)webView
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if(isFirstLoad)
    {
        webview.hidden = YES;
        tipLabel.hidden=NO;
        tipLabel.text = [StringUtil getLocalizableString:@"loading"];
    }
    else
    {
        if(self.navigationType == UIWebViewNavigationTypeLinkClicked)
        {
            webview.hidden = YES;
            tipLabel.hidden=NO;
            tipLabel.text = [StringUtil getLocalizableString:@"linking"];
        }
        else
        {
            tipLabel.hidden = YES;
            webview.hidden = NO;
        }
    }
    
    //重新初始化 定时器 检查 webview的title是否取到，取到之后，就显示webview
    [self stopCheckTimer];
    
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkWebview) userInfo:nil repeats:YES] ;
    
}

- (void)checkWebview
{
    NSString *tempStr = [webview pageTitle];
    if (tempStr.length) {
        webview.hidden = NO;
        tipLabel.hidden = YES;
        self.title = tempStr;
        [self stopCheckTimer];
    }
    
    //        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}
- (void)stopCheckTimer{
    
    if ([checkTimer isValid]) {
        [checkTimer invalidate];
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
    checkTimer = nil;
    
}

- (void)webViewDidFinishLoad:(IMYWebView*)webView
{
    [self stopCheckTimer];
    
    if(self.customTitle)
    {
        self.title = self.customTitle;
    }
    else
    {
        self.title = [webview pageTitle];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isFirstLoad = NO;
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    tipLabel.hidden=YES;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
