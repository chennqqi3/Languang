//
//  LANGUANGAppViewController.m
//  eCloud
//
//  Created by Ji on 17/5/18.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGAppViewControllerARC.h"
#import "StringUtil.h"
#import "APPListModel.h"
#import "APPPlatformDOA.h"
#import "CustomMyCell.h"
#import "IMYWebView.h"
#import "IOSSystemDefine.h"
#import "NewMsgNumberUtil.h"
#import "UIAdapterUtil.h"
#import "ImageUtil.h"
#import "MJRefresh.h"
#import "userInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "ServerConfig.h"
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
#import "ConvRecord.h"
#import "UserDefaults.h"
#import "NotificationUtil.h"
#import "LANGUANGWorkModelARC.h"
#import "LANGUANGAgentViewControllerARC.h"
#import "LANGUANGMeetingListViewControllerARC.h"
#import "TabbarUtil.h"
#import "LGMettingUtilARC.h"
#import "LGMettingDefine.h"

#define WX_D_APP_BASE_TAG 200
#define SCROLL_H 107


@interface LANGUANGAppViewControllerARC ()<IMYWebViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,SDCycleScrollViewDelegate,ASIHTTPRequestDelegate>

@property(nonatomic,strong) NSMutableArray *guideImageArr;
@property (nonatomic,strong)UIScrollView *scroll;
@property (nonatomic,strong)UIView *scrollView;
@property(nonatomic,strong) NSMutableArray *userDataTextArray;

@property (nonatomic,strong)UIImageView *leftCoverView;
@property (nonatomic,strong)UIImageView *rightCoverView;

@property(nonatomic,strong)UIScrollView *imageScrollView;
@property(nonatomic,strong)SDCycleScrollView *cycleScrollView;
@property(nonatomic,strong)IMYWebView *webview;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (nonatomic,strong)     WebViewJavascriptBridge *bridge;

@property (nonatomic,strong)UIImageView *tipImageView;

@property (nonatomic,assign) int unRead_daiban;
@property (nonatomic,assign) int unRead_email;
@property (nonatomic,assign) int unReadAppCount;
@end

@implementation LANGUANGAppViewControllerARC
{
    UIButton *_eatButton;
    JSSDKObject *jssdk;

}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];;
    self.title = [StringUtil getAppLocalizableString:@"main_my"];
    
    [UIAdapterUtil showTabar:self];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self getDaiBanCount];
    //[self getNewsCount];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(IsRefresh:) name:TAI_HE_REFRESH_PAGE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mydealloc) name:LG_LOG_OUT object:nil];
    
    self.guideImageArr = [[NSMutableArray alloc]init];
    
    [self initView];

}

- (void)IsRefresh:(NSNotification *)notification{
    
    [self getDaiBanCount];
    [self headerRefresh];
}

- (void)handleCmd:(NSNotification *)notif{

    [self ButtonAssignment];
}

- (void)initView{
    
    _scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCROLL_H)];
    
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    [self.view addSubview:_scroll];
    
    [self ButtonAssignment];
    
    [self loadHttpData];
    
}

