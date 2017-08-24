//
//  WhiteListModel.h
//  eCloud
// 白名单
//  Created by shisuping on 14-4-7.
//  Copyright (c) 2014年  lyong. All rights reserved.
//
////白名单结构
//typedef  struct  _white_list
//{
//	UINT32  dwSpecialID;		//特殊用户或部门ID
//	UINT32  dwWhiteID;		//普通用户或部门ID
//	UINT32	nWhiteTime;		//白名单时间戳
//	UINT8	cOpType;		//操作类型 0：增加 1：删除
//	UINT8 	cIdType;			//ID 类型
//}WhiteList_t;

#import <Foundation/Foundation.h>

@interface WhiteListModel : NSObject
{
    
}
@property (assign) int userId;
@property (assign) int userType;
@property (assign) int whiteUserId;
@property (assign) int updateType;

@end
