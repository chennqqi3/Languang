//
//  GXViewController.m
//  test11
//
//  Created by Pain on 14-7-23.
//  Copyright (c) 2014年 fengying. All rights reserved.
//

#import "GXViewController.h"

#import "contactViewController.h"

#import "GXCustomButton.h"
#import "NewAPPTagUtil.h"
#import "StringUtil.h"
#import "LogUtil.h"
#import "eCloudConfig.h"
#import "eCloudDefine.h"
#import "UIAdapterUtil.h"
#import "AppDelegate.h"
#ifdef _XIANGYUAN_FLAG_
#import "TabbarUtil.h"
#import "XIANGYUANAgentViewControllerARC.h"
#import "KxMenu.h"
#endif

// 标准状态栏高度
#define SYS_STATUSBAR_HEIGHT 20
// 热点高度
#define HOTSPOT_STATUSBAR_HEIGHT 20
// 正常高度
#define APP_STATUSBAR_HEIGHT  (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
// 是否连接热点
#define IS_HOTSPOT_CONNECTED  (APP_STATUSBAR_HEIGHT==(SYS_STATUSBAR_HEIGHT+HOTSPOT_STATUSBAR_HEIGHT)?YES:NO)
// 自定义tabbar上的按钮的基础索引，都是在此基础上进行递增
#define tag_base (11)
// 工作界面对应tabbar按钮的下标索引
#define WorkIndex (3)


@interface GXViewController (){
    /** 自定义的覆盖原先的tarbar的控件 */
    UIImageView *_tabBarView;
    /** 记录前一次选中的按钮 */
    GXCustomButton *_previousBtn;
    /** 底部tabbar按钮的个数 */
    int tabCount;
}
@end

@implementation GXViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTabBarItemTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //刷新通讯录语言
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLanguage) name:REFREASH_CONACTS_LANGUAGE object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reCalculateFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];

    NSLog(@"%s",__FUNCTION__);
    self.view.backgroundColor = [UIColor clearColor];
    
    //隐藏原先的tabBar
    [self hideSelfTabBar];
    CGRect frame = CGRectZero;
    if(IS_HOTSPOT_CONNECTED){
        frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y-HOTSPOT_STATUSBAR_HEIGHT, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    }else{
        frame = CGRectMake(self.tabBar.frame.origin.x, self.tabBar.frame.origin.y, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
    }
    _tabBarView = [[UIImageView alloc] initWithFrame:self.tabBar.frame];
    _tabBarView.userInteractionEnabled = YES;
//    _tabBarView.backgroundColor = [UIColor colorWithRed:52.0/255 green:54.0/255 blue:62.0/255 alpha:1.0];
    
#ifdef _LANGUANG_FLAG_

    _tabBarView.backgroundColor = [UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]];
#else
    
    _tabBarView.backgroundColor = [UIColor colorWithRed:242.0/255 green:245.0/255 blue:241.0/255 alpha:1.0];
    
#endif
    [self.view addSubview:_tabBarView];
    NSLog(@"_tabBarView.frame.size.width==%g",_tabBarView.frame.size.width);
    [_tabBarView release];
    
    tabCount = 4;
    if ([UIAdapterUtil isTAIHEApp] || [UIAdapterUtil isBGYApp]) {
        tabCount = 5;
    }
#ifdef _LANGUANG_FLAG_
    
        tabCount = 5;
#endif

#ifdef _XIANGYUAN_FLAG_
    
        tabCount = 5;
    
#endif
//    会话
    [self creatButtonWithNormalName:@"icon_conversation.png"andSelectName:@"icon_conversation_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_chats"]andIndex:[eCloudConfig getConfig].conversationIndex];
#ifdef _LANGUANG_FLAG_
    
    [self creatButtonWithNormalName:@"icon_work.png"andSelectName:@"icon_work_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_works"]andIndex:[eCloudConfig getConfig].orgIndex];
    
    [self creatButtonWithNormalName:@"icon_contacts.png"andSelectName:@"icon_contacts_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_cont"]andIndex:WorkIndex];
    