#pragma mark - 创建轻应用按钮
- (void)ButtonAssignment
{
    self.userDataTextArray = [NSMutableArray array];
    if (self.userDataTextArray != nil && [self.userDataTextArray count]) {
        [self.userDataTextArray removeAllObjects];
    }
    self.dataArray = [NSMutableArray array];
    if (self.dataArray != nil && [self.dataArray count]) {
        [self.dataArray removeAllObjects];
    }
    
    self.userDataTextArray = [[APPPlatformDOA getDatabase] getAPPListWithAppShowflag:1];
    
    int i = 0;
    
    for (UIView * subview in [_scroll subviews]) {
        [subview removeFromSuperview];
    }
    
    for (NSArray *modelArr in self.userDataTextArray) {
        
        for (APPListModel *appModel in modelArr) {
            
            self.scrollView = [[UIView alloc]initWithFrame:CGRectMake(12+86*i, 18, 70, 70)];
            [_scroll addSubview:self.scrollView];
            
            _eatButton = [UIButton buttonWithType:UIButtonTypeCustom];
            //_eatButton.frame = CGRectMake(35+SCREEN_WIDTH/3*i, 15,SCREEN_WIDTH/3-70 , SCREEN_WIDTH/3-70);
            _eatButton.frame = CGRectMake(15, 0,45,45);
            UIImage *image = [CustomMyCell getAppLogo:appModel];
            
            [_eatButton setImage:image forState:UIControlStateNormal];
            [_eatButton addTarget:self action:@selector(singleSelected:) forControlEvents:UIControlEventTouchUpInside];
            _eatButton.tag = i + WX_D_APP_BASE_TAG;
            [self.scrollView addSubview:_eatButton];
            
            CGRect _frame = _eatButton.frame;
            UILabel *eatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _frame.size.height+8 ,70 , 17)];
            eatLabel.text = appModel.appname;
            
            eatLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
            eatLabel.textAlignment = NSTextAlignmentCenter;
            eatLabel.font = [UIFont systemFontOfSize:13];
            [self.scrollView addSubview:eatLabel];
            
            // 添加显示未读数的小红点
//            [NewMsgNumberUtil addNewMsgNumberView:_eatButton];
            self.unRead_daiban = [UserDefaults getTaiHeAppUnReadDaiban];
            int unReadCount = 0;
            if (appModel.appid == 10001) {
                unReadCount = self.unRead_daiban;
            }else if (appModel.appid == 10003) {
                unReadCount = self.unRead_email;
            }
            self.unReadAppCount += unReadCount;
            [self setUnreadCount:_eatButton andCount:unReadCount];
            [self displayAllUnreadMsgCount:unReadCount];
            [self.dataArray addObject:appModel];
            i++;
        }
    }
    [_scroll setContentSize:CGSizeMake(self.scrollView.frame.origin.x + self.scrollView.frame.size.width +20,0)];
    
    // 右下角显示红点，不再计算总数
    [self displayAllUnreadMsgCount:self.unReadAppCount];
    
    self.leftCoverView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 12, _scroll.frame.size.height)];
    self.leftCoverView.backgroundColor = [UIColor clearColor];
//    self.leftCoverView.alpha = 0.7;
    self.leftCoverView.image = [StringUtil getImageByResName:@"left_image"];
    
    [self.view addSubview:self.leftCoverView];
    
    self.rightCoverView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 12, 0, 12, _scroll.frame.size.height)];
    self.rightCoverView.backgroundColor = [UIColor clearColor];
//    self.rightCoverView.alpha = 0.7;
    self.rightCoverView.image = [StringUtil getImageByResName:@"right_iamge"];
    [self.view addSubview:self.rightCoverView];
}


- (void)setUnreadCount:(UIButton *)btn andCount:(int)unReadCount{
    [NewMsgNumberUtil displayNewMsgNumber:btn andNewMsgNumber:unReadCount];
    [NewMsgNumberUtil setUnreadViewFrame:btn];
    
    //BOOL isDidShowTabBage = [TabbarUtil isDidShowTabbarBageWithIndex:[eCloudConfig getConfig].myIndex];
    if (unReadCount > 0) {
        [self displayAllUnreadMsgCount:unReadCount];
    }
}

// tabbar上显示未读数
- (void)displayAllUnreadMsgCount:(int)msgUnreadCount
{
    if ((msgUnreadCount) > 0) {
        [TabbarUtil setTabbarBage:[NSString stringWithFormat:@"%d",msgUnreadCount] andTabbarIndex:[eCloudConfig getConfig].myIndex];
        //        [TabbarUtil setTabbarBage:[NSString stringWithFormat:@"%d",msgUnreadCount] andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }else{
        [TabbarUtil setTabbarBage:nil andTabbarIndex:[eCloudConfig getConfig].myIndex];
    }
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
            
            LANGUANGWorkModelARC * entity = [[LANGUANGWorkModelARC alloc]init];
            [entity setValuesForKeysWithDictionary:adInfoDic];
            [self.guideImageArr addObject:entity];
        }
        
        [self initGuideImage];
        
        [self requestHttpData];
        
    }
    
}

- (void)requestHttpData{
    
    
    dispatch_queue_t queue = dispatch_queue_create("request Http Data", NULL);
    
    dispatch_async(queue, ^{
        
        //NSString *loginAdInfoUrl = [[ServerConfig shareServerConfig]getLoginADInfoUrl:1];
        NSString *loginAdInfoUrl = [NSString stringWithFormat:@"%@:8086/FilesService/getAdsInfo?type=1",[LGMettingUtilARC getInterfaceUrl]];
        
        NSDictionary *dict = [StringUtil getHtmlText:loginAdInfoUrl];
        [LogUtil debug:[NSString stringWithFormat:@"%s 获取首页广告信息 == %@",__FUNCTION__,dict]];
        if (dict) {
            
            NSString *status = [NSString stringWithFormat:@"%@",dict[@"status"]];
            if ([status isEqualToString:@"0"]) {
                
                id tempDict = [UserDefaults getTaiHeAppGuideImageUrl];
                if ([dict isEqualToDictionary:tempDict]) {
                    
                    return ;
                }
                
                NSMutableArray *adInfoArr = dict[@"data"];
                if (self.guideImageArr) {
                    
                    [self.guideImageArr removeAllObjects];
                    
                }
                for (NSDictionary *adInfoDic in adInfoArr) {
                    
                    LANGUANGWorkModelARC * entity = [[LANGUANGWorkModelARC alloc]init];
                    [entity setValuesForKeysWithDictionary:adInfoDic];
                    [self.guideImageArr addObject:entity];
                }
                
                [UserDefaults saveTaiHeAppGuideImageUrl:dict];
                
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self initGuideImage];
            
        });
        
    });
    
}

