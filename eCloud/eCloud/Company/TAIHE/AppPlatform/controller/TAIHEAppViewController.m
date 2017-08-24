//
//  TAIHEAppViewController.m
//  eCloud
//
//  Created by Ji on 17/1/10.
//  Copyright © 2017年  lyong. All rights reserved.
//

#import "TAIHEAppViewController.h"
#import "StringUtil.h"
#import "APPListModel.h"
#import "APPPlatformDOA.h"
#import "CustomMyCell.h"
#import "IMYWebView.h"
#import "IOSSystemDefine.h"
#import "NewMsgNumberUtil.h"
#import "UIAdapterUtil.h"
#import "ImageUtil.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "MJRefresh.h"
#import "userInfoViewController.h"
#import "TAIHEAgentLstViewController.h"
#import "UIImageView+WebCache.h"
#import "ServerConfig.h"
#import "AFNetworking.h"
#import "OANewsEntity.h"
#import "EmailViewController.h"
#import "UserDefaults.h"
#import "SDCycleScrollView.h"
#import "TabbarUtil.h"
#import "AESCipher.h"
#import "ApplicationManager.h"
#import "JSSDKObject.h"
#import "WebViewJavascriptBridge.h"
#import "JsObjectCViewController.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "NewMsgNotice.h"
#import "talkSessionUtil.h"
#import "TAIHEAppMsgModel.h"
#import "ConvRecord.h"
#import "UserDefaults.h"

#define WX_D_APP_BASE_TAG 200
#define APP_DAIBAN_ID 101
#define APP_EMAIL_ID 102

//#define LINE_MAX_COUNT (IS_IPHONE_6P ? 5 : (IS_IPHONE_6 ?  5 : 4))
//#define COLLECTION_Y (IS_IPHONE_6P ? 60 : (IS_IPHONE_6 ?  60 : 50))approval

// 不加密用的宏
//#define TAIHE_APPROVAL_URL @"http://im.tahoecn.com:9010/TaiheServer_1/DataService?username=%@&url=http://oa01.tahoecn.com:8080/ekp/sys/notify/mobile"
// 加密要用到的宏
#define TAIHE_APPROVAL_URL @"http://im2.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=http://oa.tahoecn.com/ekp/sys/notify/mobile"
// 获取邮件未读数
#define TAIHE_EMAILNOREADCOUNT_URL @"http://im.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=http://oa.tahoecn.com/ekp/sys/common/json.jsp?s_bean=sysMailGetNotReadCountService&loginName=%@"

// 获取待办未读数
#define TAIHE_DAIBANNOREADCOUNT_URL @"http://im.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=http://oa.tahoecn.com/ekp/sys/notify/sys_notify_todo/sysNotifyTodo.do?method=getNotifyCount"

@interface TAIHEAppViewController ()<IMYWebViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,SDCycleScrollViewDelegate>

@property(nonatomic,retain) NSMutableArray *userDataTextArray;
@property(nonatomic,retain) NSMutableArray *guideImageArr;
@property (nonatomic,strong)UIScrollView *scroll;

@property(nonatomic,strong)IMYWebView *webview;
@property(retain,nonatomic) Emp *emp;
@property(nonatomic,retain)UIScrollView *imageScrollView;
@property(nonatomic,retain)SDCycleScrollView *cycleScrollView3;
//@property (retain, nonatomic)  UIPageControl *page;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;

@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;

@property (nonatomic,assign) int unRead_email;
@property (nonatomic,assign) int unRead_daiban;
@property (nonatomic,assign) int unReadAppCount;
@property (nonatomic,assign) int refreshCount;
@property (nonatomic,retain)     WebViewJavascriptBridge *bridge;
@end

@implementation TAIHEAppViewController
{
    UIButton *_eatButton;
    conn *_conn;
    eCloudDAO *db;
    UIImageView *_bigImg;
    UIButton *_leftButton;
    NSInteger pages;
    UIButton *_closeButton;
    BOOL isClose;
    JSSDKObject *jssdk;
    NSTimer *_timer;
    int time;
    eCloudDAO *_ecloud;
    UIAlertView *alert;
}

static TAIHEAppViewController *_taiHeAppViewController;

+(TAIHEAppViewController *)getTaiHeAppViewController
{
    if(_taiHeAppViewController == nil)
    {
        _taiHeAppViewController = [[self alloc]init];
    }
    return _taiHeAppViewController;
}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAI_HE_REFRESH_PAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONVERSATION_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAI_HE_GO_OA_HOME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAI_HE_LOG_OUT object:nil];
    
    [self.userDataTextArray removeAllObjects];
    self.userDataTextArray = nil;
    [self.guideImageArr removeAllObjects];
    _guideImageArr = nil;
    [self.pan removeObserver:self forKeyPath:MJRefreshKeyPathPanState];
    self.pan = nil;
    _webview.delegate = nil;
    _webview = nil;
    
}

