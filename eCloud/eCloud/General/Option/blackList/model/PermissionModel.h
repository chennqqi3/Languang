//
//  permissionModel.h
//  eCloud
//
//  Created by shisuping on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PermissionModel : NSObject

////对应的权限值
//@property (assign) int permission;
//是否隐藏
@property (nonatomic,assign) BOOL isHidden;
//是否隐藏全部资料
@property (nonatomic,assign) BOOL isHideAllInfo;
//是否隐藏部分资料
@property (nonatomic,assign) BOOL isHidePartInfo;
//是否可以发消息
@property (nonatomic,assign) BOOL canSendMsg;
//是否屏蔽状态
@property (nonatomic,assign) BOOL hideState;


//对应的权限值
- (void)setPermission:(int)permission;
@end
