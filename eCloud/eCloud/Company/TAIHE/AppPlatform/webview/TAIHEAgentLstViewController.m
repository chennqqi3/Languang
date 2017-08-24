//
//  TAIHEAgentLstViewController.m
//  eCloud
//
//  Created by Ji on 17/3/16.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEAgentLstViewController.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "ScannerViewController.h"

#import "conn.h"
#import "UIAdapterUtil.h"
#import "StringUtil.h"
#import "NotificationUtil.h"
#import "UserDefaults.h"
#import "GXViewController.h"
#import "TabbarUtil.h"
#import "mainViewController.h"
#import "AppDelegate.h"
#import "JSSDKObject.h"
#import "WebViewJavascriptBridge.h"

#ifdef _TAIHE_FLAG_
#import "TaiHeLoginViewController.h"
#import "TAIHEAppViewController.h"
#endif

#define JsStr @"var Ecloud = {}; (function initialize() { Ecloud.getUserInfo = function () { return '%@';};})(); "
//不显示导航栏
#define VIEWSHOW_NOHEAD @"VIEWSHOW_NOHEAD"

@interface TAIHEAgentLstViewController ()

@property (nonatomic,retain)     WebViewJavascriptBridge *bridge;

@end

@implementation TAIHEAgentLstViewController
{
    NSTimer *checkTimer;
    
    BOOL isFirstLoad;
    JSSDKObject *jssdk;
    UIView *_statusBarView;
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
    webview = nil;
    self.urlstr = nil;
    self.curUrlStr = nil;
    self.customTitle = nil;
    self.forwardStr = nil;
    self.forwardRecord = nil;
    
    [super dealloc];

    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];
    if (!self.isNeetHideLeftBtn) {
        [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
    }else{
        //        隐藏返回按钮
        [UIAdapterUtil setLeftButtonItemWithTitle:@" " andTarget:self andSelector:nil andDisplayLeftButtonImage:NO];
    }
    
    if ([self.urlstr rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
        
        [self.navigationController setNavigationBarHidden:YES];
        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }else{
        [self.navigationController setNavigationBarHidden:NO];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO];
    
    [UIAdapterUtil processController:self];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];

    int tableH = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
    
    // 泰禾的ipad不需要减去状态栏
#ifdef _TAIHE_FLAG_
    if (IS_IPAD) {
        
        tableH = SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT ;
    }
#endif
    
    //webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH)];
    webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, tableH) usingUIWebView:YES];
    webview.scalesPageToFit = YES;
    webview.backgroundColor = [UIColor whiteColor];
    webview.scrollView.bounces = NO;
    NSLog(@"contentSize = %@",NSStringFromCGSize(webview.scrollView.contentSize));
    
//    webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:webview];
    
    NSString *strUrl = [self.urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    
    webview.delegate=self;
    
//    if ([self.urlstr rangeOfString:@"http://www.fdccloud.com"].length > 0 || [self.urlstr rangeOfString:@"https://www.fdccloud.com"].length > 0) {
//        NSString *cookieValue = [TAIHEAppViewController cookieString];
//        requestObj = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
//        [requestObj addValue:cookieValue forHTTPHeaderField:@"Cookie"];
    
//        [LogUtil debug:[NSString stringWithFormat:@"%s mingyuan: %@",__FUNCTION__,self.urlstr]];
//
 //   }
    
    [webview loadRequest:requestObj];
    [webview release];
    
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel release];
   
    [self initInterface];
    
    //	NSLog(@"%s,url str is %@",__FUNCTION__,self.urlstr);
}
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)_navigationType
{
    //    NSLog(@"%s,%@,%d",__FUNCTION__,request.URL.absoluteString,navigationType);
    
    self.curUrlStr = request.URL.absoluteString;
//    如果是明源待办，那么不走公司的sso验证，通过把从OA取回的token保存到cookie,实现单点登录
    [TAIHEAppViewController setAppCookie:request];
    
    self.navigationType = _navigationType;
    
    conn *_conn = [conn getConn];
    if(self.needUserInfo &&  _conn.userEmail.length > 0 && _conn.userId.length > 0)
    {
        NSString *userInfoStr = [NSString stringWithFormat:@"%@:%@",_conn.userEmail,_conn.userId];
        NSString *js = [NSString stringWithFormat:JsStr,userInfoStr];
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([UIAdapterUtil isTAIHEApp]) {
        if ([curWebViewUrl rangeOfString:@"taihe_h5_close"].length > 0) {
            // 返回上一级界面
            [self.navigationController popViewControllerAnimated:YES];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s return NO current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
            return NO;
        }else if([curWebViewUrl rangeOfString:@"taihe_password_modify_success"].length > 0){
            // 返回到登录界面
            [self exist];
            
            [LogUtil debug:[NSString stringWithFormat:@"%s return NO current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
            return NO;
        }else if ([curWebViewUrl rangeOfString:@"taihe_todo_home"].length > 0){
            
#ifdef _TAIHE_FLAG_
            if ([_isGoHome isEqualToString:GO_NATIVE_HOME]) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }else if([_isGoHome isEqualToString:GO_OA_HOME]){
                
                NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.urlstr,GO_OA_HOME, nil];

                [self popSelf];
                
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_GO_OA_HOME andObject:nil andUserInfo:dict];
                [dict release];
            }else if ([_isGoHome isEqualToString:WORK_GO_OA_HOME])
            {
               [self popSelf];
                NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.urlstr,WORK_GO_OA_HOME, nil];
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_WORK_GO_OA_HOME andObject:nil andUserInfo:dict];
                [dict release];
            }
//            for (UIViewController *ctrl in self.navigationController.viewControllers) {
//                
//                if ([ctrl isKindOfClass:[TAIHEAppViewController class]]) {
//                    [self.navigationController popToViewController:ctrl animated:YES];
//                }
//            }
            
            [LogUtil debug:[NSString stringWithFormat:@"%s return NO current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];

            return NO;
#endif
        }
        
        if ([curWebViewUrl rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
            CGRect _frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT);
            webview.frame = _frame;
            [self.navigationController setNavigationBarHidden:YES];

            _statusBarView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
            _statusBarView.backgroundColor = _color;
            [self.view addSubview:_statusBarView];
            [_statusBarView release];
            
        }
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s return YES current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];

    return YES;
}

