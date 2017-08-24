//
//  Emp.h
//  eCloud
//
//  Created by robert on 12-9-26.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Dept;
@class PermissionModel;

@interface Emp : NSObject

/** 用户id */
@property (assign) int emp_id;

/** 用户姓名 */
@property (nonatomic,retain) NSString *emp_name;

/** 用户性别 */
@property(assign) int emp_sex;

/** 用户状态 */
@property(assign) int emp_status;

/** 用户所在部门 */
@property(assign)int emp_dept;

/** 用户级别 */
@property (assign) int emp_level;

/** 用户邮件 */
@property(retain)NSString *emp_mail;

/** 用户办公电话 */
@property(retain)NSString *emp_tel;

/** 用户家庭电话 */
@property(retain)NSString *emp_hometel;

/** 用户紧急电话 */
@property(retain)NSString *emp_emergencytel;

/** 部门名称 */
@property(retain)NSString *deptName;

/** 职务 */
@property(retain)NSString *titleName;

/** 用户手机 */
@property(retain) NSString *emp_mobile;

/** 用户logo */
@property(nonatomic,retain) NSString *emp_logo;

/** 公司id */
@property(assign) int comp_id;

/** 用户工号 */
@property(retain) NSString* empCode;

/** 用户签名 */
@property(retain) NSString * signature;

/** 登录类型 */
@property(assign) int loginType;

/** 姓名简拼 */
@property(nonatomic,retain) NSString* empPinyinSimple;

/** add by shisp 增加empPinyin 全拼 */
@property(retain) NSString *empPinyin;

/** 生日 */
@property (nonatomic,assign) int birthday;
@property (nonatomic,retain) NSString *birthdayStr;

/** 传真 */
@property (nonatomic,retain) NSString *empFax;

/** 地址 */
@property (nonatomic,retain) NSString *empAddress;

/** 邮编 */
@property (nonatomic,retain) NSString *empPostCode;

/** 英文名字 */
@property (nonatomic,retain) NSString *empNameEng;

/** 是否缺省常用联系人 */
@property(nonatomic,assign) BOOL isDefaultCommonEmp;

/** 是否已经获取了详细资料 */
@property(assign)bool info_flag;

@property(assign) bool display;


@property(retain) NSString *parent_dept_list;

@property(retain) Dept *parentDept;

/** 对于一呼百应消息，需要展示消息的读取情况，如果已读，那么需要显示已读时间，这里增加一个字段保存这个已读时间 */
@property(assign) int msgReadTime;
@property(assign) int unread;


@property (nonatomic,retain) PermissionModel *permission;

/** 是否是特殊用户 */
@property (assign) BOOL isSpecial;

/** 是否屏蔽了消息 true是 */
@property (nonatomic,assign) BOOL isNotRcvMsg;

/** 是否是固定组管理员 */
@property (nonatomic,assign) BOOL isAdmin;

/** 增加根据empId来排序 */
- (NSComparisonResult)compareByEmpId:(Emp *) anotherElement;

/** 排序字段 */
@property (nonatomic,assign) int empSort;

/** 用户的头像属性 */
@property (nonatomic,retain) UIImage *logoImage;

/** 是默认头像还是用户自己的头像 */
@property (nonatomic,assign) BOOL isUserLogo;

/** 是否机器人 */
@property (nonatomic,assign) BOOL isRobot;

/** 查看是否已经加到了搜索结果里 */
@property (nonatomic,assign) BOOL isAddToSearchResult;


/** 新建一个方法，只是简单的设置empid属性，不考虑是否机器人 */
- (void)setEmpId:(int)emp_id;

/** 是否被选中 */
@property(assign) bool isSelected;

/** 是否可选 */
@property (nonatomic,assign) BOOL canChoose;

-(NSString *)toString;

/** 如果name为空，返回code，否则返回empId */
-(NSString*)getEmpName;

/** 返回对象自己占多少字节 */
-(int)getLength;

/**
 功能描述
 泰和 是否是应用通知消息账号 通过判断 empcode的值
 目前有以下几种工号
 会议：Meeting
 待办：todo
 邮件：email
 考勤：Attendance
 */

#define MEETING_EMP_CODE @"Meeting"
#define EMAIL_EMP_CODE @"email"
#define DAIBAN_EMP_CODE @"todo"
#define ATTENDANCE_EMP_CODE @"Attendance"

- (BOOL)isAppNoticeAccount;

@end