/** 退出登录时，制空js和计时器，不然影响到界面的释放 */
- (void)mydealloc{
    
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    
    self.bridge = nil;
    jssdk.bridge = nil;
    jssdk.curVC = nil;
    jssdk = nil;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [StringUtil getAppLocalizableString:@"taihe_office"];
    [UIAdapterUtil showTabar:self];
    [_leftButton setImage:[self headTangential] forState:UIControlStateNormal];
    
    AppDelegate *appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    // 切换3次回到首页tab进行刷新OA
    //if (appDelegate.changeAppCtrlCount == 3) {
      //  appDelegate.changeAppCtrlCount = 0;
        //[self headerRefresh];
    //}
    
    // 需求，进入邮箱或者代办后返回刷新未读数
    if (self.isReloadHttpUnReadDaiban) {
        self.isReloadHttpUnReadDaiban = NO;
        [self loadNoReadRequest:APP_DAIBAN_ID];
         [self headerRefresh];
    }
    if (self.isReloadHttpUnReadEmail) {
        self.isReloadHttpUnReadEmail = NO;
        [self loadNoReadRequest:APP_EMAIL_ID];
    }
    
    if (self.refreshCount == 1) {
        
        [self loadNoReadRequest:0];
        [self headerRefresh];
    }
    
    [self.navigationController setNavigationBarHidden:NO];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoadRequest) name:NETWORK_SWITCH object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(IsRefresh:) name:TAI_HE_REFRESH_PAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMsg:) name:CONVERSATION_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GoOAHome:) name:TAI_HE_GO_OA_HOME object:nil];
//    [self initNavLeftHead];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mydealloc) name:TAI_HE_LOG_OUT object:nil];
    
    self.guideImageArr = [[NSMutableArray alloc]init];
    
//    self.isReloadHttpUnReadDaiban = YES;
//    self.isReloadHttpUnReadEmail = YES;
    
    [self initView];
    
    //[self initInterface];
    
    self.refreshCount = 0;

    time = 0;
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    _ecloud = [eCloudDAO getDatabase];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.refreshCount = 0;
}

- (void)GoOAHome:(NSNotification *)notification{
 
    NSString *urlStr = notification.userInfo[GO_OA_HOME];
    
    TAIHEAgentLstViewController *agent = [[TAIHEAgentLstViewController alloc]init];
    agent.urlstr = urlStr;
    agent.isGoHome = GO_OA_HOME;

    [self.navigationController pushViewController:agent animated:NO];
}
- (void)IsRefresh:(NSNotification *)notification{
    
    if ([notification.userInfo isEqual:REFRESH_PAGE]) {
        
        [self headerRefresh];
        [self loadNoReadRequest:APP_DAIBAN_ID];
        
    }else if([notification.userInfo isEqual:REFRESH_EMAIL]){
        
        [self loadNoReadRequest:APP_EMAIL_ID];
        
    }else if([notification.userInfo isEqual:REFRESH_OA]){
        
        [self loadNoReadRequest:APP_DAIBAN_ID];
        [self headerRefresh];
    }
    
}

