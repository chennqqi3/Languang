//
//  EmailViewController.m
//  eCloud
//
//  Created by yanlei on 15/8/26.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "EmailViewController.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "EmailForFileViewController.h"
#import "StringUtil.h"
#import "IMYWebView.h"
#import "eCloudDefine.h"

@interface EmailViewController ()<IMYWebViewDelegate>

@end

@implementation EmailViewController
{
    /** 定时器，页面加载情况监听 */
    NSTimer *checkTimer;
    /** 是否第一次加载 */
    BOOL isFirstLoad;
    /** 加载网页时的提示语label */
    UILabel *tipLabel;
    IMYWebView *webview;
}
@synthesize urlstr;
@synthesize curUrlStr;
@synthesize navigationType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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
    [webview release];
    webview = nil;
    
    self.urlstr = nil;
    self.curUrlStr = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [StringUtil getLocalizableString:@"me_email"];
    isFirstLoad = YES;
    
    [UIAdapterUtil processController:self];
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    
    int tableH = SCREEN_HEIGHT-20;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
   
    webview=[[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT)];
    webview.scalesPageToFit = YES;
    [self.view addSubview:webview];
    
    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    
//    URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];

    webview.delegate=self;

    [webview loadRequest:requestObj];

//    NSData *data = [NSData dataWithContentsOfFile:strUrl];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDir = [paths objectAtIndex:0] ;   //根据自己的具体情况设置，我的html文件在document目录，链接也是在这个目录上开始
//    NSURL *baseUrl = [NSURL fileURLWithPath:documentsDir];
//    [webview loadData:data MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:baseUrl];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"龙湖派遣（北京）1508.xls" ofType:nil];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    webview.delegate=self;
//    [webview loadRequest:request];

    
    
    // 在页面未加载完全时，显示的加载控件
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel release];
}
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 拦截里面的点击事件
    NSString *curWebViewUrl = request.URL.absoluteString;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]]
    ;
    
    if ([curWebViewUrl rangeOfString:@"fileName="].length > 0) {
//        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSString *strUrl = [curWebViewUrl stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
//        NSURL *url = [NSURL URLWithString:strUrl];
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//        [webview loadRequest:requestObj];
//        
////        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
////        NSString *pageSource = [[NSString alloc] initWithData:pageData encoding:gbkEncoding];
//        
//        return NO;
        
//        NSData *data = [NSData dataWithContentsOfFile:curWebViewUrl];
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDir = [paths objectAtIndex:0] ;   //根据自己的具体情况设置，我的html文件在document目录，链接也是在这个目录上开始
//        NSURL *baseUrl = [NSURL fileURLWithPath:documentsDir];
//        [webview loadData:data MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:baseUrl];
//        return YES;
        
        // 将文件的路径传递到邮件附件控制器
        EmailForFileViewController *emailForFile = [[EmailForFileViewController alloc]init];
        emailForFile.urlstr = curWebViewUrl;
        [self.navigationController pushViewController:emailForFile animated:YES];
        [emailForFile release];
        
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
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
        [self stopCheckTimer];
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
    
    //    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}
- (void)stopCheckTimer{
    
    if ([checkTimer isValid]) {
        [checkTimer invalidate];
    }
    checkTimer = nil;
}


-(void)displayWebView
{
    NSString *curWebViewUrl = webview.currentRequest.URL.absoluteString;
    
    if([curWebViewUrl isEqualToString:self.curUrlStr])
    {
        //		如果webview当前的url和正在加载的url相同，则不显示提示
        if(webview.hidden)
        {
            webview.hidden = NO;
        }
        tipLabel.hidden = YES;
    }
    else
    {
        if(!webview.hidden)
        {
            webview.hidden = YES;
        }
        [self performSelector:@selector(displayWebView) withObject:nil afterDelay:0.5];
    }
}

- (void)webViewDidFinishLoad:(IMYWebView*)webView
{
    [self stopCheckTimer];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isFirstLoad = NO;
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    tipLabel.hidden=YES;
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    
    NSLog(@"%@",error.description);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