#else
    
    //    通讯录
    [self creatButtonWithNormalName:@"icon_contacts.png"andSelectName:@"icon_contacts_click.png"andTitle:[StringUtil getLocalizableString:@"main_contacts"]andIndex:[eCloudConfig getConfig].orgIndex];
    
#endif

   
//    我的
    if ([UIAdapterUtil isTAIHEApp]) {
        
        [self creatButtonWithNormalName:@"icon_main.png"andSelectName:@"icon_main_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].myIndex];
        
    }else if([UIAdapterUtil isLANGUANGApp]){
        
        [self creatButtonWithNormalName:@"icon_main.png"andSelectName:@"icon_main_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].myIndex];
        
    }
    else if([UIAdapterUtil isBGYApp]){
        
        [self creatButtonWithNormalName:@"icon_homepage.png"andSelectName:@"icon_homepage_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].homepageIndex];
        
        
        [self creatButtonWithNormalName:@"icon_mine.png"andSelectName:@"icon_mine_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].myIndex];
    }
    
#ifdef _XIANGYUAN_FLAG_
    
    else if((1)){
        
        [self creatButtonWithNormalName:@"icon_main.png"andSelectName:@"icon_main_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].myIndex];
        
    }
#endif
    
    else{
        
        [self creatButtonWithNormalName:@"icon_mine.png"andSelectName:@"icon_mine_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_my"]andIndex:[eCloudConfig getConfig].myIndex];
    }
    
    
    if ([UIAdapterUtil isHongHuApp]) {
        
        [self creatButtonWithNormalName:@"icon_found.png"andSelectName:@"icon_found_click.png"andTitle:[StringUtil getLocalizableString:@"main_contacts"] andIndex:[eCloudConfig getConfig].settingIndex];
    }else if([UIAdapterUtil isTAIHEApp]){
        [self creatButtonWithNormalName:@"icon_work.png"andSelectName:@"icon_work_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_works"]andIndex:WorkIndex];
        [self creatButtonWithNormalName:@"icon_mine.png"andSelectName:@"icon_mine_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_settings"]andIndex:[eCloudConfig getConfig].settingIndex];
    }

#ifdef _XIANGYUAN_FLAG_
    
    else if((1)){
        
        [self creatButtonWithNormalName:@"icon_work.png"andSelectName:@"icon_work_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_app"]andIndex:WorkIndex];
        [self creatButtonWithNormalName:@"icon_mine.png"andSelectName:@"icon_mine_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_settings"]andIndex:[eCloudConfig getConfig].settingIndex];
        
    }
#endif
    else{

        [self creatButtonWithNormalName:@"icon_setting.png"andSelectName:@"icon_setting_click.png"andTitle:[StringUtil getAppLocalizableString:@"main_settings"] andIndex:[eCloudConfig getConfig].settingIndex];

    }

//    设置
    UILabel *lineLab = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 0.5)];
    lineLab.backgroundColor = [UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1.0];
    [_tabBarView addSubview:lineLab];
    [lineLab release];
    
    GXCustomButton *btn = (GXCustomButton *)[_tabBarView viewWithTag:tag_base];// _tabBarView.subviews[0];
    [self changeViewController:btn];
}

