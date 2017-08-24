//
//  openWebViewController.m
//  eCloud
//
//  Created by  lyong on 13-7-30.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "openWebViewController.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "ScannerViewController.h"

#import "conn.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "ForwardingRecentViewController.h"
#import "NotificationUtil.h"
#import "UserDefaults.h"
#import "GXViewController.h"
#import "TabbarUtil.h"
#import "mainViewController.h"
#import "AppDelegate.h"

#ifdef _TAIHE_FLAG_
#import "TaiHeLoginViewController.h"
#import "TAIHEAppViewController.h"
#endif

#define JsStr @"var Ecloud = {}; (function initialize() { Ecloud.getUserInfo = function () { return '%@';};})(); "
//不显示导航栏
#define VIEWSHOW_NOHEAD @"VIEWSHOW_NOHEAD"

@interface openWebViewController ()<UIActionSheetDelegate,ForwardingDelegate>

@end


@implementation openWebViewController
{
    /** 定时器，检查网页加载的情况 */
    NSTimer *checkTimer;
    /** 是否为第一次加载 */
	BOOL isFirstLoad;
}
@synthesize customTitle;
@synthesize urlstr;
@synthesize fromtype;
@synthesize needUserInfo;
@synthesize curUrlStr;
@synthesize navigationType;
@synthesize forwardRecord;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    self.customTitle = nil;
    self.forwardStr = nil;
    self.forwardRecord = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	isFirstLoad = YES;
	
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

    UIButton *button =  [UIAdapterUtil setRightButtonItemWithImageName:@"ic_actbar_more" andTarget:self andSelector:@selector(openWithSafari)];
    [button setImage:[StringUtil getImageByResName:@"ic_actbar_more_pressed@"] forState:UIControlStateHighlighted];
    
    // yanlei 若为图片的浏览器页面则增加右侧转发按钮
    if (self.forwardStr && ![@"" isEqualToString:self.forwardStr]) {
        [UIAdapterUtil setRightButtonItemWithTitle:@"转发" andTarget:self andSelector:@selector(forward:)];
    }
	
    int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
	webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH)];
    webview.scalesPageToFit = YES;
	
    NSLog(@"contentSize = %@",NSStringFromCGSize(webview.scrollView.contentSize));
    
	[self.view addSubview:webview];
	
	// NSString *urlAddress = @"http://www.baidu.com";
	NSString *strUrl = [self.urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	//self.title = self.urlstr;
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:strUrl];
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	webview.delegate=self;
	//Load the request in the IMYWebView.
	[webview loadRequest:requestObj];
	
    tipLabel= [[self class] getTipsLabel];
    [self.view addSubview:tipLabel];
}
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)_navigationType
{
	self.curUrlStr = request.URL.absoluteString;
    self.navigationType = _navigationType;
    
	conn *_conn = [conn getConn];
	if(self.needUserInfo &&  _conn.userEmail.length > 0 && _conn.userId.length > 0)
	{
		NSString *userInfoStr = [NSString stringWithFormat:@"%@:%@",_conn.userEmail,_conn.userId];
		NSString *js = [NSString stringWithFormat:JsStr,userInfoStr];
		[webView stringByEvaluatingJavaScriptFromString:js];
	}
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%s current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]);
//    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
    
	
//	NSLog(@"%@",request.mainDocumentURL.relativePath);
//	if([request.mainDocumentURL.relativePath isEqualToString:@"/getInfo/name"])
//    {
//        NSString *info = [[UIDevice currentDevice] name];
//        NSString *js = [NSString stringWithFormat:@"showInfo(\"name\",\"%@\")",info];
//        [webView stringByEvaluatingJavaScriptFromString:js];
//        return false;
//    }

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
//    update by shisp 
//	[self performSelector:@selector(displayWebView) withObject:nil afterDelay:0.5];
    //重新初始化 定时器 检查 webview的title是否取到，取到之后，就显示webview
    [self stopCheckTimer];
    // 定时器
    checkTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(checkWebview) userInfo:nil repeats:YES] ;
}

/**
 定时器执行的任务，检测网页加载的情况
 */
- (void)checkWebview
{
    NSString *tempStr = [webview pageTitle];
    if (tempStr.length) {
        webview.hidden = NO;
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
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    [openWebViewController popViewController:self];
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
        [self stopCheckTimer];
    }
}

+ (void)popViewController:(UIViewController *)curViewController
{
    int scannerIndex = 0;
    
    for (int index = 0; index < curViewController.navigationController.viewControllers.count; index++) {
        UIViewController *childVC = curViewController.navigationController.viewControllers[index];
        if ([childVC isKindOfClass:[ScannerViewController class]]) {
            scannerIndex = index;
            break;
        }
    }
    
    if (scannerIndex > 0) {
        UIViewController *childVC = curViewController.navigationController.viewControllers[scannerIndex - 1];
        [curViewController.navigationController popToViewController:childVC animated:YES];
    }else{
        [curViewController.navigationController popViewControllerAnimated:YES];
    }
}

// 在Safari中打开当前链接
- (void)openWithSafari
{
    if (IOS8_OR_LATER)
    {
        UIAlertController *alertCtl = [[UIAlertController alloc] init];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"open_with_safari"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            
            [[UIApplication sharedApplication] openURL:webview.URL];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"cancel"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            [self popoverPresentationController];
        }];
        
        
        [alertCtl addAction:openAction];
        [alertCtl addAction:cancelAction];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
    }
    else
    {
        UIActionSheet *menu = [[UIActionSheet alloc]
                               initWithTitle:nil
                               delegate:self
                               cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"]
                               destructiveButtonTitle:nil
                               otherButtonTitles:[StringUtil getLocalizableString:@"open_with_safari"], nil];
        [menu showInView:self.view];
    }
    
    
    NSLog(@"openWithSafari");
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:webview.URL];
    }
}

// 转发 按钮
/**
 转发操作

 @param sender 转发按钮对象
 */
- (void) forward:(id) sender{
    ConvRecord *_convRecord = nil;
    
    _convRecord = [[ConvRecord alloc]init];
    _convRecord.msg_type = type_imgtxt;
    _convRecord.msg_body = self.forwardStr;
    self.forwardRecord = _convRecord;
    [_convRecord release];
    
    if (_convRecord) {
        [self openRecentContacts];
    }
}

/**
 打开最近联系人，用来转发
 */
- (void)openRecentContacts
{
    ForwardingRecentViewController *forwarding=[[ForwardingRecentViewController alloc]initWithConvRecord:self.forwardRecord];
    forwarding.fromType = transfer_from_image_preview;
    forwarding.forwardingDelegate = self;
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:forwarding];
    [forwarding release];
    nav.navigationBar.tintColor=[UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
//    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 urlstr的set方法

 @param strUrl 即将加载的url字符串
 */
- (void)setUrlstr:(NSString *)strUrl
{
    if (strUrl) {
        [urlstr release];
        
        NSRange httprange=[strUrl rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        NSRange httpsrange=[strUrl rangeOfString:@"https://"];
        NSString *newhttp=strUrl;
        // url中是否包含http前缀，若不存在就加上http前缀
        if (httprange.location==NSNotFound && httpsrange.location==NSNotFound ) {
            newhttp=[NSString stringWithFormat:@"http://%@",strUrl];
        }
        
        urlstr = [newhttp retain];
    }
}

+ (UILabel *)getTipsLabel
{
    UILabel *tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    tipLabel.text = [StringUtil getLocalizableString:@"loading"];

    return [tipLabel autorelease];
}

@end
