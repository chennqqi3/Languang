//
//  VirtualGroupMemberModel.h
//  eCloud
//
//  Created by yanlei on 15/12/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VirtualGroupMemberModel : NSObject

// 虚拟组ID
@property (nonatomic,retain) NSString *groupid;
// 虚拟组成员ID
@property (nonatomic,assign) int userid;
// 虚拟组成员状态1 正常提供服务，2暂停服务
@property (nonatomic,assign) int svc_status;
// 更新时间
@property (nonatomic,retain) NSString *update_time;
// 状态类型
@property (nonatomic,assign) int update_type;

@end
