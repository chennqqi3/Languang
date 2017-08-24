//
//  APPPermissionModel.m
//  eCloud
//
//  Created by Pain on 14-7-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "APPPermissionModel.h"
#import "StringUtil.h"

@interface APPPermissionModel ()
{
    
}
@end;


@implementation APPPermissionModel

@synthesize canOpenContactList;
@synthesize canInviteChat;
@synthesize canOpenContact;
@synthesize canGetUserStatus;
@synthesize canShare2wangxin;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.canOpenContactList = NO;
        self.canInviteChat = NO;
        self.canOpenContact = NO;
        self.canGetUserStatus = NO;
        self.canShare2wangxin = NO;
    }
    return self;
}

- (void)setPermission:(int)permission
{
    self.permissionStr = [StringUtil toBinaryStr:permission andByteCount:2];
}

- (NSString *)getStringByLocation:(int)location
{
    NSRange _range = NSMakeRange(location, 1);
    NSString *subStr = [self.permissionStr substringWithRange:_range];
    return subStr;
}

#pragma mark - 打开通讯录的权限
- (BOOL)canOpenContactList{
    NSString *subStr = [self getStringByLocation:15];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 发起会话
- (BOOL)canInviteChat{
    NSString *subStr = [self getStringByLocation:14];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 查看联系人详细信息
- (BOOL)canOpenContact{
    NSString *subStr = [self getStringByLocation:13];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 查看状态
- (BOOL)canGetUserStatus{
    NSString *subStr = [self getStringByLocation:12];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}

#pragma mark - 分享
- (BOOL)canShare2wangxin{
    NSString *subStr = [self getStringByLocation:11];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}


@end
