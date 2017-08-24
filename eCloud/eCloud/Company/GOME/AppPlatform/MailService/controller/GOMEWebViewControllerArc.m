//
//  GOMEWebViewControllerArc.m
//  eCloud
//
//  Created by Alex-L on 2017/4/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "GOMEWebViewControllerArc.h"
#import "GOMEAppMsgListViewController.h"
#import "TabbarUtil.h"
#import "GOMEUserDefaults.h"
#import "UIAdapterUtil.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"

#import <JavaScriptCore/JSContext.h>
#import "UserDefaults.h"
#import "AESCipher.h"
#import "IMYWebView.h"
#import "openWebViewController.h"

#import "eCloudDefine.h"

#import "GOMEEmailUtilArc.h"

//#if DEBUG
@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

//#endif

@interface GOMEWebViewControllerArc ()<IMYWebViewDelegate, UIWebViewDelegate>
{
    IMYWebView *webView;
    UILabel *tipLabel;
    
    NSTimer *checkTimer;
    
}
@end

@implementation GOMEWebViewControllerArc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];

    webView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];//12
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    
    tipLabel= [openWebViewController getTipsLabel];
    [self.view addSubview:tipLabel];

}

- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@ navigationType is %d",__FUNCTION__,request.URL,(int)navigationType]];
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        GOMEWebViewControllerArc *newVC = [[GOMEWebViewControllerArc alloc]init];
        newVC.urlStr = request.URL.absoluteString;
        [self.navigationController pushViewController:newVC animated:YES];
        return NO;
    }
    
    return YES;
}


-(void) webViewDidStartLoad:(IMYWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    webView.hidden = YES;
    tipLabel.hidden = NO;

    [self stopCheckTimer];
    // 定时器
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkWebview) userInfo:nil repeats:YES] ;
}

- (void)webViewDidFinishLoad:(IMYWebView *)webView
{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    [self stopCheckTimer];
    
    self.title = [webView pageTitle];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    webView.hidden = NO;
    tipLabel.hidden = YES;
    
    //首先创建JSContext 对象（此处通过当前webView的键获取到jscontext）
//    JSContext *context=[webView.realWebView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    
//    JSValue *title = [context evaluateScript:@"document.title"];
//    self.title = [NSString stringWithFormat:@"%@",title];
    
    NSString *account = [GOMEUserDefaults getGOMEEmailAccount];
    NSString *password = [GOMEUserDefaults getGOMEEmailPassword];
    
//    account = @"zy@pushdan.cn";
//    password = @"sxdt@2016";
        account = @"xc2016";
        password = @"Abcd123";

    NSString *jsAccount = [NSString stringWithFormat:@"document.getElementById(\"username\").value = \"%@\";",account];
    NSString *jsPassword = [NSString stringWithFormat:@"document.getElementById(\"password\").value = \"%@\";",password];
    NSString *jsLogin = @"var temp = document.getElementsByName('logonForm')[0];if(temp){temp.submit();}";

    //    NSString *jsLogin = @"var temp = document.getElementsByName('logonForm')[0];if(temp){clkLgn();}";//temp.submit();
    
    //    NSString *jsStr = [NSString stringWithFormat:@"%@%@%@",jsAccount,jsPassword,jsLogin];
    
    
//    if ([webView.URL.absoluteString rangeOfString:@"https://owa.corp.gome.com.cn/owa/auth/logon.aspx?url=https://owa.corp.gome.com.cn/owa/&reason=0"].length) {
    
        NSString *str = [webView stringByEvaluatingJavaScriptFromString:jsAccount];
        str = [webView stringByEvaluatingJavaScriptFromString:jsPassword];
        str = [webView stringByEvaluatingJavaScriptFromString:jsLogin];
        [LogUtil debug:[NSString stringWithFormat:@"%s str is %@",__FUNCTION__,str]];

//        JSValue *v1 = [context evaluateScript:jsAccount]; //调用js
//        JSValue *v2 = [context evaluateScript:jsPassword];
//        JSValue *v3 = [context evaluateScript:jsLogin];
//    }
    

//        JSValue *c = [context evaluateScript:jsLogin];
}

- (void)webView:(IMYWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopCheckTimer];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s error is %@",__FUNCTION__,error]];
    
    tipLabel.text = @"加载失败";
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark 异步加载

/**
 定时器执行的任务，检测网页加载的情况
 */
- (void)checkWebview
{
    NSString *tempStr = [webView pageTitle];
    if (tempStr.length) {
        webView.hidden = NO;
        tipLabel.hidden = YES;
        self.title = tempStr;
        [self stopCheckTimer];
    }
}

/**
 定制定时器
 */
- (void)stopCheckTimer{
    
    if ([checkTimer isValid]) {
        [checkTimer invalidate];
    }
    checkTimer = nil;
}


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (!parent) {
        [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
        [self stopCheckTimer];
        [webView stopLoading];
        webView.delegate = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if ([[TabbarUtil getConvTabTopVC] isKindOfClass:[GOMEAppMsgListViewController class]]) {
            [[GOMEEmailUtilArc getEmailUtil]getNewMailCountAsync];
        }
    }
}

- (void)dealloc{
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
}

@end