-(void) webViewDidStartLoad:(IMYWebView *)webView
{
    NSURL *_url = ((IMYWebView *)webView).URL;
    if (_url.absoluteString.length) {
        [LogUtil debug:[NSString stringWithFormat:@"%s request is %@",__FUNCTION__,_url]];
        [TAIHEAppViewController cookieString];
    }

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
//返回 按钮
-(void) backButtonPressed:(id) sender
{
    
    if ([UIAdapterUtil isTAIHEApp]) {
        if ([webview canGoBack]) {   // 若当前页面不是首页进行页面回退操作
            [webview goBack];
            return ;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];

    
}

- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        
        if ([UIAdapterUtil isTAIHEApp]) {
            
            if ([_isWhere isEqualToString:REFRESH_PAGE]) {
                
                //sys_news_main urlstr
                if ([self.urlstr rangeOfString:@"sys_news_main"].length > 0) {
                    
                    
                }else{
                    
                    [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:REFRESH_PAGE];
                }
                
                
            }else if ([_isWhere isEqualToString:REFRESH_EMAIL]){
                
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:REFRESH_EMAIL];
                
            }else if([_isWhere isEqualToString:REFRESH_OA]){
                
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:REFRESH_OA];
            }
        }
        
        [self stopCheckTimer];
        self.bridge = nil;
        jssdk.bridge = nil;
        jssdk.curVC = nil;
        [jssdk release];
        jssdk = nil;
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    /** 清除缓存 */
    [StringUtil cleanCacheAndCookie];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 退回到登录界面
- (void)exist{
    [UserDefaults saveUserIsExit:YES];
    // 清除原来的密码
    NSString *accountStr = [UserDefaults getAccountInfo];
    
    NSMutableDictionary *accountInfoDic = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults getAccountInfo]];
    if (accountInfoDic && [accountInfoDic allKeys].count > 0) {
        int accountSaveState = 0;
        [accountInfoDic removeObjectForKey:accountStr];
        
        [UserDefaults saveAccountInfo:accountInfoDic];
        [UserDefaults saveSaveState:[NSNumber numberWithInt:accountSaveState]];
    }
    
    id tabbarVC = [TabbarUtil getTabbarController];
    if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
        id mainVC = ((GXViewController *)tabbarVC).delegate;
        [((mainViewController*)mainVC) backRoot];
    }else{
#ifdef _TAIHE_FLAG_
        AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
        TaiHeLoginViewController *newLogin= [[TaiHeLoginViewController alloc]initWithNibName:@"TaiHeLoginViewController" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
#endif
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

}

- (void)popSelf
{
    [self performSelectorOnMainThread:@selector(popSelf2) withObject:nil waitUntilDone:YES];
}

- (void)popSelf2
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
