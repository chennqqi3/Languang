//
//  ServiceModel.m
//  eCloud
//
//  Created by Richard on 13-10-25.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "ServiceModel.h"

@implementation ServiceModel

@synthesize serviceId;
@synthesize serviceCode;
@synthesize serviceDesc;
@synthesize serviceIcon;
@synthesize serviceName;
@synthesize servicePinyin;
@synthesize serviceUrl;
@synthesize followFlag;
@synthesize rcvMsgFlag;
@synthesize lastInputMsg;
@synthesize serviceType;
@synthesize serviceStatus;

-(void)dealloc
{
	self.lastInputMsg = nil;
	self.serviceUrl = nil;
	self.servicePinyin = nil;
	self.serviceName = nil;
	self.serviceIcon = nil;
	self.serviceDesc = nil;
	self.serviceCode = nil;
	[super dealloc];
}
@end