-(void)hideSelfTabBar
{
    UITabBar *_tabBar = self.tabBar;
    UIView *contentView = [self.view.subviews objectAtIndex:0];
    CGRect _frame = contentView.frame;
    _frame.size = CGSizeMake(_frame.size.width,(_frame.size.height + _tabBar.frame.size.height));
    contentView.frame = _frame;
    self.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark 双击会话tabbar button
- (void)doubleTapConversationBtn
{
//    UINavigationController *firstNavigation = (UINavigationController *)[currentViewController.tabBarController.viewControllers objectAtIndex:[eCloudConfig getConfig].conversationIndex];
//    
//    contactViewController *contactView = (contactViewController *)[firstNavigation.viewControllers objectAtIndex:0];

    int convIndex = [eCloudConfig getConfig].conversationIndex;
    
    UINavigationController *convRoot = self.viewControllers[convIndex];
    UIViewController *rootVC = convRoot.viewControllers[0];
    if ([rootVC isKindOfClass:[contactViewController class]]) {
        contactViewController *convVC = (contactViewController *)rootVC;
        [convVC scrollToNextUnreadConv];
    }
    NSLog(@"123");
}

#pragma mark 创建自定义GXCustomButton按钮
 - (void)creatButtonWithNormalName:(NSString *)normal andSelectName:(NSString *)selected andTitle:(NSString *)title andIndex:(int)index {
     GXCustomButton *button = [GXCustomButton buttonWithType:UIButtonTypeCustom];
     button.tag = index + tag_base;
     
     CGFloat buttonW = _tabBarView.frame.size.width / tabCount;
     
     CGFloat buttonH = _tabBarView.frame.size.height;
     button.frame = CGRectMake(self.tabBar.frame.size.width/tabCount *index, 0.0 , buttonW, buttonH);
     
     [button setImage:[StringUtil getImageByResName:normal] forState:UIControlStateNormal];
     [button setImage:[StringUtil getImageByResName:selected] forState:UIControlStateDisabled];
     [button setTitle:title forState:UIControlStateNormal];
     [button setTitleColor:[UIColor colorWithRed:127/255.0 green:136/255.0 blue:145/255.0 alpha:1/1.0] forState:UIControlStateNormal];
     // changed by toxicanty 0811
     //[button setTitleColor:[UIColor colorWithRed:40.0/255 green:83.0/255 blue:142.0/255 alpha:1.0] forState:UIControlStateDisabled];
#ifdef _LANGUANG_FLAG_
     
//     [button setTitleColor:[UIColor colorWithRed:0/255 green:144/255 blue:211/255 alpha:1.0] forState:UIControlStateDisabled];
//        [button setTitleColor:[UIColor colorWithPatternImage:[StringUtil getImageByResName:@"oldRootDeptBtn1.png"]] forState:UIControlStateDisabled];
     [button setTitleColor: [UIColor colorWithRed:36/255.0 green:129/255.0 blue:252/255.0 alpha:1/1.0] forState:UIControlStateDisabled];
#else
     
     [button setTitleColor:[UIColor colorWithPatternImage:[StringUtil getImageByResName:@"rootDeptBtn1.png"]] forState:UIControlStateDisabled];
     
#endif
     
     [button addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventTouchDown];
     
     if (index == [eCloudConfig getConfig].conversationIndex){
//         [button removeTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventTouchUpInside];
         [button addTarget:self action:@selector(doubleTapConversationBtn) forControlEvents:UIControlEventTouchDownRepeat];
     }
     
     button.imageView.contentMode = UIViewContentModeCenter;
     button.titleLabel.textAlignment = NSTextAlignmentCenter;
     [button.titleLabel setFont:[UIFont systemFontOfSize:10]];
     if (IS_IPHONE) {
         [NewAPPTagUtil addAppTagView:button];
     }else{
         //         增加一个subview 宽度定为80 ，在这个view上显示新消息条数 tag定为50
         UIView *newMsgParentView = [[[UIView alloc]initWithFrame:CGRectMake((button.frame.size.width - 80) * 0.5, 0, 80, 44)]autorelease];
         newMsgParentView.backgroundColor = [UIColor clearColor];
         newMsgParentView.userInteractionEnabled = NO;
         [button addSubview:newMsgParentView];
         newMsgParentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin;
         newMsgParentView.tag = 50;
         [NewAPPTagUtil addAppTagView:newMsgParentView];
         
     }
     [_tabBarView addSubview:button];
     
 }

#pragma mark 按钮被点击时调用
- (void)changeViewController:(GXCustomButton *)sender{
    //切换不同控制器的界面
    self.selectedIndex = sender.tag - tag_base;
    
#ifdef _XIANGYUAN_FLAG_
    
    if (self.selectedIndex == 4) {
        
        UINavigationController *navigation = [[TabbarUtil getTabbarController].viewControllers objectAtIndex:self.selectedIndex];
        XIANGYUANAgentViewControllerARC *agent = [[[XIANGYUANAgentViewControllerARC alloc]init]autorelease];
        agent.urlstr = @"http://www.sunriver.cn/";
        agent.framWhere = XYGXViewController;
        [navigation pushViewController:agent animated:YES];
        return;
    }
    [KxMenu dismissMenu];
#endif
    
    // 泰禾 每切换3次回首页，就刷新一次OA界面
    if (self.selectedIndex == 0) {
        AppDelegate *appDelegate =(AppDelegate *) [[UIApplication sharedApplication]delegate];
//        appDelegate.changeAppCtrlCount++;
    }

    sender.enabled = NO;
    
    if (_previousBtn != sender) {
        _previousBtn.enabled = YES;
    }

    _previousBtn = sender;
}

- (void)activationTabbar{
    
    [self changeViewController:_previousBtn];
}
#pragma mark - 设置bageValue
- (void)setTabarbadgeValue:(NSString *)bageValue withIndex:(NSInteger)index{
    GXCustomButton *button = (GXCustomButton *)[_tabBarView viewWithTag:tag_base + index];// [_tabBarView.subviews objectAtIndex:index];
    if (IS_IPHONE) {
        [NewAPPTagUtil displayaddTagViewOnTabar:button withText:bageValue];
    }else{
        UIView *newMsgParentView = [button viewWithTag:50];
        if (newMsgParentView) {
            [NewAPPTagUtil displayaddTagViewOnTabar:newMsgParentView withText:bageValue];
        }
    }
}
#pragma mark - 未读数标签是否已显示
//- (BOOL)isDidShowTabarbadgeWithIndex:(NSInteger)index{
//    GXCustomButton *button = (GXCustomButton *)[_tabBarView viewWithTag:tag_base + index];
//    if (IS_IPHONE) {
//        [NewAPPTagUtil isDidShowTagViewOnTabar:button];
//    }
//}

- (void)hideTabar{
    if (![_tabBarView isHidden]) {
        _tabBarView.hidden = YES;
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
}


- (void)showTabar{
    if ([_tabBarView isHidden]) {
        _tabBarView.hidden = NO;
        [LogUtil debug:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    }
}

#pragma mark - 显示会话页面
- (void)showChatPage{
    GXCustomButton *btn = (GXCustomButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].conversationIndex];// _tabBarView.subviews[[eCloudConfig getConfig].conversationIndex];
    [self changeViewController:btn];
}

#pragma mark - 显示办公页面
- (void)showMyPage{
    GXCustomButton *btn = (GXCustomButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].myIndex];
    [self changeViewController:btn];
}

/**
 根据内容进行自动布局
 */
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    NSLog(@"%s",__FUNCTION__);
    
    [self setTabBarFrame];
    for (int _index = 0; _index < _tabBarView.subviews.count; _index ++) {
        UIButton *btn = (UIButton *)[_tabBarView viewWithTag:tag_base + _index];
        CGFloat buttonW = _tabBarView.frame.size.width / tabCount;
        CGFloat buttonH = _tabBarView.frame.size.height;
        btn.frame = CGRectMake(self.tabBar.frame.size.width/tabCount * _index, 0.0 , buttonW, buttonH);
    }
}

