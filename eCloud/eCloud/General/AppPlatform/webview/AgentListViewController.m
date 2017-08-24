//
//  AgentListViewController.m
//  eCloud
//
//  Created by yanlei on 15/8/19.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "AgentListViewController.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "JSSDKObject.h"

#import "WebViewJavascriptBridge.h"

#import "FGalleryViewController.h"
#import "UploadFileObject.h"

#import "PictureUtil.h"

#import "UIAdapterUtil.h"
#import "RecordUtil.h"
#import "VideoUtil.h"
#import "CurrentLocationUtil.h"


#import "conn.h"

#import "IOSSystemDefine.h"
//#import "IMYWebView.h"
#import "FGalleryViewController.h"
#import "FileListViewController.h"
#import "GKImagePicker.h"
#import "PictureManager.h"

#import "IMYWebView.h"

#import "mainViewController.h"
#import "specialChooseMemberViewController.h"
#import "NewChooseMemberViewController.h"

#import "talkSessionUtil2.h"

#import "openWebViewController.h"

#import "Barcode.h"

#import "ScannerViewController.h"

#import "eCloudDAO.h"

#import "UserTipsUtil.h"
#import "UserDefaults.h"
#import "talkSessionViewController.h"

#import "OpenCtxUtil.h"

#import "AgentDetailViewController.h"
#import "EmailForFileViewController.h"
#import "StringUtil.h"
#import "ImageUtil.h"
#import "talkSessionUtil.h"
#import "LCLLoadingView.h"
#import "UserDisplayUtil.h"
#import "FileListViewController.h"
#import "LCLShareThumbController.h"
#import "NewMyViewControllerOfCustomTableview.h"
#import "AppDelegate.h"
#import "TabbarUtil.h"
#import "UserDefaults.h"
#import "GXViewController.h"

#define BAR_HEIGHT (44)

// 创建群聊url http://target.screen/do?username=xxxxx%23xxxxx%23xxxxx&title=关于xxxx的审批&openurl=xxx.xxx.xxx%2Ftoken%3D

// 横竖屏切换
// http://target.screen/do?direction=0
// 路径中包含target.screen表示要进行创建会话(或群组)或横竖屏操作
#define TARGET_SCREEN @"target.screen"
// 路径包含target.screen的前提下，还包含username表示是创建单聊或群组
#define KEY_USERNAME @"username"
// 路径包含target.screen与username的前提下表示是创建单聊或群组的标题
#define KEY_TITLE @"title"
// 路径包含target.screen与username的前提下表示需要将url信息作为聊天内容发送到新建的单聊或群组中
#define KEY_OPENURL @"openurl"
// 路径包含target.screen的前提下，还包含direction表示是横竖屏切换
#define KEY_DIRECTION @"direction"

// 需要在新的界面中打开  路径中包含TARGET_NEW
#define TARGET_NEW @"TARGET_NEW"
// 不显示导航栏  路径中包含VIEWSHOW_NOHEAD
#define VIEWSHOW_NOHEAD @"VIEWSHOW_NOHEAD"
// 离开界面时调用OA的destory的js方法
#define DESTROY_METHOD_NAME @"destory();"

// 二维码  路径中包含target.QRcode
#define TARGET_QRCODE @"target.QRcode"

// 拨打电话  路径中包含tel:
#define KEY_TEL @"tel:"

// 选择人员  路径中包含http://target.users/do?isOne=1
// http://target.users/do?isOne=1
// @aping @vince 要不在下一版本，1待办单选，2代表多选
#define TARGET_USERS @"http://target.users/do?isOne=1"

// 要加载的url中包含lhcloud.fangcloud.com关键字时，显示导航栏
#define LHCLOUD_FANGCLOUD_COM @"lhcloud.fangcloud.com"

@interface AgentListViewController () <ChooseMemberDelegate,IMYWebViewDelegate,GKImagePickerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,photosLibraryManagerDelegate,ELCImagePickerControllerDelegate,FileListViewControllerDelegate,ChooseMemberDelegate,UIGestureRecognizerDelegate>
{
    /** 自定义状态栏的背景视图   作用：当加载的页面需要去除导航栏时，在状态栏的位置初始化这个背景视图 */
    UIView *_statusBarView;
}

//ScannerViewDelegate,RecordStatusDelegate,PictureDelegate

/** (已废弃) 第三方打开相册、图片操作 */
@property (nonatomic,retain) GKImagePicker *imagePicker;
/** webview与js绑定的对象 */
@property (nonatomic,retain) WebViewJavascriptBridge *bridge;

@end

@implementation AgentListViewController
{
    /** 网页加载时的一个定时器 */
    NSTimer *checkTimer;
    /** 是否为首次加载  YES:是   NO:不是 */
    BOOL isFirstLoad;
    /** 加载完毕之前显示的提示组件 */
    UILabel *tipLabel;
    /** 用于显示url的webview */
    IMYWebView *webview;
    /** 记录本次成功加载后的webview */
    IMYWebView *oldWebview;
    /** js与原生进行互调的处理类对象 */
    JSSDKObject *jssdk;
    /** "暂无数据，点击刷新"按钮对象 */
    UIButton *_refreshButton;
    
    /** (已废弃) 在进行选择图片操作时的开始时间 */
    long long selectPicStart;
    /** (已废弃) 在进行选择图片操作时将选中的图片的路径进行拼接起来 */
    NSMutableString *selectPics;
    /** (已废弃) 在进行选择图片操作时将选中的图片内容进行base64处理作用方便传输 */
    NSString *pictureStr;

}
@synthesize bridge;
@synthesize interceptAll;

@synthesize urlstr;
@synthesize curUrlStr;
@synthesize navigationType;
@synthesize delegete;

