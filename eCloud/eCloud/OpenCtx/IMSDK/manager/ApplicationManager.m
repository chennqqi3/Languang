//
//  eCloud
//
//  Created by shisuping on 16/6/21.
//  Copyright © 2016年  lyong. All rights reserved.
//

#import "ApplicationManager.h"
#import "mainViewController.h"

#ifdef _GOME_FLAG_
#define APPID_VALUE @"593a51f5"
#import "GOMEEmailUtilArc.h"
#import <iflyMSC/iflyMSC.h>
#endif

#import "ConnResult.h"
#import "eCloudDefine.h"
#import "Conversation.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "eCloudNotification.h"

#import "logger.h"
#import "LanUtil.h"

#import "ImageUtil.h"
#import "TabbarUtil.h"

#import "NotificationUtil.h"

#import "AppDelegate.h"
#import "UserDefaults.h"
#import "AccessConn.h"

#import "ServerConfig.h"
#import "LogUtil.h"
#import "Reachability.h"
#import "eCloudUser.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "NotificationUtil.h"
#import "GXViewController.h"
#import "ASIHTTPRequest.h"
#ifdef _XIANGYUAN_FLAG_

#import "XIANGYUANAgentViewControllerARC.h"
#import "XIANGYUANLoginViewControllerARC.h"

#endif
//南航
#define BAIDU_MAP_APPKEY @"ll1XcdahFSQn7Vxf1DFxKi5zmzFIY2BL"

#define LOGIN_BY_OTHER_DEVICE 10021

#define auto_connect_time_interval (5)
#define conn_check_timer_interval (15)
#define sleep_interval (30)

static ApplicationManager *networkUtil;

@interface ApplicationManager ()<BMKGeneralDelegate,UIAlertViewDelegate>

@property(assign)id delegete;

@end

@implementation ApplicationManager
{
    NSTimer *autoConnTimer;
    NSTimer *connCheckTimer;
    
    eCloudUser *userDb;
    eCloudDAO *db;
    
    conn *_conn;
    
    NSString *HTMLSource;
    BMKMapManager* _mapManager;

}
@synthesize notificationUserInfo;

@synthesize needShowAlertWhenUserDisable;

@synthesize isEditing;

@synthesize needSelectContactTab;
@synthesize needSelectMyTab;
@synthesize needOpenAgent;
@synthesize appInfo;

@synthesize versionAlert;

@synthesize netType;
@synthesize isNetworkOk;

@synthesize hasAccount;
@synthesize isExit;

- (id)init
{
    self = [super init];
    if (self) {
        _conn = [conn getConn];
        userDb = [eCloudUser getDatabase];
        db = [eCloudDAO getDatabase];
        
        self.navigationTitleViewFont = [UIFont boldSystemFontOfSize:20.0];
        self.navigationTitleViewFontColor = [UIColor whiteColor];
        
        self.startAppByClickAppNotificatin = NO;
    }
    return self;
}

+ (ApplicationManager *)getManager
{
    if (!networkUtil) {
        networkUtil = [[super alloc]init];
    }
    return networkUtil;
}

#pragma mark ==app 生命周期==

- (void)setUserIsExit{
    [UserDefaults saveUserIsExit:YES];
}


//设置日志路径 初始化程序语言 用户数据库初始化 增加能处理的通知 网络初始化 后台持续运行初始化 地图相关初始化
- (void)callWhenAppLaunch
{
    [LogUtil debug:[NSString stringWithFormat:@"didFinishLaunchingWithOptions----%s",__FUNCTION__]];
    
    logger_setLogPath([[StringUtil getLogFilePath] cStringUsingEncoding:NSUTF8StringEncoding]);
    
#ifdef _TAIHE_FLAG_
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieJar setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
#endif

    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // 初始化语言
    [LanUtil initUserLanguage];
    
    if (![LanUtil isChinese]){
        [LanUtil setUserlanguage:@"en"];
    }

    [[eCloudConfig getConfig]loadConfig];
    
    if ([[eCloudConfig getConfig] supportGuidePages]) {
        if ([eCloudConfig getConfig].delayWhenLaunch) {
            [LogUtil debug:[NSString stringWithFormat:@"------NSThread sleepForTimeInterval----%s",__FUNCTION__]];
            [NSThread sleepForTimeInterval:1.5f];
        }
    }
    
    //	add by shisp 创建用户库
    [userDb initDatabase];
    
    _conn.userStatus = status_offline;
    
    [self addNotification];
    
    [self initNetWork];
    
    [self setBackgroundHandler];
    
    [self initMapManager];
    
    [UIAdapterUtil setStatusBar];
    [UIAdapterUtil customNavigationBar];
    [UIAdapterUtil customSearchBar];
//    [UIAdapterUtil customTabBar];
    
    
#ifdef _GOME_FLAG_
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    
    //打开输出在console的log开关
    [IFlySetting showLogcat:YES];
    
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //语音识别
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@", APPID_VALUE];
    [IFlySpeechUtility createUtility:initString];
#endif
}

