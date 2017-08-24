//
//  LANGUANGAgentViewControllerARC.m
//  eCloud
//
//  Created by Ji on 17/5/27.
//  Copyright © 2017年 网信. All rights reserved.
//

#import "LANGUANGAgentViewControllerARC.h"
#import "IMYWebView+IMYWebViewWIthPageTitle.h"
#import "WebViewJavascriptBridge.h"
#import "JSSDKObject.h"
#import "LogUtil.h"
#import "UIAdapterUtil.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "JsObjectCViewController.h"
#import "ForwardingRecentViewController.h"
#import "UserTipsUtil.h"
#import "ConvRecord.h"
#import "eCloudDefine.h"
#import "JSONKit.h"
#import "UserDefaults.h"
#import "conn.h"
#import "LGMettingDefine.h"
#import "LGMettingUtilARC.h"
#import "LANGUANGAppViewControllerARC.h"
#import "JSONKit.h"
#import "OpenCtxUtil.h"
#import "WXMsgDialog.h"
#import "MBProgressHUD.h"
#import "EmailForFileViewController.h"
#import "AFDropdownNotification.h"
#import "openWebViewController.h"
#import "LookFileViewController.h"
#import "NotificationUtil.h"
#import "JWURLProtocol.h"

@interface LANGUANGAgentViewControllerARC ()<ForwardingDelegate,NSURLSessionDelegate,AFDropdownNotificationDelegate>

@property (nonatomic,strong) WebViewJavascriptBridge *bridge;
@property (nonatomic, strong) ConvRecord *forwardRecord;
@property (nonatomic, strong) AFDropdownNotification *notification;
@end

@implementation LANGUANGAgentViewControllerARC
{
    NSTimer *checkTimer;
    JSSDKObject *jssdk;
    BOOL isFirstLoad;
    UIButton *rightButton;
    UIButton *groupsButton;
    UIBarButtonItem *rightItem;
    UIBarButtonItem *groupsItem;
    UIBarButtonItem *space;
    NSArray *barBtns;
    MBProgressHUD *HUD;
    NSString *downloadUrl;
    NSString *approvalUrl;
    
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
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    /** 取消注册网路请求拦截 */
    [NSURLProtocol unregisterClass:[JWURLProtocol class]];
 
    [LogUtil debug:[NSString stringWithFormat:@"%s ",__FUNCTION__]];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [UIAdapterUtil hideTabBar:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstLoad = YES;
    
//    rightButton = [UIAdapterUtil setRightButtonItemWithImageName:@"Share.png" andTarget:self andSelector:@selector(shareNews)];
//    rightButton.hidden = YES;
//    
//    groupsButton = [UIAdapterUtil setRightButtonItemWithImageName:@"agent_msg.png" andTarget:self andSelector:@selector(createGroups)];
//    groupsButton.hidden = YES;
    
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToRoot) name:LG_CLOSE_WEBVIEW_NOTIFICATION object:nil];
    
    rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 48, 48);

    [rightButton setImage:[StringUtil getImageByResName:@"Share.png"] forState:UIControlStateNormal];
    [rightButton setImage:[StringUtil getImageByResName:@"Share_hl.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(shareNews) forControlEvents:UIControlEventTouchUpInside];
    rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = -12.0f;

    groupsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    groupsButton.frame = CGRectMake(0, 0, 44, 44);
    
    [groupsButton setImage:[StringUtil getImageByResName:@"agent_msg.png"] forState:UIControlStateNormal];
    [groupsButton setImage:[StringUtil getImageByResName:@"agent_msg_hl.png"] forState:UIControlStateHighlighted];
    [groupsButton addTarget:self action:@selector(createGroups) forControlEvents:UIControlEventTouchUpInside];
    groupsItem = [[UIBarButtonItem alloc]initWithCustomView:groupsButton];
    
    rightButton.hidden = YES;
    groupsButton.hidden = YES;
    
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
    
    if ([self.urlstr rangeOfString:@"$token"].length > 0) {
        
        NSString *oaToken = [UserDefaults getLoginToken];
        NSArray *arr = [self.urlstr componentsSeparatedByString:@"$"];
        if (arr.count) {
            
            self.urlstr = [NSString stringWithFormat:@"%@%@",arr[0],oaToken];

        }
    }

    NSString *strUrl = [self.urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 
//    NSString *strUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, nil, nil, kCFStringEncodingUTF8));
 
    strUrl=[strUrl stringByReplacingOccurrencesOfString:@"%23"withString:@"#"];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:url];
    
    webview.delegate=self;
  
    [webview loadRequest:requestObj];

    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 100)];
    tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];

    
    [self initInterface];
}

