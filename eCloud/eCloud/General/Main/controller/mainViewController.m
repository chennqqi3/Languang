//
//  mainViewController.m
//  eCloud
//
//  Created by  lyong on 12-9-24.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "mainViewController.h"
#ifdef _GOME_FLAG_
#import "GOMESettingViewController.h"
#import "GOMELoginViewController.h"
#import "GOMEAppViewController.h"
#import "GOMEActivateMailViewControllerArc.h"
#import "GOMEMailDefine.h"
#endif

#ifdef _BGY_FLAG_
#import "BGYMoreViewControllerARC.h"
#import "BGYWorkViewControllerArc.h"
#import "BGYLoginViewController.h"
#import "BGYTimelineViewControllerARC.h"
#import "BGYHomePageViewController.h"
#endif

#ifdef _LANGUANG_FLAG_
#import "LGLoginViewControllerArc.h"
#import "LGRootOrgViewController.h"
#endif

#ifdef _XINHUA_FLAG_
#import "XINHUALoginViewControllerArc.h"
#import "XINHUASettingViewControllerArc.h"
#import "XINHUAOrgViewControllerArc.h"
#import "XINHUACourseViewControllerArc.h"
#endif

#ifdef _TAIHE_FLAG_
#import "TAIHEAppViewController.h"
#import "TaiHeLoginViewController.h"
#import "TaiHeSettingViewController.h"
#import "TAIHEWXWorkViewController.h"
#endif

#ifdef _LANGUANG_FLAG_

#import "LANGUANGMyViewControllerARC.h"
#import "LANGUANGAppViewControllerARC.h"
#import "LGWorkViewControllerArc.h"

#endif


#ifdef _XIANGYUAN_FLAG_

#import "XIANGYUANMyViewControllerARC.h"
#import "XIANGYUANAppViewControllerARC.h"
#import "XIANGYUANWorkViewControllerARC.h"
#import "XIANGYUANLoginViewControllerARC.h"
#import "XIANGYUANAgentViewControllerARC.h"

#endif
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "ServerConfig.h"

#import "LogUtil.h"
#import "ApplicationManager.h"
#import "TabbarUtil.h"
#import "GXViewController.h"
#import "eCloudConfig.h"

#import "ConvNotification.h"

#import "AppDelegate.h"

#import "contactViewController.h"
#import "NewOrgViewController.h"
#import "settingViewController.h"
#import "conn.h"
#import "eCloudDAO.h"
#import "UIAdapterUtil.h"
#import "LanUtil.h"

#import "NewMyViewControllerOfGrid.h"
#import "NewMyViewControllerOfTableview.h"
#import "NewMyViewControllerOfCustomGrid.h"
#import "NewMyViewControllerOfCustomTableview.h"

#import "MLNavigationController.h"
#import "CBNavigationController.h"
#import "NewLoginViewController.h"
#import "AgentListViewController.h"
#import "UserDefaults.h"

@interface mainViewController ()

/** 水印内容显示相关的label组件 */
@property (nonatomic, strong) UILabel *waterMarkkLabel;
@property (nonatomic, strong) UILabel *waterMarkkLabel1;
@property (nonatomic, strong) UILabel *waterMarkkLabel2;
@property (nonatomic, strong) UILabel *waterMarkkLabel3;

@end

