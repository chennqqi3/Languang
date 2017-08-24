//
//  TabbarUtil.m
//  eCloud
//
//  Created by shisuping on 15-10-21.
//  Copyright (c) 2015年  lyong. All rights reserved.
//

#import "TabbarUtil.h"
#import "NewMyViewControllerOfCustomTableview.h"
#import "talkSessionViewController.h"
#import "contactViewController.h"
#import "eCloudConfig.h"
#import "LogUtil.h"
#import "AgentListViewController.h"
#import "ServerConfig.h"
#import "UserDefaults.h"
//#import "AudioPlayForIOS6.h"

#ifdef _XIANGYUAN_FLAG_
#import "XIANGYUANAppViewControllerARC.h"
#endif
static UITabBarController *tabbarController;

@implementation TabbarUtil

//获取tabbarController引用
+ (UITabBarController *)getTabbarController
{
    return tabbarController;
}

+ (void)setTabbarController:(UITabBarController *)_tabbarController
{
    tabbarController = _tabbarController;
}

//+ (BOOL)isDidShowTabbarBageWithIndex:(int)index
//{
//    if ([tabbarController respondsToSelector:@selector(isDidShowTabarbadgeWithIndex:)]) {
//        [tabbarController isDidShowTabarbadgeWithIndex:index];
//    }
//    
//}

+ (void)setTabbarBage:(NSString *)badgeValue andTabbarIndex:(int)index
{
    if ([tabbarController respondsToSelector:@selector(setTabarbadgeValue:withIndex:)]) {
        [tabbarController setTabarbadgeValue:badgeValue withIndex:index];
    }
}

+ (void)showMyPage
{
    if (tabbarController && tabbarController.selectedIndex != [eCloudConfig getConfig].myIndex) {
        if ([tabbarController respondsToSelector:@selector(showMyPage)] )
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s 点击代办通知 切换到办公界面",__FUNCTION__]];
            [tabbarController showMyPage];
        }
    }
}

//点击轻应用通知时，需要根据通知带的信息确定是直接打开URL还是打开轻应用的首页，还是什么都不做
+ (void)saveStartAppInfo:(NSDictionary *)appInfo
{
    if (tabbarController) {
        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].myIndex];
        [navigation popToRootViewControllerAnimated:YES];
        UIViewController  *agentView = [navigation.viewControllers objectAtIndex:0];
        
#ifdef _XIANGYUAN_FLAG_
       
        if ([agentView isKindOfClass:[XIANGYUANAppViewControllerARC class]]) {
            ((XIANGYUANAppViewControllerARC*)agentView).appInfo = appInfo;
        }
        
#else
        if ([agentView isKindOfClass:[NewMyViewControllerOfCustomTableview class]]) {
            ((NewMyViewControllerOfCustomTableview*)agentView).appInfo = appInfo;
        }
        
#endif
        
    }
}

+ (void)autoOpenAgentList
{
    if (tabbarController) {
        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].myIndex];
        [navigation popToRootViewControllerAnimated:YES];
        UIViewController  *agentView = [navigation.viewControllers objectAtIndex:0];
        if ([agentView respondsToSelector:@selector(autoOpenAgentList)]) {
            
            [LogUtil debug:[NSString stringWithFormat:@"%s 自动打开代办列表",__FUNCTION__]];
            [agentView autoOpenAgentList];
        }
    }
}

+ (void)showChatPage
{
    if (tabbarController && tabbarController.selectedIndex != [eCloudConfig getConfig].conversationIndex)
    {
        if ([tabbarController respondsToSelector:@selector(showChatPage)])
        {
            [LogUtil debug:[NSString stringWithFormat:@"%s 点击消息通知 切换到会话列表界面",__FUNCTION__]];
            [tabbarController showChatPage];
        }
    }
}

//判断当被从群组中移除时，是否需要弹框提示
+ (BOOL)needAlertWhenRemoveFromGroup:(NSString *)grpId;
{
    if (tabbarController && tabbarController.selectedIndex == [eCloudConfig getConfig].conversationIndex){
        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].conversationIndex];
        UIViewController *topVC = navigation.topViewController;
        if ([topVC isKindOfClass:[contactViewController class]]) {
            return NO;
        }
        if ([[talkSessionViewController getTalkSession].convId isEqualToString:grpId]) {
            return YES;
        }
    }
    return NO;
}

//弹出被移除提示，确定后回到会话列表界面
+ (void)backToRootContact
{
    if (tabbarController && tabbarController.selectedIndex == [eCloudConfig getConfig].conversationIndex){
        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].conversationIndex];
        [navigation popToRootViewControllerAnimated:YES];
    }
}

//是否正在显示泰禾首页
+ (BOOL)displayTaiHeHomePage
{
    if (tabbarController && tabbarController.selectedIndex == [eCloudConfig getConfig].myIndex){
        
        return YES;
    }
    return NO;
}

//刷新发现界面
+ (void)refreshFoundInterface{
    
    if (tabbarController) {

        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].settingIndex];
      
        UIViewController  *agentView = [navigation.viewControllers objectAtIndex:0];
        if ([agentView isKindOfClass:[AgentListViewController class]]) {
            
            NSString *testString= @"http://114.251.168.251:8080/worko/PAGE_WORK/index.html?VIEWSHOW_NOHEAD";
            NSString *productString = @"http://moapproval.longfor.com:59650/worko/PAGE_WORK/index.html?VIEWSHOW_NOHEAD";
            
            NSString *Str = testString;
            if ([[ServerConfig shareServerConfig].primaryServer rangeOfString:@"mop.longfor.com"].length > 0) {
                Str = productString;
            }
            NSString *agentUrl = nil;
            if ([Str rangeOfString:@"?"].length > 0) {
                agentUrl = [NSString stringWithFormat:@"%@&token=%@&usercode=%@",Str,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
            }else{
                agentUrl = [NSString stringWithFormat:@"%@?token=%@&usercode=%@",Str,[UserDefaults getLoginToken],[UserDefaults getUserAccount]];
            }

            ((AgentListViewController *)agentView).urlstr = agentUrl;
            [LogUtil debug:[NSString stringWithFormat:@"%s 刷新工作圈",__FUNCTION__]];
        }
    }
}

+ (UIViewController *)getConvTabTopVC{
    if (tabbarController) {
        
        UINavigationController *navigation = [tabbarController.viewControllers objectAtIndex:[eCloudConfig getConfig].conversationIndex];
        
        return navigation.topViewController;
    }
    return nil;
}

@end
