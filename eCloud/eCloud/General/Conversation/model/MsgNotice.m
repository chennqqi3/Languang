//
//  MsgNotice.m
//  eCloud
//
//  Created by Richard on 13-8-3.
//  Copyright (c) 2013年  lyong. All rights reserved.
//

#import "MsgNotice.h"
#import "RobotResponseModel.h"
@implementation MsgNotice

@synthesize netID;

@synthesize robotResponseModel;
@synthesize senderId;
@synthesize rcvId;
@synthesize groupId;
@synthesize msgId;
@synthesize isGroup;
@synthesize msgType;
@synthesize isOffline;
@synthesize msgTotal;
@synthesize msgSeq;
@synthesize offMsgTotal;
@synthesize offMsgSeq;
@synthesize msgLen;
@synthesize msgTime;
@synthesize msgBody;
@synthesize fileName;
@synthesize fileSize;
@synthesize msgGroupTime;
@synthesize receiptMsgFlag;

@synthesize srcMsgIdOfMassMsg;
@synthesize isMassMsg;

@synthesize isMsgFromWX;
@synthesize psCodeFromWX;
@synthesize userCodeFromWX;
@synthesize msgIdFromWX;
@synthesize msgTitle;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.groupId = @"";
        self.msgBody = @"";
        self.fileName = @"";
        self.msgGroupTime = @"";
        self.msgTitle = @"";
        self.needCreateSingleConv = YES;
    }
    return self;
}


-(void)dealloc
{
    self.robotResponseModel = nil;
    
    self.psCodeFromWX = nil;
    self.userCodeFromWX = nil;
    self.msgIdFromWX = nil;
    
	self.msgGroupTime = nil;
	self.fileName = nil;
	self.groupId = nil;
	self.msgBody = nil;
    self.msgTitle = nil;
	[super dealloc];
}

@end
