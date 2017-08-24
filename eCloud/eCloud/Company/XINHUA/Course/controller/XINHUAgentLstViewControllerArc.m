//
//  XINHUAgentLstViewControllerArc.m
//  eCloud
//
//  Created by Ji on 17/4/28.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XINHUAgentLstViewControllerArc.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "AppDelegate.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface XINHUAgentLstViewControllerArc ()<UIGestureRecognizerDelegate>
{
    /** 关闭 */
    UIButton *_closeButton;
    UILabel *tipLabel;
    NSTimer *checkTimer;
    UIImageView *_errorImage;
    UILabel *_errorLabel;
    UITapGestureRecognizer *_tapGestureRecoginizer;
    
}
@end

@implementation XINHUAgentLstViewControllerArc

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    /** 隐藏返回按钮 */
    [UIAdapterUtil setLeftButtonItemWithTitle:@" " andTarget:self andSelector:@selector(backButtonPressed:) andDisplayLeftButtonImage:YES];

    if (!_closeButton) {
        
        _closeButton=[UIAdapterUtil setNewButton:[StringUtil getAppLocalizableString:@"close"] andBackgroundImage:nil];
        _closeButton.frame = CGRectMake(40, 20, 44, 44);
        [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //_closeButton.backgroundColor = [UIColor redColor];
        [_closeButton addTarget:self action:@selector(goBackWebView) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        //    _closeButton.hidden = YES;
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.window addSubview:_closeButton];
        
    }else{
        
        _closeButton.hidden = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _closeButton.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor grayColor];
    self.view.userInteractionEnabled = YES;
    
    int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) usingUIWebView:NO];
    webview.scalesPageToFit = YES;
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.bounces = NO;
    webview.userInteractionEnabled = YES;
    [self.view addSubview:webview];
    //
    self.urlstr = self.urlstr ? self.urlstr : @"https://www.taobao.com/";
    NSString *strUrl = [self.urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    
    webview.delegate=self;
    [webview loadRequest:requestObj];
    
    
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, webview.frame.size.height/2-100, SCREEN_WIDTH, 100)];
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.hidden = YES;
    tipLabel.text = @"loading...";
    tipLabel.font = [UIFont systemFontOfSize:30];
    [self.view addSubview:tipLabel];
    
    UIImage *logoImage  = [UIImage imageWithContentsOfFile:[StringUtil getResPath:@"timg" andType:@"png"]];
    
    _errorImage = [[UIImageView alloc]initWithFrame:CGRectMake(webview.frame.size.width/2-50, 50, 100, 100)];
    _errorImage.image = logoImage;
    _errorImage.hidden = YES;
    _errorImage.userInteractionEnabled = YES;
    [self.view addSubview:_errorImage];
    
    _errorLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, _errorImage.frame.size.height + _errorImage.frame.origin.y, SCREEN_WIDTH, 70)];
    _errorLabel.backgroundColor=[UIColor clearColor];
    _errorLabel.textAlignment=NSTextAlignmentCenter;
    _errorLabel.textColor = [UIColor grayColor];
    _errorLabel.hidden = YES;
    _errorLabel.text = @"网络出错，轻触屏幕重新加载:0";
    _errorLabel.font = [UIFont systemFontOfSize:16];
    _errorImage.userInteractionEnabled = YES;
    [self.view addSubview:_errorLabel];
}

- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)_navigationType
{
 
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
        [LogUtil debug:[NSString stringWithFormat:@"%s return YES current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
    
    return YES;
}

-(void) webViewDidStartLoad:(IMYWebView *)webView
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    webview.hidden = YES;
    tipLabel.hidden = NO;
    
    /** 重新初始化 定时器 检查 webview的title是否取到，取到之后，就显示webview */
    [self stopCheckTimer];
    
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkWebview) userInfo:nil repeats:YES] ;
    
}

- (void)webViewDidFinishLoad:(IMYWebView*)webView
{
    [self stopCheckTimer];
    

    self.title = [webview pageTitle];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    tipLabel.hidden = YES;
    
    
    // 自动登录
    JSContext *context = [webView.realWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    NSString *textJS = @"document.getElementById(\"login_username\").value = \"18665886390\";document.getElementById(\"login_password\").value = \"123456\";document.getElementById(\"login-form\").submit();";
    [context evaluateScript:textJS];
    
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
//    tipLabel.hidden = YES;
//    _errorImage.hidden = NO;
//    _errorLabel.hidden = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    _tapGestureRecoginizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reloadWebView:)];
//    _tapGestureRecoginizer.numberOfTapsRequired = 1;
//    _tapGestureRecoginizer.delegate = self;
//    [webview addGestureRecognizer:_tapGestureRecoginizer];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s error == %@",__FUNCTION__,error]];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
        [self stopCheckTimer];

        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backButtonPressed:(id) sender
{
    /** 若当前页面不是首页进行页面回退操作 */
    /** 需求回退不刷新上一页，需要用uiwebview */
    if ([webview canGoBack]) {
        [webview goBack];
        return ;
    }
}

- (void)reloadWebView:(UITapGestureRecognizer *)recognizer{
    
    _errorLabel.hidden = YES;
    _errorImage.hidden = YES;

    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    //    NSLog(@"%s  cache policy is %d",__FUNCTION__,requestObj.cachePolicy);
    
    [webview loadRequest:requestObj];

    [self.view removeGestureRecognizer:_tapGestureRecoginizer];
}

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
    
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
}

/** 允许多个手势并发 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)goBackWebView{
    
    [self.navigationController popViewControllerAnimated:YES];
    _closeButton.hidden = YES;
}
@end
