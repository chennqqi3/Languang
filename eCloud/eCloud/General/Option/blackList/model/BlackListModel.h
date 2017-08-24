//
//  BlackListModel.h
//  eCloud
//  黑名单
//  Created by shisuping on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PermissionModel;

//用户类型，用户还是部门
typedef enum
{
    type_emp = 0,
    type_dept
}blackUserType;

@interface BlackListModel : NSObject
{
}

@property (nonatomic,assign) int userId;
@property (nonatomic,assign) int userType;
@property (nonatomic,assign) int hideType;
@property (nonatomic,assign) int isBlack;
@property (retain) PermissionModel *permission;

@end
