
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>


#import "OpenCtxDefine.h"
#import "OpenCtxManager.h"

#import "LogUtil.h"
#import "eCloudDefine.h"
#import "eCloudConfig.h"
#import "IOSSystemDefine.h"
#import "StringUtil.h"
#import "ApplicationManager.h"
#import "ConvRecord.h"
#import "SSKeychain.h"
#import "UIAdapterUtil.h"

#import "AccessConn.h"
#import "TabbarUtil.h"
#import "UIAdapterUtil.h"

#import "NewMyViewControllerOfCustomTableview.h"

#import <AudioToolbox/AudioToolbox.h>
#import "eCloudDAO.h"
#import "conn.h"
#import "NewLoginViewController.h"

#import "ReceiptDAO.h"
#import "AdvanceQueryDAO.h"

#define auto_connect_time_interval (5)
#define conn_check_timer_interval (15)
#define sleep_interval (30)

#import "UIAdapterUtil.h"
#import "LanUtil.h"
#import "ImageUtil.h"

#import "ConnResult.h"
#import "eCloudNotification.h"

#import "UserDefaults.h"

#ifdef _LANGUANG_FLAG_
#import "LGLoginViewControllerArc.h"
#endif

#ifdef _GOME_FLAG_
#import "GOMELoginViewController.h"
#endif

#ifdef _XINHUA_FLAG_
#import "XINHUALoginViewControllerArc.h"
#endif

#ifdef _XIANGYUAN_FLAG_
#import "XIANGYUANLoginViewControllerARC.h"
#endif

#ifdef _BGY_FLAG_
#import "BGYLoginViewController.h"
#endif
#import "ForwardingRecentViewController.h"
#import "UIAdapterUtil.h"
#import "NotificationUtil.h"
#import "UserDefaults.h"
#import "GuideImageViewController.h"
#import "logger.h"
#import "JSONKit.h"
#import "ConvRecord.h"
#import "Conversation.h"
//#import "UMMobClick/MobClick.h"
#import "CrashLogger.h"

#ifdef _TAIHE_FLAG_
#import "TaiHeLoginViewController.h"
#endif

#ifdef _GOME_FLAG_
#import <UMSocialCore/UMSocialCore.h>
#import "GuideImageView.h"
#endif

#define SERVICE @"QMENADAEMNDLKZJVOIUDFADFFD"

#ifdef _LANGUANG_FLAG_
#import "RedpacketConfig.h"
#import <BizConfSDK/BizConfVideoSDK.h>
#import "WXApi.h"
#endif
//南航
#define BAIDU_MAP_APPKEY @"ll1XcdahFSQn7Vxf1DFxKi5zmzFIY2BL"
//龙湖
//#define BAIDU_MAP_APPKEY @"gDdTD90ZG78NDBsnDdtqyZXGvxbHibRP"

#ifdef _LANGUANG_FLAG_

@interface AppDelegate () <UNUserNotificationCenterDelegate,WXApiDelegate>

#else

@interface AppDelegate () <UNUserNotificationCenterDelegate>

#endif


@end

@implementation AppDelegate
{
	eCloudUser *userDb;
	eCloudDAO *db;
	NSTimer *autoConnTimer;
	NSTimer *connCheckTimer;
	BOOL hasAccount;
	BOOL isExit;
	
	UIWindow* noConnectWindow;
    // 是否点击了图片
    BOOL isTouchGuideImage;
}
//
//@synthesize needSelectContactTab;
//@synthesize needSelectMyTab;
//@synthesize needOpenAgent;
//@synthesize appInfo;

//@synthesize netType;
@synthesize rootType;
@synthesize window;
//@synthesize isNetworkOk = _isNetworkOk;
//@synthesize versionAlert;
//@synthesize lunchView;

//Add by toxicanty 15/06/04
//@synthesize fileLength = _fileLength;

- (void)dealloc
{
//    self.appInfo = nil;
    
	[navigation release];
	navigation = nil;
	
	[noConnectWindow release];
	noConnectWindow = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
//	[notificationObject release];
//	notificationObject = nil;
//	self.versionAlert = nil;
	self.window = nil;
//    [helperAlert release];
    [super dealloc];
}

/*
 *  Add by toxicanty 2015/06/04
 *  其他App中分享文件给App中的好友
 */
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio{
    
    //保存字典，判断从哪里启动龙信
    [UserDefaults setWhereStartFrom:[url absoluteString]];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s url is %@ sourceApp is %@ ",__FUNCTION__,[url absoluteString] ,sourceApplication]];
    
#ifdef _GOME_FLAG_
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        [LogUtil debug:[NSString stringWithFormat:@"%s gome call",__FUNCTION__]];
        
    }
#endif
    
    
    [UserDefaults saveUrlFromOtherApp:url];
    
    if (![UserDefaults userIsExit]) {
        [self openUrlFromOtherApp];
    }
    
#ifdef _LANGUANG_FLAG_
    
    return [WXApi handleOpenURL:url delegate:self];
    
#endif
    
    
    return YES;
}

