//
//  APPListDetailViewController.m
//  eCloud
//
//  Created by Pain on 14-6-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPListDetailViewController.h"
#import "APPPlatformDOA.h"
#import "APPListModel.h"
#import "APPStateRecord.h"
#import "APPPermissionModel.h"
#import "APPConn.h"
#import "APPUtil.h"
#import "UIAdapterUtil.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "WebViewJavascriptBridge.h"
#import "eCloudDefine.h"
#import "eCloudDAO.h"

#import "UIWebViewWithPageTitle.h"
#import "specialChooseMemberViewController.h"


#import "personInfoViewController.h"
#import "conn.h"
#import "talkSessionViewController.h"
#import "APPPermissionModel.h"
#import "JSONKit.h"
#import "Emp.h"


#define JsStr @"var Ecloud = {}; (function initialize() { Ecloud.getUserInfo = function () { return '%@';};})(); "

@interface APPListDetailViewController (){
    specialChooseMemberViewController *chooseMember;
    
    APPPermissionModel *permissionModel;
    talkSessionViewController *talkSession;
    int maxGroupNum;
    conn *_conn;
}

@property WebViewJavascriptBridge* bridge;
@end


@implementation APPListDetailViewController
{
	BOOL isFirstLoad;
}
@synthesize customTitle;
@synthesize urlstr;
@synthesize fromtype;
@synthesize needUserInfo;
@synthesize curUrlStr;
@synthesize navigationType;
@synthesize dataArray;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAppID:(NSString *)_appid{
    self = [super init];
    if (self) {
        // Custom initialization
        appid = [[NSString alloc] initWithFormat:@"%@",_appid];
    }
    return self;
}

-(void)dealloc
{
    request.delegate = nil;
    request = nil;
    
    webview.delegate = nil;
    webview = nil;
    
    self.urlstr = nil;
    self.curUrlStr = nil;
    self.customTitle = nil;
    
    [appid release];
    appid = nil;
    
    [self.dataArray removeAllObjects];
    self.dataArray = nil;
    
    [permissionModel release];
    permissionModel = nil;

    [_bridge release];
    _bridge = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:js_choose_NOTIFICATION object:nil];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	isFirstLoad = YES;
	
    self.title = self.customTitle;
    
    self.view.backgroundColor=[UIColor colorWithRed:235/255.0 green:240/255.0 blue:244/255.0 alpha:1];
    
    [UIAdapterUtil processController:self];
    [UIAdapterUtil setLeftButtonItemWithTitle:nil andTarget:self andSelector:@selector(backButtonPressed:)];
	
    tipLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 280, 100)];
	tipLabel.numberOfLines = 0;
    tipLabel.backgroundColor=[UIColor clearColor];
    tipLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
	[tipLabel release];
    
	int tableH = 480-44-20;
	if(iPhone5)
		tableH = tableH + i5_h_diff;
	webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, tableH)];
    webview.scalesPageToFit = NO;
	webview.delegate=self;
	[self.view addSubview:webview];
    [webview release];
	
	NSString *strUrl = [[APPUtil getStandartUrlStr:self.urlstr] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:strUrl];
    
//    NSURL *url = [NSURL URLWithString:@"http://120.132.153.5/ExampleApp.html"];
    NSLog(@"url-----%@",url);