//返回 按钮
-(void) backButtonPressed:(id) sender
{

    if ([webview canGoBack]) {   // 若当前页面不是首页进行页面回退操作
        [webview goBack];
        return ;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
    
    NSString *curWebViewUrl = [request.URL.absoluteString  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s return YES current url is %@ self.url is %@",__FUNCTION__,curWebViewUrl,self.urlstr]];
    
    if (![curWebViewUrl isEqualToString:@"about:blank"]) {
        
        self.curUrlStr = curWebViewUrl;
        
        
        if (_isNews) {
            
            barBtns = nil;
            space.width = -12;
            barBtns = [NSArray arrayWithObjects:space,rightItem, nil];
            [self.navigationItem setRightBarButtonItems:barBtns];
            rightButton.hidden = NO;
            
        }else{
            
            rightButton.hidden = YES;
        }
        

        if ([curWebViewUrl rangeOfString:@"attachmentAction!downFile"].length >0 || [curWebViewUrl rangeOfString:@"file/download?"].length > 0) {
            
            [WXMsgDialog toastCenter:@"文件开始下载" onView:self.view delay:2.0f];
            
            NSURLSessionConfiguration *epheSession=[NSURLSessionConfiguration ephemeralSessionConfiguration];
            epheSession.discretionary=YES;
            NSURLSession *downsession =[NSURLSession sessionWithConfiguration:epheSession delegate:self delegateQueue:nil];
            NSURLSessionDownloadTask *downTask = [downsession downloadTaskWithRequest:request];
            [downTask resume];
//            downloadUrl = curWebViewUrl;
            return NO;
        }
        
        if ([curWebViewUrl rangeOfString:@"UICtrl.js"].length > 0) {
            
            UIViewController *target = nil;
            for (UIViewController * controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[LANGUANGAppViewControllerARC class]]){
                    target = controller;
                }
            }
            if (target) {
                
                [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:nil];
                [self.navigationController popToViewController:target animated:YES];
            }
        }
        NSDictionary *dict = [LANGUANGAppViewControllerARC cutString:self.curUrlStr];
        NSString *procInstEndTime = dict[@"procInstEndTime"];
        NSString *bizId = dict[@"bizId"];
        NSString *procUnitId = dict[@"procUnitId"];
        NSString *taskId = dict[@"taskId"];
        
        if (bizId.length && procUnitId.length &&taskId.length) {
            
            if (procInstEndTime.length == 0) {
    
                barBtns = nil;
                space.width = 0;
                barBtns = [NSArray arrayWithObjects:space,groupsItem, nil];
                [self.navigationItem setRightBarButtonItems:barBtns];
                groupsButton.hidden = NO;
            }
        }else{
            groupsButton.hidden = YES;
        }
        
        if ([curWebViewUrl rangeOfString:@"workflowAction!showTaskDetail.do"].length >0) {
            
            webview.scalesPageToFit = NO;
        }
        
        if ([curWebViewUrl rangeOfString:@".job" options:NSCaseInsensitiveSearch].length) {
            /** 注册 网络请求拦截 */
            [NSURLProtocol registerClass:[JWURLProtocol class]];
        }
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
    
    // 修改左上角显示文字内容
    [UIAdapterUtil changeLeftButtonTitle:self.navigationItem.leftBarButtonItems andTarget:self];
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
    
    [LogUtil debug:[NSString stringWithFormat:@"%s , %@",__FUNCTION__,error]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareNews
{
  
    NSString *Js = @"document.body.innerText";
    NSString *lHtml1 = [webview stringByEvaluatingJavaScriptFromString:Js];
    NSString *jsUrl = @"document.URL";
    NSString *url = [webview stringByEvaluatingJavaScriptFromString:jsUrl];
    
    NSArray *array = [lHtml1 componentsSeparatedByString:@" "];
    NSString *shareString;
    if (array.count) {
        
        shareString = array[0];
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:shareString forKey:@"title"];
    [dict setObject:url forKey:@"url"];
    [dict setObject:@"news" forKey:@"type"];

    NSString *jsonStr = [dict JSONString];
    
    ConvRecord *_convRecord = nil;
    _convRecord = [[ConvRecord alloc]init];
    _convRecord.msg_type = type_text;
    _convRecord.msg_body = jsonStr;
    self.forwardRecord = _convRecord;
    
    ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc] initWithConvRecord:self.forwardRecord];
    forwarding.fromType = transfer_from_news;
    forwarding.forwardingDelegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:forwarding];
    nav.navigationBar.tintColor = [UIColor blackColor];
    [UIAdapterUtil presentVC:nav];
}

