//
//  VirtualGroupInfoModel.m
//  eCloud
//
//  Created by yanlei on 15/12/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "VirtualGroupInfoModel.h"

@implementation VirtualGroupInfoModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.virtualMemberArray = [[[NSMutableArray alloc]init]autorelease];
    }
    return self;
}
-(void)dealloc
{
    self.groupid = nil;
    self.waiting_prompt = nil;
    self.hangup_prompt = nil;
    self.oncall_prompt = nil;
    self.update_time = nil;
    [super dealloc];
}
@end
