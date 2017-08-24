//
//  massConversationObject.m
//  eCloud
//
//  Created by  lyong on 14-1-13.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "massConversationObject.h"
#import "ConvRecord.h"
#import "Emp.h"

@implementation massConversationObject
@synthesize create_emp_id;
@synthesize last_msg_id;
@synthesize last_emp_id;
@synthesize last_msg_type;
@synthesize emp_count;
@synthesize conv_id;
@synthesize conv_title;
@synthesize create_time;
@synthesize lastmsg_body;
@synthesize last_msg_body;
@synthesize last_msg_time;
@synthesize unread;
-(void)dealloc
{
	self.last_msg_time = nil;
	self.last_msg_body = nil;
	self.conv_title = nil;
	self.lastmsg_body = nil;
	self.create_time = nil;
	self.create_time = nil;
	self.conv_title = nil;
    self.conv_id = nil;
	[super dealloc];
}
@end