@implementation mainViewController
{
#ifdef _TAIHE_FLAG_
    TAIHEWXWorkViewController *workViewController;
#endif
    /** 会话列表控制器 */
	contactViewController *contactController;
    /** 通讯录控制器 */
    NewOrgViewController *organizationalController;
    /** 设置界面控制器 */
    settingViewController *settingController;
    /** 发现界面控制器 */
    AgentListViewController *AgentListController;
    /** 会话列表控制器作为根控制器的导航栏控制器 */
    UINavigationController *conversationNavigationController;
    /** 通讯录控制器作为根控制器的导航栏控制器 */
    UINavigationController *orgNavigationController;
    /** 设置控制器作为根控制器的导航栏控制器 */
    UINavigationController *settingsNavigationController;
    /** 我的(龙湖的是办公、泰禾的是首页)控制器作为根控制器的导航栏控制器 */
    UINavigationController *myNavigationController;
    /** 发现控制器作为根控制器的导航栏控制器 */
    UINavigationController *AgentListNavigationController;
    /** 工作(泰禾专用)控制器作为根控制器的导航栏控制器 */
    UINavigationController *workNavigationController;
    /** 自定义tabbarviewController */
    /** 工作(蓝光专用)控制器作为根控制器的导航栏控制器 */
    UINavigationController *LGworkNavigationController;
    
    GXViewController *tabBarController;
}
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
	NSLog(@"%s",__FUNCTION__);
    [self removeSomeview];
    
    [TabbarUtil setTabbarController:nil];
    
    // 删除此类注册的通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];

	[super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    if ([UINavigationController instancesRespondToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];

    if ([UINavigationController instancesRespondToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    
    [((AppDelegate *)([UIApplication sharedApplication].delegate)) openUrlFromOtherApp];

    // 是否需要默认打开会话列表界面
    if ([ApplicationManager getManager].needSelectContactTab)
    {
        [LogUtil debug:@"如果是点击消息通知进入系统的，那么默认显示会话界面"];
        [tabBarController showChatPage];
        [ApplicationManager getManager].needSelectContactTab = NO;
    }
    // 是否需要默认打开办公界面
    if ([ApplicationManager getManager].needSelectMyTab)
    {
        [LogUtil debug:@"如果是点击代办通知进入系统的，那么默认显示我的界面"];
        [tabBarController showMyPage];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置当前控制器的背景颜色
    [UIAdapterUtil setBackGroundColorOfController:self];
    
    [UIAdapterUtil processController:self];
    // 创建、设置自定义tabbarviewcontroller
    tabBarController = [[GXViewController alloc] init];
    [TabbarUtil setTabbarController:tabBarController];
	tabBarController.delegate = self;
    // 去除tabbar按钮选中后的背景方块
    tabBarController.tabBar.selectionIndicatorImage = [[[UIImage alloc] init] autorelease];
    
    // 首先初始化数组，下面再修改数组元素的value
    // 数组中的元素存放的是对应位置的界面控制器对象
    // 比如appconfig.plist文件中的ConversationIndex为1，那表示会话界面在底部tabbar的位置是第2个，数组的第二个元素存放的是会话控制器
    NSMutableArray *mArray = nil;
    if ([UIAdapterUtil isTAIHEApp] || [UIAdapterUtil isBGYApp]) {
        mArray = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",nil];
    }else{
        mArray = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",nil];
    }
#ifdef _LANGUANG_FLAG_
    
        mArray = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",nil];
    
#endif

#ifdef _XIANGYUAN_FLAG_
    
        mArray = [NSMutableArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",nil];
    
#endif
    // 创建会话界面及设置会话界面在tabbar上显示的位置
    contactController = [[[contactViewController alloc]init]autorelease];
    contactController.delegete=self;
    
    conversationNavigationController = [mainViewController getNavigationVCwithRootVC:contactController];
    mArray[[eCloudConfig getConfig].conversationIndex] = conversationNavigationController;
    
    if ([UIAdapterUtil isTAIHEApp]) {
#ifdef _TAIHE_FLAG_
        workViewController = [[[TAIHEWXWorkViewController alloc] init]autorelease];
        workNavigationController = [mainViewController getNavigationVCwithRootVC:workViewController];
        
        mArray[3] = workNavigationController;
#endif
    }
    
#ifdef _LANGUANG_FLAG_
    
    LGRootOrgViewController *work = [[[LGRootOrgViewController alloc] init]autorelease];
//    NewOrgViewController *work = [[[NewOrgViewController alloc] init]autorelease];
    LGworkNavigationController = [mainViewController getNavigationVCwithRootVC:work];
    mArray[3] = LGworkNavigationController;
    
#endif

#ifdef _XIANGYUAN_FLAG_
    
    XIANGYUANWorkViewControllerARC *work = [[[XIANGYUANWorkViewControllerARC alloc] init]autorelease];
    UINavigationController *XYWorkNav = [mainViewController getNavigationVCwithRootVC:work];
    
    mArray[3] = XYWorkNav;
    
#endif
//    contactController.title = [StringUtil getLocalizableString:@"main_chats"];
//    contactController.tabBarItem = [self getTabbarItemWithTitle:@"会话" andImageName:@"icon_conversation" andTag:0];
//    conversationNavigationController = [[UINavigationController alloc] initWithRootViewController:contactController];
//    [UIAdapterUtil setStatusBarColor:conversationNavigationController];
    
    // 创建 我的 界面及设置 我的 界面在tabbar上显示的位置
    UIViewController *my = nil;
    
    if ([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_grid) {
        my = [[NewMyViewControllerOfGrid alloc]init];
    }
    else if([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_tableview)
    {
        my = [[NewMyViewControllerOfTableview alloc]init];
    }
    else if ([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_customgrid)
    {
        my = [[NewMyViewControllerOfCustomGrid alloc]init];
    }
    else if ([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_customtableview)
    {
        my = [[NewMyViewControllerOfCustomTableview alloc]init];
    }
    else if ([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_collectionView)
    {
#ifdef _GOME_FLAG_
        my = [[GOMEAppViewController alloc] init];
#endif
    }else if ([eCloudConfig getConfig].myViewModeType.intValue == myview_type_of_customView)
    {
#ifdef _TAIHE_FLAG_
            my = [[TAIHEAppViewController alloc] init];
#endif
    }
#ifdef _XINHUA_FLAG_
    
    my = [[XINHUACourseViewControllerArc alloc] init];

#endif
    
#ifdef _BGY_FLAG_
    
    //http://ydyywx1.bgy.com.cn:8090/appPage/worko/PAGE_WORK/work.html
//    my = [[BGYAgentViewControllerARC alloc] init];
    
    
#endif
    
#ifdef _LANGUANG_FLAG_
    
    my = [[LANGUANGAppViewControllerARC alloc]init];
    
#endif
    
#ifdef _XIANGYUAN_FLAG_
    
    my = [[XIANGYUANAppViewControllerARC alloc]init];
    
#endif
    myNavigationController = [mainViewController getNavigationVCwithRootVC:my];

    [my release];
    
    mArray[[eCloudConfig getConfig].myIndex] = myNavigationController;
    
    //    my.title=[StringUtil getAppLocalizableString:@"main_my"];
    //    my.tabBarItem = [self getTabbarItemWithTitle:@"我的" andImageName:@"icon_mine" andTag:1];
    //    [UIAdapterUtil setStatusBarColor:myNavigationController];
    
    
    // 创建通讯录界面及设置通讯录界面在tabbar上显示的位置
#ifdef _BGY_FLAG_
    
    //http://ydyywx1.bgy.com.cn:8090/appPage/worko/PAGE_WORK/work.html
    BGYTimelineViewControllerARC *agent = [[BGYTimelineViewControllerARC alloc]init];
    myNavigationController = [mainViewController getNavigationVCwithRootVC:agent];
    [agent release];
    
    mArray[[eCloudConfig getConfig].myIndex] = myNavigationController;
    
    
    //http://ydyywx1.bgy.com.cn:8090/appPage/worko/PAGE_WORK/work.html
//    BGYAgentViewControllerARC *agent = [[BGYAgentViewControllerARC alloc]init];
//    agent.urlstr = @"http://ydyywx1.bgy.com.cn:8090/appPage/worko/PAGE_WORK/work.html";
//    myNavigationController = [mainViewController getNavigationVCwithRootVC:agent];
//    
//    [agent release];
//    
//    mArray[[eCloudConfig getConfig].myIndex] = myNavigationController;
    
    
#endif
#ifdef _XINHUA_FLAG_
    XINHUAOrgViewControllerArc *orgVC = [[[XINHUAOrgViewControllerArc alloc] init]autorelease];
    orgNavigationController = [mainViewController getNavigationVCwithRootVC:orgVC];
    
    mArray[[eCloudConfig getConfig].orgIndex] = orgNavigationController;
#else
    
//    organizationalController = [[[NewOrgViewController alloc] init]autorelease];
#ifdef _LANGUANG_FLAG_
    
    LGWorkViewControllerArc *orgVC = [[[LGWorkViewControllerArc alloc] init]autorelease];
    orgNavigationController = [mainViewController getNavigationVCwithRootVC:orgVC];
    
    mArray[[eCloudConfig getConfig].orgIndex] = orgNavigationController;
    
#else
    
    NewOrgViewController *orgVC = [[[NewOrgViewController alloc] init]autorelease];
    orgNavigationController = [mainViewController getNavigationVCwithRootVC:orgVC];
    
    mArray[[eCloudConfig getConfig].orgIndex] = orgNavigationController;
    
#endif
    
#endif
    
    //    organizationalController = [[organizationalViewController alloc] init];
    //    organizationalController.title = [StringUtil getLocalizableString:@"main_concatas"];
    //    organizationalController.tabBarItem = [self getTabbarItemWithTitle:@"通讯录" andImageName:@"icon_contacts" andTag:2];
//    [UIAdapterUtil setStatusBarColor:orgNavigationController];
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        //工作圈界面
        AgentListController = [[[AgentListViewController alloc]init]autorelease];
        
        AgentListController.delegete = self;
        
        // 工作圈测试环境url
        NSString *testString= @"http://114.251.168.251:8080/worko/PAGE_WORK/index.html?VIEWSHOW_NOHEAD";
        // 工作圈正式环境url
        NSString *productString = @"http://moapproval.longfor.com:59650/worko/PAGE_WORK/index.html?VIEWSHOW_NOHEAD";
        // 工作圈的url默认是测试环境url
        NSString *Str = testString;
        // 当前运行的版本是否为正式环境
        if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
            Str = productString;
        }
        NSString *agentUrl = nil;
        // 参数拼接
        if ([Str rangeOfString:@"?"].length > 0) {
            agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",Str,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
        }else{
            agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",Str,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
        }
        
        AgentListController.urlstr = agentUrl;
        AgentListNavigationController = [mainViewController getNavigationVCwithRootVC:AgentListController];
        // 设置工作圈界面在tabbar上显示的位置顺序
        mArray[[eCloudConfig getConfig].settingIndex] = AgentListNavigationController;
        
    }else if ([UIAdapterUtil isGOMEApp]) {
#ifdef _GOME_FLAG_
        //        国美的设置界面
        GOMESettingViewController *gomeSetting = [[[GOMESettingViewController alloc]init]autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:gomeSetting];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
#endif

    }
#ifdef _TAIHE_FLAG_
    else if ([UIAdapterUtil isTAIHEApp]){
        
        TaiHeSettingViewController *taiHeSettingViewController = [[[TaiHeSettingViewController alloc] init]autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:taiHeSettingViewController];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
    }
#endif
    
#ifdef _XINHUA_FLAG_
    else if (1){
        XINHUASettingViewControllerArc *xinhuaSettingViewController = [[[XINHUASettingViewControllerArc alloc] initWithNibName:@"XINHUASettingViewControllerArc" bundle:nil]autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:xinhuaSettingViewController];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
    }
#endif
    
#ifdef _BGY_FLAG_
    else if (1){
        BGYWorkViewControllerArc *settingViewController = [[[BGYWorkViewControllerArc alloc] init]autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:settingViewController];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
        
        
        BGYHomePageViewController *homeCtl = [[[BGYHomePageViewController alloc] init] autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:homeCtl];
        mArray[[eCloudConfig getConfig].homepageIndex] = settingsNavigationController;
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    
    else if (1){
        
        LANGUANGMyViewControllerARC *my = [[[LANGUANGMyViewControllerARC alloc]init]autorelease];
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:my];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
        
    }
#endif
#ifdef _XIANGYUAN_FLAG_
    
    else if (1){
        
        XIANGYUANAgentViewControllerARC *my = [[[XIANGYUANAgentViewControllerARC alloc]init]autorelease];
//        my.urlstr = @"http://www.sunriver.cn/";
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:my];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
        
    }
    
#endif

    else{
        // 创建设置界面及设置设置界面在tabbar上显示的位置
        settingController = [[[settingViewController alloc] init]autorelease];
        settingController.delegete=self;
        
        settingsNavigationController = [mainViewController getNavigationVCwithRootVC:settingController];
        mArray[[eCloudConfig getConfig].settingIndex] = settingsNavigationController;
        
    }
 
    //    settingController.title = [StringUtil getLocalizableString:@"main_settings"];
    //    settingController.tabBarItem = [self getTabbarItemWithTitle:@"设置" andImageName:@"icon_setting" andTag:3];
    //    [settingController loadSettingView];
    //    [UIAdapterUtil setStatusBarColor:settingsNavigationController];
    

    
//    NSArray *controllers = [NSArray arrayWithObjects:conversationNavigationController,orgNavigationController,myNavigationController,settingsNavigationController,nil];
    
    // 将前面设置的控制器数组赋值给tabbar控制器控制器集合
    tabBarController.viewControllers = mArray;
    
    [self.navigationController.view addSubview:tabBarController.view];
    
    // 获取所有会话未读数
    int count=[[eCloudDAO getDatabase]getAllNumNotReadedMessge];

    // NSLog(@"---getAllNumNotReadedMessge-- count--: %d",count);
    // 根据未读数个数，设置会话控制器的未读角标数字
    if (count==0) {
        conversationNavigationController.tabBarItem.badgeValue =nil;
    }else{
	    conversationNavigationController.tabBarItem.badgeValue =[NSString stringWithFormat:@"%d",count];
    }
    
  //  [tabBarController release];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rcvOfflineMsgFinish) name:RCV_OFFLINE_MSG_NOTIFICATION object:nil];

	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectConvList:) name:BACK_TO_CONV_LIST_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectConvList:) name:AUTO_SELECT_CONVERSATION_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(js_notive:) name:js_list_NOTIFICATION object:nil];
    
//    add by shisp 增加接收登录通知，看是否有新版本
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmd:) name:LOGIN_NOTIFICATION object:nil];
    
    // 若会话列表界面不是tabbar上的第一个位置，则要重新进行获取未读数操作
    [self displayUnreadMsgNumber];
    
    // 已废弃，若存在新版本的话，在tabbar的设置界面显示new角标
    [self dspHasNewVersion];
  
    if ([eCloudConfig getConfig].needWaterMark){
        // 添加水印
        [self addWaterMark];
    }
    
#ifdef _XINHUA_FLAG_
    
    [UIAdapterUtil setSearchBarBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
#endif
    
}

#ifdef _GOME_FLAG_
- (void)isActivateMail
{
    GOMEActivateMailViewControllerArc *activateMailCV = [[[GOMEActivateMailViewControllerArc alloc] initWithNibName:@"GOMEActivateMailViewControllerArc" bundle:nil] autorelease];
    activateMailCV.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    [window addSubview:activateMailCV.view];
    [self addChildViewController:activateMailCV];
}
#endif

#pragma mark - 水印处理（目前国美专用）
/**
 添加水印
 */
- (void)addWaterMark
{
    if (self.waterMarkkLabel != nil)
    {
        return;
    }
    // 日期初始化
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (IPHONE_5S_OR_LESS)
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm"];
    }
    else
    {
        [formatter setDateFormat:@"yyyy/MM/dd/ HH:mm:ss"];
    }
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    NSString *str = [NSString stringWithFormat:[StringUtil getAppLocalizableString:@"water_mark_format"], [UserDefaults getUserAccount],time];

    self.waterMarkkLabel = [[[UILabel alloc] initWithFrame:CGRectMake(-15, 120, 200, 100)] autorelease];
    self.waterMarkkLabel.userInteractionEnabled = NO;
    self.waterMarkkLabel.numberOfLines = 0;
    self.waterMarkkLabel.textAlignment = NSTextAlignmentCenter;
    self.waterMarkkLabel.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [self.waterMarkkLabel setFont:[UIFont systemFontOfSize:18]];
    self.waterMarkkLabel.text = str;
#ifdef _LANGUANG_FLAG_
    
    self.waterMarkkLabel.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];
    
#else
    
    self.waterMarkkLabel.textColor = [UIColor colorWithWhite:0.78 alpha:0.025];
    
#endif
    
    // 将水印label添加到主window上
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window addSubview:self.waterMarkkLabel];
    [self.waterMarkkLabel release];
    
    self.waterMarkkLabel1 = [[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, 120, 200, 100)] autorelease];
    self.waterMarkkLabel1.userInteractionEnabled = NO;
    self.waterMarkkLabel1.numberOfLines = 0;
    self.waterMarkkLabel1.textAlignment = NSTextAlignmentCenter;
    self.waterMarkkLabel1.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [self.waterMarkkLabel1 setFont:[UIFont systemFontOfSize:18]];
    self.waterMarkkLabel1.text = str;
