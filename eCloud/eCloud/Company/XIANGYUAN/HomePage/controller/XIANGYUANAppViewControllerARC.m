//
//  XIANGYUANAppViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/24.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "XIANGYUANAppViewControllerARC.h"
#import "UserTipsUtil.h"
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
#import "XIANGYUANHomeModleARC.h"
#import "ScannerViewController.h"
#import "XIANGYUANAgentViewControllerARC.h"
#import "XIANGYUANOfficeLoginViewControllerARC.h"
#import "JSONKit.h"
#import "talkSessionViewController.h"
#import "ASIFormDataRequest.h"
#import "GetXYConfigUtil.h"
#import "XIANGYUANMyViewControllerARC.h"
#import "KxMenu.h"
#import "contactViewController.h"
#import "Conversation.h"
#import "NewChooseMemberViewController.h"
#import "eCloudDefine.h"

#define WX_D_APP_BASE_TAG 200
/** 需要在新的界面中打开 */
#define TARGET_NEW @"TARGET_NEW"

@interface XIANGYUANAppViewControllerARC ()<IMYWebViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,SDCycleScrollViewDelegate,ASIHTTPRequestDelegate>

@property(nonatomic,retain) NSMutableArray *guideImageArr;
@property (nonatomic,strong)UIScrollView *scroll;
@property(nonatomic,retain) NSMutableArray *userDataTextArray;
@property (nonatomic,assign) int unReadAppCount;
@property(nonatomic,retain)UIScrollView *imageScrollView;
@property(nonatomic,retain)SDCycleScrollView *cycleScrollView;
@property(nonatomic,strong)IMYWebView *webview;
@property(nonatomic,retain) NSMutableArray *dataArray;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (nonatomic,assign) int unRead_daiban;
@property(retain,nonatomic) Emp *emp;

@end

@implementation XIANGYUANAppViewControllerARC
{
    
    conn *_conn;
    eCloudDAO *db;
    UIButton *_eatButton;
    UIView *leftBarView;
    UIImageView *header;
    
    /** 是否需要自动打开 代办界面 */
    BOOL needAutoOpenAgent;
    /** 是否需要等待loginToken */
    BOOL isWaitingForLoginToken;

}
@synthesize appInfo;

//static XIANGYUANAppViewControllerARC *_XIANGYUANAppViewControllerARC;
//
//+(XIANGYUANAppViewControllerARC *)getXIANGYUANAppViewControllerARC
//{
//    if(_XIANGYUANAppViewControllerARC == nil)
//    {
//        _XIANGYUANAppViewControllerARC = [[self alloc]init];
//    }
//    return _XIANGYUANAppViewControllerARC;
//}

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        db = [eCloudDAO getDatabase];
//        [[GetXYConfigUtil getUtil]getXYOAToken];
        
        [_conn addObserver:self forKeyPath:@"connStatus" options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processLoginAck:) name:LOGIN_NOTIFICATION object:nil];

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar addSubview:leftBarView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"祥源办公";
    [UIAdapterUtil showTabar:self];

    header.image =  [self headTangential];
    [self.navigationController setNavigationBarHidden:NO];
    
    // 是否需要打开轻应用
    if (needAutoOpenAgent) {
        needAutoOpenAgent = NO;
        [self autoOpenAgentList];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [UIAdapterUtil setBackGroundColorOfController:self];
    [UIAdapterUtil processController:self];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleCmd:) name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMsgCount:) name:XIANGYUAN_REFRESH_COUNT object:nil];
    
    //刷新头像通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:@"ModifyThePicture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Picture) name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    [UIAdapterUtil setRightButtonItemWithImageName:@"add_ios.png" andTarget:self andSelector:@selector(addButtonPressed)];
    
    self.guideImageArr = [[NSMutableArray alloc]init];
    
    [self initNavLeftHead];
    [self initView];
    
//    默认不自动打开待办
    needAutoOpenAgent = NO;
//    如果需要自动打开待办，则需要给appInfo赋值，保存待办的URL，并且设置 needAutoOpenAgent 属性为YES 同时清空 ApplicationManager 里保存的属性
    if (([ApplicationManager getManager].needOpenAgent)) {
        self.appInfo =  [ApplicationManager getManager].appInfo;
        needAutoOpenAgent = YES;
        
        [ApplicationManager getManager].needOpenAgent = NO;
        [ApplicationManager getManager].appInfo = nil;
    }
}