- (void)callWhenAppActive
{
//    if (![eCloudConfig getConfig].supportShareExtension)
//    {
        NSString *str =  [[ServerConfig shareServerConfig]getShareName];
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
        NSArray *arr = [sharedDefaults objectForKey:@"msgDataArray"];
        for (NSData *jsonData in arr)
        {
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonStr %@", jsonStr);
            // 保存进数据库
            
        }
        // 删除已经保存好的数据
        [sharedDefaults removeObjectForKey:@"msgDataArray"];
    //}
    
    
    // 检测系统语言，如果不一样就发出通知，是app语言与系统语言保持一致（南航需求）
    if ([UIAdapterUtil isCsairApp])
    {
        // 英文:en-CN  中文:zh-Hans-CN
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];
        NSLog( @"%@" , currentLanguage);
        NSLog(@"userLanguage-%@", [LanUtil userLanguage]);
        if (![currentLanguage hasPrefix:[LanUtil userLanguage]])
        {
            if ([currentLanguage hasPrefix:@"zh-Hans"])
            {
                [LanUtil setUserlanguage:@"zh-Hans"];
                [[NSNotificationCenter defaultCenter] postNotificationName:REFREASH_CONACTS_LANGUAGE object:nil];
                NSLog(@"设置语言为中文");
            }
            else
            {
                [LanUtil setUserlanguage:@"en"];
                [[NSNotificationCenter defaultCenter] postNotificationName:REFREASH_CONACTS_LANGUAGE object:nil];
                NSLog(@"设置语言为英文");
            }
        }
    }
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    [BMKMapView didForeGround];//当应用恢复前台状态时调用，回复地图的渲染和opengl相关的操作
    
    //    self.needSelectMyTab = YES;
    //    self.needOpenAgent = YES;
    
    //	如果还没有下载完数据，那么发送通知，取消提示框
    if([_conn isFirstGetUserDeptList])
    {
        [LogUtil debug:[NSString stringWithFormat:@"组织架构还未下载完毕"]];
        eCloudNotification *_object = [[eCloudNotification alloc]init];
        _object.cmdId = first_load_org;
        
        [[NotificationUtil getUtil]sendNotificationWithName:ORG_NOTIFICATION andObject:_object andUserInfo:nil];
    }
    
    if (![UIAdapterUtil isCombineApp]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    [self getAccountProperty];
    
//    [[eCloudDAO getDatabase]deleteAllCionversation];
    
    if(!hasAccount)
    {
        [LogUtil debug:@"hasAccount is NO,return"];
#ifdef _XIANGYUAN_FLAG_
 
        AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
        XIANGYUANLoginViewControllerARC *newLogin= [[XIANGYUANLoginViewControllerARC alloc]initWithNibName:@"XIANGYUANLoginViewControllerARC" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        
        return;
        
#endif
        return;
    }
    if(isExit)
    {
        [LogUtil debug:@"isExit is YES,return"];
        return;
    }
    
    //	如果用户是在线状态
    if(_conn.userStatus == status_online)
    {
        int ret = [_conn sendConnCheckCmd];
        if(ret == 0)
        {
            [LogUtil debug:[NSString stringWithFormat:@"用户在线，发送checkTime指令看通讯是否正常"]];
            [self startConnCheckTimer];
            return;
        }
        else if(ret == 1)
        {
            [LogUtil debug:[NSString stringWithFormat:@"发送checkTime指令发送失败，自动重连"]];
            [self connCheckTimeout];
            return;
        }
    }
    else
    {
        [LogUtil debug:[NSString stringWithFormat:@"用户离线，自动登录"]];
        if(_conn.connStatus == not_connect_type)
        {
            [NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];			
        }
    }
    
}

- (void)saveRecentConvForSharing
{
    if (![eCloudConfig getConfig].supportShareExtension)
    {
        eCloudDAO *ecloud = [eCloudDAO getDatabase];
        NSArray *convs = [ecloud getRecentConvForTransMsg];
        
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:convs.count];
        for (Conversation *conv in convs)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"conv_type"]  = @(conv.conv_type);
            dic[@"conv_id"]    = conv.conv_id;
            dic[@"conv_title"] = conv.conv_title;
            dic[@"emp_id"]     = [NSString stringWithFormat:@"%d",conv.emp.emp_id];
            
            // 保存头像
            if (conv.conv_type == 0)
            {
                UIImage *emp_logo  = [ImageUtil getEmpLogo:conv.emp];
                if (emp_logo) {
                    NSData *imageData  = UIImagePNGRepresentation(emp_logo);
                    dic[@"emp_logo"]   = @[imageData];
                }
            }
            else if (conv.conv_type == 1)
            {
                NSMutableArray *logoArr = [NSMutableArray array];
                for (UIImage *emp_logo in conv.groupLogoEmpArray)
                {
//                    NSData *imageData  = UIImagePNGRepresentation(emp_logo);
//                    [logoArr addObject:imageData];
                }
                dic[@"emp_logo"] = logoArr;
            }
            
            [mArr addObject:dic];
        }
        NSString *str =  [[ServerConfig shareServerConfig]getShareName];
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:str];
        [sharedDefaults setObject:mArr forKey:@"convs"];
        conn *_conn = [conn getConn];
        
        if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
            
            [sharedDefaults setObject:@"productService" forKey:@"service"];
        }else{
            [sharedDefaults setObject:@"testService" forKey:@"service"];
        }
        
        [sharedDefaults setObject:_conn.userId forKey:@"userID"];
        [sharedDefaults setObject:_conn.userEmail forKey:@"userEmail"];
        
        [sharedDefaults setObject:[UserDefaults getUserAccount] forKey:@"account"];
        [sharedDefaults setObject:[UserDefaults getUserPassword] forKey:@"password"];
        [sharedDefaults setObject:[UserDefaults getDeviceToken] forKey:@"deviceToken"];
    }
}

