//
//  UserInfo.m
//  eCloud
//
//  Created by robert on 12-10-12.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize userEmail = _userEmail;
@synthesize userPasswd = _userPasswd;
@synthesize tel = _tel;
@synthesize mobile = _mobile;
@synthesize compId = _compId;
@synthesize sex = _sex;
@synthesize title = _title;
@synthesize status = _status;
@synthesize logo = _logo;
@synthesize voiceFlag;
@synthesize vibrateFlag;
@synthesize sendreadFlag;
@synthesize noticeFlag;
@synthesize receiver_model_Flag;
-(void)dealloc
{
	self.title = nil;
	self.userName = nil;
	self.userEmail = nil;
	self.userPasswd = nil;
	self.tel = nil;
	self.mobile = nil;
	self.logo = nil;
	self.receiver_model_Flag=nil;
	[super dealloc];
}
 
@end
