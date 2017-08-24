//
//  deleteAllChatRecord.m
//  eCloud
//
//  Created by SH on 14-7-15.
//  Copyright (c) 2014年  lyong. All rights reserved.
//

#import "deleteAllChatRecord.h"
#import "eCloudDAO.h"
#import "StringUtil.h"

@implementation deleteAllChatRecord

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int tag = alertView.tag;
	
	if(tag == 1 && buttonIndex == 1)
	{
        db = [eCloudDAO getDatabase];
        //		清除所有聊天记录
		[db deleteAllConversation];
        
		return;
	}
}

-(void)deleteAction
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[StringUtil getLocalizableString:@"clear_all_message_history"] delegate:self cancelButtonTitle:[StringUtil getLocalizableString:@"cancel"] otherButtonTitles:[StringUtil getLocalizableString:@"confirm"], nil];
	alert.tag = 1;
	[alert dismissWithClickedButtonIndex:1 animated:YES];
	[alert show];
	[alert release];
}

@end