- (void)handleMsg:(NSNotification *)notification{
    
    eCloudNotification	*cmd =	(eCloudNotification *)[notification object];
    
    switch (cmd.cmdId){
        case rev_msg:
        {
            NSDictionary *_userInfo = notification.userInfo;
            if (_userInfo){
                NewMsgNotice *_notice = [_userInfo valueForKey:@"msg_notice"];
                if (_notice){
                    if(_notice.msgType == normal_new_msg_type){
                        NSString* convId = _notice.convId;
                        NSString *msgId = _notice.msgId;
                        ConvRecord *convRecord = [[eCloudDAO getDatabase] getConvRecordByMsgId:msgId];
                        if(convRecord){
                            
                            [talkSessionUtil preProcessTextAppMsg:convRecord];
                            
                            if (convRecord.appMsgModel.title) {
                                if (convRecord.appMsgModel.apptype == 1) {
                                    
                                    [self loadNoReadRequest:APP_EMAIL_ID];
                                    
                                }else if (convRecord.appMsgModel.apptype ==2){
                                    
                                    [self loadNoReadRequest:APP_DAIBAN_ID];
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                
            }
            
            break;
        }
    }
    
}

#pragma mark - 泰禾需求，如果在首页，1分钟刷新一次  3月31号需求，改为15分钟刷新一次
- (void)timerAction
{
    time++;
    if (time == 900) {
        
        [self IsHeaderRefresh];
        time = 0;
    }
}

#pragma mark - 是否刷新首页
- (void)IsHeaderRefresh{
    
    //当前是否停留在泰禾首页
    if ([TabbarUtil displayTaiHeHomePage]) {
        
        [self loadNoReadRequest:0];
        [self headerRefresh];
    }else{
        
        //如果不是，做个标记，回首页的时候刷新
        self.refreshCount = 1;
    }
    
}
- (void)reLoadRequest{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

    [self loadHttpData];
    [self loadNoReadRequest:0];
    
}

#pragma mark ======和JS互相调用接口========

//接口初始化
- (void)initInterface
{
    [WebViewJavascriptBridge enableLogging];
    UIViewController *weakSelf =self;
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webview webViewDelegate:weakSelf handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取_bridge----");
    }];
    
    jssdk = [[JSSDKObject alloc]init];
    jssdk.bridge = self.bridge;
    jssdk.curVC = self;
    
    [jssdk initSDK];
    
    //    [self initImage];
}

- (void)Picture{
    
    [_leftButton setImage:[self headTangential] forState:UIControlStateNormal];
}
- (void)handleCmd:(NSNotification *)notif{
    // 每次都重新建应用这个需要优化
    [self ButtonAssignment];
}

- (void)initView{
    
    _scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/3/2)];
    
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:_scroll];
  
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"ad_image_tmp.png",@"ad_image_tmp.png",@"ad_image_tmp.png",@"ad_image_tmp.png", nil];
//    UIImage *image = [StringUtil getImageByResName:@"ad_image_tmp.png"];
//    _bigImg = [[UIImageView alloc]init];
//    _bigImg.frame = CGRectMake(0, _scroll.frame.size.height, SCREEN_WIDTH,SCREEN_HEIGHT/3/2);
//    _bigImg.image = image;
//    _bigImg.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_bigImg];
    
    [self ButtonAssignment];
    
    [self loadHttpData];

    // 发出请求加载邮件未读数
    [self loadNoReadRequest:0];
    //[self initGuideImage];
}
#pragma mark - 待办参数加密  如linzhongxing,t=182156这样的参数格式加密
- (NSString *)encryptStr:(NSString *)sourceStr{
    // 获取服务器时间
    int currentServerTime = [[conn getConn] getCurrentTime];
    NSDateFormatter *formatter 	= [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd:HH:mm";
    NSString *dateStr2=[formatter stringFromDate:[NSDate date]];
    
    sourceStr = [sourceStr stringByAppendingString:[NSString stringWithFormat:@",t=%@",[dateStr2 stringByReplacingOccurrencesOfString:@":" withString:@""]]];
    NSString *password = @"1234567891234567";
    NSString *encryStr = [AESCipher encryptAES:sourceStr key:password];
    
    return encryStr;
}

#pragma mark - 下拉刷新
- (void)headerRefresh{

    if ([self checkNetwork]) {
        // 使用加密的参数
        NSString *paramStr = [StringUtil encryptStr];
        
        //@"http://im2.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=http://oa.tahoecn.com/ekp/sys/notify/mobile"
        NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
        NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

        NSString *urlString = [[NSString stringWithFormat:@"%@?username=%@&url=%@/sys/notify/mobile",ssoUrl,paramStr,oaUrl]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSLog(@"待办的请求路径urlString = %@",urlString);
//        NSString *cookieValue = [[self class] cookieString];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

        [_webview loadRequest:request];
        
    }else{
        
        [_webview.scrollView.mj_header endRefreshing];
    }
    
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{

    [_webview.scrollView.mj_header endRefreshing];
    
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationTyp{
    
    [[self class] setAppCookie:request];
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@",__FUNCTION__,curWebViewUrl]]
    ;
    // OA的H5中点击含有TARGET_NEW=1关键字时，拦截此路径在新页面中打开
    if ([curWebViewUrl rangeOfString:@"TARGET_NEW=1"].length > 0) {
        TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
        openweb.urlstr= curWebViewUrl;
        openweb.isWhere = REFRESH_PAGE;
        openweb.isGoHome = GO_NATIVE_HOME;
        [self.navigationController pushViewController:openweb animated:YES];
        [UIAdapterUtil hideTabBar:self];
        return NO;
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSURL *_url = ((IMYWebView *)webView).URL;
    if (_url.absoluteString.length) {
        [LogUtil debug:[NSString stringWithFormat:@"%s request is %@",__FUNCTION__,_url]];
        [TAIHEAppViewController cookieString];
    }

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self endRefresh];
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    // new for memory cleanup
    
    [[NSURLCache sharedURLCache] setMemoryCapacity: 0];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    
    [NSURLCache setSharedURLCache:sharedCache];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s error==== %@",__FUNCTION__,error]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    [self endRefresh];
}

#pragma mark - 创建广告页和webview
- (void)initGuideImage{//:(NSMutableArray *)newsList{
    
    //[_guideImageArr addObjectsFromArray:newsList];
    
    if (!self.imageScrollView) {
        
        self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _scroll.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT/3/2)];
        self.imageScrollView.pagingEnabled=YES;
        self.imageScrollView.showsVerticalScrollIndicator = NO;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.delegate = self;
        self.imageScrollView.userInteractionEnabled = YES;
        self.imageScrollView.bounces = NO;
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.imageScrollView];
        
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(SCREEN_WIDTH - 30, self.imageScrollView.frame.origin.y + 10,20 , 20);
        
        UIImage *image = [StringUtil getImageByResName:@"close_button.png"];
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeGuideImage) forControlEvents:UIControlEventTouchUpInside];
    }
    // 客户要求不要这个关闭按钮
