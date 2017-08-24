//
//  PermissionUtil.m
//  eCloud
//
//  Created by shisuping on 14-4-11.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "PermissionUtil.h"
#import "Emp.h"
#import "StringUtil.h"

@implementation PermissionUtil

#pragma mark 如果对方设置了消息屏蔽，那么应该提示用户
+ (void)showAlertWhenCanNotSendMsg:(Emp*)emp
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[StringUtil getLocalizableString:@"can_not_send_msg"] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"]  otherButtonTitles:nil, nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
    [alert release];
}

#pragma mark 如果对方设置了隐藏，那么应该提示用户
+ (void)showAlertWhenCanNotSee:(Emp*)emp
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[StringUtil getAlertTitle] message:[NSString stringWithFormat:[StringUtil getLocalizableString:@"can_not_see"],emp.emp_name] delegate:nil cancelButtonTitle:[StringUtil getLocalizableString:@"confirm"] otherButtonTitles:nil, nil];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [alert show];
    [alert release];
}

#pragma mark 如果对方设置了资料隐藏，那么显示不可见
+ (NSString *)getHideInfoStr
{
   return @"";//NSLocalizedString(@"hide_info", @"");
}
@end