- (void)callWhenAppEnterBackground
{
    [LogUtil debug:[NSString stringWithFormat:@"applicationDidEnterBackground----%s",__FUNCTION__]];
    
    //保存最近联系人用于在相册或系统浏览器分享信息 选择联系人时用
    [self saveRecentConvForSharing];
    
    [self stopConnCheckTimer];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    if (![UIAdapterUtil isCombineApp]) {
        int count=[db getAllNumNotReadedMessge];
#ifdef _XIANGYUAN_FLAG_
        
        /** 祥源需要加上待办的未读数 */
        NSNumber *daibanCount = [UserDefaults getXIANGYUANAppDAIBAN];
        count += [daibanCount intValue];
        
#endif
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
    }
    

    [self backgroundHandler];
    
    if([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground)
    {
        [_conn putUnreadMsgCountToServer];
    }
    
    //    测试代码
    //    [_conn performSelector:@selector(logout) withObject:nil afterDelay:5];
    
    
    //进行后台任务
    //    [application beginBackgroundTaskWithExpirationHandler:nil];
}

- (void)callWhenAppWillResignActive
{
    [BMKMapView willBackGround];//当应用即将后台时调用，停止一切调用opengl相关的操作
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
}

/**
 应用即将进入前台运行
 */
- (void)callWhenAppWillEnterForground{
    [LogUtil debug:[NSString stringWithFormat:@"%s 应用即将进入前台",__FUNCTION__]];

    self.startAppByClickAppNotificatin = NO;
}


//保存token
- (void)saveToken:(NSString *)deviceToken
{
    if (deviceToken)
    {
        [UserDefaults setDeviceToken:deviceToken];
    }
}

//增加接口 确定是appstore版本 还是 企业证书版本
- (void)setAppType:(NSString *)appType
{
    [UserDefaults setAppType:appType];
}

#pragma mark 定义能处理的通知

-(void)addNotification
{
    //    增加处理 被移除 出群的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processConv:) name:CONVERSATION_NOTIFICATION object:nil];
    
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(statusBarChange:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    //	接收 网络变化通知 广播通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    //   在别处登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noctiveOFFLINE:)
                                                 name: USER_NOTICE_OFFLINE
                                               object: nil];
    //    被禁用通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDisable:) name:USER_DISABLE_NOTIFICATION object:nil];
    
}

#pragma mark 检测和服务器的网络和网络类型
-(void)initNetWork
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    ServerConfig *serverConfig = [ServerConfig shareServerConfig];
    [[eCloudUser getDatabase]getServerConfig];
    
    NSString *primaryIp = serverConfig.primaryServer;
    NSString *primaryPort = [StringUtil getStringValue:serverConfig.primaryPort];
    
    //	检查是否能连上南航服务器
    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
    address.sin_port = htonl(primaryPort.intValue);
    address.sin_addr.s_addr = htons(inet_addr([primaryIp cStringUsingEncoding:NSUTF8StringEncoding]));
    
    Reachability * reachability = [[Reachability reachabilityWithAddress:&address] retain];
    NetworkStatus status = [reachability currentReachabilityStatus];
    if (status == NotReachable)
    {
        self.isNetworkOk = NO;
    }
    else
    {
        self.isNetworkOk = YES;
        [self setNetTypeByStatus:status];
    }
    
    [reachability startNotifier];
    
}

