//
//  CreateGroupUtil.h
//  eCloud
// 华夏只集成IM功能，通讯录要求使用华夏自己的，所以创建讨论组、讨论组加人界面都不能在选人界面完成，选人界面只负责选人，选到人之后，再进行业务处理，这里可以根据选择的人创建一个讨论组
//  Created by shisuping on 17/4/19.
//  Copyright © 2017年 网信. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForwardingProtocol.h"
#import "CreateGroupDefine.h"
@interface CreateGroupUtil : NSObject

/** 业务类型 创建会话、添加成员、转发消息 */
@property (nonatomic,assign) int typeTag;
/** 打开联系人选择界面的VC 比如 会话列表界面 通讯录界面 聊天资料界面 转发选人界面，但是目前只有聊天资料界面使用了这个属性*/
@property (nonatomic,assign) id currentVC;

/** 转发来自哪个VC 比如聊天界面 文件助手界面 图片预览界面，这些界面要实现转发协议，转发完成后提示已经转发 */
@property (nonatomic,assign) id<ForwardingDelegate> forwardingDelegate;

/** 转发的消息列表 */
@property (nonatomic,retain) NSArray *forwardRecordsArray;

/** 是不是转发自文件助手，如果是则需要直接打开转发的会话界面 */
@property (nonatomic,assign) BOOL isComeFromFileAssistant;

/**
 获取单例

 @return id
 */
+ (CreateGroupUtil *)getUtil;

/**
 创建讨论组，如果用户只选择了单个人，那就是单聊，如果是选择了多个人，那么就是群聊；如果找到了可以复用的讨论组，就打开复用的，不用再重新创建了。

 @param userArray 用户选择的人员
 */
- (void)createGroup:(NSArray *)userArray;


/**
 讨论组添加成员 可以单聊变群聊，这时是发起创建讨论组指令；如果有可以复用的，则不重新创建；已经存在的讨论组，增加成员；

 @param userArray 添加的成员
 */
- (void)addConvEmp:(NSArray *)userArray;


/**
 转发消息给选中的人员

 @param userArray 选中的用户
 */
- (void)forwardRecordsToUsers:(NSArray *)userArray;

@end