#pragma mark - 创建广告页和webview
- (void)initGuideImage{
    
//    if (!self.imageScrollView) {
//        
//        self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _scroll.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT/3/2)];
//        self.imageScrollView.pagingEnabled=YES;
//        self.imageScrollView.showsVerticalScrollIndicator = NO;
//        self.imageScrollView.showsHorizontalScrollIndicator = NO;
//        self.imageScrollView.delegate = self;
//        self.imageScrollView.userInteractionEnabled = YES;
//        self.imageScrollView.bounces = NO;
//        self.imageScrollView.backgroundColor = [UIColor clearColor];
//        [self.view addSubview:self.imageScrollView];
//        
//        NSMutableArray *imagesURLStrings;
//        imagesURLStrings = [NSMutableArray array];
//        for (int i = 0 ; i < self.guideImageArr.count; i++) {
//            
//            LANGUANGWorkModelARC * model = [[LANGUANGWorkModelARC alloc]init];
//            model = self.guideImageArr[i];
//            
//            [imagesURLStrings addObject:model.thumb];
//        }
//        
//        if (_cycleScrollView) {
//            
//            _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
//            
//        }else{
//            _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
//            _cycleScrollView.backgroundColor = [UIColor whiteColor];
//            _cycleScrollView.delegate = self;
//            _cycleScrollView.currentPageDotColor = [UIColor grayColor];
//            _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
//            //         --- 轮播时间间隔，默认1.0秒，可自定义
//            _cycleScrollView.autoScrollTimeInterval = 8.0;
//            
//            [self.imageScrollView addSubview:_cycleScrollView];
//        }
//        //block监听点击方式
//        __weak typeof(self) weakSelf = self;
//        _cycleScrollView.clickItemOperationBlock = ^(NSInteger index) {
//            
//            [weakSelf OpenImageLinks:index];
//        };
//    }
        if (_webview) {
            
            [self headerRefresh];
            
        }else{
            
//            _webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48) usingUIWebView:YES];
            _webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, _scroll.frame.size.height + _scroll.frame.origin.y + 12 , SCREEN_WIDTH, SCREEN_HEIGHT - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48 - 12) usingUIWebView:YES];
            _webview.scalesPageToFit = YES;
            _webview.delegate=self;
            _webview.scrollView.bounces = YES;
            _webview.backgroundColor = [UIColor clearColor];
            _webview.scrollView.delegate = self;
            
            _webview.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

            NSString * urlString= [NSString stringWithFormat:@"%@/BrcDataService/brc_h5/home.html?token=%@&t=%@",[LGMettingUtilARC getTestUrl],[UserDefaults getLoginToken],[StringUtil currentTime]];
            
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            [_webview loadRequest:request];
            [self.view addSubview:_webview];
            
            _webview.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
            [self.imageScrollView setContentSize:CGSizeMake(SCREEN_WIDTH*self.guideImageArr.count,SCROLL_H)];
            
            //self.pan =  _webview.scrollView.panGestureRecognizer;
            //NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
            //[self.pan addObserver:self forKeyPath:MJRefreshKeyPathPanState options:options context:nil];
   
            float imageH = 144;
            float imageW = 184;
            
            self.tipImageView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - imageW)/2, 95.5, imageW, imageH)];
            self.tipImageView.image = [StringUtil getImageByResName:@"img_home_network_off"];
            [_webview addSubview:self.tipImageView];
            self.tipImageView.hidden = YES;
            
        }
    
    [self initInterface];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationTyp{
    
    if ([self checkNetwork]) {
        [self endRefresh];
        self.tipImageView.hidden = NO;
        return NO;
    }else{
        
        self.tipImageView.hidden = YES;
    }
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([curWebViewUrl rangeOfString:@"about:blank"].length > 0) {
        
        return NO;
    }
    
    if ([curWebViewUrl rangeOfString:@"BrcDataService/brc_h5/home.html" options:NSCaseInsensitiveSearch].length == 0) {
        
        LANGUANGAgentViewControllerARC *agent = [[LANGUANGAgentViewControllerARC alloc]init];
        agent.urlstr = curWebViewUrl;
        [self.navigationController pushViewController:agent animated:YES];
        return NO;
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@",__FUNCTION__,curWebViewUrl]]
    ;
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self endRefresh];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s error==== %@",__FUNCTION__,error]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self endRefresh];
}