- (void)setNetTypeByStatus:(NetworkStatus)status
{
    if(status == ReachableViaWiFi)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,net work is wifi",__FUNCTION__]];
        self.netType = type_wifi;
    }
    else if(status == ReachableViaWWAN)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,net work is gprs",__FUNCTION__]];
        self.netType = type_gprs;
    }
    [[NotificationUtil getUtil]sendNotificationWithName:NETWORK_SWITCH andObject:nil andUserInfo:nil];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    conn *_conn = [conn getConn];
    Reachability* curReach = [note object];
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,net work is NotReachable",__FUNCTION__]];
        
#ifdef _GOME_FLAG_
        [[GOMEEmailUtilArc getEmailUtil]stopEmailTimer];
#endif

        
        self.isNetworkOk = NO;
        
        if(_conn.userId != nil)
        {
            if(_conn.connStatus == linking_type)
            {
                [LogUtil debug:[NSString stringWithFormat:@"%s,connstatus is linking return",__FUNCTION__]];
            }
            else
            {
                _conn.userStatus = status_offline;
                [[eCloudDAO getDatabase] updateUserStatus:_conn.userId andStatus:status_offline];
                _conn.connStatus = not_connect_type;
                
                [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
                
            }
        }
    }
    else
    {
        self.isNetworkOk = YES;
        [self setNetTypeByStatus:status];
        
        [self getAccountProperty];
        if(self.hasAccount && _conn.userStatus != status_online && _conn.connStatus == not_connect_type)
        {
            //            自动登录
                        [NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];
        }
    }
}


#pragma mark 获取账号信息，确定是否有账号，是否为注销状态
-(void)getAccountProperty
{
    //	获取保存的用户名和密码
    //	NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    //    NSString* username=[accountDefaults objectForKey:@"username"];
    //    NSString* password=[accountDefaults objectForKey:@"password"];
    //	NSString *userId = [accountDefaults objectForKey:@"user_id"];
    
    NSString *username = nil;
    NSString *password = nil;
    username = [UserDefaults getUserAccount];
    password = [UserDefaults getUserPassword];
    
    isExit = [UserDefaults userIsExit];
    
    hasAccount = NO;
    
    conn *_conn = [conn getConn];
    
    if(username && username.length > 0 && password && password.length > 0 )//&& userId && userId.length > 0
    {
        _conn.userEmail = username;
        _conn.userPasswd = password;
        
        NSString *userId = nil;
        NSDictionary *dic = [[eCloudUser getDatabase] searchUserByMail:username andPasswd:password];
        if (dic) {
            userId = [StringUtil getStringValue:[[dic valueForKey:user_id]intValue]];
        }
        
        //       如果根据用户名和密码查到了用户id，那么打开数据库
        if (userId)
        {
            _conn.userId = userId;
            
            if([eCloudDAO getDatabase].lastUserId == nil || [eCloudDAO getDatabase].lastUserId.intValue != _conn.userId.intValue)
            {
                [[eCloudDAO getDatabase] initDatabase:_conn.userId];
                _conn.curUser = [[eCloudDAO getDatabase]getEmployeeById:userId];
            }
        }
        
        hasAccount = YES;
    }
}

#pragma mark 自动重连

//启动重连timer
-(void)startAutoConnTimer
{
    if([self needAutoConnect])
    {
        if(autoConnTimer)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s,timer已经启动 return",__FUNCTION__]];
            return;
        }
        
        if(_conn.connStatus == not_connect_type)
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
            autoConnTimer = [NSTimer scheduledTimerWithTimeInterval:auto_connect_time_interval target:self selector:@selector(autoConn) userInfo:nil repeats:NO];
        }
    }
}

-(void)autoConn
{
    autoConnTimer = nil;
    if(_conn.connStatus == not_connect_type)
    {
        [NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];
    }
}

//停止重连timer
-(void)stopAutoConnTimer
{
    if(autoConnTimer && [autoConnTimer isValid])
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
        [autoConnTimer invalidate];
    }
    autoConnTimer = nil;
}

-(void)startConnCheckTimer
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    connCheckTimer = [NSTimer scheduledTimerWithTimeInterval:conn_check_timer_interval target:self selector:@selector(connCheckTimeout) userInfo:nil repeats:NO];
}
-(void)connCheckTimeout
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    connCheckTimer = nil;
    
    if(_conn.connStatus == linking_type)
    {
        [LogUtil debug:[NSString stringWithFormat:@"%s,isLinking return",__FUNCTION__]];
        return;
    }
    _conn.userStatus = status_offline;
    _conn.connStatus = not_connect_type;
    
    [NSThread detachNewThreadSelector:@selector(autoLogin) toTarget:self withObject:nil];
}