#ifdef _LANGUANG_FLAG_
    
    self.waterMarkkLabel1.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];
    
#else

    self.waterMarkkLabel1.textColor = [UIColor colorWithWhite:0.78 alpha:0.025];
    
#endif
    
    
    [delegate.window addSubview:self.waterMarkkLabel1];
    [self.waterMarkkLabel1 release];
    
    self.waterMarkkLabel2 = [[[UILabel alloc] initWithFrame:CGRectMake(-15, SCREEN_HEIGHT-200, 200, 100)] autorelease];
    self.waterMarkkLabel2.userInteractionEnabled = NO;
    self.waterMarkkLabel2.numberOfLines = 0;
    self.waterMarkkLabel2.textAlignment = NSTextAlignmentCenter;
    self.waterMarkkLabel2.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [self.waterMarkkLabel2 setFont:[UIFont systemFontOfSize:18]];
    self.waterMarkkLabel2.text = str;
#ifdef _LANGUANG_FLAG_
    
    self.waterMarkkLabel2.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];
    
#else
    
    self.waterMarkkLabel2.textColor = [UIColor colorWithWhite:0.78 alpha:0.025];
    
#endif
    
    [delegate.window addSubview:self.waterMarkkLabel2];
    [self.waterMarkkLabel2 release];
    
    self.waterMarkkLabel3 = [[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-195, SCREEN_HEIGHT-200, 200, 100)] autorelease];
    self.waterMarkkLabel3.userInteractionEnabled = NO;
    self.waterMarkkLabel3.numberOfLines = 0;
    self.waterMarkkLabel3.textAlignment = NSTextAlignmentCenter;
    self.waterMarkkLabel3.transform = CGAffineTransformMakeRotation(-M_PI_4);
    [self.waterMarkkLabel3 setFont:[UIFont systemFontOfSize:18]];
    self.waterMarkkLabel3.text = str;
