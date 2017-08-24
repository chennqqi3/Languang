//
//  permissionModel.m
//  eCloud
//
//  Created by shisuping on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "PermissionModel.h"
#import "StringUtil.h"
@interface PermissionModel ()
{
    
}
@property (nonatomic,retain) NSString *permissionStr;
@end;

@implementation PermissionModel
{
}
@synthesize isHidden;
@synthesize isHideAllInfo;
@synthesize isHidePartInfo;
@synthesize canSendMsg;
@synthesize hideState;

- (id)init
{
    self = [super init];
    if(self)
    {
        self.isHidden = NO;
        self.isHideAllInfo = NO;
        self.isHidePartInfo = NO;
        self.canSendMsg = YES;
    }
    return self;
}
-(void)dealloc
{
    self.permissionStr = nil;
    [super dealloc];
}

- (void)setPermission:(int)permission
{
    self.permissionStr = [StringUtil toBinaryStr:permission andByteCount:1];
}

- (NSString *)getStringByLocation:(int)location
{
    NSRange _range = NSMakeRange(location, 1);
    NSString *subStr = [self.permissionStr substringWithRange:_range];
    return subStr;
}

- (BOOL)canSendMsg
{
    NSString *subStr = [self getStringByLocation:4];
    if(subStr.intValue == 0)
    {
        return YES;
    }
    return NO;
}

-(BOOL)isHidden
{
    NSString *subStr = [self getStringByLocation:7];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;    
}

-(BOOL)isHideAllInfo
{
//    NSString *subStr = [self getStringByLocation:5];
//    if(subStr.intValue == 1)
//    {
//        return YES;
//    }
    return NO;
}

-(BOOL)isHidePartInfo
{
    NSString *subStr = [self getStringByLocation:6];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}

- (BOOL)hideState
{
    NSString *subStr = [self getStringByLocation:5];
    if(subStr.intValue == 1)
    {
        return YES;
    }
    return NO;
}
@end
