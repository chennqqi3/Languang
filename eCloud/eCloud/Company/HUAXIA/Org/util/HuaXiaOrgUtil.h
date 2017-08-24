//
//  HuaXiaOrgUtil.h
//  eCloud
//  使用这个程序可以打开华夏的通讯录选人界面，选择完成后，把结果返回给调用程序
//  Created by shisuping on 17/5/2.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 选择联系人界面打开类型 */
typedef enum{
    org_open_type_push = 0,
    org_open_type_present
}org_open_type_def;

/*
 从华夏办公系统获取用户资料结果结果block
 
 参数说明：
 empInfoDic:是从华夏获取到的用户资料数据
 userInfo:是IM获取用户资料时的上下文信息
 */
typedef void(^getHXEmpInfoByEmpIdResultBlock)(NSDictionary *empInfoDic,NSDictionary *userInfo);


/** 
 从华夏办公系统获取某人的头像block定义
 
 参数说明:
 empLogo:用户头像Image，如果不存在则返回nil
 userInfo:是IM获取用户头像时的上下文信息
 */
typedef void(^getHXEmpLogoByEmpIdResultBlock)(UIImage *empLogo,NSDictionary *userInfo);



/** 华夏选择联系人协议 */
@protocol HuaXiaOrgProtocol <NSObject>

- (void)didSelectHXUsers:(NSArray *)usersArray;

@end

@interface HuaXiaOrgUtil : NSObject

/** 最多选择人数 */
@property (nonatomic,assign) int maxUserCount;

/** 不能选择的人员数组 */
@property (nonatomic,retain) NSArray *disableSelectUserArray;

@property (nonatomic,assign) id<HuaXiaOrgProtocol> orgDelegate;

/** 联系人选择界面打开类型 */
@property (nonatomic,assign) int orgOpenType;

/** 打开联系人选择界面的界面 */
@property (nonatomic,retain) UIViewController *openVC;

/** 获取单例 */
+ (HuaXiaOrgUtil *)getUtil;

/** 打开选人界面 */
- (void)openSelectHXUserVC;

/** 异步获取华夏用户资料 */
- (NSDictionary *)getHXEmpInfoByEmpId:(int)empId withUserInfo:(NSDictionary *)userInfo withCompleteHandler:(getHXEmpInfoByEmpIdResultBlock)completeHandler;

/** 异步获取华夏用户头像 如果没有头像则返回nil*/
- (UIImage *)getHXEmpLogoByEmpId:(int)empId withUserInfo:(NSDictionary *)userInfo withCompleteHandler:(getHXEmpLogoByEmpIdResultBlock)completeHandler;

/** 打开华夏办公系统联系人资料界面 */
- (void)openHXUserInfoById:(int)empId andCurController:(UIViewController *)curController;

@end