#ifdef _LANGUANG_FLAG_
    
    self.waterMarkkLabel3.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:0.025];
    
#else
    
    self.waterMarkkLabel3.textColor = [UIColor colorWithWhite:0.78 alpha:0.025];
    
#endif
    
    [delegate.window addSubview:self.waterMarkkLabel3];
    [self.waterMarkkLabel3 release];
}


/**
 显示水印
 */
- (void)showWaterMark
{
    [self.waterMarkkLabel  setHidden:NO];
    [self.waterMarkkLabel1 setHidden:NO];
    [self.waterMarkkLabel2 setHidden:NO];
    [self.waterMarkkLabel3 setHidden:NO];
}

/**
 隐藏水印
 */
- (void)hideWaterMark
{
    [self.waterMarkkLabel  setHidden:YES];
    [self.waterMarkkLabel1 setHidden:YES];
    [self.waterMarkkLabel2 setHidden:YES];
    [self.waterMarkkLabel3 setHidden:YES];
}


/**
 已废弃，检查应答内容是否存在新的版本，若存在新版本则在设置界面显示  New  的字样
 */
-(void)dspHasNewVersion
{
    conn *_conn=[conn getConn];
	if(_conn.hasNewVersion)
    {
//        [tabBarController setTabarbadgeValue:@"new" withIndex:[eCloudConfig getConfig].settingIndex];
//        NSLog(@"%s",__FUNCTION__);
    }
}

