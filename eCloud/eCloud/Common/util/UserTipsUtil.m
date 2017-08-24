//
//  AlertUtil.m
//  eCloud
//
//  Created by shisuping on 14-9-19.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "UserTipsUtil.h"
#import "StringUtil.h"
#import "LCLLoadingView.h"
#import "conn.h"
#import "eCloudDefine.h"

@implementation UserTipsUtil

+ (void)showNoConnectAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:@"未连接" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

+ (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:message delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

+ (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}


+ (void)showAlert:(NSString *)message autoDimiss:(BOOL)autoDimiss
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:message delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    if (autoDimiss) {
        //        因为 iphone ios8 系统上，这段代码 会引起闪退，所以 不再执行 这个代码
        //        [self performSelector:@selector(dimissAlertView:) withObject:alert afterDelay:1.5];
    }
}

+(void)dimissAlertView:(UIAlertView *)alert{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

+ (void)showLoadingView:(NSString *)message
{
    [[LCLLoadingView currentIndicator]setCenterMessage:message];
    [[LCLLoadingView currentIndicator]showSpinner];
    [[LCLLoadingView currentIndicator]show];
}

+ (void)hideLoadingView
{
    [[LCLLoadingView currentIndicator]hiddenForcibly:true];
}

//查询时如果用户输入字符少于2个字符则提示用户
+ (void)showSearchTip
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[StringUtil getLocalizableString:@"search_tip"] message:@"" delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles: nil];
    [alert show];
    [alert release];
}

//提示无搜索结果
+ (void)setSearchResultsTitle:(NSString *)title andCurrentViewController:(UIViewController *)currentController
{
    for(UIView *subview in currentController.searchDisplayController.searchResultsTableView.subviews) {
        if([subview isKindOfClass:[UILabel class]]) {
            [(UILabel*)subview setText:title];
        }
    }
}

//用户不在群组中 无法发送任何类型的消息 talksessionView 和 forwardingRecentView 用到
+ (void)sendMsgForbidden
{
    [self showAlert:[StringUtil getLocalizableString:@"chats_talksession_group_remove_notice"]];
}

//add by shisp 检查网络是否正常
+ (BOOL)checkNetworkAndUserstatus
{
    conn *_conn = [conn getConn];
    
    if (![StringUtil isNetworkOK]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"check_network"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return NO;
    }
    else if (_conn.userStatus != status_online)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"user_is_offline"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return NO;
    }
    return YES;
}

+ (void)showForwardTips
{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:@"sent"]];
    [[LCLLoadingView currentIndicator]showTickView];
    [[LCLLoadingView currentIndicator]show];
}

+ (void)showForwardTips:(NSString *)message
{
    [[LCLLoadingView currentIndicator]setCenterMessage:[StringUtil getLocalizableString:message]];
    [[LCLLoadingView currentIndicator]showTickView];
    [[LCLLoadingView currentIndicator]show];
}

@end
