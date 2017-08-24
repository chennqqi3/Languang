//
//  SpecialListModel.h
//  eCloud
//  特殊用户
//  Created by shisuping on 14-4-7.
//  Copyright (c) 2014年  lyong. All rights reserved.
//
//typedef  struct  _special_list
//{
//	UINT32  dwSpecialID;		//特殊用户或部门ID
//	UINT8	cOpType;		//操作类型 0：增加 1：删除
//	UINT8 	cIdType;			//ID 类型
//	UINT8	cHideType;		//隐藏类型
//}SpecialList_t;

#import <Foundation/Foundation.h>

@interface SpecialListModel : NSObject
{
    
}
@property (assign) int userId;
@property (assign) int userType;
@property (assign) int hideType;
@property (assign) int updateType;
@end