/**
 显示会话未读消息数
 */
- (void)displayUnreadMsgNumber
{
    if ([eCloudConfig getConfig].conversationIndex > 0) {
        int count = [[eCloudDAO getDatabase]getAllNumNotReadedMessge];
        [tabBarController setTabarbadgeValue:[NSString stringWithFormat:@"%d",count] withIndex:[eCloudConfig getConfig].conversationIndex];
    }
}

/**
 接收通知后的处理方法

 @param notification 通知对象
 */
- (void)handleCmd:(NSNotification *)notification
{
    eCloudNotification *_object = notification.object;
    
    if (_object) {
        switch (_object.cmdId) {
            // 登录成功通知后的处理
            case login_success:
            {
                [self dspHasNewVersion];
            }
                break;
            default:
                break;
        }
    }
}

// 处理选中会话列表的通知
-(void)selectConvList:(NSNotification *)notification
{
    return;
}


/**
 (已作废)
 js调用通讯录列表通知处理方法

 @param notification 通知对象
 */
-(void)js_notive:(NSNotification *)notification
{
	if(self.tabBarController.selectedIndex != 1)
	{
		self.tabBarController.selectedIndex = 1;
	}
}

/**
 释放tabBarController控制器
 */
-(void)removeSomeview
{
    [tabBarController.view removeFromSuperview];
	[tabBarController release];
	tabBarController = nil;
}