- (id)init{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    self = [super init];
    if (self) {
        self.interceptAll = YES;
        [self initWebView];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(void)dealloc
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    [self stopCheckTimer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    self.bridge = nil;
    
    if (webview.isLoading)
    {
        [webview stopLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    webview.delegate = nil;
//    [webview release];
    
//    NSLog(@"%s webview retaincount is %d",__FUNCTION__,(int)[webview retainCount]);
    webview = nil;

    self.urlstr = nil;
    self.curUrlStr = nil;
    [super dealloc];
}


-(void)viewWillAppear:(BOOL)animated{
    
    if (!self.isNeetHideLeftBtn) {
        [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed)];
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
    [super viewWillAppear:animated];
    [LogUtil debug:[NSString stringWithFormat:@"%s isrefresh is %@",__FUNCTION__,(self.isrefresh?@"YES":@"NO")]];

    [UIAdapterUtil hideTabBar:self];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self.navigationController setNavigationBarHidden:NO];
        
//    [self initWebView];
    
    if (self.navigationController.viewControllers.count == 1) {
        
        [UIAdapterUtil showTabar:self];
        
        oldWebview.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT);
        webview.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT - STATUSBAR_HEIGHT);

    }
    if ([UIAdapterUtil isHongHuApp]) {
        
        if (IS_IPHONE) {
            
            NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
            [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
            
        }
    }
    
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([self.urlstr rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
        return NO;
    }else{
        return YES;
    }
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

    //龙湖要求 发现界面 执行 dofind 方法 其它界面执行 也没用影响
    NSString *ret = [webview stringByEvaluatingJavaScriptFromString:@"dofind();"];
    [LogUtil debug:[NSString stringWithFormat:@"%s dofind ret is %@",__FUNCTION__,ret]];
   
}
- (void)viewWillDisappear:(BOOL)animated
{
    
    if ([self.urlstr rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
        
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        //[self.navigationController setNavigationBarHidden:YES];
    }else{
        //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
    }
    [super viewWillDisappear:animated];
    
    //[UIAdapterUtil showTabar:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//    [self initWebView];
//    self.title = [StringUtil getLocalizableString:@"me_agent_list"];

    
//    timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(reLoadRequest) userInfo:nil repeats:YES];
    
    //网络切换通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reLoadRequest) name:NETWORK_SWITCH object:nil];
}

- (void)handleGesture
{
    
}
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent == nil) {
        
        [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:DESTROY_METHOD_NAME]];
        
        self.bridge = nil;
        
        jssdk.bridge = nil;
        jssdk.curVC = nil;
        
        [jssdk release];
        jssdk = nil;
        _statusBarView = nil;
        [self stopCheckTimer];
        
    }

}


- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // 拦截里面的点击事件
//    NSString *curWebViewUrl = request.URL.absoluteString ;
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [LogUtil debug:[NSString stringWithFormat:@"%s current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]]
    ;

    // 云盘鉴权   作用是在用户第一次使用云盘进行绑定鉴权后的回退操作
    if ([curWebViewUrl rangeOfString:@"http://mop.longfor.com:18080/cloud/callback?"].length >0) {
        
        NSArray *array = [curWebViewUrl componentsSeparatedByString:@"&"];
        if (array.count>2) {
       
            if ([array[2] isEqualToString:@"errcode=0"]) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [UserTipsUtil showAlert:@"授权失败，请重试"];
            }
        }
        
    }
    if ([curWebViewUrl rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
        CGRect _frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT);
        webview.frame = _frame;
        oldWebview.frame = _frame;
        [self.navigationController setNavigationBarHidden:YES];
        _statusBarView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
        _statusBarView.backgroundColor = _color;
        [self.view addSubview:_statusBarView];
        [_statusBarView release];
    }
    
    if ([curWebViewUrl isEqualToString:@"about:blank"]) {
        return NO;
    }
    if ([curWebViewUrl rangeOfString:TARGET_NEW].length > 0) {
        self.isrefresh = NO;
//
        AgentListViewController *agentListVC=[[AgentListViewController alloc]init];
        // agentListVC.urlstr = appModel.apphomepage;
        curWebViewUrl = [curWebViewUrl stringByReplacingOccurrencesOfString:TARGET_NEW withString:@""];
        agentListVC.urlstr = curWebViewUrl ;
        [self.navigationController pushViewController:agentListVC animated:YES];
        [agentListVC release];
        return NO;
    }

//    curWebViewUrl = @"http://target.screen/do?username=lucl#网信-user8#网信-user9&title=关于龙湖二期上线的审批&openurl=xxx.xxx.xxx/token=abcdefg";
//
//    curWebViewUrl = @"/http://target.screen/do?direction=1";
    
    if ([curWebViewUrl rangeOfString:@"fileName="].length > 0) {
        self.isrefresh = NO;
        //代办中的附件
        EmailForFileViewController *emailForFileCtrl=[[EmailForFileViewController alloc]init];
        emailForFileCtrl.urlstr = curWebViewUrl ;
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:emailForFileCtrl animated:YES];
        [emailForFileCtrl release];
        return NO;
    }else if ([curWebViewUrl rangeOfString:@"failure"].length > 0){
        if(!webview.hidden)
        {
            webview.hidden = YES;
        }
        tipLabel.hidden = NO;
        NSArray *_array = [curWebViewUrl componentsSeparatedByString:@"msg="];
        if (_array.count >= 2) {
            tipLabel.text = _array[1];
        }
//        tipLabel.text = [1];// [[curWebViewUrl componentsSeparatedByString:@"msg="][1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
        return NO;
    }else if ([curWebViewUrl rangeOfString:@"back/?isrefresh="].length > 0){
        self.isrefresh = NO;
        
        //如果 拦截到url里包含 UPDATE_NOTICE，那么需要获取工作圈的未读数 add by shisp
        if ([curWebViewUrl rangeOfString:@"UPDATE_NOTICE"].length > 0) {
            //获取工作圈未读数
            [NewMyViewControllerOfCustomTableview unReadForWorkWorld];
        }
        // 获取上一个controller的对象
        NSArray *ctrlArray = self.navigationController.viewControllers;
        if (ctrlArray.count >= 2) {
            id _viewcontroller = ctrlArray[ctrlArray.count - 2];
            if ([_viewcontroller isKindOfClass:[AgentListViewController class]]) {
                AgentListViewController *listCtroller = (AgentListViewController *)(_viewcontroller);
                if ([curWebViewUrl rangeOfString:@"isrefresh=1"].length > 0){
                    listCtroller.isrefresh = YES;
                }else{
                    listCtroller.isrefresh = NO;
                }
            }
        }
        [self backButtonPressed];
        return NO;
    }else if ([curWebViewUrl rangeOfString:@"target.office"].length > 0){
        self.isrefresh = NO;

        for (UIViewController *ctrl in self.navigationController.viewControllers) {
            if ([ctrl isKindOfClass:[NewMyViewControllerOfCustomTableview class]]) {
                [self.navigationController popToViewController:ctrl animated:YES];
            }
        }
        return NO;
    }else if ([curWebViewUrl rangeOfString:@"target.select"].length > 0){
        if ([curWebViewUrl rangeOfString:@"type=photo"].length > 0) {
            [self getCameraPicture];
//            NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:@"Mb6Bvm0222792.png"];
//            [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"backSelect(%@);",picpath]];
//            [[webView windowScriptObject] evaluateWebScript:@"function x(x) { return x + 1;}"];
//            
//            
//            NSNumber *result = [[webView windowScriptObject] evaluateWebScript:@"x(1)"];
//            
//            NSLog(@"result:%d", [result integerValue]); // Returns 2
        }else if ([curWebViewUrl rangeOfString:@"type=images"].length > 0){
            [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"backSelect('%@');",@"123"]];
//            [self openSelectPictureController];
        }else if ([curWebViewUrl rangeOfString:@"type=files"].length > 0){
            [self openSelectFileController];
        }
        return NO;
    }else if ([curWebViewUrl rangeOfString:TARGET_SCREEN].length > 0)
    {
        self.isrefresh = NO;
        if ([curWebViewUrl rangeOfString:KEY_USERNAME].length > 0) {
            [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];
            
            [self performSelector:@selector(createConvsationWithUrl:) withObject:curWebViewUrl afterDelay:0.05];
            
        }else if ([curWebViewUrl rangeOfString:KEY_DIRECTION].length > 0)
        {
            //            切换方向
            NSArray *mArray = [curWebViewUrl componentsSeparatedByString:@"="];
            if (mArray.count >= 2) {
                NSString *directionValue = mArray[1];
                int direction = directionValue.intValue;
                [[self class] changeOrientation:self andDirection:direction];
            }
        }
        return NO;
    }else if ([curWebViewUrl rangeOfString:TARGET_QRCODE options:NSCaseInsensitiveSearch].length > 0){
        self.isrefresh = NO;

        ScannerViewController *scanner = [[[ScannerViewController alloc]init]autorelease];
        [self.navigationController pushViewController:scanner animated:YES];
        
        return NO;
    }else if ([curWebViewUrl rangeOfString:KEY_TEL].length > 0)
    {
        return YES;
    }else if ([curWebViewUrl rangeOfString:TARGET_USERS].length > 0)
    {
        NewChooseMemberViewController *newChoose = [[[NewChooseMemberViewController alloc]init]autorelease];
        newChoose.typeTag = type_app_select_contacts;
        newChoose.isSingleSelect = YES;
        NSArray *_array = [curWebViewUrl componentsSeparatedByString:@"="];
        if (_array.count == 2) {
            NSString *str = _array[1];
//            1：单选，其他代表多选
            if (![str isEqualToString:@"1"]) {
                newChoose.isSingleSelect = NO;
            }
        }
        
        newChoose.chooseMemberDelegate = self;
        
//        newChoose.contentOffSetYArray = [NSMutableArray arrayWithObjects:@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0), nil];
        
        UINavigationController *navController = [mainViewController getNavigationVCwithRootVC:newChoose];
        [UIAdapterUtil presentVC:navController];
        return NO;
    }