#pragma mark =======转发提示=======
- (void)showTransferTips
{
    [self performSelectorOnMainThread:@selector(showForwardTips) withObject:nil waitUntilDone:YES];
    [self performSelector:@selector(dismissLoadingView) withObject:nil afterDelay:1];
}

- (void)showForwardTips
{
    [UserTipsUtil showForwardTips];
}

- (void)dismissLoadingView
{
    [UserTipsUtil hideLoadingView];
}

- (void)createGroups{
    
    //[UserTipsUtil showLoadingView:@"请稍后"];
    [self requestGroupsMembers];
    
}

- (void)requestGroupsMembers{
    
    [UserTipsUtil showLoadingView:[StringUtil getLocalizableString:@"please_wait"]];

    NSString *account = [UserDefaults getUserAccount];
    NSString *curTime = [[conn getConn] getSCurrentTime];
    NSString *md5Str = [StringUtil getMD5Str:[NSString stringWithFormat:@"%@%@%@",account,curTime,LGmd5_password]];
    NSString *urlString = [NSString stringWithFormat:@"%@/middleware/longRange/workFlow?",[LGMettingUtilARC get9013Url]];
    
    NSString *oaToken = [UserDefaults getLoginToken];
    //http://im.brc.com.cn/BrcDataService/BRC5-22/index.html#/notCardCertificateBill?a=1&processDefinitionKey=notCardCertificate&procUnitId=Approve&catalogId=process&taskKindId=task&procInstId=155751902&procUnitHandlerId=2860543957&bizId=2860543492&isReadOnly=false&procInstEndTime=&taskStatusId=ready&bizCode=WDK17061911148&taskId=155756442&statusId=ready&name=审批未打卡证明单&url=attNotCardCertificateAction!showUpdate.job&access_token=4e28350c093e4035bbe16745e86ea6c8
    NSDictionary *dict = [LANGUANGAppViewControllerARC cutString:self.curUrlStr];
    
    NSString *httpPath = [NSString stringWithFormat:@"%@&timestamp=%@&md5key=%@&account=%@&bizId=%@&procUnitId=%@&access_token=%@&taskId=%@",urlString,curTime,md5Str,account,dict[@"bizId"],dict[@"procUnitId"],oaToken,dict[@"taskId"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:httpPath]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (data) {
            
            NSArray *respArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if (respArr != nil && respArr.count > 0) {
                NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                [LogUtil debug:[NSString stringWithFormat:@"%s 获取流程审批群组成员 == %@",__FUNCTION__,respDict]];
                NSString *status = [NSString stringWithFormat:@"%@",respDict[@"status"]];
                
//                [UserTipsUtil hideLoadingView];
                if ([status isEqualToString:@"100"]) {
       
                    NSArray *arr = respDict[@"data"];
                    if (arr.count == 2) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [UserTipsUtil hideLoadingView];
                            [UserTipsUtil showAlert:@"审批人员少于2人，不能创建审批群组"];
                            return ;
                            
                        });
                    }
                    NSMutableString *string = [NSMutableString string];
                    for (int i = 0 ; i < arr.count; i++) {
                        
                        NSDictionary *tempDict = arr[i];
                        [string appendFormat:@"%@#",tempDict[@"loginName"]];
                    }
                    NSString *tempStr;
                    if (string.length) {
                        
                         tempStr = [string substringToIndex:[string length] - 1];
                    }
                   
                    NSString *convTitle;
                    NSString *name = dict[@"name"];
                    if (name.length) {
                        
                        convTitle = name;
                        
                    }else if (self.title.length){
                        
                        convTitle = self.title;
                        
                    }else{
                        
                        convTitle = @"待办讨论";
                    }
                    
                    //tempStr = @"zhuxiaoli#shisuping";
                    NSArray *userCodesArray = [tempStr componentsSeparatedByString:@"#"];
                    NSSet *set = [NSSet setWithArray:userCodesArray];
                    NSArray *userArray = [set  allObjects];
                    NSString *groupID = [NSString stringWithFormat:@"666666%@",dict[@"bizId"]];
                    
                    OpenCtxUtil *openCtx = [OpenCtxUtil getUtil];
                    [openCtx LGcreateAndOpenConvWithEmpCodes:userArray andConvTitle:convTitle groupID:groupID andCompletionHandler:^(int result, UIViewController *talkSession) {
                        
                        if (result == createAndOpenConvResult_ok)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                [UserTipsUtil hideLoadingView];
                                [UserDefaults removeModifyGroupNameFlag:groupID];
                                [self.navigationController pushViewController:talkSession animated:YES];
                                [LogUtil debug:[NSString stringWithFormat:@"%s,审批群组创建成功 ID%@",__FUNCTION__,groupID]];
                                
                                 });
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
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
                                
                                
                                [UserTipsUtil hideLoadingView];
                                
                                [UserTipsUtil showAlert:tipsStr];
                            });
                        }
                    }];
                    
                }
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UserTipsUtil hideLoadingView];
                });
                [UserTipsUtil showAlert:@"获取流程审批群组成员失败"];
                [LogUtil debug:[NSString stringWithFormat:@"%s 获取流程审批群组成员失败 == %@",__FUNCTION__,connectionError]];

                
            }
        }
        
        
    }];
    
}

