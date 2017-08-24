//
//  APPPermissionModel.h
//  eCloud
//
//  Created by Pain on 14-7-9.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APPPermissionModel : NSObject{
    
}
//对应的权限值
@property (nonatomic,assign) BOOL canOpenContactList;//是否具备打开通讯录的权限
@property (nonatomic,assign) BOOL canInviteChat;//是否能够发起会话
@property (nonatomic,assign) BOOL canOpenContact;//是否查看联系人详细信息
@property (nonatomic,assign) BOOL canGetUserStatus;//是否可以查看状态
@property (nonatomic,assign) BOOL canShare2wangxin;//是否可以分享

@property (nonatomic,retain) NSString *permissionStr;

//对应的权限值
- (void)setPermission:(int)permission;

@end