//    else if ([curWebViewUrl rangeOfString:KEY_AIGUANHUAI].length > 0 || [curWebViewUrl rangeOfString:KEY_INTERVIEW_PLATFORM].length > 0 || [curWebViewUrl rangeOfString:KEY_JUXIAN].length > 0)
//    {
////        爱关怀 不使用AgentList打开
//        self.isrefresh = NO;
//        //代办审批
//        openWebViewController *agentListVC=[[openWebViewController alloc]init];
//        agentListVC.urlstr = curWebViewUrl ;
//        [self.navigationController pushViewController:agentListVC animated:YES];
//        [agentListVC release];
//        return NO;
//    }
//    if (interceptAll) {
//        if ([curWebViewUrl rangeOfString:self.urlstr].length <= 0) {
//            
//            NSLog(@"%s 再次pushAgent",__FUNCTION__);
//            
//            self.isrefresh = NO;
//            //代办审批
//            AgentListViewController *agentListVC=[[AgentListViewController alloc]init];
//            // agentListVC.urlstr = appModel.apphomepage;
//            agentListVC.urlstr = curWebViewUrl ;
//            [self.navigationController pushViewController:agentListVC animated:YES];
//            [agentListVC release];
//            return NO;
//        }
//    }
    
    return YES;
}
-(void) webViewDidStartLoad:(IMYWebView *)webView
{
    [LogUtil debug:[NSString stringWithFormat:@"%s isFirstLoad is %@",__FUNCTION__,(isFirstLoad?@"YES":@"NO")]];

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
//            tipLabel.text = [StringUtil getLocalizableString:@"linking"];
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
    
    _refreshButton.hidden = YES;
    
    
    id agent = self.navigationController.viewControllers[self.navigationController.viewControllers.count-1];
    NSString * url =    ((AgentListViewController *)agent).urlstr;
    if ([url rangeOfString:LHCLOUD_FANGCLOUD_COM].length > 0) {
        
        [self.navigationController setNavigationBarHidden:NO];
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
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

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
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

    oldWebview = webView;
    // 不到3秒就得到了相应，就不会调用定时器的代理方法
//    [self closeTime];
    if (webview) {
       self.title = [webview pageTitle];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isFirstLoad = NO;
    if(webview.hidden)
    {
        webview.hidden = NO;
    }
    if (tipLabel) {
        
        tipLabel.hidden=YES;
    }
    
    _refreshButton.hidden = YES;
    
}

- (void)webView:(IMYWebView*)webView didFailLoadWithError:(NSError*)error
{
    [self stopCheckTimer];
    [LogUtil debug:[NSString stringWithFormat:@"%s error is %@",__FUNCTION__,error]];

//    [self closeTime];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
//    tipLabel.text = @"加载失败,请点击刷新";
    tipLabel.hidden = YES;
    _refreshButton.hidden = NO;
//    if (webView.isLoading) {
//        
//    }else{
//        
//    
//    }
}

- (void)reloadWebView{
    
    _refreshButton.hidden = YES;
    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    
    //    NSLog(@"%s  cache policy is %d",__FUNCTION__,requestObj.cachePolicy);
    
    [webview loadRequest:requestObj];
}
//返回 按钮
-(void) backButtonPressed
{
//    
//    [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:DESTROY_METHOD_NAME]];
//    
//    NSLog(@"%lu %lu",(unsigned long)self.bridge.retainCount,(unsigned long)jssdk.retainCount);
//    self.bridge = nil;
//    jssdk.bridge = nil;
//    jssdk.curVC = nil;
//    [jssdk release];
//    jssdk = nil;
    
    if ([_isForm isEqualToString:@"广告页"]) {
        AppDelegate *dele = [[[AppDelegate alloc]init]autorelease];
        [dele gotoRootViewCtrl];
    }else{
        //        返回时 调用destroy方法
    

//    if (_bridge) {
//        [_bridge release];
//        _bridge = nil;
//    }
    
//    NSLog(@"self retain is %d webview retain is  %d",(int)[self retainCount],(int)[webview retainCount]);
    webview.delegate = nil;
    [openWebViewController popViewController:self];

    }
    
}

- (void)initWebView{
    
    self.isrefresh = NO;
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setBackGroundColorOfController:self];
    //    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    int tableH = SCREEN_HEIGHT-20;
    if (!IOS7_OR_LATER) {
        tableH += 20;
    }
    CGRect _frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.navigationController setNavigationBarHidden:NO];
    if ([self.urlstr rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
        _frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT);
        [self.navigationController setNavigationBarHidden:YES];
        
        _statusBarView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        
        UIColor *_color = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
        _statusBarView.backgroundColor = _color;
        //[UIColor colorWithRed:34/255.0 green:37/255.0 blue:47/255.0 alpha:1];
        [self.view addSubview:_statusBarView];
        
        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        [_statusBarView release];
        
    }
    
    oldWebview=[[IMYWebView alloc]initWithFrame:_frame];
    oldWebview.scalesPageToFit = YES;
    oldWebview.delegate=self;
    oldWebview.hidden = YES;
    [self.view addSubview:oldWebview];
    [oldWebview release];
    
    webview=[[IMYWebView alloc]initWithFrame:_frame];
    webview.scalesPageToFit = YES;
    webview.delegate=self;
    webview.scrollView.bounces = NO;
    webview.tag = WEBVIEW_TAG;
    webview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:webview];
    [webview release];
    webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    NSLog(@"%@ %@",oldWebview,webview);
    // 在页面未加载完全时，显示的加载控件
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel release];
//    [self initWebView];
    
    //    if (timer) {
    //        [timer invalidate];
    //        timer = nil;
    //    }
    //self.navigationController.delegate = self;
    //[self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(handleGesture)];
    
    [self initInterface];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

    isFirstLoad = YES;