//    [self.view addSubview:_closeButton];
    
    //self.page=[[UIPageControl alloc]initWithFrame:CGRectMake(self.imageScrollView.frame.size.width/2-40, self.imageScrollView.frame.origin.y +self.imageScrollView.frame.size.height- 20,80,20)];
    //共有几个点
    //self.page.numberOfPages = self.guideImageArr.count;
    //在第几个点上
    //self.page.currentPage=0;
    //[self.page addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    //self.page.currentPageIndicatorTintColor = [UIColor whiteColor];
    //self.page.pageIndicatorTintColor = [UIColor grayColor];
    //if (self.guideImageArr.count > 1) {
      //  [self.view addSubview:self.page];
    //}
    
    NSMutableArray *imagesURLStrings;
    imagesURLStrings = [NSMutableArray array];
    for (int i = 0 ; i < self.guideImageArr.count; i++) {
        
        OANewsEntity * model = [[OANewsEntity alloc]init];
        model = self.guideImageArr[i];
        
        [imagesURLStrings addObject:model.thumb];
    }
    
    if (_cycleScrollView3) {
        
        _cycleScrollView3.imageURLStringsGroup = imagesURLStrings;
        
    }else{
        _cycleScrollView3 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
        _cycleScrollView3.backgroundColor = [UIColor whiteColor];
        _cycleScrollView3.delegate = self;
        _cycleScrollView3.currentPageDotColor = [UIColor grayColor];
        _cycleScrollView3.imageURLStringsGroup = imagesURLStrings;
        //         --- 轮播时间间隔，默认1.0秒，可自定义
        //cycleScrollView.autoScrollTimeInterval = 4.0;
        
        [self.imageScrollView addSubview:_cycleScrollView3];
    }
    //block监听点击方式
    //17-3-13新需求，首页广告不需求点击跳转
