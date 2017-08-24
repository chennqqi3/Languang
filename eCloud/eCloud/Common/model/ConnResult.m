//
//  ConnResult.m
//  eCloud
//
//  Created by robert on 12-10-12.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "ConnResult.h"
#import "StringUtil.h"
#import "UIAdapterUtil.h"

@implementation ConnResult
@synthesize resultCode = _resultCode;
@synthesize serverRetMsg;

-(void) dealloc
{
    self.serverRetMsg = nil;
	[super dealloc];
}
-(NSString *)getResultMsg
{
	if(self.resultCode == RESULT_INVALIDUSER)
	{
#ifdef _XIANGYUAN_FLAG_
        return @"该账号已删除";
#else
        return [StringUtil getLocalizableString:@"connResult_invalidUser"];
#endif
		
	}
	if(self.resultCode == RESULT_NOLOGIN)
	{
		return [StringUtil getLocalizableString:@"connResult_noLogin"];
	}
	if(self.resultCode == RESULT_INVALIDPASSWD || self.resultCode == RESULT_SSO_USER_OR_PASSWD_ERR)
	{
		return [StringUtil getLocalizableString:@"connResult_invalidPasswd"];
	}
	if(self.resultCode == RESULT_REQTIMEOUT)
	{
		return [StringUtil getLocalizableString:@"connResult_reqtimeout"];
	}
    if (self.resultCode == RESULT_FORBIDDENUSER || self.resultCode == RESULT_SSO_USER_FORBID_ERR) {
//        if ([UIAdapterUtil isTAIHEApp]) {
//            
//            return [StringUtil getLocalizableString:@"connResult_LoginOtherDevices"];
//        }else{
#ifdef _XIANGYUAN_FLAG_
        
        return @"该账号已禁用";
#else
        return [StringUtil getLocalizableString:@"connResult_forbiddenUser"];
#endif
        
//        }
        
    }
    if (self.serverRetMsg.length > 0) {
        return self.serverRetMsg;
    }
	return [StringUtil getLocalizableString:@"connResult_unkonwmError"];
}
@end