//    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:strUrl];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//
////    NSLog(@"%s  cache policy is %d",__FUNCTION__,requestObj.cachePolicy);
//    
//    [webview loadRequest:requestObj];
    
    _refreshButton=[UIAdapterUtil setNewButton:@"暂无数据，点击刷新" andBackgroundImage:nil];
    _refreshButton.frame=tipLabel.frame;
    [_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _refreshButton.backgroundColor = [UIColor clearColor];
    [_refreshButton addTarget:self action:@selector(reloadWebView) forControlEvents:UIControlEventTouchUpInside];
    _refreshButton.hidden = YES;
    [self.view addSubview:_refreshButton];
}

- (void)reLoadRequest{
    
    if (webview.loading){
        [self closeTime];
        [LogUtil debug:[NSString stringWithFormat:@"%s，请求的路径为%@",__FUNCTION__,webview.currentRequest.URL.absoluteString]];
        [webview reload];
        [LogUtil debug:[NSString stringWithFormat:@"%s--重新加载",__FUNCTION__]];
    }
}

- (void)closeTime{
//    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//
//    if (timer != nil && timer.isValid) {
//        [timer invalidate];
//        timer = nil;
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//#pragma mark - 拍照
////相机拍摄图片
//-(void) getCameraPicture {
//    //判断是否支持摄像头
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"chatBackground_warning"]
//                                                        message: [StringUtil getLocalizableString:@"chatBackground_warning_message"]
//                                                       delegate:nil
//                                              cancelButtonTitle: [StringUtil getLocalizableString:@"confirm"]
//                                              otherButtonTitles:nil];
//        [alert show];
//        [alert release];
//        
//        return;
//        
//    }
//    self.imagePicker = [[[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera]autorelease];
//    self.imagePicker.cropSize = [self getCropSize];
//    self.imagePicker.delegate = self;
//    [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
////    CGSize headerSize = [UserDisplayUtil getDefaultUserLogoSize];
////    
////    if (headerSize.width != headerSize.height)
////    {
////        self.imagePicker = [[[GKImagePicker alloc] initWithSourceType:UIImagePickerControllerSourceTypeCamera]autorelease];
////        self.imagePicker.cropSize = [self getCropSize];
////        self.imagePicker.delegate = self;
////        [self presentModalViewController:self.imagePicker.imagePickerController animated:YES];
////    }else
////    {
////        // 使用系统的调用相机 0819
////        [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
////    }
//}
//
//// 调用系统相机或相册 0819
//- (void)callSystemImagePickerControllerWithType:(UIImagePickerControllerSourceType)type{
//    UIImagePickerController *pickCtl = [[UIImagePickerController alloc]init];
//    pickCtl.sourceType = type;
//    pickCtl.delegate = self;
//    pickCtl.allowsEditing = YES;
//    [self presentViewController:pickCtl animated:YES completion:nil];
//    [pickCtl release];
//}
//
////- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
////{
////    if ([navigationController isKindOfClass:[GKImagePicker class]])
////    {
////        [UIAdapterUtil setStatusBar];
////    }
////}
////从相册选择图片
////- (void) selectExistingPicture {
////    
////    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
////        // 使用系统的方式选择照片
////        [self callSystemImagePickerControllerWithType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
////    } else {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"访问图片库错误",@"")
////                                                        message: NSLocalizedString(@"设备不支持图片库",@"")
////                                                       delegate:nil
////                                              cancelButtonTitle: NSLocalizedString(@"确定",@"")
////                                              otherButtonTitles:nil];
////        [alert show];
////        [alert release];
////    }
////}