//    __weak typeof(self) weakSelf = self;
//    _cycleScrollView3.clickItemOperationBlock = ^(NSInteger index) {
//        //NSLog(@">>>>>  %ld", (long)index);
//        
//        [weakSelf OpenImageLinks:index];
//    };
    if (_webview) {
        
        [self headerRefresh];
    }else{
        //_webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48)];
        
        _webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48) usingUIWebView:NO];
        _webview.scalesPageToFit = YES;
        _webview.delegate=self;
        _webview.scrollView.bounces = YES;
        _webview.backgroundColor = [UIColor clearColor];
        _webview.scrollView.delegate = self;
        
        _webview.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        //    NSString *paramStr = [UserDefaults getUserAccount];
        
        // 使用加密的参数
        
        
        NSString *paramStr = [StringUtil encryptStr];
        
        //@"http://im2.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=http://oa.tahoecn.com/ekp/sys/notify/mobile"
        NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
        NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];

        NSString *urlString = [[NSString stringWithFormat:@"%@?username=%@&url=%@/sys/notify/mobile",ssoUrl,paramStr,oaUrl]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSString *cookieValue = [[self class] cookieString];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [_webview loadRequest:request];
        [self.view addSubview:_webview];
        
        _webview.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
        [self.imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH*self.guideImageArr.count,SCREEN_HEIGHT/3/2)];
        
        self.pan =  _webview.scrollView.panGestureRecognizer;
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.pan addObserver:self forKeyPath:MJRefreshKeyPathPanState options:options context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    UIPanGestureRecognizer *recognizer = object;
    
    [self commitTranslation:[recognizer translationInView:_webview.scrollView]];
    
    
}
- (void)commitTranslation:(CGPoint)translation
{
    
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);

    if (absY > absX) {
        if (translation.y<0) {
 
            if (self.imageScrollView.hidden) {
                
                return;
            }else{
                
                [self HiddenGuideImage];
                
            }
            //向上滑动
        }else{

            //向下滑动
        }
    }
    
    
}
#pragma mark - 关闭广告页
- (void)closeGuideImage{
    
    [UIView beginAnimations:nil context:nil];
    //设置动画时长
    [UIView setAnimationDuration:0.5];
    
    [self.imageScrollView removeFromSuperview];
    
    _webview.frame = CGRectMake(0, _scroll.frame.size.height + _scroll.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT  - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48);
    
    _closeButton.hidden = YES;
    isClose = YES;
    [UIView commitAnimations];
    
}
#pragma mark - 隐藏广告页
- (void)HiddenGuideImage{
    
//    [UIView beginAnimations:nil context:nil];
    //设置动画时长
//    [UIView setAnimationDuration:0.5];

    self.imageScrollView.hidden = YES;
    _webview.frame = CGRectMake(0, _scroll.frame.size.height + _scroll.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT  - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48);
   
//    _closeButton.hidden = YES;
//    [UIView commitAnimations];
}
#pragma mark - 创建轻应用按钮
- (void)ButtonAssignment
{
    self.userDataTextArray = [NSMutableArray array];
    if (self.userDataTextArray != nil && [self.userDataTextArray count]) {
        [self.userDataTextArray removeAllObjects];
    }
    self.userDataTextArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];

    int i = 0;
    
    for (UIView * subview in [_scroll subviews]) {
        [subview removeFromSuperview];
    }
    
    self.unReadAppCount = 0;
    for (NSArray *modelArr in self.userDataTextArray) {
        
        for (APPListModel *appModel in modelArr) {
            
            _eatButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _eatButton.frame = CGRectMake(10+SCREEN_WIDTH/5*i, 15,SCREEN_WIDTH/5-20 , SCREEN_WIDTH/5-20);
            
            UIImage *image = [CustomMyCell getAppLogo:appModel];
            
            [_eatButton setImage:image forState:UIControlStateNormal];
            [_eatButton addTarget:self action:@selector(singleSelected:) forControlEvents:UIControlEventTouchUpInside];
            _eatButton.tag = i + WX_D_APP_BASE_TAG;
            [_scroll addSubview:_eatButton];
            
            CGRect _frame = _eatButton.frame;
            UILabel *eatLabel = [[UILabel alloc] initWithFrame:CGRectMake(_frame.origin.x - 10, _frame.size.height + 10 ,_frame.size.width +20 , 50)];
            eatLabel.text = appModel.appname;
            
            eatLabel.textColor = [UIColor colorWithRed:147/255.0 green:147/255.0 blue:147/255.0 alpha:1];
            eatLabel.textAlignment = NSTextAlignmentCenter;
            //            eatLabel.backgroundColor = [UIColor redColor];
            [_scroll addSubview:eatLabel];
            if (IS_IPAD) {
                
                _eatButton.frame = CGRectMake(10+SCREEN_WIDTH/5*i, 15,SCREEN_WIDTH/5-30 , SCREEN_WIDTH/5-30);
                
                CGRect _frame = eatLabel.frame;
                _frame.size.height = eatLabel.frame.size.height - 30;
                _frame.size.width = _eatButton.frame.size.width;
                _frame.origin.x = _eatButton.frame.origin.x;
                _frame.origin.y = eatLabel.frame.origin.y - 5;
                eatLabel.frame = _frame;
                eatLabel.font = [UIFont systemFontOfSize:18];
                
            }else{
                eatLabel.font = [UIFont systemFontOfSize:14];
            }
            // 添加显示未读数的小红点
            [NewMsgNumberUtil addNewMsgNumberView:_eatButton];
            int unReadCount = 0;
            if (appModel.appid == 101) {
                unReadCount = self.unRead_daiban;
            }else if (appModel.appid == 102) {
                unReadCount = self.unRead_email;
            }
            self.unReadAppCount += unReadCount;
            [self setUnreadCount:_eatButton andCount:unReadCount];
            i++;
        }
    }
    [_scroll setContentSize:CGSizeMake(_eatButton.frame.origin.x + _eatButton.frame.size.width +20,0)];

    // 右下角显示红点，不再计算总数
    [self displayAllUnreadMsgCount:self.unReadAppCount];
}

- (void)setUnreadCount:(UIButton *)btn andCount:(int)unReadCount{
    [NewMsgNumberUtil displayNewMsgNumber:btn andNewMsgNumber:unReadCount];
    [NewMsgNumberUtil setUnreadViewFrame:btn];
    
    BOOL isDidShowTabBage = [TabbarUtil isDidShowTabbarBageWithIndex:[eCloudConfig getConfig].myIndex];
    if (!isDidShowTabBage && unReadCount > 0) {
        [self displayAllUnreadMsgCount:unReadCount];
    }
}

#pragma mark - 导航栏左右按钮
- (void)initNavLeftHead{
    
    _leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:_leftButton];
    _leftButton.adjustsImageWhenHighlighted = NO;
    [_leftButton setImage:[self headTangential] forState:UIControlStateNormal];
    [_leftButton addTarget:self action:@selector(openUserInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:item];
    
    [UIAdapterUtil setRightButtonItemWithImageName:@"conf_UserList.png" andTarget:self andSelector:@selector(goTowebsite)];
    
}

