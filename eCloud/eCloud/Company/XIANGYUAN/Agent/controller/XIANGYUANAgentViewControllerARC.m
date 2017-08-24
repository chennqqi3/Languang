//
//  XIANGYUANAgentViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANAgentViewControllerARC.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "WebViewJavascriptBridge.h"
#import "JSSDKObject.h"
#import "LogUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "JsObjectCViewController.h"
#import "WaterMarkViewARC.h"
#import "UserDefaults.h"
#import "WaterMarkViewARC.h"
#import "GXViewController.h"
#import "eCloudDefine.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "XIANGYUANAppViewControllerARC.h"
#import "XIANGYUANWorkViewControllerARC.h"
#import "ServerConfig.h"
#import "UserDefaults.h"
#import "TabbarUtil.h"
#import "mainViewController.h"
#import "XIANGYUANLoginViewControllerARC.h"
#import "AppDelegate.h"

#define TARGET_NEW @"TARGET_NEW"

#define XIANGYUAN_TODO @"xiangyuan_todo"

@interface XIANGYUANAgentViewControllerARC ()

@property (nonatomic,strong) WebViewJavascriptBridge *bridge;

@end

@implementation XIANGYUANAgentViewControllerARC
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
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstLoad = YES;
    
    self.navigationController.delegate = self;
    
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
    
    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    
    webview.delegate=self;
    
    [webview loadRequest:requestObj];
    
//    NSString *userAgent = [webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
//    NSLog(@"userAgent :%@", userAgent);
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    
    
    [self initInterface];
    
    // 添加水印
    [WaterMarkViewARC waterMarkView:self.view];
    
    [UIAdapterUtil setRightButtonItemWithTitle:@"关闭" andTarget:self andSelector:@selector(closeWebView)];

}

//返回 按钮
-(void) backButtonPressed:(id) sender
{
    if (_isDAIBAN) {
        
        UIViewController *target = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[XIANGYUANAppViewControllerARC class]]){
                target = controller;
            }
        }
        if (target) {
            
            [self.navigationController popToViewController:target animated:YES];
        }
        return ;
    }else if (_isWorkDAIBAN) {
        
        UIViewController *target = nil;
        for (UIViewController * controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[XIANGYUANWorkViewControllerARC class]]){
                target = controller;
            }
        }
        if (target) {
            
            [self.navigationController popToViewController:target animated:YES];
        }
        return ;
    }
    
    if ([webview canGoBack]) {   // 若当前页面不是首页进行页面回退操作
        [webview goBack];
        return ;
    }
    
    if ([self.framWhere isEqualToString:XYGXViewController]) {
        
        [((GXViewController *)[self tabBarController]) activationTabbar];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s return YES current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
    
    //修改密码成功后的url
    NSString *urlString = [[ServerConfig shareServerConfig]getXYChangePasswordUrl];
    
    if ([curWebViewUrl rangeOfString:urlString].length > 0) {

        // 返回到登录界面
        [self exist];
        
    }
    if ([curWebViewUrl rangeOfString:TARGET_NEW].length > 0) {

        XIANGYUANAgentViewControllerARC *agentListVC=[[XIANGYUANAgentViewControllerARC alloc]init];
        curWebViewUrl = [curWebViewUrl stringByReplacingOccurrencesOfString:TARGET_NEW withString:@""];
        NSString *usercode = [UserDefaults getUserAccount];
        NSString *token = [UserDefaults getXIANGYUANAppToken];
        NSString *urlStr = [NSString stringWithFormat:@"%@?usercode=%@&token=%@",curWebViewUrl,usercode,token];
        agentListVC.urlstr = urlStr;
        if (_isDAIBAN) {
            
            agentListVC.isDAIBAN = YES;
            
        }else if (_isWorkDAIBAN){
            
            agentListVC.isWorkDAIBAN = YES;
        }
        
        [self.navigationController pushViewController:agentListVC animated:YES];

        return NO;
        
    }
    else if ([curWebViewUrl rangeOfString:XIANGYUAN_TODO].length>0){
        
        if (_isDAIBAN) {
            
            UIViewController *target = nil;
            for (UIViewController * controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[XIANGYUANAppViewControllerARC class]]){
                    target = controller;
                }
            }
            if (target) {
                
                [self.navigationController popToViewController:target animated:NO];
                self.delegate = target;
                [self.delegate returnString:@"todo"];
            }
            return NO;
        }else if (_isWorkDAIBAN) {
            
            UIViewController *target = nil;
            for (UIViewController * controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[XIANGYUANWorkViewControllerARC class]]){
                    target = controller;
                }
            }
            if (target) {

                [self.navigationController popToViewController:target animated:NO];
                self.delegate = target;
                [self.delegate returnString:@"todo"];
            }
            return NO;
        }

        return NO;
        
    }

    
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
    
//    NSMutableString *jsStr = [NSMutableString string];
//    [jsStr appendString:@"$('input.fs_username’).attr(\"value\",\"hucheng\");"];
//    [jsStr appendString:@"$('input.fs_password').attr(\"value\", \"hucheng\");"];
//    [jsStr appendString:@"singIN();"];
//    
//    NSString *result = [webView stringByEvaluatingJavaScriptFromString:jsStr];
    
    
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

- (void)closeWebView{
    
    if ([self.framWhere isEqualToString:XYGXViewController]) {
        
        [((GXViewController *)[self tabBarController]) activationTabbar];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - 退回到登录界面
- (void)exist{
    
    [UserDefaults saveUserIsExit:YES];
    [UserDefaults saveIsSavePassword:NO];
    
//    NSString *account = [UserDefaults getUserAccount];
    [[UserDefaults getUserDefaults]removeObjectForKey:@"user_password"];
    
    
//    id tabbarVC = [TabbarUtil getTabbarController];
//    if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
//        id mainVC = ((GXViewController *)tabbarVC).delegate;
//        [((mainViewController*)mainVC) backRoot];
//    }else{
//
//        AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
//        XIANGYUANLoginViewControllerARC *newLogin= [[XIANGYUANLoginViewControllerARC alloc]initWithNibName:@"TaiHeLoginViewController" bundle:nil];
//        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
//        delegate.window.rootViewController = navigation;
//
//    }
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
}
@end