+ (void)displaySubViewOfView:(UIView *)view andLevel:(int)i
{
    if (i < 5) {
        [LogUtil debug:[NSString stringWithFormat:@"level is %d ;%@",i,view]];
    }
    for (UIView *subview in view.subviews) {
        [self displaySubViewOfView:subview andLevel:i+1];
    }
}

/**
 设置tabbar的frame
 */
- (void)setTabBarFrame
{
    if (self.view.frame.origin.y > 0) {
        CGRect _frame = self.tabBar.frame;
        _frame.origin.y = _frame.origin.y - self.view.frame.origin.y;
        _tabBarView.frame = _frame;
    }else{
        _tabBarView.frame = self.tabBar.frame;
        
//        [LogUtil debug:[NSString stringWithFormat:@"%s system tabbar frame is %@",__FUNCTION__,NSStringFromCGRect(self.tabBar.frame)]];
        
        if ((_tabBarView.frame.origin.y + _tabBarView.frame.size.height) > SCREEN_HEIGHT) {
            CGRect _frame = _tabBarView.frame;
            _frame.origin.y = SCREEN_HEIGHT - _tabBarView.frame.size.height;
            _tabBarView.frame = _frame;
        }
    }
//    [LogUtil debug:[NSString stringWithFormat:@"%s tabbar frame is %@",__FUNCTION__,NSStringFromCGRect(_tabBarView.frame)]];
}

