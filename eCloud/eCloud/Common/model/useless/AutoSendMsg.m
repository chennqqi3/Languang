//
//  AutoSendMsg.m
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "AutoSendMsg.h"

@implementation AutoSendMsg
@synthesize id=_id;
@synthesize msg = _msg;
-(void)dealloc
{
	self.msg = nil;
	[super dealloc];
}

@end