- (void)handleCmd:(NSNotification *)notif{
    // 每次都重新建应用这个需要优化
    [self ButtonAssignment];
}

- (void)initView{
    //SCREEN_HEIGHT/3/2
    _scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.backgroundColor = [UIColor colorWithRed:0xe6/255.0 green:0xea/255.0 blue:0xf0/255.0 alpha:1];
    _scroll.alwaysBounceHorizontal = YES;
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
            
            _eatButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _eatButton.frame = CGRectMake(15+SCREEN_WIDTH/5*i, 15,50 , 50);
//            _eatButton.frame = CGRectMake(35+SCREEN_WIDTH/3*i, 15,SCREEN_WIDTH/3-70 , SCREEN_WIDTH/3-70);
//            _eatButton.frame = CGRectMake(35+SCREEN_WIDTH/3*i, 15,50 , 50);
            UIImage *image = [CustomMyCell getAppLogo:appModel];
            
            [_eatButton setImage:image forState:UIControlStateNormal];
            [_eatButton addTarget:self action:@selector(singleSelected:) forControlEvents:UIControlEventTouchUpInside];
            _eatButton.tag = i + WX_D_APP_BASE_TAG;
            [_scroll addSubview:_eatButton];
            
            CGRect _frame = _eatButton.frame;
            UILabel *eatLabel = [[UILabel alloc] initWithFrame:CGRectMake(_frame.origin.x - 10, _frame.size.height + 7 ,_frame.size.width +20 , 50)];
            eatLabel.text = appModel.appname;
            eatLabel.font = [UIFont systemFontOfSize:14.f];
            eatLabel.textColor = [UIColor colorWithRed:0x76/255.0 green:0x7b/255.0 blue:0x82/255.0 alpha:1];
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
            if (appModel.appid == 2) {
                int unRead_daiban = [[UserDefaults getXIANGYUANAppDAIBAN]intValue];
                unReadCount = unRead_daiban;
                self.unReadAppCount = unReadCount;
            }
            [self setUnreadCount:_eatButton andCount:unReadCount];
            [self.dataArray addObject:appModel];
            i++;
        }
    }
    [_scroll setContentSize:CGSizeMake(_eatButton.frame.origin.x + _eatButton.frame.size.width +15,0)];
    
    // 右下角显示红点，不再计算总数
    [self displayAllUnreadMsgCount:self.unReadAppCount];
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
        [TabbarUtil setTabbarBage:@"Push" andTabbarIndex:[eCloudConfig getConfig].myIndex];
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
            
            XIANGYUANHomeModleARC * entity = [[XIANGYUANHomeModleARC alloc]init];
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
        
        NSString *loginAdInfoUrl = [[ServerConfig shareServerConfig]getLoginADInfoUrl:1];
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
                    
                    XIANGYUANHomeModleARC * entity = [[XIANGYUANHomeModleARC alloc]init];
                    [entity setValuesForKeysWithDictionary:adInfoDic];
                    [self.guideImageArr addObject:entity];
                }
                
                [UserDefaults saveTaiHeAppGuideImageUrl:dict];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self initGuideImage];
                    
                });
                
            }
        }
        
    });
    
}