// 暂留 调用相册、图片功能
//# pragma mark -
//# pragma mark GKImagePicker Delegate Methods
//
//- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image
//{
//    if (image)
//    {
////        CGSize _size = [self getStandardLogoSize];
////        if (image.size.width > _size.width || image.size.height > _size.height) {
////            image= [ImageUtil scaledImage:image toSize:_size withQuality:kCGInterpolationHigh];
////        }
//        
//        NSData *picData = UIImageJPEGRepresentation(image, 0.5);
//        pictureStr = [picData base64Encoding];
//    }
//    
//    [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
//    if (pictureStr) {
//        NSLog(@"拍照的图片的Base64编码:%@", pictureStr);
//        [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"backSelect('%@');",pictureStr]];
//    }
//}
//
////- (CGSize)getStandardLogoSize
////{
////    return CGSizeMake([eCloudConfig getConfig].uploadUserLogoWidth.intValue, [eCloudConfig getConfig].uploadUserLogoHeight.intValue);
////}
////
//- (CGSize)getCropSize
//{
//    CGSize _size = [UserDisplayUtil getDefaultUserLogoSize];
//    float width = SCREEN_WIDTH;
//    float height = (width * _size.height) / _size.width;
//    return CGSizeMake(width, height);
//}
//
//#pragma mark - 相册
////打开选择图片界面
//- (void)openSelectPictureController
//{
//    selectPicStart = [StringUtil currentMillionSecond];
//    
//    if(nil == pictureManager)
//    {
//        pictureManager	=	[[PictureManager alloc]init];
//    }
//    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
//        //用户手动取消授权
//        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
//            [self showCanNotAccessPhotos];
//            return;
//        }
//        else {
//            //其他情况下都去请求访问图片库
//            [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
//        }
//    }
//    else
//    {
//        [(PictureManager *)pictureManager obtainPicturesFrom:fromLibrary delegate:self];
//    }
//}
//#pragma mark - pic
//- (void)photosLibraryManager:(photosLibraryManager *)manager error:(NSError *)error
//{
//    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
//}
//
//- (void)photosLibraryManager:(photosLibraryManager *)manager pictureInfo:(NSArray *)pictures
//{
//    long long end = [StringUtil currentMillionSecond];
//    [LogUtil debug:[NSString stringWithFormat:@"%s 从点击到获取图片完毕需要时间%lld,获取图片张数为%d",__FUNCTION__,(end - selectPicStart),pictures.count]];
//    
//    selectPicStart = end;
//    
//    [[LCLLoadingView currentIndicator]hiddenForcibly:YES];
//    
//    LCLShareThumbController *assetTable		=	[[LCLShareThumbController alloc]initWithNibName:nil bundle:nil];
//    ELCImagePickerController *elcPicker		=	[[ELCImagePickerController alloc] initWithRootViewController:assetTable];
//    assetTable.pre_delegete=self;
//    [assetTable setParent:elcPicker];
//    [assetTable preparePhotos:pictures];
//    [elcPicker setDelegate:self];
//    
//    [self presentModalViewController:elcPicker animated:YES];
//    [elcPicker release];
//    [assetTable release];
//    
//    [LogUtil debug:[NSString stringWithFormat:@"%s ,从取完图片到打开图片界面需要时间%lld",__FUNCTION__,[StringUtil currentMillionSecond] - selectPicStart]];
//    
//}
//- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
//{
//    [picker dismissModalViewControllerAnimated:YES];
//}
//#pragma mark - 多图 发送
//-(void)uploadManyPics:(NSMutableArray *)picArray
//{
//    manyPicArray=[picArray copy];
//    pic_index=0;
//    if (manyPicArray != nil && manyPicArray.count > 0) {
//        selectPics = [[NSMutableString alloc]init];
//    }
//    
//    manypicTimer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(doUploadManyPicsAction) userInfo:nil repeats:YES];
//}
//
//-(void)doUploadManyPicsAction
//{
//    if (pic_index < [manyPicArray count]){
//        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//        CGImageRef imageRef;
//        ALAsset *asset=[[manyPicArray objectAtIndex:pic_index] asset];
//        ALAssetRepresentation* rep = [asset defaultRepresentation];
//        imageRef = [rep fullScreenImage];
//        
//        if(imageRef)
//        {
//            UIImage *image = [UIImage imageWithCGImage:imageRef];
//            CGSize _size = [talkSessionUtil getImageSizeAfterCropForUpload:image];
//            if(_size.width > 0 && _size.height > 0)
//            {
//                image= [ImageUtil scaledImage:image  toSize:_size withQuality:kCGInterpolationHigh];
//            }
//            NSData * data =UIImageJPEGRepresentation(image, 0.5);
//            NSLog(@"-----------------picdata--: %d",data.length);
//            [self displayAndUploadPic:data];
//            
//        }
//        
//        [pool drain];
//        
//        pic_index++;
//    }
//    
//    if (pic_index==[manyPicArray count]) {
//        [manypicTimer invalidate];
//        manypicTimer=nil;
//        [manyPicArray release];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPicFinished" object:nil];
//        NSLog(@"selectpicsPath = %@",[NSString stringWithFormat:@"backSelect('%@');",selectPics]);
//        
//        
//        
//        
////        [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"function bendihuancun(){var storage = window.localStorage;if (storage) {storage.setItem('picdatas', %@); }}",selectPics]];
////        [oldWebview stringByEvaluatingJavaScriptFromString:@"bendihuancun();"];
////        [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"function onStart(){var storage = window.localStorage;if(storage.getItem('picdatas')!=null){alert(storage.getItem('picdatas'));}alert(2);} "]];
////        [oldWebview stringByEvaluatingJavaScriptFromString:@"onStart();"];
//        
//        [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"backSelect('%@');",selectPics]];
//        [selectPics release];
//        return;
//    }
//}
//
//#pragma mark 确定发送图片消息后，显示在聊天界面，并且开始传输
//-(void)displayAndUploadPic:(NSData *)data
//{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
////    NSString *encodingStr = [data base64Encoding];
////    NSLog(@"Base64编码:%@", encodingStr);
//    // 文件的临时名称，此处文件类型怎么不是jpeg类型，因为压缩时是按照jpeg类型压缩的
//    NSString *currenttimeStr = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] * 1000];
//    NSString *pictempname = [NSString stringWithFormat:@"%@.png",currenttimeStr];
//    
//    //存入本地
//    NSString *picpath = [[StringUtil newRcvFilePath] stringByAppendingPathComponent:pictempname];
//    [selectPics appendString:picpath];
//    if (pic_index != [manyPicArray count]-1) {
//        [selectPics appendString:@","];
//    }
//    NSLog(@"--------datalength-%d-----picpath---%@",data.length,picpath);
//    
//    BOOL success = NO;
//    success = [data writeToFile:picpath atomically:YES];
//    
//    if (!success) {
//        [pool release];
//        return;
//    }
//    
//    [pool release];
//}
#pragma mark - 打开文件界面
- (void)openSelectFileController
{
    FileListViewController *ctr = [[FileListViewController alloc] init];
    ctr.locaLFilesDelegate = self;
    ctr.fromCtrl = @"agentListCtrl";
    [self.navigationController pushViewController:ctr animated:YES];
    [ctr release];
}
- (void)fileListViewControllerClickOnBackBtn:(FileListViewController *)localFilesCtr withSelectFiles:(NSMutableArray *)filesArr{
    ConvRecord *_convRecord = filesArr[0];
    NSString *token = [self getTokenFromString:_convRecord.msg_body];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadFilesFinished" object:nil];
    [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"backSelect('%@','%@');",_convRecord.file_name,token]];
}
- (NSString *)getTokenFromString:(NSString *)_msgbody{
    NSString *token;
    NSRange _range = [_msgbody rangeOfString:@"_" options:NSBackwardsSearch];
    if(_range.length > 0){
        token = [NSString stringWithFormat:@"%@",[_msgbody stringByReplacingOccurrencesOfString:@"_" withString:@""]];
    }
    else{
        token = _msgbody;
    }
    return token;
}