//-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
//    
//    NSDictionary *dic = [(NSHTTPURLResponse *)downloadTask.response allHeaderFields];
//    NSString *contentType = (NSString*)[dic objectForKey:@"Content-Type"];
//    NSString *contentDisposition = [dic objectForKey:@"Content-Disposition"];
//    NSLog(@"=== %@ : %@", contentType, contentDisposition);
//    
////    [downloadTask cancel];//最后记得取消自己建立的下载任务
//}

- (void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(nonnull NSURL *)location
{

//    downloadTask.response.suggestedFilename
    NSString *fileName = downloadTask.response.suggestedFilename;
    NSArray *temp=[fileName componentsSeparatedByString:@"."];

    if (temp.count >0) {
        
        fileName = [NSString stringWithFormat:@"123321.%@",temp[1]];
    }
    NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
    
    //6.2 剪切文件
    [[NSFileManager defaultManager]moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    NSLog(@"fullPath=====%@",fullPath);
    downloadUrl = fullPath;
    [downloadTask cancel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showNotification];
        
    });
    
}

- (void)showNotification{
    
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;
    _notification.titleText = @"文件下载完成";
    //    _notification.subtitleText = @"Do you want to download the update of this file?";
    _notification.image = [StringUtil getImageByResName:@"update"];
    _notification.topButtonText = @"打开";
    _notification.bottomButtonText = @"取消";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];    
    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                break;
                
            default:
                break;
        }
    }];
    
}

-(void)dropdownNotificationTopButtonTapped {
    
    //打开文件
//    openWebViewController *agent = [[openWebViewController alloc]init];
//    agent.urlstr = downloadUrl;
    
    LookFileViewController *agent = [[LookFileViewController alloc]init];
    agent.filePath = downloadUrl;
    
    [self.navigationController pushViewController:agent animated:YES];
    
    [_notification dismissWithGravityAnimation:YES];
    
}

-(void)dropdownNotificationBottomButtonTapped {
    
    //取消
    [_notification dismissWithGravityAnimation:YES];
}
// 是否能回退,左上角显示的返回按钮
- (BOOL)isCanBack
{
    if (webview) {
        return [webview canGoBack];
    }
    return NO;
}

//回到首页
- (void)backToRoot{
    UIViewController *target = nil;
    for (UIViewController * controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[LANGUANGAppViewControllerARC class]]){
            target = controller;
        }
    }
    if (target) {
        [[NotificationUtil getUtil]sendNotificationWithName:TAI_HE_REFRESH_PAGE andObject:nil andUserInfo:nil];
        [self.navigationController popToViewController:target animated:YES];
    }
}

@end