//    [self loadExamplePage:webview];
    
	[self loadURL:url];
    [self setupWebViewJavascriptBridge];

    //应用统计数据上报
    [self sendOneAPPStateRecordOfApp:appid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 返回按钮
-(void) backButtonPressed:(id) sender
{
    if (webview.isLoading)
    {
        [webview stopLoading];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 本地测试
- (void)loadExamplePage:(UIWebView*)webView {
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"newExampleApp" ofType:@"html"];
    
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
    [webView loadHTMLString:appHtml baseURL:baseURL];
}

#pragma mark - 设置WebViewJavascriptBridge
- (void)setupWebViewJavascriptBridge{
    //权限控制
    if (!permissionModel) {
        permissionModel = [[APPPermissionModel alloc] init];
    }
    
    APPListModel *appModel = [[APPPlatformDOA getDatabase] getAPPModelByAppid:appid];
    [permissionModel setPermission:appModel.permission];
//    [permissionModel setPermission:31];
    
    //回调消息中心
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(js_choose:) name:js_choose_NOTIFICATION object:nil];
    
    _conn = [conn getConn];
    maxGroupNum = _conn.maxGroupMember;
    
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webview webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取_bridge----");
    }];
    
    //获取通信录
    [_bridge registerHandler:@"openContacts" handler:^(id data, WVJBResponseCallback responseCallback){
        NSLog(@"openContacts called: %@", data);
    
         if ([permissionModel canOpenContactList]) {
             specialChooseMemberViewController *chooseMember=[[specialChooseMemberViewController alloc]init];
             chooseMember.typeTag=3;
             [self.navigationController pushViewController:chooseMember animated:YES];
             [chooseMember release];
         
         }else{
             //不允许访问通讯录
             [self showAlertViewWithTitle:@"无权限,不能打开通讯录"];
         }
        
        /*
        //允许访问通讯录
        specialChooseMemberViewController *chooseMember=[[specialChooseMemberViewController alloc]init];
        chooseMember.typeTag=3;
        [self.navigationController pushViewController:chooseMember animated:YES];
        [chooseMember release];
        
        responseCallback(@"true");
         */
    }];
    [self release];
    
    //发起会话
    [_bridge registerHandler:@"inviteChat" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"inviteChat called: %@", data);
        
        if ([permissionModel canInviteChat]) {
            BOOL selectContact = [[data objectForKey:@"selectContact"] boolValue];
            NSMutableArray *usercodesArr = [NSMutableArray arrayWithArray:[data objectForKey:@"usercodes"]];
            
            if (selectContact) {
                
                [[conn getConn]setAllEmpNotSelect];
                
                if(!self.dataArray){
                    self.dataArray  = [[NSMutableArray alloc] init];
                }
                
                if([self.dataArray count]){
                    [self.dataArray removeAllObjects];
                }
                
                NSString *user_code = _conn.user_code;
                for (NSString *usercodeStr in usercodesArr){
//                    update by shisp 暂时不把自己加进去
                    if (![usercodeStr isEqualToString:_conn.user_code])
                    {
//                        修改为从内存中获取，并且把状态设置为已选中
                        Emp *_emp = [[eCloudDAO getDatabase] getEmpFromMemoryByEmpCode:usercodeStr];
                        if (_emp) {
                            [self.dataArray addObject:_emp];
                            _emp.isSelected = YES;
                        }
                    }
                 }
//                update by shisp 暂时不把自己加进去
//                if (![usercodesArr containsObject:user_code]){
//                    Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:user_code];
//                    [self.dataArray addObject:_emp];
//                }
                
                //打开联系人界面
                specialChooseMemberViewController *chooseMember=[[specialChooseMemberViewController alloc]init];
                chooseMember.typeTag = 4;
                chooseMember.delegete = self;
                [self.navigationController pushViewController:chooseMember animated:YES];
                [chooseMember release];
                
            }else{
                //直接发起会话
                [self createConventWithUsercodesArr:usercodesArr];
            }
        }
        else{
            //不允许发起会话
            [self showAlertViewWithTitle:@"无权限,不能发起会话"];
        }
    }];
    [self release];
    
    //查看联系人信息
    [_bridge registerHandler:@"openContact" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"openContact called: %@", data);
        /*
         NSString *usercode = [data objectForKey:@"usercode"];
         NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];
         responseCallback([userinfoDic JSONString]);
         */
        if ([permissionModel canOpenContact]) {
            //跳转到联系人页面
            NSString *usercode = [data objectForKey:@"usercode"];
            NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];
            
            NSString *emp_id = [NSString stringWithFormat:@"%@",[userinfoDic objectForKey:@"emp_id"]];
            personInfoViewController *personInfo = [[personInfoViewController alloc] init];
            personInfo.emp = [[eCloudDAO getDatabase] getEmpInfo:emp_id];
            [self.navigationController pushViewController:personInfo animated:YES];
            [personInfo release];
        }
        else{
          [self showAlertViewWithTitle:@"无权限,不能查看用户资料"];
        }
    }];
    [self release];
    
    //状态感知
    [_bridge registerHandler:@"getUserStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"getUserStatus called: %@", data);
        if ([permissionModel canGetUserStatus]) {
            NSString *usercode = [data objectForKey:@"usercode"];
            NSDictionary *userinfoDic = [[eCloudDAO getDatabase] searchEmpInfoByUsercode:usercode];
            NSString *emp_status = [userinfoDic objectForKey:@"emp_status"];
            responseCallback(emp_status);
        }
        else{
            [self showAlertViewWithTitle:@"无权限,不能查看用户状态"];
        }
    }];
    [self release];
    
    //分享
    [_bridge registerHandler:@"share2wangxin" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"share2wangxin called: %@", data);
        
        if ([permissionModel canShare2wangxin]) {
            NSMutableDictionary *sharInfoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"content"],@"content",[data objectForKey:@"contenturl"],@"contenturl",[data objectForKey:@"messagetype"],@"messagetype", nil];
            responseCallback(@"share");
        }
        else{
            [self showAlertViewWithTitle:@"无权限,不能分享"];
        }
    }];
    [self release];
}