#pragma mark ========在轻应用中创建群组并发送消息=========

//            http://target.screen/do?username=lucl#lichuan#wang&title=关于xxxx的审批&openurl=http://114.251.168.251:8080/lhydsp/general.html?flowNo=f41f96b6-4d79-41f0-adcb-f734c896bf34&systemNo=PROJPLAN&businessType=JHSP&todoid=db2be55d-ede4-4eb4-a442-52082581c364&runnoteId=SH1&status=0&appvUsername=kongbing
- (void)createConvsationWithUrl:(NSString *)curWebViewUrl
{
    NSString *decodeUrlStr = curWebViewUrl;
//    [curWebViewUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s decodeUrlStr is %@",__FUNCTION__,decodeUrlStr]];
    
//    首先取出openUrl的值
    NSString *openUrlStr = nil;

    NSRange openUrlRange = [decodeUrlStr rangeOfString:[NSString stringWithFormat:@"%@=",KEY_OPENURL]];
    if (openUrlRange.length > 0) {
        NSString *beforeOpenUrlStr = [decodeUrlStr substringToIndex:openUrlRange.location];
        NSString *afterOpenUrlStr = [decodeUrlStr substringFromIndex:openUrlRange.location + openUrlRange.length];
        
        openUrlStr = [NSString stringWithFormat:@"%@",afterOpenUrlStr];
        decodeUrlStr = [NSString stringWithFormat:@"%@",beforeOpenUrlStr];
    }
    
    NSMutableArray *userCodeArray = [NSMutableArray array];
    NSString *convTitle = nil;
    
    NSArray *parameterArray = [decodeUrlStr componentsSeparatedByString:@"&"];
    for (NSString *str in parameterArray) {
        [LogUtil debug:[NSString stringWithFormat:@"%s &分隔后的str:%@",__FUNCTION__,str]];
        
        NSArray *_array = [str componentsSeparatedByString:@"="];
        if (_array.count < 2) {
            continue;
        }
        
        NSString *valueStr = _array[1];
        
        if ([str rangeOfString:KEY_USERNAME].length > 0) {
            userCodeArray = [valueStr componentsSeparatedByString:@"#"];
        }else if ([str rangeOfString:KEY_TITLE].length > 0){
            convTitle = valueStr;
        }
    }
    
    if (userCodeArray.count == 0 || convTitle == nil) {
        [LogUtil debug:[NSString stringWithFormat:@"%s 没有找到用户或则没有传入title",__FUNCTION__]];
        [UserTipsUtil hideLoadingView];
    }else{
        OpenCtxUtil *openCtx = [OpenCtxUtil getUtil];
        {
            NSArray *_array = userCodeArray;
            [openCtx createAndOpenConvWithEmpCodes:_array andConvTitle:convTitle andCompletionHandler:^(int result, UIViewController *talkSession) {
                [UserTipsUtil hideLoadingView];
                if (result == createAndOpenConvResult_ok)
                {
                    talkSessionViewController *_talkSession = ((talkSessionViewController *)talkSession);
                    [UserDefaults removeModifyGroupNameFlag:_talkSession.convId];
                    
//                    如果有url 那么就要发送到群聊里
                    if (openUrlStr) {
                        
                        if (_talkSession.talkType == singleType) {
                            [[talkSessionUtil2 getTalkSessionUtil]createSingleConversation:_talkSession.convId andTitle:_talkSession.titleStr];
                        }
                        
                        conn *_conn = [conn getConn];
                        
                        NSString *msgBody = [NSString stringWithFormat:@"%@",openUrlStr];
                        NSString *convId = _talkSession.convId;
                        
                        int nowtimeInt= [_conn getCurrentTime];
                        NSString *nowTime =[StringUtil getStringValue:nowtimeInt];
                        
                        //		信息类型
                        NSString *msgType = [StringUtil getStringValue:type_text];
                        
                        //		信息类型为发送信息
                        NSString *msgFlag = [StringUtil getStringValue:send_msg];
                        
                        //		发送状态为正在发送
                        NSString *sendFlag = [StringUtil getStringValue:sending];

                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:convId,@"conv_id",_conn.userId,@"emp_id",msgType,@"msg_type",msgBody,@"msg_body", nowTime,@"msg_time", msgFlag,@"msg_flag",sendFlag,@"send_flag",@"0",@"read_flag",[StringUtil getStringValue:conv_status_normal],@"receipt_msg_flag", nil];
                        
                        eCloudDAO *_ecloud = [eCloudDAO getDatabase];
                        
                        NSDictionary *_dic =[_ecloud addConvRecord:[NSArray arrayWithObject:dic]];
                        
                        if(_dic)
                        {
                            //				添加数据库成功
//                            msgId = [_dic valueForKey:@"msg_id"];
                            NSString *sendMsgId = [_dic valueForKey:@"origin_msg_id"];
                            
                            [_conn sendMsg:convId andConvType:_talkSession.talkType andMsgType:type_text andMsg:msgBody andMsgId:[sendMsgId longLongValue]  andTime:nowtimeInt andReceiptMsgFlag:conv_status_normal];
                        }
                    }
                    
                    [self.navigationController pushViewController:talkSession animated:YES];
                }
                else
                {
                    NSString *tipsStr = @"";
                    switch (result) {
                        case createAndOpenConvResult_create_group_fail:
                            tipsStr = @"创建群组失败";
                            break;
                        case createAndOpenConvResult_create_group_timeout:
                            tipsStr = @"创建群组超时";
                            break;
                        case createAndOpenConvResult_user_not_login:
                            tipsStr = @"用户未登录";
                            break;
                        case createAndOpenConvResult_can_not_find_user:
                            tipsStr = @"没有找到用户";
                            break;
                        default:
                            break;
                    }
                    
                    [UserTipsUtil showAlert:tipsStr];
                }
            }];
        }
    }
}