#pragma mark - 获取头像
- (UIImage *)headTangential
{
    self.emp = [db getEmpInfo:_conn.userId];

    UIImage *image = [ImageUtil getOnlineEmpLogo:self.emp];;
    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [path addClip];
    [image drawAtPoint:CGPointZero];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 打开个人资料
- (void)openUserInfo{
    
    userInfoViewController *userInfoView = [[userInfoViewController alloc] init];
    
    //        [self hideTabBar];
    [self.navigationController pushViewController:userInfoView animated:YES];
  
}

#pragma mark - 打开泰禾主页
- (void)goTowebsite
{
    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    openweb.urlstr= @"http://www.thaihot.com.cn";
    [self.navigationController pushViewController:openweb animated:YES];
    [UIAdapterUtil hideTabBar:self];

}

#pragma mark - 打开轻应用
- (void)singleSelected:(UIButton *)sender{
    
    UIButton *button = (UIButton *)[self.view viewWithTag:sender.tag];
    [self openAgent:(int)button.tag - WX_D_APP_BASE_TAG];
}
- (void)openAgent:(int)tag
{
    if (self.userDataTextArray) {
        NSArray *modelArr = self.userDataTextArray[0];
        APPListModel *appModel = modelArr[tag];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,appModel.apphomepage]];
        
        // 使用加密的参数
        NSString *paramStr = [StringUtil encryptStr];
        NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
        NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
        NSString *url = [NSString stringWithFormat:@"%@?username=%@",ssoUrl,paramStr];
        if (appModel.appid == 102) {
        
            EmailViewController *emailVC = [[EmailViewController alloc]init];
            [UIAdapterUtil hideTabBar:self];
            
            //@"http://im.tahoecn.com:9010/TaiheServer/DataService?username=%@&url=%@"
            
            emailVC.urlstr = [[NSString stringWithFormat:@"%@&url=%@",url,appModel.apphomepage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.isReloadHttpUnReadEmail = YES;
            [self.navigationController pushViewController:emailVC animated:YES];
            return;
        }
        
        //JsObjectCViewController *agentListVC = [[JsObjectCViewController alloc] init];
        TAIHEAgentLstViewController *agentListVC = [[TAIHEAgentLstViewController alloc]init];
        if (appModel.appid == 101) {
            self.isReloadHttpUnReadDaiban = YES;
            
        }
        agentListVC.isGoHome = GO_OA_HOME;
        agentListVC.urlstr = [[NSString stringWithFormat:@"%@&url=%@",url,appModel.apphomepage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self.navigationController pushViewController:agentListVC animated:YES];
    }
}

//-(void)pageTurn:(UIPageControl *)aPageControl{
//
//    NSInteger whichPage = aPageControl.currentPage;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3f];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [self.imageScrollView setContentOffset:CGPointMake(self.imageScrollView.frame.size.width * whichPage, 0.0f) animated:YES];
//    [UIView commitAnimations];
//}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    //int page = self.imageScrollView.contentOffset.x / 290;//通过滚动的偏移量来判断目前页面所对应的小白点
    //self.page.currentPage = page;   //pagecontroll响应值的变化
    //pages = self.page.currentPage;

    if (_webview.scrollView.contentOffset.y < 0) {
        
        if (self.imageScrollView.hidden) {
            
            _webview.scrollView.bounces = NO;
            [self showGuideImage];
        }
    }
    //Y等于负数
}

#pragma mark - 显示广告页
- (void)showGuideImage{
    
    if (isClose) {
        
        _webview.scrollView.bounces = YES;
        return;
    }
//    [UIView beginAnimations:nil context:nil];
    //设置动画时长
//    [UIView setAnimationDuration:0.5];
    
    self.imageScrollView.hidden = NO;
    
    _webview.frame = CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48);
//    _closeButton.hidden = NO;
//    [UIView commitAnimations];
    
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.5];
    
}
- (void)delayMethod
{
    _webview.scrollView.bounces = YES;
}
#pragma mark - 打开广告页连接
- (void)OpenImageLinks:(NSInteger )index
{

    OANewsEntity * model = [[OANewsEntity alloc]init];
    model = self.guideImageArr[index];
    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    openweb.urlstr= model.url;
    //JsObjectCViewController *openweb = [[JsObjectCViewController alloc] init];
    [self.navigationController pushViewController:openweb animated:YES];
    [UIAdapterUtil hideTabBar:self];
   
}