- (void)createConventWithUsercodesArr:(NSArray *)usercodesArr{
    //直接发起会话
    if (![usercodesArr count]) {
        return;
    }
    
    NSMutableArray *nowSelectedEmpArray = [[NSMutableArray alloc] init];
    NSString *user_code = _conn.user_code;
//    update by shisp 在这里只处理不是当前用户的数据
    for (NSString *usercodeStr in usercodesArr) {
        if (![usercodeStr isEqualToString:user_code]) {
            Emp *_emp = [[eCloudDAO getDatabase] getEmpInfoByUsercode:usercodeStr];
            [nowSelectedEmpArray addObject:_emp];
        }
    }
    if (nowSelectedEmpArray.count == 0) {
        return;
    }
    
    if(talkSession == nil)
        talkSession=[[talkSessionViewController alloc]init];
    
    if ([nowSelectedEmpArray count]==1){
        //创建单聊
        Emp *emp = [nowSelectedEmpArray objectAtIndex:0];
        talkSession.titleStr=emp.emp_name;
        talkSession.talkType=singleType;
        talkSession.fromType = 3;
        
        talkSession.convEmps = nowSelectedEmpArray;
        //如果是群聊，则不设置convId
        talkSession.convId = [NSString stringWithFormat:@"%d",emp.emp_id];
        talkSession.needUpdateTag = 1;
    }
    else
    {
//        把当前用户加到聊天成员里 update by shisp
        [nowSelectedEmpArray addObject:[[conn getConn]curUser]];
        
        //判断选中的人员数量
        if([nowSelectedEmpArray count] > maxGroupNum )
        {
            [self showGroupNumExceedAlert];
            return;
        }
        
        //创建多人会话
        talkSession.titleStr=@"多人会话";
        talkSession.talkType=mutiableType;
        talkSession.convId=nil;
        talkSession.fromType = 3;
        talkSession.convEmps = nowSelectedEmpArray;
        
        talkSession.needUpdateTag = 1;
    }
    //打开会话窗口
    [self.navigationController pushViewController:talkSession animated:YES];
}

-(void)showGroupNumExceedAlert
{
    //提醒用户选择人数已经超过最大值
	NSString *titlestr=[NSString stringWithFormat:@"群组的成员个数最多为%d个",maxGroupNum];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:titlestr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
}


- (void)showAlertViewWithTitle:(NSString *)_title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_title message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

#pragma mark - 获取通讯录数据回调消息中心
-(void)js_choose:(NSNotification *)notification
{
    [_bridge callHandler:@"openContactsHandler" data:[notification.object JSONString] responseCallback:^(id response) {
        NSLog(@"openContactsHandler responded: %@", response);
    }];
    
}

#pragma mark - WebView缓存加载
- (void)loadURL:(NSURL*)url
{
    request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(webPageFetchFailed:)];
    [request setDidFinishSelector:@selector(webPageFetchSucceeded:)];
    [request setDownloadCache:[ASIDownloadCache sharedCache]];
    [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setDownloadDestinationPath:[[ASIDownloadCache sharedCache] pathToStoreCachedResponseDataForRequest:request]];
    [self loadLoacalWebCacheWithRequest:request];
    [request startAsynchronous];
}

