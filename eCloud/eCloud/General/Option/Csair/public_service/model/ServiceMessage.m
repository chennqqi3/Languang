//
//  ServiceMessage.m
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ServiceMessage.h"

@implementation ServiceMessage
@synthesize msgBody;
@synthesize msgLink;
@synthesize msgUrl;
@synthesize msgFlag;
@synthesize msgId;
@synthesize msgTime;
@synthesize msgType;
@synthesize detail;
@synthesize readFlag;
@synthesize serviceId;
@synthesize msgTimeDisplay;
@synthesize isTimeDisplay;
@synthesize sendFlag;
@synthesize redDotFlag;
@synthesize fileSize;

@synthesize singlePsMsgDate;

-(void)dealloc
{
	self.singlePsMsgDate = nil;
	self.msgTimeDisplay = nil;
	self.msgBody = nil;
	self.msgLink = nil;
	self.msgUrl = nil;
	self.detail = nil;
	
	[super dealloc];
}

@end
