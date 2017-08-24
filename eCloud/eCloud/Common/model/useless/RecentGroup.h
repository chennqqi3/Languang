//
//  RecentGroup.h
//  eCloud
//
//  Created by  lyong on 13-12-10.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecentGroup : NSObject
{
//	部门id
int _type_id;
//	部门名称
NSString *_type_name;
//	父部门名称
NSString *_ftype_name;
//	上级部门
int _type_parent;
//	公司id
int _type_comp_id;

bool _isChecked;
//	展开状态
bool _isExtended;
//级别
int _type_level;
//	是否显示
bool _display;
//	是否已经展开过
bool _firstExtend;

int totalNum;
int onlineNum;
 NSString *_conv_id;

}
@property(nonatomic,assign)int totalNum;
@property(nonatomic,assign)int onlineNum;
@property(nonatomic,assign) int type_id;
@property(nonatomic,retain) NSString *type_name;
@property(nonatomic,retain) NSString *ftype_name;
@property(nonatomic,retain) NSString *type_tel;
@property(nonatomic,assign) int type_parent;
@property(nonatomic,assign) int type_comp_id;
@property(nonatomic,assign) bool isChecked;
@property(nonatomic,assign) bool isExtended;
@property(nonatomic,assign) int type_level;
@property(nonatomic,assign) bool display;
@property(nonatomic,assign) bool firstExend;
@property(nonatomic,retain) NSString *conv_id;
@end