//打开 从其它app 转发过来的文件
- (void)openUrlFromOtherApp
{
    NSURL *url = [UserDefaults getUrlFromOtherApp];
    if (url) {
        [UserDefaults saveUrlFromOtherApp:nil];
        
        NSString *encodeFilePath = [url absoluteString];
//        update by shisp 先对路径进行decode
        NSString *filePath = [encodeFilePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (url && [url isFileURL]) {
            
            NSData *fileData = [NSData dataWithContentsOfURL:url];
            
            if (fileData) {
                
                NSRange dotRange = [filePath rangeOfString:@"." options:NSBackwardsSearch];
                
                if (dotRange.length > 0) {
                    
                    NSRange fileNameRange = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
                    
                    if (fileNameRange.length > 0 && dotRange.location > fileNameRange.location) {
                        
                        NSString *fileName = [filePath substringWithRange: NSMakeRange(fileNameRange.location + 1, dotRange.location - fileNameRange.location - 1)];
                        
                        NSString *ext = [filePath substringFromIndex:dotRange.location + 1];
                        
                        //                    NSLog(@"file name is %@ ext is %@",fileName,ext);
                        
                        NSString *fullFileName = [filePath substringFromIndex:fileNameRange.location + 1];
                        
                        ConvRecord *newRecord = [[[ConvRecord alloc]init]autorelease];
                        newRecord.msg_body = @"FromOtherApp";
                        newRecord.file_name = fullFileName;
                        
                        newRecord.file_size = [NSString stringWithFormat:@"%lu",(unsigned long)fileData.length];
                        
                        //                    NSLog(@"file_size is %@",newRecord.file_size);
                        
                        // 其他必要字段
                        newRecord.msg_type = type_file;
                        newRecord.send_flag = send_upload_waiting;
                        
                        NSString *savePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.%@",fileName,newRecord.msg_body,ext]];
                        
                        //                    NSLog(@"savePath is %@",savePath);
                        
                        BOOL success = [fileData writeToFile:savePath atomically:YES];
                        
                        if (success) {
                            
                            ForwardingRecentViewController *forwarding = [[ForwardingRecentViewController alloc]init];
                            forwarding.isComeFromFileAssistant = YES;
                            forwarding.forwardRecordsArray = [NSArray arrayWithObject:newRecord];
                            
                            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:forwarding];
                            //                        nav.navigationBar.tintColor = [UIColor blackColor];
                            
                            if (self.window.rootViewController)
                            {
                                [self.window.rootViewController presentModalViewController:nav animated:YES];
                            }
                            
                            [forwarding release];
                            [nav release];
                        }
                    }
                }
            }
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [LogUtil debug:[NSString stringWithFormat:@"didFinishLaunchingWithOptions----%s",__FUNCTION__]];
// 	logger_setLogPath([[StringUtil getLogFilePath] cStringUsingEncoding:NSUTF8StringEncoding]);
//    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    
    // 崩溃日志的处理
    // 友盟和自己写的异常处理类不能同时使用
//#ifdef _TAIHE_FLAG_
    // 将崩溃日志保存到沙盒中
    [CrashLogger initCrashLogs];
//#else
//    //    友盟统计SDK
//    NSString *UMKey = [StringUtil getUMSdkKey];
//    UMConfigInstance.appKey = UMKey;
//    [MobClick startWithConfigure:UMConfigInstance];
//#endif
    
//    [UserDefaults setWhereStartFrom:nil];
    
//    独立版本 被禁用时 被踢时需要提示
    [ApplicationManager getManager].needShowAlertWhenUserDisable = YES;
    //    设置为独立版本
    [[ApplicationManager getManager]setAppType:independent_enterprise_type];

    [[ApplicationManager getManager]callWhenAppLaunch];

//    国美生产 内网
//    [[OpenCtxManager getManager]initServer:@"10.124.26.25" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"10.124.26.25" andPort:8080 andServerPath:@"/"];

//    国美测试
//    [[OpenCtxManager getManager]initServer:@"119.254.61.14" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"119.254.61.14" andPort:8080 andServerPath:@"/"];
//    [[OpenCtxManager getManager]initOtherServer:@"119.254.61.14" andPort:8080];

//    国美生产
//    [[OpenCtxManager getManager]initServer:@"imweb.corp.gome.com.cn" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"imweb.corp.gome.com.cn" andPort:8080 andServerPath:@"/"];
//    [[OpenCtxManager getManager]initOtherServer:@"imweb.corp.gome.com.cn" andPort:8080];
//
    
    
    
    
    // 新华测试  58.60.231.2  42168       172.16.7.84  22
//    [[OpenCtxManager getManager]initServer:@"172.16.7.84" andPort:22];
//    [[OpenCtxManager getManager]initFileServer:@"172.16.7.84" andPort:3306 andServerPath:@"/"];
//    115.159.153.235
//    [[OpenCtxManager getManager]initServer:@"115.159.153.235" andPort:9002];
    
    
////    泰和生产
//    [[OpenCtxManager getManager]initServer:@"im.tahoecn.com" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"im.tahoecn.com" andPort:8080 andServerPath:@"/"];
//    [[OpenCtxManager getManager]initOtherServer:@"im.tahoecn.com" andPort:8080];

    
//    [[OpenCtxManager getManager]initServer:@"ctx.wanda.cn" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"ctx.wanda.cn" andPort:8080 andServerPath:@"/"];
//    [[OpenCtxManager getManager]initOtherServer:@"ctx.wanda.cn" andPort:8090];
    
//    正式生产 测试地址
//    125.254.153.22
//    [[OpenCtxManager getManager]initServer:@"125.254.153.22" andPort:9002];
//    [[OpenCtxManager getManager]initFileServer:@"125.254.153.22" andPort:8080 andServerPath:@"/"];
//    [[OpenCtxManager getManager]initOtherServer:@"125.254.153.22" andPort:8080];
//
	[self addNoConnectView];

	[self initRootView:launchOptions];
    
    
//    if (launchOptions)
//    {
//        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        [self enterAppByClickNotification:userInfo];
//    }

//	检查是否允许推送
    [self checkIsNeedToSetNotice];
//    [self performSelector:@selector(checkIsNeedToSetNotice) withObject:nil afterDelay:1];

//	[self lauchOptions];

//	[[ApplicationManager getManager] setBackgroundHandler];
    
    
//    _mapManager = [[BMKMapManager alloc]init];
//    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
//    NSString *mapKey = [StringUtil getBaiduMapKey];
//    if (!mapKey) {
//        mapKey = BAIDU_MAP_APPKEY;
//    }
//    
//    BOOL ret = [_mapManager start:mapKey  generalDelegate:self];
//    if (!ret) {
//        NSLog(@"manager start failed!");
//    }
    
    
    
#ifdef _GOME_FLAG_
    // 添加导航页
    if ([UIAdapterUtil isGOMEApp] && ![[NSUserDefaults standardUserDefaults] objectForKey:GUIDE_IMAGE_KEY])
    {
        GuideImageView *guideView = [[[GuideImageView alloc] initWithImages:@[@"1.gif", @"2.png", @"3.png", @"4.png"]] autorelease];
        guideView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.window addSubview:guideView];
    }
#endif

#ifdef _LANGUANG_FLAG_
    /** 红包初始化sdk */
    [RedpacketConfig sharedConfig];
    
    //BOOL isAuthorized = [[BizConfVideoSDK sharedSDK] isAuthorized];
    
    /** 会议sdk认证 */
//    [[BizConfVideoSDK sharedSDK]authSdk:@"9999" withKey:@"05cb105a9dc984f4a0991ecabecdace4" withTarget:self result:^(BizSDKAuthError auth) {
//        
//        //通过auth判断验证结果
//        if (auth == BizSDKAuthError_Success) {
//            
//            [LogUtil debug:[NSString stringWithFormat:@"会议认证通过%s",__FUNCTION__]];
//        }else{
//            
//            [LogUtil debug:[NSString stringWithFormat:@"会议认证失败 === %u %s",auth,__FUNCTION__]];
//        }
//        
//    }];
    
    [[BizConfVideoSDK sharedSDK]authSdk:@"9999" withKey:@"05cb105a9dc984f4a0991ecabecdace4" withTarget:self resultWithDetail:^(BizSDKAuthError authErrorCode, NSURLResponse *response, NSError *error)  {
       
        /** 通过auth判断验证结果 */
        if (authErrorCode == BizSDKAuthError_Success) {
            
            [LogUtil debug:[NSString stringWithFormat:@"会议认证通过%s",__FUNCTION__]];
        }else{
            
            [LogUtil debug:[NSString stringWithFormat:@"会议认证失败 === %u %s",authErrorCode,__FUNCTION__]];
        }
    }];
    
    /** 向微信注册 */
    [WXApi registerApp:@"wx2962ea2727d8db5d" enableMTA:YES];
#endif
    
#ifdef _XIANGYUAN_FLAG_
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUserAgent = [userAgent stringByAppendingString:@"9bd3a8274e49e5fe@sxit_im_ua"];//自定义需要拼接的字符串
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];

#endif
    return YES;
}

#ifdef _LANGUANG_FLAG_
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)option
{

    return [WXApi handleOpenURL:url delegate:self];
}
#endif

#ifdef _LANGUANG_FLAG_
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return [WXApi handleOpenURL:url delegate:self];

}
#endif