#pragma mark - 创建广告页和webview
- (void)initGuideImage{
    
    if (!self.imageScrollView) {
        //SCREEN_HEIGHT/3/2
        self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _scroll.frame.size.height, SCREEN_WIDTH, 100)];
        self.imageScrollView.pagingEnabled=YES;
        self.imageScrollView.showsVerticalScrollIndicator = NO;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.delegate = self;
        self.imageScrollView.userInteractionEnabled = YES;
        self.imageScrollView.bounces = NO;
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.imageScrollView];
        
        NSMutableArray *imagesURLStrings;
        imagesURLStrings = [NSMutableArray array];
        for (int i = 0 ; i < self.guideImageArr.count; i++) {
            
            XIANGYUANHomeModleARC * model = [[XIANGYUANHomeModleARC alloc]init];
            model = self.guideImageArr[i];
            
            [imagesURLStrings addObject:model.thumb];
        }
        
        if (_cycleScrollView) {
            
            _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
            
        }else{
            _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, self.imageScrollView.frame.size.width, self.imageScrollView.frame.size.height) delegate:self placeholderImage:[UIImage imageNamed:@"placeholder"]];
            _cycleScrollView.backgroundColor = [UIColor whiteColor];
            _cycleScrollView.delegate = self;
            _cycleScrollView.currentPageDotColor = [UIColor grayColor];
            _cycleScrollView.imageURLStringsGroup = imagesURLStrings;
            //         --- 轮播时间间隔，默认1.0秒，可自定义
            //cycleScrollView.autoScrollTimeInterval = 4.0;
            
            [self.imageScrollView addSubview:_cycleScrollView];
        }
        //block监听点击方式
            __weak typeof(self) weakSelf = self;
            _cycleScrollView.clickItemOperationBlock = ^(NSInteger index) {
        
                [weakSelf OpenImageLinks:index];
            };
        if (_webview) {
            
            [self headerRefresh];
            
        }else{
            //_webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48)];
            
            _webview = [[IMYWebView alloc]initWithFrame:CGRectMake(0, self.imageScrollView.frame.size.height + self.imageScrollView.frame.origin.y , SCREEN_WIDTH, SCREEN_HEIGHT - self.imageScrollView.frame.size.height - _scroll.frame.size.height - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT -48) usingUIWebView:YES];
            _webview.scalesPageToFit = YES;
            _webview.delegate=self;
            _webview.scrollView.bounces = YES;
            _webview.backgroundColor = [UIColor clearColor];
            _webview.scrollView.delegate = self;
            
            _webview.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;

//            NSString *urlString = @"http://61.191.30.195:8090/app/flow/index";
            NSString *urlString = [[ServerConfig shareServerConfig]getXYOAUrl];
            NSString *usercode = [UserDefaults getUserAccount];
            NSString *token = [UserDefaults getXIANGYUANAppToken];
            NSString *urlStr = [NSString stringWithFormat:@"%@?usercode=%@&token=%@",urlString,usercode,token];
            
            NSURL *url = [NSURL URLWithString:urlStr];
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
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationTyp{
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@",__FUNCTION__,curWebViewUrl]]
    ;
    if ([curWebViewUrl rangeOfString:TARGET_NEW].length > 0) {

        XIANGYUANAgentViewControllerARC *agentListVC=[[XIANGYUANAgentViewControllerARC alloc]init];
        curWebViewUrl = [curWebViewUrl stringByReplacingOccurrencesOfString:TARGET_NEW withString:@""];
//        NSString *usercode = [UserDefaults getUserAccount];
//        NSString *token = [UserDefaults getXIANGYUANAppToken];
//        NSString *urlStr = [NSString stringWithFormat:@"%@?usercode=%@&token=%@",curWebViewUrl,usercode,token];
        agentListVC.urlstr = curWebViewUrl ;
        [self.navigationController pushViewController:agentListVC animated:YES];
        return NO;
    }
    
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
    
//    [LogUtil debug:[NSString stringWithFormat:@"%s error==== %@",__FUNCTION__,error]];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self endRefresh];
}

#pragma mark - 下拉刷新
- (void)headerRefresh{
    
//    NSString *urlString = @"http://61.191.30.195:8090/app/flow/index";
    NSString *urlString = [[ServerConfig shareServerConfig]getXYOAUrl];
    NSString *usercode = [UserDefaults getUserAccount];
    NSString *token = [UserDefaults getXIANGYUANAppToken];
    NSString *urlStr = [NSString stringWithFormat:@"%@?usercode=%@&token=%@",urlString,usercode,token];
    NSURL *url = [NSURL URLWithString:urlStr];
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
    
    XIANGYUANHomeModleARC * model = [[XIANGYUANHomeModleARC alloc]init];
    model = self.guideImageArr[index];
    XIANGYUANAgentViewControllerARC *openweb=[[XIANGYUANAgentViewControllerARC alloc]init];
    openweb.urlstr= model.url;
    //JsObjectCViewController *openweb = [[JsObjectCViewController alloc] init];
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
    if (self.dataArray) {
        
        APPListModel *appModel = self.dataArray[tag];
        
        [LogUtil debug:[NSString stringWithFormat:@"%s agent url is %@",__FUNCTION__,appModel.apphomepage]];
        XIANGYUANAgentViewControllerARC *openweb=[[XIANGYUANAgentViewControllerARC alloc]init];
        
        if (appModel.appid == XIANGYUAN_BAOBIAO_APP_ID) {

            NSString *urlStr = [NSString stringWithFormat:@"%@&fr_username=%@&fr_password=%@",appModel.apphomepage,[UserDefaults getUserAccount],[UserDefaults getUserPassword]];
            openweb.urlstr = urlStr;
            
        }else if(appModel.appid == XIANGYUAN_ZHIDU_APP_ID){
            
            NSString *jsonToekn = [[UserDefaults getXIANGYUANAppToken] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData* jsonData = [jsonToekn dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDict = [jsonData objectFromJSONData];
            NSString *token = resultDict[@XIANGYUAN_FANWEI_TOKEN_KEY];
            NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",appModel.apphomepage,[UserDefaults getUserAccount],token]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            openweb.urlstr= urlStr;
            
        }else{
            
            if(appModel.appid == XIANGYUAN_DAIBAN_APP_ID){
                
                openweb.isDAIBAN = YES;
                
            }
            NSString *usercode = [UserDefaults getUserAccount];
            NSString *token = [UserDefaults getXIANGYUANAppToken];
            NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",appModel.apphomepage,usercode,token]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            openweb.urlstr = urlStr;
        }
        [self.navigationController pushViewController:openweb animated:YES];
        [UIAdapterUtil hideTabBar:self];

    }
}

- (void)scanAction{

    ScannerViewController *scanner = [[ScannerViewController alloc]init];
    scanner.processType = 0;
    scanner.delegate = self;
    [self.navigationController pushViewController:scanner animated:YES];
//    XIANGYUANOfficeLoginViewControllerARC *vc = [[XIANGYUANOfficeLoginViewControllerARC alloc]initWithNibName:@"XIANGYUANOfficeLoginViewControllerARC" bundle:nil];
//    
//    [self.navigationController pushViewController:vc animated:YES];
//    [UIAdapterUtil hideTabBar:self];
}

- (void)delayMethod
{
    _webview.scrollView.bounces = YES;
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

//- (void)getOAToken{
//
//    Emp *emp = [conn getConn].curUser;
//    int userId = emp.emp_id;
//    NSString *account = [UserDefaults getUserAccount];
//    NSString *passWord = [StringUtil getMD5Str:[UserDefaults getUserPassword]];
//    int interval = [[conn getConn]getCurrentTime];
//    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%d%@",account,interval,md5_password]];
//    NSString *urlString = [NSString stringWithFormat:@"http://61.191.30.195:8090/rest/sso/getToken"];
//
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
// 
//    request.HTTPMethod = @"POST";
//    request.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
//    
////    "t": 1496631745,
////    "userName": "test",
////    "password": "46f94c8de14fb36680850768ff1b7f2a",
////    "userid": 490011,
////    "mdkey": "4b78739f6ae10b5ba7f164d6d5fbfaf5",
////    "terminal": 3
//
//    NSDictionary *dic = @{@"userName":account,@"password":passWord,@"hasToken":@(1),@"terminal":@(2),@"userid":@(userId),@"t":@(interval),@"mdkey":md5Str};
//    
//    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//    
//    request.HTTPBody = data;
//    // 将字符串转换成数据
//
////    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:queue
//                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
//                               if (error) {
//                                
//                                   [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源OAtoken失败 %@",__FUNCTION__,error]];
//                                   
//                               }else{
//                                   
//                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
//                                   
////                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                   
//                                   if (responseCode == 200) {
//                                       NSDictionary *responseDic = [data objectFromJSONData];
//                                       
//                                       [LogUtil debug:[NSString stringWithFormat:@"%s 获取祥源OAtoken %@",__FUNCTION__,responseDic]];
//                                       
//                                       if ([responseDic[@"status"]intValue] == 0) {
//                                           
//                                           [UserDefaults setXIANGYUANAppToken:responseDic[@"result"]];
//                                           
//                                       }
//                                       
//                                   }
//
//                               }
//                           }];
//    
//}

- (void)refreshMsgCount:(NSNotification *)notification{
    
    [self headerRefresh];
    
    NSString *msgType = [NSString stringWithFormat:@"%@",notification.userInfo[@"msgType"]];
    if ([msgType isEqualToString:@"1"]) {
        
        NSDictionary *dict = notification.userInfo[@"message"];
        NSNumber *count = dict[@"count"];
        NSNumber *time = dict[@"time"];
        NSNumber *timeStamp = [UserDefaults getXIANGYUANAppDAIBANTimeStamp];
        if (timeStamp == nil) {
            
            [UserDefaults setXIANGYUANAppDAIBANTimeStamp:time];
            [self addDAIBANCount:count];
            
        }else if([timeStamp intValue] <= [time intValue]){
            
            [UserDefaults setXIANGYUANAppDAIBANTimeStamp:time];
            [self addDAIBANCount:count];
        }else{
            
            NSNumber *count = [UserDefaults getXIANGYUANAppDAIBAN];
            [self addDAIBANCount:count];
        }
        
        
    }
    
}

- (void)addDAIBANCount:(NSNumber *)count{
    
    UIButton *appBtn = [_scroll viewWithTag:WX_D_APP_BASE_TAG];
    [self setUnreadCount:appBtn andCount:[count intValue]];
    [UserDefaults setXIANGYUANAppDAIBAN:count];
    
    // 右下角显示红点，不再计算总数
    [self displayAllUnreadMsgCount:[count intValue]];
    
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPLIST_UPDATE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ModifyThePicture" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GET_CURUSERICON_NOTIFICATION object:nil];
    
    [self.userDataTextArray removeAllObjects];
    self.userDataTextArray = nil;
    [self.guideImageArr removeAllObjects];
    _guideImageArr = nil;
    _webview.delegate = nil;
    _webview = nil;
    [self.pan removeObserver:self forKeyPath:MJRefreshKeyPathPanState];
    self.pan = nil;

    [_conn removeObserver:self forKeyPath:@"connStatus"];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)openAppUrl:(NSString *)appUrl{
    
    XIANGYUANAgentViewControllerARC *agent = [[XIANGYUANAgentViewControllerARC alloc]init];
    NSString *usercode = [UserDefaults getUserAccount];
    NSString *token = [UserDefaults getXIANGYUANAppToken];
    NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",appUrl,usercode,token ]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    agent.urlstr = urlStr;
    agent.customTitle = @"统一待办";
    [self.navigationController pushViewController:agent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [leftBarView removeFromSuperview];

}

#pragma mark - 导航栏左右按钮
- (void)initNavLeftHead{
    
    if(!leftBarView) {
        leftBarView = [[UIView alloc] initWithFrame:CGRectMake(13, self.navigationController.navigationBar.frame.size.height - 32 - 10, 32, 40)];
        UIImage *image = [StringUtil getImageByResName:@"office_leftbar"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, (32 - image.size.height) / 2, image.size.width, image.size.height);
        [leftBarView addSubview:imageView];
        
        image = [self headTangential];
        header = [[UIImageView alloc] initWithImage:image];
        header.frame = CGRectMake(5, 0, 38, 38);
        header.layer.cornerRadius = header.frame.size.width/2;
        header.layer.masksToBounds = YES;
        [leftBarView addSubview:header];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(openUserInfo) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, leftBarView.frame.size.width, leftBarView.frame.size.height);
        [leftBarView addSubview:btn];
        
        [self.navigationController.navigationBar addSubview:leftBarView];
    }
    
//    [UIAdapterUtil setRightButtonItemWithImageName:@"conf_UserList.png" andTarget:self andSelector:@selector(goTowebsite)];
    
}

#pragma mark - 打开个人资料
- (void)openUserInfo{
    
    XIANGYUANMyViewControllerARC *userInfoView = [[XIANGYUANMyViewControllerARC alloc] init];
    [self.navigationController pushViewController:userInfoView animated:YES];
    [UIAdapterUtil hideTabBar:self];
    
}

#pragma mark - 获取头像
- (UIImage *)headTangential
{
    self.emp = [db getEmpInfo:_conn.userId];
    
    UIImage *image = [ImageUtil getOnlineEmpLogo:self.emp];
    CGSize size = image.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [path addClip];
    [image drawAtPoint:CGPointZero];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)Picture{
    
    header.image =  [self headTangential];
}

- (void)addButtonPressed{
    
    NSMutableArray *menuItems = [NSMutableArray array];
    
    KxMenuItem *shortCutMenuItem1 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_create_new_chat"]
                                                   image:[StringUtil getImageByResName:@"faqihuihua.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem1)];
    
    KxMenuItem *shortCutMenuItem2 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"scan_the_code"]
                                                   image:[StringUtil getImageByResName:@"jiqiren.png"]
                                                  target:self
                                                  action:@selector(scanAction)];
    
    KxMenuItem *shortCutMenuItem3 = [KxMenuItem menuItem:[StringUtil getLocalizableString:@"contact_FileTransfer"]
                                                   image:[StringUtil getImageByResName:@"wenjianzhushou.png"]
                                                  target:self
                                                  action:@selector(selectMenuItem3)];
    
    [menuItems addObject:shortCutMenuItem1];
    [menuItems addObject:shortCutMenuItem2];
    [menuItems addObject:shortCutMenuItem3];
    
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(self.view.frame.size.width - 30, 0, 0, 0) menuItems:menuItems];

    KxMenuItem * first = menuItems [0];
  
}

// 点击发起群聊
- (void)selectMenuItem1
{
    NewChooseMemberViewController *_controller = [[NewChooseMemberViewController alloc]init];
    _controller.typeTag = type_create_conversation;
    
    _controller.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
    
    UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:_controller];
    
    [UIAdapterUtil presentVC:navController];

}

- (void)selectMenuItem3{
    
    Emp *emp = [db getEmpInfoByUsercode:USERCODE_OF_FILETRANSFER];
    if (!emp) {
        return;
    }
    Conversation *conv = [[Conversation alloc] init] ;
    conv.emp = emp;
    conv.conv_id = [StringUtil getStringValue:emp.emp_id];
    conv.conv_type = singleType;
    conv.recordType = normal_conv_type;
    [contactViewController openConversation:conv andVC:self];
}


#pragma mark ======点击推送打开待办应用=======
/**
 自动打开轻应用
 */
- (void)autoOpenAgentList
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
//    默认不需要登录token
    isWaitingForLoginToken = NO;
    
    switch (_conn.userStatus) {
        case status_online:
        {
            [self findAndOpenAgentList];
        }
            break;
        default:
        {
            //                提示请稍候.. 如果用户登录成功了，那么就可以关闭提示框了
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
            isWaitingForLoginToken = YES;
        }
            break;
    }
}