- (void)webPageFetchFailed:(ASIHTTPRequest *)theRequest
{
    NSLog(@"%@",[theRequest error]);
}

#pragma mark - 加载本地网页缓存
- (void)loadLoacalWebCacheWithRequest:(ASIHTTPRequest *)theRequest{
    NSString *response = [NSString stringWithContentsOfFile:[theRequest downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"response--------%@",response);
    
    if ([response length]) {
        [webview  loadHTMLString:response baseURL:[theRequest url]];
    }
    else {
        
        NSString *response = [NSString stringWithContentsOfFile:
                              [theRequest downloadDestinationPath] encoding:NSISO2022JPStringEncoding error:nil];
        if ([response length]) {
            [webview  loadHTMLString:response baseURL:[theRequest url]];
        }
    }
}

- (void)webPageFetchSucceeded:(ASIHTTPRequest *)theRequest
{
    NSString *response = [NSString stringWithContentsOfFile:[theRequest downloadDestinationPath] encoding:NSUTF8StringEncoding error:nil];

    if ([response length]) {
        [webview  loadHTMLString:response baseURL:[theRequest url]];
    }
    else {
        
        NSString *response = [NSString stringWithContentsOfFile:
                              [theRequest downloadDestinationPath] encoding:NSISO2022JPStringEncoding error:nil];
        if ([response length]) {
            [webview  loadHTMLString:response baseURL:[theRequest url]];
        }
        else{
            //网页请求
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:[theRequest url]];
            [webview loadRequest:requestObj];
        }
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)_navigationType
{
    //    NSLog(@"%s,%@,%d",__FUNCTION__,request.URL.absoluteString,navigationType);
    
	self.curUrlStr = request.URL.absoluteString;
    self.navigationType = _navigationType;
    
	conn *_conn = [conn getConn];
	if(self.needUserInfo &&  _conn.userEmail.length > 0 && _conn.userId.length > 0)
	{
		NSString *userInfoStr = [NSString stringWithFormat:@"%@:%@",_conn.userEmail,_conn.userId];
		NSString *js = [NSString stringWithFormat:JsStr,userInfoStr];
		[webView stringByEvaluatingJavaScriptFromString:js];
	}
	
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

-(void) webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	if(isFirstLoad)
	{
        webview.hidden = YES;
        tipLabel.hidden=NO;
		tipLabel.text=[StringUtil getLocalizableString:@"loading"];
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
}

-(void)displayWebView
{
	NSString *curWebViewUrl = webview.request.URL.absoluteString;
	NSLog(@"curWebViewUrl is %@, self.curUrlStr is %@",curWebViewUrl,self.curUrlStr);
	
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

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    /*
    if(self.customTitle)
    {
        self.title = self.customTitle;
    }
    else
    {
        self.title = [webview pageTitle];
    }
    */
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	isFirstLoad = NO;
	if(webview.hidden)
	{
		webview.hidden = NO;
	}
	tipLabel.hidden=YES;
}

- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //	if(!webview.hidden)
    //	{
    //		webview.hidden = YES;
    //	}
    //    tipLabel.hidden=NO;
    //    tipLabel.text=[NSString stringWithFormat:NSLocalizedString(@"load_error", @"加载失败"),error.domain,error.code];
}

#pragma mark - 发送应用统计数据
- (void)sendOneAPPStateRecordOfApp:(NSString *)_appid{
    APPStateRecord *appStateRec = [[APPPlatformDOA getDatabase] getLatestAPPStateRecordOfApp:_appid];
    if (appStateRec.recordid) {
        APPStateRecord *newAPPStateRec = [APPUtil getNewAPPStateRecordOfApp:_appid];
        if (NSOrderedDescending ==[newAPPStateRec.optime compare:appStateRec.optime]){
            //当前时间比记录时间大时统计
            [[conn getConn] sendOneAPPStateRecordOfApp:newAPPStateRec];
        }
    }
    else{
        //首次数据记录
        APPStateRecord *newAPPStateRec = [APPUtil getNewAPPStateRecordOfApp:_appid];
        [[conn getConn] sendOneAPPStateRecordOfApp:newAPPStateRec];
    }
}


@end