-(void)stopConnCheckTimer
{
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    if(connCheckTimer && [connCheckTimer isValid])
    {
        [connCheckTimer invalidate];
    }
    connCheckTimer = nil;
}


-(BOOL)needAutoConnect
{
    BOOL isExit = [UserDefaults userIsExit];
    
    //    update by shisp 不是强制升级
    if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive && !_conn.isKick && !_conn.isDisable && !_conn.isInvalidPassword && self.isNetworkOk && !isExit && !_conn.forceUpdate && [AccessConn getConn].isUserExist)
        
        //        && !([eCloudConfig getConfig].needShowAlertWhenOptionUpdate && _conn.hasNewVersion)  只要有新版本，就可以自动重连
    {
        //        如果未处理的离线消息数量不是0，则不连接
        conn *_conn = [conn getConn];
        if (_conn.offlineMsgArray.count > 0) {
            [LogUtil debug:@"未处理的离线消息数量大于0"];
            return NO;
        }
        
        if (self.versionAlert.visible && self.versionAlert.tag == OPTION_UPDATE_ALERT_TAG) {
            [LogUtil debug:@"如果升级提示框是显示状态，并且是可选升级，那么不自动重连"];
            return NO;
        }
        [LogUtil debug:[NSString stringWithFormat:@"%s,YES",__FUNCTION__]];
        return YES;
    }
    [LogUtil debug:[NSString stringWithFormat:@"%s,NO",__FUNCTION__]];
    return NO;
}

-(void)autoLogin
{
    [LogUtil debug:[NSString stringWithFormat:@"%s，自动登录",__FUNCTION__]];
    
    if([self needAutoConnect])
    {
        if(_conn.connStatus == normal_type || _conn.userStatus == status_online)
        {
            [LogUtil debug:@"用户在线,return"];
            return;
        }
        
        //	提示用户正在连接
        [[NotificationUtil getUtil]sendNotificationWithName:CONNECTING_NOTIFICATION andObject:nil andUserInfo:nil];
        
        if(_conn.connStatus == linking_type)
        {
            [LogUtil debug:@"current is connecting ,return"];
            return;
        }
        
        //        update by shisp 设置为正在连接
        _conn.connStatus = linking_type;
        [self loginAction];
    }
}

-(void)loginAction
{
    if([_conn initConn])
    {
        if(_conn.forceUpdate || (_conn.hasNewVersion && [eCloudConfig getConfig].needShowAlertWhenOptionUpdate))
        {
            _conn.connStatus = not_connect_type;
            [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
            
            if(self.versionAlert == nil)
            {
                
                [self performSelectorOnMainThread:@selector(showVersionAlert:) withObject:self waitUntilDone:YES];
      
            }
        }
        else
        {
            if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
            {
                //                update by shisp 设置未连接状态
                _conn.connStatus = not_connect_type;
                
                [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
            }
        }
    }
    else
    {
        //                update by shisp 设置未连接状态
        _conn.connStatus = not_connect_type;
        
        [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
    }
}


#pragma mark 可以后台运行，不被回收
-(void)setBackgroundHandler
{
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        [LogUtil debug:@"600秒后开启background task"];
        [self backgroundHandler];
    }];
    
    if (backgroundAccepted)
    {
        NSLog(@"backgrounding accepted");
    }
}

- (void)backgroundHandler
{
    UIApplication *app = [UIApplication sharedApplication];
    
    __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        
        //        判断下用户是否是在线，并且是就绪的状态，如果是则 调用logout方法
        if ([[UIApplication sharedApplication]applicationState] == UIApplicationStateBackground && _conn.userStatus == status_online && _conn.connStatus == normal_type) {
            [_conn logout:0];
        }
        
        [LogUtil debug:@"结束backgroundTask"];
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [LogUtil debug:@"开启long-running task"];
        int counter = 0;
        //        while (1)
        //		{
        //			if([[UIApplication sharedApplication]applicationState] == UIApplicationStateActive)
        //			{
        //				[LogUtil debug:@"结束long-running task,原因是应用已经在前台运行"];
        //				break;
        //			}
        //			counter = counter + sleep_interval;
        //			[LogUtil debug:[NSString stringWithFormat:@"counter:%ld", counter]];
        //			if(counter > 650)
        //			{
        //				[LogUtil debug:@"结束long-running task,原因是时间已经超过了600秒"];
        //				break;
        //			}
        //            sleep(sleep_interval);
        //		}
    });
}