#pragma mark - 请求登录界面广告信息接口
- (void)loadHttpData{
    
    id dict = [UserDefaults getTaiHeAppGuideImageUrl];
    
    if (dict == nil) {
        
        [self requestHttpData];
        
    }else{
        
        if (self.guideImageArr) {
            
            [self.guideImageArr removeAllObjects];
            
        }
        NSMutableArray *adInfoArr = dict[@"data"];
        for (NSDictionary *adInfoDic in adInfoArr) {
            
            OANewsEntity * entity = [[OANewsEntity alloc]init];
            [entity setValuesForKeysWithDictionary:adInfoDic];
            [self.guideImageArr addObject:entity];
        }
        
        [self initGuideImage];
        
        [self requestHttpData];
        
    }
    
}

- (void)requestHttpData{
    
    NSString *loginAdInfoUrl = [[ServerConfig shareServerConfig]getLoginADInfoUrl:1];
    self.manager.requestSerializer.timeoutInterval = 30;
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [self.manager POST:loginAdInfoUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取登录页广告信息 == %@",__FUNCTION__,responseObject]];
        id dict = responseObject;
        id empDict = [UserDefaults getTaiHeAppGuideImageUrl];
        
        if ([dict isEqualToDictionary:empDict]) {
            
            return ;
        }
        NSString *stateCode = [NSString stringWithFormat:@"%@",dict[@"status"]];
        if ([stateCode isEqualToString:@"0"]) {
            NSMutableArray *adInfoArr = dict[@"data"];
            if (self.guideImageArr) {
                
                [self.guideImageArr removeAllObjects];
                
            }
            for (NSDictionary *adInfoDic in adInfoArr) {
                
                OANewsEntity * entity = [[OANewsEntity alloc]init];
                [entity setValuesForKeysWithDictionary:adInfoDic];
                [self.guideImageArr addObject:entity];
            }
            
            [UserDefaults saveTaiHeAppGuideImageUrl:responseObject];
            
            [self initGuideImage];
        }else{
            //            [UserTipsUtil showAlert:dict[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        [[LCLLoadingView currentIndicator]hiddenForcibly:true];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取登录页广告信息失败 == %@",__FUNCTION__,error]];
        //        [UserTipsUtil showAlert:@"登录页广告信息获取失败"];
        [self initGuideImage];
    }];
}
#pragma mark - 发出获取邮件等第三方应用的未读数
- (void)loadNoReadRequest:(int)index{
    
    NSString *emailUrl;
    NSString *daiBanUrl;
    NSString *ssoUrl = [[ServerConfig shareServerConfig]getSSOServerUrl];
    NSString *oaUrl = [[ServerConfig shareServerConfig]getOAServerUrl];
    
    emailUrl = [NSString stringWithFormat:@"%@?username=%@&url=%@/sys/common/json.jsp?s_bean=sysMailGetNotReadCountService&loginName=",ssoUrl,[StringUtil encryptStr],oaUrl];
    daiBanUrl = [NSString stringWithFormat:@"%@?username=%@&url=%@/sys/notify/sys_notify_todo/sysNotifyTodo.do?method=getNotifyCount",ssoUrl,[StringUtil encryptStr],oaUrl];
    if (index == 0) {
        for (int index = 0; index < 2; index++) {
            NSString *httpPath = [NSString string];
            if (index == 0) {
                httpPath = [NSString stringWithFormat:emailUrl,[StringUtil encryptStr],[UserDefaults getUserAccount]];
            }else{
                httpPath = [NSString stringWithFormat:daiBanUrl,[StringUtil encryptStr]];
            }
            [self httpRequestForNoRead:httpPath withTag:index];
        }
    }else if(index == APP_DAIBAN_ID){
        NSString *httpPath = [NSString stringWithFormat:daiBanUrl,[StringUtil encryptStr]];
        [self httpRequestForNoRead:httpPath withTag:1];
    }else if(index == APP_EMAIL_ID){
        NSString *httpPath = [NSString stringWithFormat:emailUrl,[StringUtil encryptStr],[UserDefaults getUserAccount]];
        [self httpRequestForNoRead:httpPath withTag:0];
    }
}

