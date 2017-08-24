//
//  LaunchChatParm.m
//  OpenCtx
//
//  Created by shisuping on 14-11-18.
//  Copyright (c) 2014年 mimsg. All rights reserved.
//

#import "LaunchChatParm.h"

@implementation LaunchChatParm
@synthesize isSelect;
@synthesize openType;
@synthesize userAccounts;
@synthesize messageStr;
@synthesize viewController;
@synthesize empArray;
@synthesize hasUserAccounts;
@synthesize hasMessage;

@synthesize convRecord;

- (void)dealloc
{
    self.empArray = nil;
    self.viewController = nil;
    self.messageStr = nil;
    self.userAccounts = nil;
    self.convRecord = nil;
    
    [super dealloc];
}

@end
