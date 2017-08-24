//
//  ServiceMessageDetail.m
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ServiceMessageDetail.h"

@implementation ServiceMessageDetail
@synthesize msgId;
@synthesize msgBody;
@synthesize msgLink;
@synthesize msgUrl;
@synthesize serviceMsgId;
@synthesize row;
@synthesize isPicExists;
@synthesize isPicDownloading;
@synthesize serviceId;

-(void)dealloc
{
	self.msgUrl = nil;
	self.msgLink = nil;
	self.msgBody = nil;
	[super dealloc];
}

@end
