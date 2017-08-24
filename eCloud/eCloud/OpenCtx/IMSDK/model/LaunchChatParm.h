//  deprecated

//  LaunchChatParm.h
//  OpenCtx
//  在公司应用中 传入各种参数 发起会话
//  Created by shisuping on 14-11-18.
//  Copyright (c) 2014年 mimsg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ConvRecord;

@interface LaunchChatParm : NSObject

@property (nonatomic,retain) UIViewController *viewController;
@property (nonatomic,retain) NSArray *userAccounts;
@property (nonatomic,retain) NSString *messageStr;
@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,assign) int openType;

//userAccounts对应的Emp
@property (nonatomic,retain) NSArray *empArray;

//如果要发送消息 需要首先保存消息记录
@property (nonatomic,retain) ConvRecord *convRecord;

@property (nonatomic,assign) BOOL hasUserAccounts;
@property (nonatomic,assign) BOOL hasMessage;
@end
