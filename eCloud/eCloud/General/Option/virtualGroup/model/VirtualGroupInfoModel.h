//
//  VirtualGroupInfoModel.h
//  eCloud
//
//  Created by yanlei on 15/12/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirtualGroupInfoModel : NSObject
// 虚拟组主账号
@property (nonatomic,assign) int main_userid;
// 虚拟组ID
@property (nonatomic,retain) NSString *groupid;
// 虚拟组成员个数
@property (nonatomic,assign) int member_num;
// 单个成员支持人员上限
@property (nonatomic,assign) int single_svc_num;
// 服务过期时间，单位分钟
@property (nonatomic,assign) int timeout_minute;
// 等待提示语
@property (nonatomic,retain) NSString *waiting_prompt;
// 挂断提示语
@property (nonatomic,retain) NSString *hangup_prompt;
// 接通提示语
@property (nonatomic,retain) NSString *oncall_prompt;
// 是否显示真是账号 0不显示，非0显示
@property (nonatomic,assign) int real_code;
// 更新时间
@property (nonatomic,retain) NSString *update_time;
// 更新状态
@property (nonatomic,assign) int update_type;

// 虚拟组成员集合
@property (nonatomic,retain) NSMutableArray *virtualMemberArray;

@end
