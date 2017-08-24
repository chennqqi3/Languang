//
//  PermissionDAO.h
//  eCloud
//  权限使用到的数据库表

//  Created by shisuping on 14-4-2.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "eCloud.h"


/*
 黑名单表
 UINT32  dwSpecialID;		//特殊用户或部门ID
 UINT8 	cIdType;			//ID 类型
 UINT8	cHideType;		//隐藏类型
// 增加一列，是否黑名单，这张表可以保存所有的特殊用户或部门，默认不是黑名单,0
 */
#define table_black_list @"black_list"
#define create_black_list_table @"create table if not exists black_list (user_id integer,user_type integer,hide_type integer, isblack integer default 0, primary key (user_id,user_type))"


/*
 白名单表 和当前登录用户相关的白名单数据
 UINT32  dwSpecialID;		//特殊用户或部门ID
 UINT8 	cIdType;			//ID 类型
 UINT8	dwWhiteID;		//白名单id
 */
#define table_white_list @"white_list"
#define create_white_list_table @"create table if not exists white_list (special_id integer,special_type integer,white_id integer)"

@class BlackListModel;
@class WhiteListModel;
@class SpecialListModel;

@interface PermissionDAO : eCloud

@property (assign) BOOL needReComputeDeptEmpCout;

+ (id)getDatabase;

//增加一个特殊用户
- (void)addSpeicalUser:(BlackListModel *)_model;

//修改一个特殊用户
- (void)updateSpecialUser:(BlackListModel *)_model;

//删除一个特殊用户
- (void)deleteSpecialUser:(BlackListModel *)_model;

//根据用户id和用户类型获取一个特殊用户的资料
- (BlackListModel *)getSpeicialUser:(int)userId andUserType:(int)userType;

#pragma mark 如果某个特殊用户的白名单变了，那么只是修改下是否黑名单列
- (void)updateSpecialUserBlackFlag:(BlackListModel *)_model;

//有必要就重新计算部门人数
- (void)reComputeDeptEmpCountIfNeed;

//增加一个白名单
- (void)addWhiteUser:(WhiteListModel *)model;

//删除一个白名单
- (void)deleteWhiteUser:(WhiteListModel *)model;

//判断一个特殊用户，是否是黑名单
- (BOOL)isBlack:(BlackListModel *)model;

//如果是员工，那么是增加，那么就保存为是特殊用户，如果是删除，那么久保存为不是特殊用户，并且修改内存里的值
- (void)saveIfIsSpecial:(SpecialListModel *)model;
@end