/**
 重新设置frame
 */
- (void)reCalculateFrame
{
    [LogUtil debug:[NSString stringWithFormat:@"%s 状态栏有变化 现在高度是%.0f tabbar父viewframe is %@ screen 尺寸 is %@",__FUNCTION__,[StringUtil getStatusBarHeight],NSStringFromCGRect(self.view.frame),NSStringFromCGRect([UIScreen mainScreen].bounds)]];
    
    //    [GXViewController displaySubViewOfView:self.view andLevel:0];
    //    CGRect _frame = self.tabBar.frame;
    //    _frame.origin =  CGPointMake(0, SCREEN_HEIGHT - self.tabBar.frame.size.height - ([StringUtil getStatusBarHeight] - 20));
    //    _tabBarView.frame = _frame;// self.tabBar.frame;
    
    [self setTabBarFrame];
    
    for (UINavigationController *navigation in self.viewControllers) {
        UIViewController *rootController = navigation.viewControllers[0];
        if ([rootController respondsToSelector:@selector(reCalculateFrame)]) {
            [rootController reCalculateFrame];
        }
    }
}
/**
 切换语言后，收到通知更改tabbar按钮上的标题
 */
- (void)refreshLanguage
{
    [self setTabBarItemTitle];
}

/**
 设置tabbar按钮上的标题名称
 */
- (void)setTabBarItemTitle
{
    //    会话
    UIButton *btn0 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].conversationIndex];
    [btn0 setTitle:[StringUtil getAppLocalizableString:@"main_chats"] forState:UIControlStateNormal];
    
    //通讯录
#ifdef _LANGUANG_FLAG_
    
#else
        UIButton *btn1 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].orgIndex];
        [btn1 setTitle:[StringUtil getLocalizableString:@"main_contacts"] forState:UIControlStateNormal];
#endif
        
    //    我的
    UIButton *btn2 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].myIndex];
    [btn2 setTitle:[StringUtil getAppLocalizableString:@"main_my"] forState:UIControlStateNormal];
    
    //    设置
    UIButton *btn3;
    if ([UIAdapterUtil isHongHuApp]) {
        btn3 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].settingIndex];
        [btn3 setTitle:[StringUtil getLocalizableString:@"main_found"] forState:UIControlStateNormal];
    }else{
        btn3 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].settingIndex];
        [btn3 setTitle:[StringUtil getAppLocalizableString:@"main_settings"] forState:UIControlStateNormal];
    }
    
    if ([UIAdapterUtil isTAIHEApp]) {
        UIButton *btn4 = (UIButton *)[_tabBarView viewWithTag:tag_base + WorkIndex];
        [btn4 setTitle:[StringUtil getAppLocalizableString:@"main_works"] forState:UIControlStateNormal];
    }
    
    if ([UIAdapterUtil isBGYApp]) {
        UIButton *btn4 = (UIButton *)[_tabBarView viewWithTag:tag_base + [eCloudConfig getConfig].homepageIndex];
        [btn4 setTitle:[StringUtil getAppLocalizableString:@"main_works"] forState:UIControlStateNormal];
    }

#ifdef _GOME_FLAG_
    
    [btn0.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btn1.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btn2.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [btn3.titleLabel setFont:[UIFont systemFontOfSize:12]];
  
#endif

}
@end