#pragma mark 版本升级提示 被踢提示 被禁用提示
- (void)showVersionAlert:(id)alertDelegate
{
       // 是强制升级或者有新版本
        if (_conn.forceUpdate || _conn.hasNewVersion) {
        
            NSString *title ;
            if ([UIAdapterUtil isHongHuApp]) {
                title = [NSString stringWithFormat:@"%@新版本",[StringUtil getAppName]];
                
            }else{
                title = [StringUtil getAppName];
            }
            NSString *updateInfo = [NSString stringWithFormat:@"%@%@",[StringUtil getAppName],[StringUtil getLocalizableString:@"has_new_version"]] ;
            
            if (_conn.forceUpdate) {
                self.versionAlert =	[[UIAlertView alloc]initWithTitle:title message:updateInfo delegate:alertDelegate cancelButtonTitle:nil otherButtonTitles:[StringUtil getLocalizableString:@"update_at_once"], nil];
                self.versionAlert.tag = FORCE_UPDATE_ALERT_TAG;
    
            }else{
                self.versionAlert =	[[UIAlertView alloc]initWithTitle:title message:updateInfo delegate:alertDelegate cancelButtonTitle:[StringUtil getLocalizableString:@"later"] otherButtonTitles:[StringUtil getLocalizableString:@"update_at_once"], nil];
                self.versionAlert.tag = OPTION_UPDATE_ALERT_TAG;
   
            }
            
            //
            NSString *convertData = @"";
            
            if ([UIAdapterUtil isHongHuApp] || [UIAdapterUtil isTAIHEApp]){
                NSString *temp = [UserDefaults getNewVersionTipUrl];
                NSURL *_url = [NSURL URLWithString:temp];
                NSData *_data = [NSData dataWithContentsOfURL:_url];
                convertData = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
                
                //                convertData = [NSString stringWithFormat:@"%@%@",convertData,convertData];
            }
            
            float tipsWidth = 240;
            CGSize size = [convertData sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(tipsWidth, 600) lineBreakMode:NSLineBreakByCharWrapping];
            UILabel *textLabel;
            if ([[[UIDevice currentDevice] systemVersion]floatValue] <= 7.0) {
                textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, tipsWidth, size.height)]autorelease];
            }else{
                textLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 0, tipsWidth , size.height)]autorelease];
            }
            
            textLabel.font = [UIFont systemFontOfSize:15];
            textLabel.textColor = [UIColor blackColor];
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            textLabel.numberOfLines = 0;
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.text = convertData;
            
            NSMutableString *msg = [NSMutableString stringWithString:@""];
            if (convertData.length == 0) {
                [self.versionAlert show];
            }else{
                int count = size.height / 20.0;
                for (int i = 0;i<count;i++) {
                    [msg appendString:@"\n"];
                }
                
                
                UILabel *parentLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, tipsWidth, size.height)]autorelease];
                parentLabel.backgroundColor = [UIColor clearColor];
                parentLabel.numberOfLines = 0;
                parentLabel.text = msg;
                
                [parentLabel addSubview:textLabel];
                
                [self.versionAlert setValue:parentLabel forKey:@"accessoryView"];
                self.versionAlert.message = @"";
                
                [self.versionAlert show];
            }
        }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == REMOVED_FROM_GROUP_TAG && buttonIndex == 0) {
        [TabbarUtil backToRootContact];
        return;
    }
    if (alertView.tag == FORCE_UPDATE_ALERT_TAG || (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 1 ))
    {
        [self userClickUpdateAtOnce];
    }
    else if (alertView.tag == OPTION_UPDATE_ALERT_TAG && buttonIndex == 0)
    {
        [self userClickLater];
    }else if(alertView.tag == DISABLE_TAG && buttonIndex ==0){
        
        isExit = true;
        
        [_conn logout:1];
        
        [self exit];
    }
    else if (alertView.tag == LOGIN_BY_OTHER_DEVICE)
    {
        if (buttonIndex ==0)
        {
            [self exit];
        }
        else
        {
            [self reLinkButtonAction];
        }
    }
    
    self.versionAlert = nil;
}

- (void)reLinkButtonAction
{
    if([ApplicationManager getManager].isNetworkOk)
    {
        [[NotificationUtil getUtil]sendNotificationWithName:CONNECTING_NOTIFICATION andObject:nil andUserInfo:nil];
        
        [NSThread detachNewThreadSelector:@selector(reLink) toTarget:self withObject:nil];
    }else
    {
        UIAlertView *linkalert=[[UIAlertView alloc]initWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"contact_noConnection"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil];
        [linkalert show];
        [linkalert release];
    }
}