-(void)back
{
  [self performSelector:@selector(removeSomeview) withObject:nil afterDelay:0.2];
  [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)backRoot
{
    AppDelegate * delegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
    if ([UIAdapterUtil isGOMEApp])
    {
#ifdef _GOME_FLAG_
        GOMELoginViewController *newLogin= [[GOMELoginViewController alloc]initWithNibName:@"GOMELoginViewController" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
#endif
    }
#ifdef _TAIHE_FLAG_
    else if([UIAdapterUtil isTAIHEApp])
    {
        TaiHeLoginViewController *newLogin= [[TaiHeLoginViewController alloc]initWithNibName:@"TaiHeLoginViewController" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
    }
#endif
    
#ifdef _LANGUANG_FLAG_
    else if(1)
    {
        LGLoginViewControllerArc *newLogin= [[LGLoginViewControllerArc alloc]initWithNibName:@"LGLoginViewControllerArc" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
    }
#endif

    
#ifdef _XINHUA_FLAG_
    else if(1)
    {
        XINHUALoginViewControllerArc *newLogin= [[XINHUALoginViewControllerArc alloc]initWithNibName:@"XINHUALoginViewControllerArc" bundle:nil];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
    }
#endif
    
#ifdef _XIANGYUAN_FLAG_
    else if(1)
    {
        XIANGYUANLoginViewControllerARC *loginController = [[XIANGYUANLoginViewControllerARC alloc]initWithNibName:@"XIANGYUANLoginViewControllerARC" bundle:nil];

        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:loginController];
        delegate.window.rootViewController = navigation;
        [navigation release];
        [loginController release];
    }
#endif

#ifdef _BGY_FLAG_
    else if(1)
    {
        BGYLoginViewController *loginController = [[BGYLoginViewController alloc]initWithNibName:@"BGYLoginViewController" bundle:nil];
        
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:loginController];
        delegate.window.rootViewController = navigation;
        [navigation release];
        [loginController release];
    }
#endif
    else
    {
        NewLoginViewController *newLogin= [[NewLoginViewController alloc]init];
        UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:newLogin];
        delegate.window.rootViewController = navigation;
        [newLogin release];
        [navigation release];
    }
    
    [self performSelector:@selector(removeSomeview) withObject:nil afterDelay:0.2];
}

// 是否支持旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// tabbar是否可以选中
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if(viewController == conversationNavigationController)
	{
//		如果切换到了会话列表界面，显示所有最近会话
		contactController.searchText = @"";
	}
    
	return YES;
}