#pragma mark ========在轻应用中进行横竖屏切换=========
//add by shisp 横竖屏切换
//0:横屏，1竖屏。
+ (void)changeOrientation:(UIViewController *)curVC andDirection:(int)directionType
{
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    UIWebView *webview = (UIWebView *)[curVC.view viewWithTag:WEBVIEW_TAG];
    
    if (directionType == direction_portrait) {
        [UIView animateWithDuration:duration animations:^{
            // 修改状态栏的方向及view的方向进而强制旋转屏幕
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            [curVC.navigationController setNavigationBarHidden:NO];
            
            curVC.navigationController.view.transform = CGAffineTransformIdentity;
            
            CGRect _frame = curVC.navigationController.view.bounds;
            _frame.size.width = SCREEN_WIDTH;
            _frame.size.height = SCREEN_HEIGHT;
            curVC.navigationController.view.bounds = _frame;
            
            CGRect webviewFrame = webview.frame;
            webviewFrame.size.width = SCREEN_WIDTH;
            webviewFrame.size.height = SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT;
            webview.frame = webviewFrame;
            
            NSLog(@"222 navigation view frame is %@  webview frame is %@",NSStringFromCGRect(curVC.navigationController.view.frame),NSStringFromCGRect(webview.frame));
        }];
    }else{
        
        float arch = M_PI_2;
        //        if (_orientation == UIDeviceOrientationLandscapeRight)
        //            arch = -M_PI_2;
        
        [UIView animateWithDuration:duration animations:^{
            // 修改状态栏的方向及view的方向进而强制旋转屏幕
            //            这个不生效 所以暂时隐藏状态栏
            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            //            [UIApplication sharedApplication].statusBarFrame = CGRectZero;
            
            [[UIApplication sharedApplication]setStatusBarHidden:YES animated:YES];
            [curVC.navigationController setNavigationBarHidden:YES animated:YES];
            
            curVC.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
            
            CGRect _frame = curVC.navigationController.view.bounds;
            _frame.size.width = SCREEN_HEIGHT;
            _frame.size.height = SCREEN_WIDTH ;
            curVC.navigationController.view.bounds = _frame;

            webview.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH );
            NSLog(@"111 navigation view frame is %@  webview frame is %@",NSStringFromCGRect(curVC.navigationController.view.frame),NSStringFromCGRect(webview.frame));
        }];
    }
}