- (void)findAndOpenAgentList{
    if (!self.appInfo) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，和通知相关的userinfo为nil",__FUNCTION__]];
        return;
    }
    NSString *appUrl = self.appInfo[KEY_NOTIFICATION_APP_URL];
    if (appUrl.length) {    // 轻应用链接不为空
        [LogUtil debug:[NSString stringWithFormat:@"%s 点击通知启动应用时，包括了具体的url:%@",__FUNCTION__,appUrl]];
        [self openAppUrl:appUrl];
    }
    self.appInfo = nil;
}

#pragma mark =============处理登录应答=================
- (void)processLoginAck:(NSNotification *)notification
{
    if (!isWaitingForLoginToken) {
        return;
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    isWaitingForLoginToken = NO;
    [UserTipsUtil hideLoadingView];
    
    eCloudNotification	*cmd	 =	(eCloudNotification *)[notification object];
    switch (cmd.cmdId) {
        case login_success:
        {
            [self findAndOpenAgentList];
        }
            break;
        case login_failure:
        {
            [UserTipsUtil showAlert:@"登录失败" autoDimiss:YES];
        }
            break;
        case login_timeout:
        {
            [UserTipsUtil showAlert:@"登录超时" autoDimiss:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark =============修改会话列表界面的标题=================
// 监听conn.connStatus值的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:MJRefreshKeyPathPanState]) {
        UIPanGestureRecognizer *recognizer = object;
        
        [self commitTranslation:[recognizer translationInView:_webview.scrollView]];
    }else if ([keyPath isEqualToString:@"connStatus"]){
        if (!isWaitingForLoginToken)
            return;
        
        [LogUtil debug:[NSString stringWithFormat:@"%s connstatus is %d userstatus is %d",__FUNCTION__,_conn.connStatus,_conn.userStatus]];
        
        if (_conn.connStatus == not_connect_type) {   // 未连接时的一些操作
            isWaitingForLoginToken = NO;
            [UserTipsUtil hideLoadingView];
            [UserTipsUtil showAlert:@"连接失败" autoDimiss:YES];
        }else{
            if (_conn.userStatus == status_online) {   // 在线状态下的一些操作
                isWaitingForLoginToken = NO;
                [UserTipsUtil hideLoadingView];
                [self findAndOpenAgentList];    // 打开点击通知后的轻应用处理
            }
        }
        
    }
}

- (void)returnString:(NSString *)string{
    
    if ([string isEqualToString:@"todo"]) {
        
        NSString *urlString = [[ServerConfig shareServerConfig]getXYDAIBANUrl];
        XIANGYUANAgentViewControllerARC *agent = [[XIANGYUANAgentViewControllerARC alloc]init];
        NSString *usercode = [UserDefaults getUserAccount];
        NSString *token = [UserDefaults getXIANGYUANAppToken];
        NSString *urlStr = [[NSString stringWithFormat:@"%@?usercode=%@&token=%@",urlString,usercode,token]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        agent.urlstr = urlStr;
        [self.navigationController pushViewController:agent animated:NO];
        
    }
    
}

@end