#ifdef _LANGUANG_FLAG_
-(void) onResp:(BaseResp*)resp{
    
//    NSString *str = [NSString stringWithFormat:@"%d",resp.errCode];
//    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"微信返回结果" message:str delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
//    [alertview show];
}
#endif
//-(void)setBackgroundHandler
//{
//	
//	BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//		[LogUtil debug:@"600秒后开启background task"];
//		[self backgroundHandler];
//	}];
//	
//    if (backgroundAccepted)
//    {
//        NSLog(@"backgrounding accepted");
//    }
//}

//-(void)getAccountProperty
//{
//	//	获取保存的用户名和密码
////	NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
////    NSString* username=[accountDefaults objectForKey:@"username"];
////    NSString* password=[accountDefaults objectForKey:@"password"];
////	NSString *userId = [accountDefaults objectForKey:@"user_id"];
//    
//    NSString *username = nil;
//    NSString *password = nil;
//    username = [UserDefaults getUserAccount];
//    password = [UserDefaults getUserPassword];
//    
//    isExit = [UserDefaults userIsExit];
//
//	hasAccount = NO;
//	
//	if(username && username.length > 0 && password && password.length > 0 )//&& userId && userId.length > 0
//	{
//		_conn.userEmail = username;
//		_conn.userPasswd = password;
//		
//        NSString *userId = nil;
//        NSDictionary *dic = [userDb searchUserByMail:username andPasswd:password];
//        if (dic) {
//            userId = [StringUtil getStringValue:[[dic valueForKey:user_id]intValue]];
//        }
//
////       如果根据用户名和密码查到了用户id，那么打开数据库
//        if (userId)
//        {
//            _conn.userId = userId;
//            
//            if(db.lastUserId == nil || db.lastUserId.intValue != _conn.userId.intValue)
//            {
//                [db initDatabase:_conn.userId];
//            }
//        }
//		
//		hasAccount = YES;
//	}
//}
- (void)initRootView:(NSDictionary *)dict
{
    [LogUtil debug:[NSString stringWithFormat:@"initRootView----%s",__FUNCTION__]];

    [UIAdapterUtil setStatusBar];
    [UIAdapterUtil customNavigationBar];
    [UIAdapterUtil customSearchBar];
    [UIAdapterUtil customTabBar];
    
    if ([UIAdapterUtil isGOMEApp])
    {
#ifdef _GOME_FLAG_
        GOMELoginViewController *loginController = [[GOMELoginViewController alloc]initWithNibName:@"GOMELoginViewController" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
#endif
    }
#ifdef _TAIHE_FLAG_
    else if([UIAdapterUtil isTAIHEApp]){
        TaiHeLoginViewController *loginController = [[TaiHeLoginViewController alloc]initWithNibName:@"TaiHeLoginViewController" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
    
#ifdef _XINHUA_FLAG_
    else if(1) {
        XINHUALoginViewControllerArc *loginController = [[XINHUALoginViewControllerArc alloc]initWithNibName:@"XINHUALoginViewControllerArc" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    else if(1)
    {
        LGLoginViewControllerArc *loginController = [[LGLoginViewControllerArc alloc]initWithNibName:@"LGLoginViewControllerArc" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif

#ifdef _XIANGYUAN_FLAG_
    else if(1)
    {
        XIANGYUANLoginViewControllerARC *loginController = [[XIANGYUANLoginViewControllerARC alloc]initWithNibName:@"XIANGYUANLoginViewControllerARC" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
#ifdef _BGY_FLAG_
    else if (1)
    {
        BGYLoginViewController *loginController = [[BGYLoginViewController alloc]initWithNibName:@"BGYLoginViewController" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
    
#endif
    else
    {
        NewLoginViewController *loginController = [[NewLoginViewController alloc]init];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }

    
	self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window addSubview:navigation.view];
	[self.window setBackgroundColor:[UIColor whiteColor]];
    isTouchGuideImage = NO;
    [LogUtil debug:[NSString stringWithFormat:@"supportGuidePages----%d",[eCloudConfig getConfig].supportGuidePages]];
    
    // 定制化加载广告页 yanlei
    NSString *status = [UserDefaults getGuideImageStatus];

    if ([eCloudConfig getConfig].supportGuidePages && dict == nil && [status isEqualToString:@"1"]) {
        NSString *guideImageName = [UserDefaults getGuideImageName];
        NSString *guideImageSuffix = [UserDefaults getGuideImageSuffix];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSArray *imageArr = [user objectForKey:@"imageNameArray"];
        [LogUtil debug:[NSString stringWithFormat:@"guideImageName--before--%@",guideImageName]];
        if (imageArr) {
            [LogUtil debug:[NSString stringWithFormat:@"guideImageName--after--%@",guideImageName]];

            
            GuideImageViewController *imageViewController = [[[GuideImageViewController alloc]init]autorelease];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:imageViewController];
            
            //            根据手机进行判断 使用哪张欢迎页
            NSString *guideImageNameStr = [NSString stringWithFormat:@"%@.%@",guideImageName,guideImageSuffix];
            imageViewController.landscapeString = [NSString stringWithFormat:@"%@_ipad.%@",guideImageName,guideImageSuffix];
            imageViewController.VerticalString = [NSString stringWithFormat:@"%@_ipad_portrait.%@",guideImageName,guideImageSuffix];
            if (IS_IPHONE) {
                if (IS_IPHONE_6P) {
                    guideImageNameStr = [NSString stringWithFormat:@"%@@3x.%@",guideImageName,guideImageSuffix];
                }else if (IS_IPHONE_6){
                    guideImageNameStr = [NSString stringWithFormat:@"%@@2x.%@",guideImageName,guideImageSuffix];
                }else if (IS_IPHONE_5){
                    guideImageNameStr = [NSString stringWithFormat:@"%@-568h@2x.%@",guideImageName,guideImageSuffix];
                }
            }else{
                //                默认竖屏 需要判断当前是否横屏
                if (SCREEN_WIDTH > SCREEN_HEIGHT) {
                    guideImageNameStr = [NSString stringWithFormat:@"%@_ipad.%@",guideImageName,guideImageSuffix];
                }else{
                    guideImageNameStr = [NSString stringWithFormat:@"%@_ipad_portrait.%@",guideImageName,guideImageSuffix];
                }
            }
            
            for (int i = 0; i < imageArr.count; i ++) {
                
            
            NSString *guideImagePath = [[StringUtil newRcvFilePath]stringByAppendingPathComponent:imageArr[i]];
            UIImage *_image = [UIImage imageWithContentsOfFile:guideImagePath];
            
            if (!_image) {
                [UserDefaults saveGuideImageName:@""];
                [LogUtil debug:@"需要重新下载欢迎页"];
                [self gotoRootViewCtrl];
                [self.window makeKeyAndVisible];
                return;
            }

            if ([guideImageSuffix isEqualToString:@"gif"]) {
                
                imageViewController.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                imageViewController.guideImageView.hidden = YES;
                [imageViewController.webView setScalesPageToFit:YES];
                [imageViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:guideImagePath]]];
            }else{
                
                imageViewController.guideImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                UIImage *_image = [UIImage imageWithContentsOfFile:guideImagePath];
                [LogUtil debug:[NSString stringWithFormat:@"%s guidpath is %@ guideimage is %@",__FUNCTION__,guideImagePath,_image]];
                imageViewController.guideImageView.image = _image;
                imageViewController.guideImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGestureRecoginizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchGuideImageAction)];
                [imageViewController.guideImageView addGestureRecognizer:tapGestureRecoginizer];
            }
            
            self.window.rootViewController = nav;
            
//            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(removeGuidePage) userInfo:nil repeats:NO];
        }
        
        }else{
            [LogUtil debug:[NSString stringWithFormat:@"guideImageName--else--%@",guideImageName]];
            [self gotoRootViewCtrl];
        }
        [self.window makeKeyAndVisible];
    }else{
        // by toxicanty 15/06/07
        [LogUtil debug:@"guideImageName--else else--%@"];
        [self gotoRootViewCtrl];
        [self.window makeKeyAndVisible];
    }
    
    
    
}

- (void)gotoRootViewCtrl{
    if ([UIAdapterUtil isGOMEApp])
    {
#ifdef _GOME_FLAG_
        GOMELoginViewController *loginController = [[GOMELoginViewController alloc]init];
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        [loginController release];
#endif

    }
#ifdef _TAIHE_FLAG_
    else if([UIAdapterUtil isTAIHEApp]){
        TaiHeLoginViewController *loginController = [[TaiHeLoginViewController alloc]initWithNibName:@"TaiHeLoginViewController" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
    
#ifdef _XINHUA_FLAG_
    else if(1){
        XINHUALoginViewControllerArc *loginController = [[XINHUALoginViewControllerArc alloc]initWithNibName:@"XINHUALoginViewControllerArc" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    else if(1){
        LGLoginViewControllerArc *loginController = [[LGLoginViewControllerArc alloc]initWithNibName:@"LGLoginViewControllerArc" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif

#ifdef _XIANGYUAN_FLAG_
    else if(1)
    {
        XIANGYUANLoginViewControllerARC *loginController = [[XIANGYUANLoginViewControllerARC alloc]initWithNibName:@"XIANGYUANLoginViewControllerARC" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
#endif
#ifdef _BGY_FLAG_
    else if (1)
    {
        BGYLoginViewController *loginController = [[BGYLoginViewController alloc]initWithNibName:@"BGYLoginViewController" bundle:nil];
        
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        
        [loginController release];
    }
    
#endif
    else
    {
        NewLoginViewController *loginController = [[NewLoginViewController alloc]init];
        navigation = [[UINavigationController alloc]initWithRootViewController:loginController];
        [loginController release];
    }
    
    [UIView transitionWithView:[[UIApplication sharedApplication].delegate window]
                      duration:0.6
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState=[UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[[UIApplication sharedApplication].delegate window] setRootViewController:navigation];
                        [UIView setAnimationsEnabled:oldState];
                        [[ApplicationManager getManager] getAccountProperty];
                        if([ApplicationManager getManager].hasAccount && ![ApplicationManager getManager].isExit)
                        {
                                _NewLoginViewController->goToMainView(self);
                                
                                [navigation release];
                                navigation = nil;
                            
                        }
                    }
                    completion:NULL];
//    self.window.rootViewController = navigation;
}
-(void)removeGuidePage
{
    // 将
    if (!isTouchGuideImage) {
        [self gotoRootViewCtrl];
    }
    
}

- (void) touchGuideImageAction{
    isTouchGuideImage = YES;
    [self gotoRootViewCtrl];
}

//-(void)lauchOptions
//{
//	//判断程序是不是由推送服务完成的
//	//    if (launchOptions) {
//	//        NSDictionary* pushNotificationKey = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//	//        if (pushNotificationKey) {
//	//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"推送通知"
//	//                                                           message:@"这是通过推送窗口启动的程序，你可以在这里处理推送内容"
//	//                                                          delegate:nil
//	//                                                 cancelButtonTitle:@"知道了"
//	//                                                 otherButtonTitles:nil, nil];
//	//            [alert show];
//	//            [alert release];
//	//        }
//	//    }
//}

//-(void)initNetWork
//{
//    [[ApplicationManager getManager]initNetWork];
//}

-(void)addNoConnectView
{
	//	没有网络的情况下，显示网络未链接
    CGFloat screenW = [UIAdapterUtil getDeviceMainScreenWidth];
    CGRect frame = {{0, 0}, {5, 20}};
     noConnectWindow = [[UIWindow alloc] initWithFrame:frame];
	
    [noConnectWindow setBackgroundColor:[UIColor clearColor]];
    [noConnectWindow setWindowLevel:UIWindowLevelStatusBar];
	
    CGFloat tiplabelX = screenW * 0.5 + 30;
    frame = CGRectMake(tiplabelX, 0, 60, 20);
    tiplabel=[[UILabel alloc]initWithFrame:frame];
    tiplabel.hidden=YES;
    tiplabel.backgroundColor=[UIColor clearColor];
    tiplabel.text=@"网络未连接";
    tiplabel.font=[UIFont systemFontOfSize:12];
    tiplabel.textColor=[UIColor whiteColor];
	
    [noConnectWindow addSubview:tiplabel];
	[tiplabel release];
    
    [noConnectWindow setRootViewController:[UIViewController new]];
    [noConnectWindow makeKeyAndVisible];
}

//-(void)addNotification
//{
//    增加处理 被移除 出群的通知
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processConv:) name:CONVERSATION_NOTIFICATION object:nil];

//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarChange:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
	//	接收 网络变化通知 广播通知
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(reachabilityChanged:)
//												 name: kReachabilityChangedNotification
//											   object: nil];
	
//    [[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(showBroadcastMessage:)
//												 name: BROADCAST_NOTIFICATION
//											   object: nil];
	//	这是什么通知？？？
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(recvieFileTip:)
//												 name: RECEIVE_FILE_NOTIFICATION
//											   object: nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(noctiveOFFLINE:)
//												 name: @"noctiveOFFLINE"
//											   object: nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDisable:) name:USER_DISABLE_NOTIFICATION object:nil];

//}
//
//- (void)userDisable:(NSNotification *)notification
//{
//    ConnResult *result = [[ConnResult alloc]init];
//    result.resultCode = RESULT_FORBIDDENUSER;
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[result getResultMsg]  delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
//    [alert show];
//    [alert release];
//    [result release];
//}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif
{
    NSDictionary * dic=notif.userInfo;
    [LogUtil debug:[NSString stringWithFormat:@"%s user info is %@",__FUNCTION__,[dic description]]];

    [[ApplicationManager getManager] enterAppByClickNotification:dic];
}

-(void)checkIsNeedToSetNotice
{
    //    UserInfo* userinfo= [userDb searchUserObjectByUserid:_conn.userId];
    //	if(userinfo)
    //	{
    ////		[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    //		if (userinfo.noticeFlag==0)
    //		{
    /** 注册推送通知功能, */
    
    if(IOS8_OR_LATER)
    {
        
        if (IOS10_OR_LATER) {
            //注册本地推送
            // 使用 UNUserNotificationCenter 来管理通知
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            
            //监听回调事件
            
            center.delegate = self;
            
            //iOS 10 使用以下方法注册，才能得到授权
            
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 NSLog(@"%@",(granted?@"yes":@"no"));
            }];            
            
            //获取当前的通知设置，UNNotificationSettings 是只读对象，不能直接修改，只能通过以下方法获取
            
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                
                NSLog(@"ok");
                
            }];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
            
        }else{
            
            //1.创建消息上面要添加的动作(按钮的形式显示出来)
            UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
            action.identifier = @"action";//按钮的标示
            action.title=@"Accept";//按钮的标题
            action.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
            //    action.authenticationRequired = YES;
            //    action.destructive = YES;
            
            UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];
            action2.identifier = @"action2";
            action2.title=@"Reject";
            action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
            action.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
            action.destructive = YES;
            
            //2.创建动作(按钮)的类别集合
            UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
            categorys.identifier = @"alert";//这组动作的唯一标示,推送通知的时候也是根据这个来区分
            [categorys setActions:@[action,action2] forContext:(UIUserNotificationActionContextMinimal)];
            
            //3.创建UIUserNotificationSettings，并设置消息的显示类类型
            UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:[NSSet setWithObjects:categorys, nil]];
            [[UIApplication sharedApplication] registerUserNotificationSettings:notiSettings];
        }
        
    }
    //    {
    //        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
    //                                                                                             |UIRemoteNotificationTypeSound
    //                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
    //
    //        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    //
    //    }
    
    else
    {
        //        [LogUtil debug:[NSString stringWithFormat:@"---------------注册推送通知功能"]];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    //		}else
    //		{
    //			//注消操作
    //			//        [LogUtil debug:[NSString stringWithFormat:@"---------------注消操作"]];
    //			[[UIApplication sharedApplication] unregisterForRemoteNotifications];
    //		}
    
    //	}
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* token = [NSString stringWithFormat:@"%@",deviceToken];
	[LogUtil debug:[NSString stringWithFormat:@"%s，获取token:%@",__FUNCTION__,token]];
    
//     [LogUtil debug:[NSString stringWithFormat:@"apns -> 生成的完整的devToken:%@", token]];
 
	NSString* deviceTokenStr = [[token substringWithRange:NSMakeRange(0, 72)] substringWithRange:NSMakeRange(1, 71)];
    NSString* device_Token=[deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    _conn.deviceToken=device_Token;
	
    [LogUtil debug:[NSString stringWithFormat:@"apns -> 生成的devToken:%@", device_Token]];
    
     [UserDefaults setDeviceToken:device_Token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
	[LogUtil debug:[NSString stringWithFormat:@"%s,err is %@",__FUNCTION__,err.domain]];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	[LogUtil debug:[NSString stringWithFormat:@"%s userinfo is %@",__FUNCTION__,[userInfo description]]];
    
    [[ApplicationManager getManager] enterAppByClickNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    
    [LogUtil debug:[NSString stringWithFormat:@"%s userinfo is %@",__FUNCTION__,[userInfo description]]];
    
    [[ApplicationManager getManager] enterAppByClickNotification:userInfo];
}

//
//-(void)showBroadcastMessage:(NSNotification *)note
//{
//    eCloudNotification	*cmd	 =	(eCloudNotification *)[note object];
//    NSDictionary *dic=cmd.info;
//	[LogUtil debug:[NSString stringWithFormat:@"%s,%@",__FUNCTION__,[dic description]]];
//	
////dictionaryWithObjectsAndKeys:SenderID,@"sender_id",RecverID,@"recver_id",MsgID,@"msg_id",SendTime,@"sendtime",MsgLen,@"msglen",Titile,@"asz_titile",Message,@"asz_message", nil
//   
//	NSString *Titile=[dic objectForKey:@"asz_titile"];
//    NSString *Message=[dic objectForKey:@"asz_message"];
//    NSString *SenderId=[dic objectForKey:@"sender_id"];
//  //  NSString *SendTime=[dic objectForKey:@"sendtime"];
//    NSString *sendtimeStr=[StringUtil getDisplayTime:[dic objectForKey:@"sendtime"]];
//    Emp *emp= [db getEmpInfo:SenderId];
//    NSString *sendName=emp.emp_name;
//   
//    if (broadcastAlert!=nil) {
//        [broadcastAlert dismissWithClickedButtonIndex:1 animated:NO];
//        [broadcastAlert release];
//    }
//        broadcastAlert=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        if (IOS7_OR_LATER) {
//            
//        }
//        else
//        {
//            for(UIView *subview in broadcastAlert.subviews)
//            {
//                if([[subview class] isSubclassOfClass:[UILabel class]])
//                {
//                    UILabel *label = (UILabel*)subview;
//                    label.textAlignment = UITextAlignmentLeft;
//                }
//            }
//        }
//    
//
//    NSString *title_str=[NSString stringWithFormat:@"发送人:%@\n标题:%@",sendName,Titile];
//    NSString *msg_str=[NSString stringWithFormat:@"发送时间:%@\n内容:\n%@",sendtimeStr,Message];
//    broadcastAlert.title=title_str;
//    broadcastAlert.message=msg_str;
//    [broadcastAlert show];
//}

//- (void)noctiveOFFLINE:(NSNotification *)note
//{
//    UIAlertView *offalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"Your_account_has_been_logged_elsewhere"] message:nil delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
//    [offalert show];
//	[offalert release];
//}

//- (void)recvieFileTip:(NSNotification *)note
//{
//    NSDictionary *dic=note.userInfo;
//     NSString *tipstr= [dic objectForKey:@"tipstr"];
//     [LogUtil debug:[NSString stringWithFormat:@"----tipstr----%@",tipstr]];
//     UIAlertView *revcieFileAlert=[[UIAlertView alloc]initWithTitle:@"接收文件提示" message:tipstr delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    revcieFileAlert.message=tipstr;
//    [revcieFileAlert show];
//	[revcieFileAlert release];
//}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[ApplicationManager getManager]callWhenAppWillEnterForground];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[ApplicationManager getManager]callWhenAppWillResignActive];
}
- (void)romoveGuideImageViewAction{
    UIImageView *guideTmpImageView = (UIImageView *)[[[UIApplication sharedApplication]keyWindow] viewWithTag:5521];
    
    [guideTmpImageView removeFromSuperview];
}
//
//- (void)saveRecentConvForSharing
//{
//    eCloudDAO *ecloud = [eCloudDAO getDatabase];
//    NSArray *convs = [ecloud getRecentConvForTransMsg];
//    
//    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:convs.count];
//    for (Conversation *conv in convs)
//    {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"conv_type"]  = @(conv.conv_type);
//        dic[@"conv_id"]    = conv.conv_id;
//        dic[@"conv_title"] = conv.conv_title;
//        dic[@"emp_id"]     = [NSString stringWithFormat:@"%d",conv.emp.emp_id];
//        // 保存头像
//        UIImage *emp_logo  = [ImageUtil getEmpLogo:conv.emp];
//        NSData *imageData  = UIImagePNGRepresentation(emp_logo);
//        dic[@"emp_logo"]   = imageData;
//        
//        [mArr addObject:dic];
//    }
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.longFor"];
//    [sharedDefaults setObject:mArr forKey:@"convs"];
//    conn *_conn = [conn getConn];
//    [sharedDefaults setObject:_conn.userId forKey:@"userID"];
//}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ApplicationManager getManager]callWhenAppEnterBackground];
}
//{
//    [LogUtil debug:[NSString stringWithFormat:@"applicationDidEnterBackground----%s",__FUNCTION__]];
// 
//    [[ApplicationManager getManager]callWhenAppEnterBackground];
//    
//    //保存最近联系人用于在相册或系统浏览器分享信息 选择联系人时用
//    [self saveRecentConvForSharing];
//    
//    // 定制化加载广告页 yanlei
////    if ([eCloudConfig getConfig].supportGuidePages) {
////        NSString *guideImageName = [UserDefaults getGuideImageName];
////        
////        if (guideImageName) {
////            UIImageView *guideTmpImageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
////            guideTmpImageView.tag = 5521;
////            
////            guideTmpImageView.image = [UIImage imageWithContentsOfFile:[[StringUtil getHomeDir]stringByAppendingPathComponent:[NSString stringWithFormat:@"receiveFile/%@.png",guideImageName]]];
////            guideTmpImageView.userInteractionEnabled = YES;
////            UITapGestureRecognizer *tapGestureRecoginizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(romoveGuideImageViewAction)];
////            [guideTmpImageView addGestureRecognizer:tapGestureRecoginizer];
////            
////            [[application keyWindow] addSubview:guideTmpImageView];
////        }
////    }
//	[self stopConnCheckTimer];
//	
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//
////	if(self.versionAlert && !self.versionAlert.hidden)
////	{
////        [self.versionAlert dismissWithClickedButtonIndex:0 animated:YES];
////        self.versionAlert = nil;
////	}
//
//	int count=[db getAllNumNotReadedMessge];
//	[UIApplication sharedApplication].applicationIconBadgeNumber = count;
//// 	
////	BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
////		[LogUtil debug:@"600秒后开启background task"];
////		[self backgroundHandler];
////	}];
////	
////    if (backgroundAccepted)
////    {
////        NSLog(@"backgrounding accepted");
////    }
////	
//    [self backgroundHandler];
//	
//	if([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground)
//	{
//		[_conn putUnreadMsgCountToServer];
//	}
//    
////    测试代码
////    [_conn performSelector:@selector(logout) withObject:nil afterDelay:5];
//    
//    
//    //进行后台任务
////    [application beginBackgroundTaskWithExpirationHandler:nil];
//}

//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//    // 定制化加载广告页 yanlei
////    if ([eCloudConfig getConfig].supportGuidePages) {
////        NSString *guideImageName = [UserDefaults getGuideImageName];
////        
////        if (guideImageName) {
////            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(romoveGuideImageViewAction) userInfo:nil repeats:NO];
////        }
////    }
//}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[ApplicationManager getManager]callWhenAppActive];
}

//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
// 
//    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
//    
////    self.needSelectMyTab = YES;
////    self.needOpenAgent = YES;
//
//	//	如果还没有下载完数据，那么发送通知，取消提示框
//	if([_conn isFirstGetUserDeptList])
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"组织架构还未下载完毕"]];
//		notificationObject.cmdId = first_load_org;
//		notificationName = ORG_NOTIFICATION;
//		[self notifyMessage:nil];
//	}
//
//	
//	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//
//	[self getAccountProperty];
//	if(!hasAccount)
//	{
//		[LogUtil debug:@"hasAccount is NO,return"];
//		return;
//	}
//	if(isExit)
//	{
//		[LogUtil debug:@"isExit is YES,return"];
//		return;		
//	}
//	
//	//	如果用户是在线状态
//	if(_conn.userStatus == status_online)
//	{
//        int ret = [_conn sendConnCheckCmd];
//		if(ret == 0)
//		{
//            [LogUtil debug:[NSString stringWithFormat:@"用户在线，发送checkTime指令看通讯是否正常"]];
//			[self startConnCheckTimer];
//			return;
//		}
//		else if(ret == 1)
//		{
//			[LogUtil debug:[NSString stringWithFormat:@"发送checkTime指令发送失败，自动重连"]];
//			[self connCheckTimeout];
//			return;
//		}
//	}
//	else
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"用户离线，自动登录"]];
//		if(_conn.connStatus == not_connect_type)
//		{
//			[NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];			
//		}
//	}
//    
//}
//-(void)autoLogin
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s，自动登录",__FUNCTION__]];
//
//	if([self needAutoConnect])
//	{
//		if(_conn.connStatus == normal_type || _conn.userStatus == status_online)
//		{
//			[LogUtil debug:@"用户在线,return"];
//			return;
//		}
//		
//		//	提示用户正在连接
//		notificationName = CONNECTING_NOTIFICATION;
//		[self notifyMessage:nil];
//		
//		if(_conn.connStatus == linking_type)
//		{
//			[LogUtil debug:@"current is connecting ,return"];
//			return;
//		}
//		
////        update by shisp 设置为正在连接
//        _conn.connStatus = linking_type;
//		[self loginAction];
//	}
//}
//-(void)loginAction
//{
//	if([_conn initConn])
//	{
//        if(_conn.forceUpdate || (_conn.hasNewVersion && [eCloudConfig getConfig].needShowAlertWhenOptionUpdate))
//        {
//            _conn.connStatus = not_connect_type;
//            notificationName = NO_CONNECT_NOTIFICATION;
//            [self notifyMessage:nil];
//            
//            if(self.versionAlert == nil)
//            {
//                [self performSelectorOnMainThread:@selector(showVersionAlert:) withObject:self waitUntilDone:YES];
//            }
//        }
//        else
//        {
// 			if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
//			{
////                update by shisp 设置未连接状态
//                _conn.connStatus = not_connect_type;
//
//				notificationName = NO_CONNECT_NOTIFICATION;
//				[self notifyMessage:nil];
//			}
//        }
//	}
//	else
//	{
//        //                update by shisp 设置未连接状态
//        _conn.connStatus = not_connect_type;
//
//		notificationName = NO_CONNECT_NOTIFICATION;
//		[self notifyMessage:nil];
//	}
//}

//- (void)showVersionAlert:(id)alertDelegate
//{
////    是强制升级或者有新版本
//    if (_conn.forceUpdate || _conn.hasNewVersion) {
//        NSString *updateInfo = [NSString stringWithFormat:@"%@%@",[StringUtil getAppName],[StringUtil getLocalizableString:@"has_new_version"]] ;
//        
//        if (_conn.forceUpdate) {
//            self.versionAlert =	[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:updateInfo delegate:alertDelegate cancelButtonTitle:nil otherButtonTitles:[StringUtil getLocalizableString:@"update_at_once"], nil];
//            self.versionAlert.tag = FORCE_UPDATE_ALERT_TAG;
//        }else{
//            self.versionAlert =	[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:updateInfo delegate:alertDelegate cancelButtonTitle:[StringUtil getLocalizableString:@"later"] otherButtonTitles:[StringUtil getLocalizableString:@"update_at_once"], nil];
//            self.versionAlert.tag = OPTION_UPDATE_ALERT_TAG;
//        }
//        [self.versionAlert show];
//    }
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == REMOVED_FROM_GROUP_TAG && buttonIndex == 0) {
//        [TabbarUtil backToRootContact];
//        return;
//    }
//    if (alertView.tag == FORCE_UPDATE_ALERT_TAG || (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 1 ))
//    {
//        _conn.connStatus = not_connect_type;
//        notificationName = NO_CONNECT_NOTIFICATION;
//        [self notifyMessage:nil];
//        
//        [LogUtil debug:[NSString stringWithFormat:@"强制升级 或者 可选升级，打开升级页面"]];
//        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_conn.updateUrl]];
//        if ([_conn.updateUrl hasPrefix:@"itms-services://"]) {
//            //            ios8下 用户选择安装新版本后，系统不会自动退出，所以
//            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
//        }
//    }
//    else if (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 0)
//    {
//        [LogUtil debug:[NSString stringWithFormat:@"可选升级，用户选择了以后再说，那么继续登录"]];
//        _conn.connStatus = linking_type;
//        if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
//        {
//            //                update by shisp 设置未连接状态
//            _conn.connStatus = not_connect_type;
//            notificationName = NO_CONNECT_NOTIFICATION;
//            [self notifyMessage:nil];
//        }
//    }
//    self.versionAlert = nil;
//}
//
//
//- (void)notifyMessage:(NSDictionary *)message
//{
//	[self performSelectorOnMainThread:@selector(sendNotificationMessage:)  withObject:message waitUntilDone:YES];
//}
//
//- (void)sendNotificationMessage:(NSDictionary *)message
//{
//	[[NSNotificationCenter defaultCenter ]postNotificationName:notificationName object:notificationObject userInfo:message];
//}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    /*
//    NSArray *accouts = [SSKeychain accountsForService:SERVICE];
//    for (NSDictionary *dic in accouts)
//    {
//        NSString *lastAccount = [dic objectForKey:@"acct"];
//        [SSKeychain deletePasswordForService:SERVICE account:lastAccount];
//    }
//    */
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//}
//
//- (void)willPresentAlertView:(UIAlertView *)alertView
//{
//    // 成功提示设置自定义Fream
////    if (alertView == broadcastAlert) {
////        [alertView setFrame:CGRectMake(20, 100, 280, 260)];
////        
////        for( UIView * view in alertView.subviews )
////            
////            if( [view isKindOfClass:[UIButton class]] )
////                { 
////                   view.frame = CGRectMake(10, 200, 260, 45);
////                }        
////        
////      }
//}

//启动重连timer
//-(void)startAutoConnTimer
//{
//	if([self needAutoConnect])
//	{
//		if(autoConnTimer)
//		{
//			[LogUtil debug:[NSString stringWithFormat:@"%s,timer已经启动 return",__FUNCTION__]];
//			return;
//		}
//		
//		if(_conn.connStatus == not_connect_type)
//		{
//			[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//			autoConnTimer = [NSTimer scheduledTimerWithTimeInterval:auto_connect_time_interval target:self selector:@selector(autoConn) userInfo:nil repeats:NO];
//		}
//	}
//}
//
//-(void)autoConn
//{
//	autoConnTimer = nil;
//	if(_conn.connStatus == not_connect_type)
//	{
//		[NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];
//	}
//}
//
////停止重连timer
//-(void)stopAutoConnTimer
//{
//	if(autoConnTimer && [autoConnTimer isValid])
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//		[autoConnTimer invalidate];
//	}
//	autoConnTimer = nil;
//}
//
//-(void)startConnCheckTimer
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//	connCheckTimer = [NSTimer scheduledTimerWithTimeInterval:conn_check_timer_interval target:self selector:@selector(connCheckTimeout) userInfo:nil repeats:NO];
//}
//-(void)connCheckTimeout
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//	connCheckTimer = nil;
//	
//	if(_conn.connStatus == linking_type)
//	{
//		[LogUtil debug:[NSString stringWithFormat:@"%s,isLinking return",__FUNCTION__]];
//		return;
//	}
//	_conn.userStatus = status_offline;
//	_conn.connStatus = not_connect_type;
//	
//	[NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];
//}
//
//-(void)stopConnCheckTimer
//{
//	[LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
//	if(connCheckTimer && [connCheckTimer isValid])
//	{
//		[connCheckTimer invalidate];
//	}
//	connCheckTimer = nil;
//}

//- (void)backgroundHandler
//{
//	UIApplication *app = [UIApplication sharedApplication];
//	
//	__block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        
////        判断下用户是否是在线，并且是就绪的状态，如果是则 调用logout方法
//        if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground && _conn.userStatus == status_online && _conn.connStatus == normal_type) {
//            [_conn logout:0];
//        }
//        
//		[LogUtil debug:@"结束backgroundTask"];
//		[app endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//	
//    // Start the long-running task
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//		[LogUtil debug:@"开启long-running task"];
//		int counter = 0;
////        while (1)
////		{
////			if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive)
////			{
////				[LogUtil debug:@"结束long-running task,原因是应用已经在前台运行"];
////				break;
////			}
////			counter = counter + sleep_interval;
////			[LogUtil debug:[NSString stringWithFormat:@"counter:%ld", counter]];
////			if(counter > 650)
////			{
////				[LogUtil debug:@"结束long-running task,原因是时间已经超过了600秒"];
////				break;
////			}
////            sleep(sleep_interval);
////		}
//    });
//}
//
//-(BOOL)needAutoConnect
//{
//    BOOL isExit = [UserDefaults userIsExit];
//    
////    update by shisp 不是强制升级
//	if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive && !_conn.isKick && !_conn.isDisable && !_conn.isInvalidPassword && [ApplicationManager getManager].isNetworkOk && !isExit && !_conn.forceUpdate && [AccessConn getConn].isUserExist)
//        
////        && !([eCloudConfig getConfig].needShowAlertWhenOptionUpdate && _conn.hasNewVersion)  只要有新版本，就可以自动重连
//	{
////        如果未处理的离线消息数量不是0，则不连接
//        conn *_conn = [conn getConn];
//        if (_conn.offlineMsgArray.count > 0) {
//            [LogUtil debug:@"未处理的离线消息数量大于0"];
//            return NO;
//        }
//        
//        if (self.versionAlert.visible && self.versionAlert.tag == OPTION_UPDATE_ALERT_TAG) {
//            [LogUtil debug:@"如果升级提示框是显示状态，并且是可选升级，那么不自动重连"];
//            return NO;
//        }
//		[LogUtil debug:[NSString stringWithFormat:@"%s,YES",__FUNCTION__]];
//		return YES;
//	}
//	[LogUtil debug:[NSString stringWithFormat:@"%s,NO",__FUNCTION__]];
//	return NO;
//}


#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

////用户点击通知启动应用或者进入应用
//- (void)enterAppByClickNotification:(NSDictionary *)userInfo
//{
//    [LogUtil debug:[NSString stringWithFormat:@"--%s userinfo is %@",__FUNCTION__,[userInfo description]]];
//    
//    self.needOpenAgent = NO;
//    self.needSelectContactTab = NO;
//    self.needSelectMyTab = NO;
//    
//    if (userInfo) {
//        if ([[userInfo objectForKey:KEY_NOTIFICATION_MSG_TYPE] intValue] == notification_agent_msg){
//            
//            if ([TabbarUtil getTabbarController])
//            {
//                [TabbarUtil saveStartAppInfo:userInfo];
//                [TabbarUtil showMyPage];
//                [TabbarUtil autoOpenAgentList];
//            }
//            else
//            {
//                self.appInfo = userInfo;
//                self.needSelectMyTab = YES;
//                self.needOpenAgent = YES;
//            }
//        }else{
//            if ([TabbarUtil getTabbarController]) {
//                [TabbarUtil showChatPage];
//            }
//            else
//            {
//                self.needSelectContactTab = YES;
//            }
//        }
//    }else
//    {
//        [LogUtil debug:@"远程代办通知userinfo为空"];
//    }
//}

//
//- (void)statusBarChange:(NSNotification *)notification
//{
////    NSDictionary *userInfo = notification.userInfo;
////    NSValue *value = [userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
////    
////    CGRect statusBarFrame;
////    [value getValue:&statusBarFrame];
//    
//    NSLog(@"%s %@",__FUNCTION__,NSStringFromCGRect([UIApplication sharedApplication].statusBarFrame));
//}

#pragma mark =====横竖屏======
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (IS_IPAD) {
        
        if ([UIAdapterUtil isTAIHEApp]) {
            
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else{
        if ([UIAdapterUtil isHongHuApp]) {
            
            if (_allowRotation == 1) {
                
                return UIInterfaceOrientationMaskAllButUpsideDown;
            }
        }else{
            return UIInterfaceOrientationMaskPortrait;
        }
        return UIInterfaceOrientationMaskPortrait;
    }
}
//
////龙湖轻应用支持横屏
//@implementation UINavigationController (Rotation)
//- (BOOL)shouldAutorotate
//{
//    NSLog(@"%s vc is %@",__FUNCTION__,[self.viewControllers lastObject]);
//    return NO;
//    
//    //    return [[self.viewControllers lastObject] shouldAutorotate];
//}
//
//
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
//}
//
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
//}
//
////如果被移出时，停留在这个讨论组界面，那么给出提示，然后回到到会话列表
//- (void)processConv:(NSNotification *)notification
//{
//    eCloudNotification *_notification = [notification object];
//    if (_notification) {
//        int cmdId = _notification.cmdId;
//        if (cmdId == removed_from_group) {
//            NSDictionary *dic = _notification.info;
//            NSString *grpId = [dic valueForKey:@"conv_id"];
//            [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:grpId];
//
//            if ([TabbarUtil needAlertWhenRemoveFromGroup:grpId]) {
//                if (IOS8_OR_LATER) {
//                    UIAlertController *_alert = [UIAlertController alertControllerWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"you_are_removed_from_this_group"] preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"I_know"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//                        [TabbarUtil backToRootContact];
//                    }];
//                    
//                    [_alert addAction:confirmAction];
//                    
//                    [UIAdapterUtil presentVC:_alert];
//                    
//                }else{
//                    
//                    UIAlertView *_alert = [[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"you_are_removed_from_this_group"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"I_know"] otherButtonTitles:nil, nil]autorelease];
//                    _alert.tag = REMOVED_FROM_GROUP_TAG;
//                    
//                    [_alert show];
//                }
//            }
//        }
//    }
//}
//
//- (void)setAppBadge
//{
//    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
//    
//    [LogUtil debug:[NSString stringWithFormat:@"%s badgeCount is %d",__FUNCTION__,badgeCount]];
//}


//#pragma mark 百度地图？
//- (void)onGetNetworkState:(int)iError
//{
//    if (0 == iError) {
//        NSLog(@"联网成功");
//    }
//    else{
//        NSLog(@"onGetNetworkState %d",iError);
//    }
//    
//}
//
//- (void)onGetPermissionState:(int)iError
//{
//    if (0 == iError) {
//        NSLog(@"授权成功");
//    }
//    else {
//        NSLog(@"onGetPermissionState %d",iError);
//    }
//}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    //1. 处理通知
    
    
    
    //2. 处理完成后条用 completionHandler ，用于指示在前台显示通知的形式
    
    completionHandler(UNNotificationPresentationOptionAlert);
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    //点击通知进入应用 NSLog(@"response:%@", response);
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [[ApplicationManager getManager] enterAppByClickNotification:userInfo];
}

//暂时没有使用到
- (void)registerNotification{
    /*
     identifier：行为标识符，用于调用代理方法时识别是哪种行为。
     title：行为名称。
     UIUserNotificationActivationMode：即行为是否打开APP。
     authenticationRequired：是否需要解锁。
     destructive：这个决定按钮显示颜色，YES的话按钮会是红色。
     behavior：点击按钮文字输入，是否弹出键盘
     */
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"策略1行为1" options:UNNotificationActionOptionForeground];
    /*iOS9实现方法
     UIMutableUserNotificationAction * action1 = [[UIMutableUserNotificationAction alloc] init];
     action1.identifier = @"action1";
     action1.title=@"策略1行为1";
     action1.activationMode = UIUserNotificationActivationModeForeground;
     action1.destructive = YES;
     */
    
    UNTextInputNotificationAction *action2 = [UNTextInputNotificationAction actionWithIdentifier:@"action2" title:@"策略1行为2" options:UNNotificationActionOptionDestructive textInputButtonTitle:@"textInputButtonTitle" textInputPlaceholder:@"textInputPlaceholder"];
    /*iOS9实现方法
     UIMutableUserNotificationAction * action2 = [[UIMutableUserNotificationAction alloc] init];
     action2.identifier = @"action2";
     action2.title=@"策略1行为2";
     action2.activationMode = UIUserNotificationActivationModeBackground;
     action2.authenticationRequired = NO;
     action2.destructive = NO;
     action2.behavior = UIUserNotificationActionBehaviorTextInput;//点击按钮文字输入，是否弹出键盘
     */
    
    UNNotificationCategory *category1 = [UNNotificationCategory categoryWithIdentifier:@"Category1" actions:@[action2,action1] minimalActions:@[action2,action1] intentIdentifiers:@[@"action1",@"action2"] options:UNNotificationCategoryOptionCustomDismissAction];
    //        UIMutableUserNotificationCategory * category1 = [[UIMutableUserNotificationCategory alloc] init];
    //        category1.identifier = @"Category1";
    //        [category1 setActions:@[action2,action1] forContext:(UIUserNotificationActionContextDefault)];
    
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action3" title:@"策略2行为1" options:UNNotificationActionOptionForeground];
    //        UIMutableUserNotificationAction * action3 = [[UIMutableUserNotificationAction alloc] init];
    //        action3.identifier = @"action3";
    //        action3.title=@"策略2行为1";
    //        action3.activationMode = UIUserNotificationActivationModeForeground;
    //        action3.destructive = YES;
    
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"action4" title:@"策略2行为2" options:UNNotificationActionOptionForeground];
    //        UIMutableUserNotificationAction * action4 = [[UIMutableUserNotificationAction alloc] init];
    //        action4.identifier = @"action4";
    //        action4.title=@"策略2行为2";
    //        action4.activationMode = UIUserNotificationActivationModeBackground;
    //        action4.authenticationRequired = NO;
    //        action4.destructive = NO;
    
    UNNotificationCategory *category2 = [UNNotificationCategory categoryWithIdentifier:@"Category2" actions:@[action3,action4] minimalActions:@[action3,action4] intentIdentifiers:@[@"action3",@"action4"] options:UNNotificationCategoryOptionCustomDismissAction];
    //        UIMutableUserNotificationCategory * category2 = [[UIMutableUserNotificationCategory alloc] init];
    //        category2.identifier = @"Category2";
    //        [category2 setActions:@[action4,action3] forContext:(UIUserNotificationActionContextDefault)];
    
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category1,category2, nil]];
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"completionHandler");
    }];
    /*iOS9实现方法
     UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects: category1,category2, nil]];
     
     [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
     */
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
}

#ifdef _GOME_FLAG_
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [LogUtil debug:[NSString stringWithFormat:@"%s 111",__FUNCTION__]];

    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        [LogUtil debug:[NSString stringWithFormat:@"%s 222",__FUNCTION__]];

    }
    return result;
}
#endif

@end