//- (void)changeOrientation:(int)directionType
//{
//    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
//
//    if (directionType == 1) {
//        [UIView animateWithDuration:duration animations:^{
//            // 修改状态栏的方向及view的方向进而强制旋转屏幕
//            [[UIApplication sharedApplication] setStatusBarHidden:NO];
////            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
//            [self.navigationController setNavigationBarHidden:NO];
//            
//            self.navigationController.view.transform = CGAffineTransformIdentity;
//            
//            float newWidth = [UIScreen mainScreen].bounds.size.width;
//            float newHeight = [UIScreen mainScreen].bounds.size.height;
//            
//            CGRect frame = CGRectMake(self.navigationController.view.bounds.origin.x, self.navigationController.view.bounds.origin.y, newWidth, newHeight);
//            
//            self.navigationController.view.bounds = frame;
//            
//            CGRect webviewFrame = webview.frame;
//            webviewFrame.size.width = newWidth;
//            webviewFrame.size.height = newHeight;
//            webview.frame = CGRectMake(0, 0, newWidth, newHeight - 64);
//            
//            NSLog(@"222 navigation view frame is %@  webview frame is %@",NSStringFromCGRect(self.navigationController.view.frame),NSStringFromCGRect(webview.frame));
//        }];
//    }else{
//        
//        float arch = M_PI_2;
////        if (_orientation == UIDeviceOrientationLandscapeRight)
////            arch = -M_PI_2;
//        
//        [UIView animateWithDuration:duration animations:^{
//            // 修改状态栏的方向及view的方向进而强制旋转屏幕
//            //            这个不生效 所以暂时隐藏状态栏
//            //            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
//            //            [UIApplication sharedApplication].statusBarFrame = CGRectZero;
//            
//            [[UIApplication sharedApplication]setStatusBarHidden:YES animated:YES];
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
//            
//            self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
//            
//            float newWidth = [UIScreen mainScreen].bounds.size.height;
//            float newHeight = [UIScreen mainScreen].bounds.size.width;// self.view.frame.size.width;
//            CGRect frame = CGRectMake(self.navigationController.view.bounds.origin.x, self.navigationController.view.bounds.origin.y, newWidth, newHeight);
//            
//            self.navigationController.view.bounds = frame;
//            
//            webview.frame = CGRectMake(0, 0, newWidth, newHeight);
//            
//            NSLog(@"111 navigation view frame is %@  webview frame is %@",NSStringFromCGRect(self.navigationController.view.frame),NSStringFromCGRect(webview.frame));
//        }];
//    }
//}

#pragma mark ======扫描二维码结果========
- (void)barcodeFind:(ScannerViewController *)scanner barCodes:(NSArray *)foundBarcodes
{
    if (foundBarcodes.count) {
        Barcode *_barCode = [foundBarcodes lastObject];
        NSLog(@"bar code type is %@  bar code data is %@",_barCode.getBarcodeType,_barCode.getBarcodeData);
    }
}

#pragma mark ======选中的成员=========
- (void)didSelectContacts:(NSString *)retStr
{
    [oldWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"choiceUsers('%@');",retStr]];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s",__FUNCTION__);
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
}


#pragma mark ======图像接口======
#define CHOOSE_IMAGE @"chooseImage"
#define CHOOSE_IMAGE_HANDLER @"chooseImageHandler"
#define PREVIEW_IMAGE @"previewImage"
#define UPLOAD_IMAGE @"uploadImage"
#define DOWNLOAD_IMAGE @"downloadImage"

#define PREVIEW_IAMGE_CUR_RUL @"current"
#define PREVIEW_IMAGE_URLS @"urls"

- (void)initImage
{
    //    [_bridge registerHandler:CHOOSE_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
    //        [PictureUtil getUtil].delegate = self;
    //        [[PictureUtil getUtil]presentSheet:self];
    //    }];
    //    [_bridge registerHandler:UPLOAD_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
    //        [[PictureUtil getUtil]uploadImage];
    //    }];
    //    [_bridge registerHandler:DOWNLOAD_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
    //        [[PictureUtil getUtil]downloadImage:nil];
    //    }];
    [self.bridge registerHandler:PREVIEW_IMAGE handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *curUrl = data[PREVIEW_IAMGE_CUR_RUL];
        NSArray *previewImageArray = data[PREVIEW_IMAGE_URLS];
        if (previewImageArray.count > 0) {
            FGalleryViewController *gallery = [[PictureUtil getUtil]previewImages:previewImageArray andCurUrl:curUrl];
            if (gallery) {
                [self.navigationController pushViewController:gallery animated:YES];
            }
        }
    }];
}

#pragma mark picture delegate
- (void)didSelectPicture:(NSArray *)imageArray
{
    if (imageArray.count) {
        [self.bridge callHandler:CHOOSE_IMAGE_HANDLER data:[StringUtil getStringValue:imageArray.count] responseCallback:^(id responseData) {
            
        }];
    }
}

- (void)setUrlstr:(NSString *)_urlstr
{
    if (urlstr) {
        [urlstr release];
        urlstr = nil;
    }
    urlstr = [_urlstr retain];
    if (urlstr) {
        
        NSString *strUrl = [self.urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:strUrl];
        //NSURLRequestReturnCacheDataElseLoad
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:7];
        
//        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        //    NSLog(@"%s  cache policy is %d",__FUNCTION__,requestObj.cachePolicy);
        
        [webview loadRequest:requestObj];

    }
}

- (void)viewWillLayoutSubviews{
 
    [super viewWillLayoutSubviews];
    
    int height = [StringUtil getStatusBarHeight];
    if (height == 40) {
        
        CGRect _frame = webview.frame;
        _frame.size.height = webview.frame.size.height - 20;
        webview.frame = _frame;
    }else if(height == 20){
        
        CGRect _frame = webview.frame;
        if ([self.urlstr rangeOfString:VIEWSHOW_NOHEAD].length > 0) {
            _frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT);
            webview.frame = _frame;
        }else{
            _frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUSBAR_HEIGHT - NAVIGATIONBAR_HEIGHT);
            webview.frame = _frame;
        }
    }
    
}
@end