#pragma mark - 下拉刷新
- (void)headerRefresh{
    
    [StringUtil cleanCacheAndCookie];
    NSString * urlString= [NSString stringWithFormat:@"%@/BrcDataService/brc_h5/home.html?token=%@&t=%@",[LGMettingUtilARC getTestUrl],[UserDefaults getLoginToken],[StringUtil currentTime]];

    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [_webview loadRequest:request];
    
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{
    
    [_webview.scrollView.mj_header endRefreshing];
    
}

#pragma mark - 打开广告页连接
- (void)OpenImageLinks:(NSInteger )index
{
    
    LANGUANGWorkModelARC * model = [[LANGUANGWorkModelARC alloc]init];
    model = self.guideImageArr[index];
    //    TAIHEAgentLstViewController *openweb=[[TAIHEAgentLstViewController alloc]init];
    //    openweb.urlstr= model.url;
//        [UIAdapterUtil hideTabBar:self];
    
}

#pragma mark - 打开轻应用
- (void)singleSelected:(UIButton *)sender{
    
    UIButton *button = (UIButton *)[self.view viewWithTag:sender.tag];
    [self openAgent:(int)button.tag - WX_D_APP_BASE_TAG];

//    JsObjectCViewController *openweb = [[JsObjectCViewController alloc] init];
//    [self.navigationController pushViewController:openweb animated:YES];
//    [UIAdapterUtil hideTabBar:self];
//    return;
}
- (void)openAgent:(int)tag
{
    if (self.dataArray) {
        
        APPListModel *appModel = self.dataArray[tag];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,appModel.apphomepage]];
        if (appModel.appid == 10002) {
            
            LANGUANGMeetingListViewControllerARC *meeting = [[LANGUANGMeetingListViewControllerARC alloc]init];
            [self.navigationController pushViewController:meeting animated:YES];
            
        }else{
        
            LANGUANGAgentViewControllerARC *openweb=[[LANGUANGAgentViewControllerARC alloc]init];
            openweb.urlstr= appModel.apphomepage;
            if (appModel.appid == 10003) {
                
                openweb.isNews = YES;
            }
            [self.navigationController pushViewController:openweb animated:YES];
        }
        
        [UIAdapterUtil hideTabBar:self];
        
    }
}


- (void)delayMethod
{
    _webview.scrollView.bounces = YES;
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

#pragma mark - 隐藏广告页
- (void)HiddenGuideImage{
    
    self.imageScrollView.hidden = YES;
    _webview.frame = CGRectMake(0, _scroll.frame.size.height + _scroll.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT  - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48);

}

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
    
    if (_webview.scrollView.bounces) {
  
        return;
    }

    self.imageScrollView.hidden = NO;
    
    _webview.frame = CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48);

    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.5];
    
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
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
}

/** 退出登录时，制空js，不然影响到界面的释放 */
- (void)mydealloc{
    
    self.bridge = nil;
    jssdk.bridge = nil;
    jssdk.curVC = nil;
    jssdk = nil;
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAI_HE_REFRESH_PAGE object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LG_LOG_OUT object:nil];
    
    [self.userDataTextArray removeAllObjects];
    self.userDataTextArray = nil;
    [self.guideImageArr removeAllObjects];
    _guideImageArr = nil;
    _webview.delegate = nil;
    _webview = nil;
    [self.pan removeObserver:self forKeyPath:MJRefreshKeyPathPanState];
    self.pan = nil;
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
}

+ (NSDictionary *)cutString:(NSString *)urlString{
    
    NSString *tmpString;
    NSArray *array = [urlString componentsSeparatedByString:@"&"];
    if (array) {
        
        tmpString = array[0];
    }
    
    NSArray *confno = [tmpString componentsSeparatedByString:@"?"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *str in confno) {
        
        NSArray *tmpArr = [str componentsSeparatedByString:@"="];
        if (tmpArr.count == 2) {
            
            [dict setObject:tmpArr[1] forKey:tmpArr[0]];
        }
        
    }
    
    for (NSString *str in array) {
        
        NSArray *tmpArr = [str componentsSeparatedByString:@"="];
        if (tmpArr.count == 2) {
            
            [dict setObject:tmpArr[1] forKey:tmpArr[0]];
        }
        
    }
    
    return dict;
}

