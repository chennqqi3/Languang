//
//  ConvRecord.m
//  eCloud
//
//  Created by robert on 12-9-28.
//  Copyright (c) 2012年  lyong. All rights reserved.
//

#import "ConvRecord.h"
#import "LocationModel.h"
#import "eCloudDefine.h"
#import "UploadFileModel.h"
#import "StringUtil.h"
#import "talkSessionUtil.h"
#import "LanUtil.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RobotResponseModel.h"
#import "CloudFileModel.h"
#import "ReplyOneMsgModelArc.h"
#import "MiLiaoUtilArc.h"

#ifdef _TAIHE_FLAG_
#import "TAIHEAppMsgModel.h"
#endif

@implementation ConvRecord

@synthesize localSrcMsgId;
@synthesize imageIndexPath;

@synthesize emp_name_eng;

@synthesize msgId = _id;
@synthesize conv_id = _conv_id;
@synthesize emp_id = _emp_id;
@synthesize msg_type = _msg_type;
@synthesize msg_body = _msg_body;
@synthesize msg_time = _msg_time;
@synthesize read_flag = _read_flag;
@synthesize emp_name=_emp_name;
@synthesize msg_flag = _msg_flag;
@synthesize send_flag = _send_flag;
@synthesize file_name = _file_name;
@synthesize file_size = _file_size;

@synthesize emp_logo = _emp_logo;
@synthesize conv_type = _conv_type;
@synthesize emp_sex = _emp_sex;
@synthesize is_set_redstate;
@synthesize emp_code;

@synthesize origin_msg_id = _origin_msg_id;
@synthesize msgSize;
@synthesize isTimeDisplay;

@synthesize isLinkText;
@synthesize isHyperlink;
@synthesize isTextPic;

@synthesize isVideoExist;

@synthesize isAudioExist;
@synthesize isSmallPicExist;
@synthesize isBigPicExist;
@synthesize isLongMsgExist;

@synthesize isFileExists;
@synthesize fileNameAndSize;

@synthesize isDownLoading;

@synthesize imageDisplay;

@synthesize avplay;

@synthesize msgTimeDisplay;

@synthesize tryCount;

@synthesize isLastHistoryRecord = _isLastHistoryRecord;

@synthesize recordType;

@synthesize downloadRequest;

@synthesize uploadRequest;

@synthesize receiptTips;

@synthesize receiptMsgFlag;

@synthesize readNoticeFlag;

@synthesize mass_reply_emp_count;
@synthesize mass_total_emp_count;


@synthesize empStatus;
@synthesize empLoginType;

@synthesize download_flag;
@synthesize isChosen;
@synthesize conv_title;
@synthesize robotModel;

@synthesize locationModel;
#ifdef _XINHUA_FLAG_
@synthesize systemMsgModel;
#endif
#ifdef _TAIHE_FLAG_
@synthesize appMsgModel;
#endif
@synthesize cloudFileModel;
#ifdef _LANGUANG_FLAG_
@synthesize redPacketModel;
@synthesize newsModel;
#endif
@synthesize isEdit;
@synthesize isSelect;

-(void)dealloc
{

    self.replyOneMsgModel = nil;

#ifdef _XINHUA_FLAG_
    self.systemMsgModel = nil;
#endif
    self.cloudFileModel = nil;
#ifdef _LANGUANG_FLAG_
    self.redPacketModel = nil;
    self.newsModel = nil;
#endif
    self.textMsgArray = nil;
    self.locationModel = nil;
#ifdef _TAIHE_FLAG_
    self.appMsgModel = nil;
#endif
    self.localSrcMsgId = nil;
    
    self.imageIndexPath = nil;
    
    self.emp_name_eng = nil;
    
	self.receiptTips = nil;
	self.downloadRequest = nil;
    self.uploadRequest = nil;
	self.fileNameAndSize = nil;
	self.msgTimeDisplay = nil;
	self.imageDisplay = nil;
    self.avplay = nil;
	self.msg_body = nil;
	self.msg_time = nil;
	self.emp_code = nil;
	self.conv_id = nil;
	self.emp_name = nil;
	self.file_name = nil;
	self.file_size = nil;
	self.emp_logo = nil;
    self.conv_title = nil;
    
    if (self.robotModel != nil) {
        self.robotModel = nil;
    }
	[super dealloc];
}