-(void)reLink
{
    [[ApplicationManager getManager] stopAutoConnTimer];
    if(_conn.connStatus == linking_type)
    {
        return;
    }
    if(![_conn initConn] || ![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
    {
        [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
    }
}

- (void)exit{
    [UserDefaults saveUserIsExit:YES];
    
    if (self.delegete && [self.delegete isKindOfClass:[mainViewController class]]) {
        [( (mainViewController*)self.delegete)backRoot];
    }else{
        id tabbarVC = [TabbarUtil getTabbarController];
        if (tabbarVC && [tabbarVC isKindOfClass:[GXViewController class]]) {
            id mainVC = ((GXViewController *)tabbarVC).delegate;
            [((mainViewController*)mainVC) backRoot];
        }
    }
}

//用户选择了以后再说
- (void)userClickLater
{
    [LogUtil debug:[NSString stringWithFormat:@"可选升级，用户选择了以后再说，那么继续登录"]];
    _conn.connStatus = linking_type;
    if(![_conn login:_conn.userEmail andPasswd:_conn.userPasswd])
    {
        //                update by shisp 设置未连接状态
        _conn.connStatus = not_connect_type;
        [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
    }
}

- (void)userClickUpdateAtOnce
{
    _conn.connStatus = not_connect_type;
    [[NotificationUtil getUtil]sendNotificationWithName:NO_CONNECT_NOTIFICATION andObject:nil andUserInfo:nil];
    
    [LogUtil debug:[NSString stringWithFormat:@"强制升级 或者 可选升级，打开升级页面"]];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_conn.updateUrl]];
    if ([_conn.updateUrl hasPrefix:@"itms-services://"]) {
        //            ios8下 用户选择安装新版本后，系统不会自动退出，所以
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        
        isExit = true;
        
        [_conn logout:1];
        
        [self exit];
        
    }
    
}

- (void)noctiveOFFLINE:(NSNotification *)note
{
    NSString *string;
    if ([UIAdapterUtil isTAIHEApp]) {
        
        string = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
    }else{
        
        string = [StringUtil getLocalizableString:@"Your_account_has_been_logged_elsewhere"];
    }
    
    if (self.needShowAlertWhenUserDisable) {
        
        if ([UIAdapterUtil isXINHUAApp])
        {
            NSString *tips = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下线通知" message:tips  delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
            alert.tag = LOGIN_BY_OTHER_DEVICE;
            [alert show];
            [alert release];
        }
        else if ([UIAdapterUtil isXIANGYUANApp]){
            
            NSString *tips = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下线通知" message:tips  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = LOGIN_BY_OTHER_DEVICE;

            [alert show];
            [alert release];
        }
        else
        {
            UIAlertView *offalert=[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:string delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
            if ([eCloudConfig getConfig].backToLoginWhenLoginOtherTerminal) {
                offalert.tag = DISABLE_TAG;
            }
            [offalert show];
            [offalert release];
        }
    }
}

- (void)userDisable:(NSNotification *)notification
{
    if (self.needShowAlertWhenUserDisable) {
        ConnResult *result = [[ConnResult alloc]init];
        result.resultCode = RESULT_FORBIDDENUSER;
        NSString *tips = [result getResultMsg];
        if ([UIAdapterUtil isTAIHEApp]) {
            tips = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
        }
        if ([UIAdapterUtil isXINHUAApp])
        {
            tips = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"下线通知" message:tips  delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
            alert.tag = LOGIN_BY_OTHER_DEVICE;
            [alert show];
            [alert release];
        }
        else if ([UIAdapterUtil isXIANGYUANApp]){
            
//            NSString *tips = [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:tips  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = LOGIN_BY_OTHER_DEVICE;
            
            [alert show];
            [alert release];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:tips  delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
            if ([eCloudConfig getConfig].backToLoginWhenForbidden) {
                alert.tag = DISABLE_TAG;
            }
            [alert show];
            [alert release];
        }
        
        [result release];
    }
}

#pragma mark 用户点击通知启动应用或者进入应用
- (void)startAppFromLaunchOptions:(NSDictionary *)launchOptions
{
    ///获取到推送相关的信息
    [LogUtil debug:[NSString stringWithFormat:@"%s:%@，launch=%@",__FUNCTION__,[StringUtil getAppName],[launchOptions description]]];
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    [self enterAppByClickNotification:userInfo];
}

- (void)enterAppByClickNotification:(NSDictionary *)userInfo
{
    [LogUtil debug:[NSString stringWithFormat:@"--%s userinfo is %@",__FUNCTION__,[userInfo description]]];
    
    self.needOpenAgent = NO;
    self.needSelectContactTab = NO;
    self.needSelectMyTab = NO;
    
    if (userInfo) {
        
#ifdef _XIANGYUAN_FLAG_
        
        if ([userInfo[KEY_NOTIFICATION_MSG_TYPE]intValue] == xy_notification_agent_msg || [userInfo[KEY_NOTIFICATION_MSG_TYPE]intValue] == notification_agent_msg ) {
            
            self.startAppByClickAppNotificatin = YES;

            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            
//            这个url并不是服务器推送的，是客户端自己确定的
            NSString *urlString = [[ServerConfig shareServerConfig]getXYDAIBANUrl];
            
            if ([userInfo[KEY_NOTIFICATION_MSG_TYPE]intValue] == notification_agent_msg) {
                
                urlString = [[ServerConfig shareServerConfig]getXYNoticeUrl];
            }
            [mDic setObject:urlString forKey:KEY_NOTIFICATION_APP_URL];

            if ([TabbarUtil getTabbarController])
            {
                [TabbarUtil showMyPage];
                [TabbarUtil saveStartAppInfo:mDic];
                [TabbarUtil autoOpenAgentList];
            }else{
//                应用是重新启动的 这时候 需要 应用 在启动并且自动登录后，自动打开待办
                self.appInfo = mDic;
                self.needSelectMyTab = YES;
                self.needOpenAgent = YES;
            }

            
        }else{
            if ([TabbarUtil getTabbarController]) {
                [TabbarUtil showChatPage];
            }
            else
            {
                self.needSelectContactTab = YES;
            }
        }
#else
        

        if ([[userInfo objectForKey:KEY_NOTIFICATION_MSG_TYPE] intValue] == notification_agent_msg && [UIAdapterUtil isHongHuApp]){
            
            self.notificationUserInfo = userInfo;
            
            if ([TabbarUtil getTabbarController])
            {
                [TabbarUtil saveStartAppInfo:userInfo];
                [TabbarUtil showMyPage];
                [TabbarUtil autoOpenAgentList];
            }
            else
            {
                self.appInfo = userInfo;
                self.needSelectMyTab = YES;
                self.needOpenAgent = YES;
            }
        }else if ([[userInfo objectForKey:KEY_NOTIFICATION_MSG_TYPE] intValue] == notification_agent_msg && [UIAdapterUtil isLANGUANGApp]){
            
            if ([TabbarUtil getTabbarController])
            {
                [TabbarUtil showMyPage];
            }
            
        }else{
            if ([TabbarUtil getTabbarController]) {
//#ifdef _LANGUANG_FLAG_
//                
//                [TabbarUtil showMyPage];
//#else
                
                [TabbarUtil showChatPage];
//#endif
                
            }
            else
            {
                self.needSelectContactTab = YES;
            }
        }
 #endif
    }
    else
    {
        [LogUtil debug:@"远程代办通知userinfo为空"];
    }

}

#pragma mark 如果被移出时，停留在这个讨论组界面，那么给出提示，然后回到到会话列表
- (void)processConv:(NSNotification *)notification
{
    eCloudNotification *_notification = [notification object];
    if (_notification) {
        int cmdId = _notification.cmdId;
        if (cmdId == removed_from_group) {
            NSDictionary *dic = _notification.info;
            NSString *grpId = [dic valueForKey:@"conv_id"];
            [[eCloudDAO getDatabase]deleteConvAndConvRecordsBy:grpId];
            
            if ([TabbarUtil needAlertWhenRemoveFromGroup:grpId]) {
                if (IOS8_OR_LATER) {
                    UIAlertController *_alert = [UIAlertController alertControllerWithTitle:[StringUtil getLocalizableString:@"hint"] message:[StringUtil getLocalizableString:@"you_are_removed_from_this_group"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:[StringUtil getLocalizableString:@"I_know"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [TabbarUtil backToRootContact];
                    }];
                    
                    [_alert addAction:confirmAction];
                    
                    [UIAdapterUtil presentVC:_alert];
                    
                }else{
                    
                    UIAlertView *_alert = [[[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"you_are_removed_from_this_group"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"I_know"] otherButtonTitles:nil, nil]autorelease];
                    _alert.tag = REMOVED_FROM_GROUP_TAG;
                    
                    [_alert show];
                }
            }
        }
    }
}

#pragma mark 百度地图
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

- (void)initMapManager
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    NSString *mapKey = [StringUtil getBaiduMapKey];
    if (!mapKey) {
        mapKey = BAIDU_MAP_APPKEY;
    }
    
    BOOL ret = [_mapManager start:mapKey  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

}

#pragma mark 扩展
@end
