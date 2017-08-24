//
//  VirtualGroupMemberModel.m
//  eCloud
//
//  Created by yanlei on 15/12/4.
//  Copyright © 2015年  lyong. All rights reserved.
//

#import "VirtualGroupMemberModel.h"

@implementation VirtualGroupMemberModel
-(void)dealloc
{
    self.groupid = nil;
    self.update_time = nil;
    [super dealloc];
}
@end