-(id)init
{
	self = [super init];
	if(self)
	{
	}
	return self;
}
-(BOOL)isReceiptMsg
{
	if(receiptMsgFlag == conv_status_receipt)
	{
		return YES;
	}
	return NO;
}

- (BOOL)isHuizhiMsg
{
    if (receiptMsgFlag == conv_status_huizhi) {
        return YES;
    }
    return NO;
}

-(BOOL)isPicMsg
{
	if(self.msg_type == type_pic)
	{
		return YES;
	}
	return NO;
}

-(BOOL)isVideoMsg
{
    if (self.msg_type == type_video) {
        return YES;
    }
    return NO;
}

-(BOOL)isTextMsg
{
	if(self.msg_type == type_text)
	{
		return YES;
	}
	return NO;
}

-(BOOL)isRecordMsg
{
	if(self.msg_type == type_record)
	{
		return YES;
	}
	return NO;
}
-(BOOL)isLongMsg
{
	if(self.msg_type == type_long_msg)
	{
		return YES;
	}
	return NO;
}

-(BOOL)isFileMsg
{
	if(self.msg_type == type_file)
	{
		return YES;
	}
	return NO;
}

-(BOOL)isImgtxtMsg
{
    if (self.msg_type == type_imgtxt) {
        return YES;
    }
    return NO;
}

- (BOOL)isWikiMsg{
    if (self.msg_type == type_wiki) {
        return YES;
    }
    return NO;
}

-(NSString*)toString
{
	NSMutableString *_str = [NSMutableString stringWithString:@""];
	[_str appendString:[NSString stringWithFormat:@"self.msgId is %d",self.msgId]];
	[_str appendString:[NSString stringWithFormat:@"self.conv_id is %@",self.conv_id]];
	[_str appendString:[NSString stringWithFormat:@"self.origin_msg_id is %lld",self.origin_msg_id]];
	[_str appendString:[NSString stringWithFormat:@"self.msg_body is %@",self.msg_body]];
	[_str appendString:[NSString stringWithFormat:@"self.file_name is %@",self.file_name]];
	[_str appendString:[NSString stringWithFormat:@"self.file_size is %@",self.file_size]];
	
	return [NSString stringWithString:_str];
}

- (NSString *)emp_name
{
    if ([LanUtil isChinese])
    {
        if (_emp_name && _emp_name.length > 0) {
            return _emp_name;
        }
    }
    else
    {
        if (emp_name_eng && emp_name_eng.length > 0) {
            return emp_name_eng;
        }
        if (_emp_name && _emp_name.length > 0) {
            return _emp_name;
        }
    }
    return [StringUtil getStringValue:_emp_id];
}

- (BOOL)isRobotImgTxtMsg
{
    if (self.robotModel && ((self.robotModel.msgType == type_imgtxt || self.robotModel.msgType == type_wiki) && self.robotModel.imgtxtArray.count == 1))
    {
        return YES;
    }
    return NO;
}

- (BOOL)isRobotFileMsg{
    if (self.robotModel && (self.robotModel.msgType == type_video || self.robotModel.msgType == type_record)) {
        return YES;
    }
    return NO;
}

- (BOOL)isRobotPicMsg{
    if (self.robotModel && self.robotModel.msgType == type_pic) {
        return YES;
    }
    return NO;
}

- (BOOL)isMiLiaoMsg{
    if (self.conv_type == singleType && [[MiLiaoUtilArc getUtil]isMiLiaoConv:self.conv_id]) {
        return YES;
    }
    return NO;
}

@end