/**
 (已作废)
 为底部tabbar按钮初始化标题及显示图片

 @param title     按钮名称
 @param imageName 图片名称
 @param _tag      按钮标识

 @return 组装后的UITabBarItem对象
 */
- (UITabBarItem *)getTabbarItemWithTitle:(NSString *)title andImageName:(NSString *)imageName andTag:(int)_tag
{
    NSString *_imageName = [NSString stringWithFormat:@"%@.png",imageName];
    NSString *_selectImageName = [NSString stringWithFormat:@"%@_click.png",imageName];
    
    UIImage *_image = [StringUtil getImageByResName:_imageName];
    UIImage *_selectImage = [StringUtil getImageByResName:_selectImageName];
    
    UITabBarItem *item;
    if (IOS7_OR_LATER) {
        item = [[UITabBarItem alloc]initWithTitle:title image:_image selectedImage:_selectImage];
        [item setFinishedSelectedImage:_selectImage withFinishedUnselectedImage:_image];
        item.tag = _tag;
    }
    else
    {
        item = [[UITabBarItem alloc] initWithTitle:title image:_image tag:_tag];
        [item setFinishedSelectedImage:_selectImage withFinishedUnselectedImage:_image];
    }
    return [item autorelease];
}

+ (UINavigationController *)getNavigationVCwithRootVC:(UIViewController *)root{
    UINavigationController *navigationVC = nil;
    if ([UINavigationController instancesRespondToSelector:@selector(interactivePopGestureRecognizer)])
    {
        navigationVC = [[[CBNavigationController alloc] initWithRootViewController:root]autorelease];
        
    }
    else
    {
        navigationVC = [[[MLNavigationController alloc] initWithRootViewController:root]autorelease];
    }
    return navigationVC;
}

- (void)rcvOfflineMsgFinish{
#ifdef _GOME_FLAG_
    if (START_GOME_MAIL) {
        //    判断一下通讯状态，如果已经就绪，就可以显示
        if (![GOMEUserDefaults getGomeShowEmailActiveFlag].length)
        {
            [self isActivateMail];
            [GOMEUserDefaults saveGomeShowEmailActiveFlag];
        }
    }
#endif
}

@end