- (void)httpRequestForNoRead:(NSString *)httpPath withTag:(int)appTag{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:httpPath]];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s appTag == %d",__FUNCTION__,appTag]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        // 没有数据会产生崩溃
        if (data) {
            if (appTag == 0) {
                NSArray *respArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (respArr != nil && respArr.count > 0) {
                    NSString * countStr = respArr[0][@"count"];
                    [LogUtil debug:[NSString stringWithFormat:@"%s 邮件的未读数个数为 == %@",__FUNCTION__,countStr]];
                    int oldUnreadCount = self.unRead_email;
                    self.unRead_email = [countStr intValue] <= 0 ? 0 : [countStr intValue];
                    if ((oldUnreadCount > 0 && self.unRead_email == 0) || self.unRead_email > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG+1];
                            [self setUnreadCount:appBtn andCount:self.unRead_email];
                            [UserDefaults saveTaiHeAppUnReadEmail:self.unRead_email];
                        });
                    }
                }else{
                    [LogUtil debug:[NSString stringWithFormat:@"%s 邮件的未读数获取失败 == %@",__FUNCTION__,connectionError]];
                    UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG+1];
                    int unRead_email = [UserDefaults getTaiHeAppUnReadEmail];
                    [self setUnreadCount:appBtn andCount:unRead_email];
                }
            }else{
                NSArray *respArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                if (respArr != nil && respArr.count > 0) {
                    NSDictionary *daibanDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    int oldUnreadCount = self.unRead_daiban;
                    [LogUtil debug:[NSString stringWithFormat:@"%s 待办的未读数个数为 == %@",__FUNCTION__,[daibanDic valueForKey:@"toDoCount"]]];
                    self.unRead_daiban = [[daibanDic valueForKey:@"toDoCount"] intValue];
                    if ((oldUnreadCount > 0 && self.unRead_daiban == 0) || self.unRead_daiban > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG];
                            [self setUnreadCount:appBtn andCount:self.unRead_daiban];
                            [UserDefaults saveTaiHeAppUnReadDaiban:self.unRead_daiban];
                        });
                    }
                }else{
                    
                    [LogUtil debug:[NSString stringWithFormat:@"%s 待办的未读数获取失败 == %@",__FUNCTION__,connectionError]];
                    UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG];
                    int unRead_daiban = [UserDefaults getTaiHeAppUnReadDaiban];
                    [self setUnreadCount:appBtn andCount:unRead_daiban];
                
                }
            }
        }
    }];
}
// tabbar上显示未读数
- (void)displayAllUnreadMsgCount:(int)msgUnreadCount
{
    if ((msgUnreadCount) > 0) {
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
//        [TabbarUtil setTabbarBage:[NSString stringWithFormat:@"%d",msgUnreadCount] andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
}
#pragma mark - 检测网络并弹出提示
- (BOOL)checkNetwork{
    
    UIApplicationState *appState = [[UIApplication sharedApplication]applicationState];
    
    //如果在前台，
    if (appState == UIApplicationStateActive) {
        
        if(![ApplicationManager getManager].isNetworkOk)
        {
            if (!alert.visible) {
                
                alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"check_network"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
                [alert show];
            }
            
            return NO;
        }
        return YES;
        
    }else{
        
        return YES;
        
    }
    
}


/**
 获取cookie

 @return cookie字符串
 */
+ (NSString *)cookieString{
    
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.domain isEqualToString:TAIHE_OA_DOMAIN]) {
            [LogUtil debug:[NSString stringWithFormat:@"%s cookie %@",__FUNCTION__,cookie]];
            if ([cookie.name isEqualToString:TAIHE_SSO_TOKEN_NAME]) {
                //            [LogUtil debug:[NSString stringWithFormat:@"%s 取到了token %@",__FUNCTION__,cookie]];
                [UserDefaults saveTaiHeAppToken:cookie.value];
            }
        }
    }
    
    return cookieValue;
}
//注释掉横竖屏代码，怕以后会用得到
//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    
//    CGRect _frame = _scroll.frame;
//
//    if (_frame.size.width == SCREEN_WIDTH) {
//        
//        return;
//    }
//    
//    _frame.size.width = SCREEN_WIDTH;
//    _scroll.frame = _frame;
//
//    [_cycleScrollView3 removeFromSuperview];
//    _cycleScrollView3 = nil;
//    [_imageScrollView removeFromSuperview];
//    _imageScrollView = nil;
//    [self initGuideImage];
//    
//    _frame = _webview.frame;
//    _frame.size.width = SCREEN_WIDTH;
//    _webview.frame = _frame;
//}


+ (void)setAppCookie:(NSURLRequest *)request
{
    NSString *_curUrlStr = request.URL.absoluteString;
    //    如果是明源待办，那么不走公司的sso验证，通过把从OA取回的token保存到cookie,实现单点登录
    if ([_curUrlStr rangeOfString:TAIHE_MINGYUAN_URL].length) {
        NSString *taiheAppToken = [UserDefaults getTaiHeAppToken];
        NSDictionary *cookieProperties = [[NSMutableDictionary alloc]init];
        [cookieProperties setValue:taiheAppToken forKey:NSHTTPCookieValue];
        [cookieProperties setValue:TAIHE_SSO_TOKEN_NAME  forKey:NSHTTPCookieName];
        [cookieProperties setValue:TAIHE_MINGYUAN_URL forKey:NSHTTPCookieDomain];
        //没有增加新cookie也许是由于没有把NSHTTPCookieExpires和NSHTTPCookiePath设置好.
        [cookieProperties setValue:nil forKey:NSHTTPCookieExpires];
        [cookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
        
        NSHTTPCookie *ncookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:ncookie];
    }
}

@end