- (void)getDaiBanCount
{
    
    NSString *account = [UserDefaults getUserAccount];
    NSString *curTime = [[conn getConn] getSCurrentTime];
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",account,curTime,LGmd5_password]];
    NSString *oaToken = [UserDefaults getLoginToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/middleware/conference/getTotal?",[LGMettingUtilARC get9013Url]];
    //http://222.209.223.92:9013/middleware/conference/getTotal?access_token=584d522aff064623bfa841a7fbbca1b0&timestamp=1496735269537&md5key=9702414DB7B35552B1D6360AF22C2A19&account=lhai
    
    NSString *httpPath = [NSString stringWithFormat:@"%@access_token=%@&timestamp=%@&md5key=%@&account=%@",urlString,oaToken,curTime,md5Str,account];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:httpPath]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (data) {
            
            NSArray *respArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (respArr != nil && respArr.count > 0) {
                NSDictionary *daibanDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                int oldUnreadCount = self.unRead_daiban;
                [LogUtil debug:[NSString stringWithFormat:@"%s 待办的未读数个数为 == %@",__FUNCTION__,[daibanDic valueForKey:@"data"]]];
                self.unRead_daiban = [[daibanDic valueForKey:@"data"] intValue];
                if ((oldUnreadCount > 0 && self.unRead_daiban == 0) || self.unRead_daiban > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG];
                        [self setUnreadCount:appBtn andCount:self.unRead_daiban];
                        [UserDefaults saveTaiHeAppUnReadDaiban:self.unRead_daiban];
                        [self displayAllUnreadMsgCount:self.unRead_daiban];
                    });
                }
            }else{
                
                [LogUtil debug:[NSString stringWithFormat:@"%s 待办的未读数获取失败 == %@",__FUNCTION__,connectionError]];
                UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG];
                int unRead_daiban = [UserDefaults getTaiHeAppUnReadDaiban];
                [self setUnreadCount:appBtn andCount:unRead_daiban];
                [self displayAllUnreadMsgCount:self.unRead_daiban];
                
            }
        }
        
        
    }];
    
}

- (void)getNewsCount{

    NSString *account = [UserDefaults getUserAccount];
    NSString *curTime = [[conn getConn] getSCurrentTime];
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",account,curTime,LGmd5_password]];
    NSString *oaToken = [UserDefaults getLoginToken];
    NSString *urlString = [NSString stringWithFormat:@"%@/middleware/conference/getInfoNumber?",[LGMettingUtilARC get9013Url]];
    //http://222.209.223.92:9013/middleware/conference/getTotal?access_token=584d522aff064623bfa841a7fbbca1b0&timestamp=1496735269537&md5key=9702414DB7B35552B1D6360AF22C2A19&account=lhai

    
    NSString *httpPath = [NSString stringWithFormat:@"%@access_token=%@&timestamp=%@&md5key=%@&account=%@",urlString,oaToken,curTime,md5Str,account];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:httpPath]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (data) {
            
            NSArray *respArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (respArr != nil && respArr.count > 0) {
                NSDictionary *daibanDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                int oldUnreadCount = self.unRead_email;
                [LogUtil debug:[NSString stringWithFormat:@"%s 新闻的未读数个数为 == %@",__FUNCTION__,[daibanDic valueForKey:@"data"]]];
                self.unRead_email = [[daibanDic valueForKey:@"data"] intValue];
                if ((oldUnreadCount > 0 && self.unRead_email == 0) || self.unRead_email > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG+2];
                        [self setUnreadCount:appBtn andCount:self.unRead_email];
                        [UserDefaults saveTaiHeAppUnReadEmail:self.unRead_email];
                    });
                }
            }else{
                
                [LogUtil debug:[NSString stringWithFormat:@"%s 新闻的未读数获取失败 == %@",__FUNCTION__,connectionError]];
                UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG+2];
                int unRead_news = [UserDefaults getTaiHeAppUnReadEmail];
                [self setUnreadCount:appBtn andCount:unRead_news];
                
            }
        }
        
        
    }];
}

#pragma mark - 检测网络并弹出提示
- (BOOL)checkNetwork{
    
    if(![ApplicationManager getManager].isNetworkOk)
    {

        return YES;
    }
    return NO;

}

@end
